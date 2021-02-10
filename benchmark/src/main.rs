use chrono::Local;
use futures::stream::StreamExt;
use memmap::MmapMut;
use std::{
    fs::{self, OpenOptions},
    io::{Read, Seek, SeekFrom},
    os::unix::fs::OpenOptionsExt,
    time::Instant,
};
use usb_disk_probe::stream::UsbDiskProbe;

fn format_speed(speed: u128) -> String {
    if speed > 4 * 1024 * 1024 * 1024 {
        format!("{} GiB/s", speed / 1024 / 1024 / 1024)
    } else if speed > 4 * 1024 * 1024 {
        format!("{} MiB/s", speed / 1024 / 1024)
    } else if speed > 4 * 1024 {
        format!("{} KiB/s", speed / 1024)
    } else {
        format!("{} B/s", speed)
    }
}

fn main() {
    let mut paths: Vec<std::path::PathBuf> = Vec::new();
    futures::executor::block_on(async {
        let mut stream = UsbDiskProbe::new().await.expect("failed to find USB disks");
        while let Some(path_res) = stream.next().await {
            let path = path_res.expect("failed to read USB disk path");
            paths.push(path.to_path_buf().into());
        }
    });
    for path in paths.iter_mut() {
        let canonical = fs::canonicalize(&path).expect(&format!(
            "failed to get canonical path for USB disk: {}",
            path.display()
        ));
        eprintln!("{}: {}", path.display(), canonical.display());
        *path = canonical;
    }
    paths.sort();

    let mut disks = Vec::new();
    for path in paths {
        let file = OpenOptions::new()
            .read(true)
            .custom_flags(libc::O_DIRECT)
            .open(&path)
            .expect(&format!(
                "failed to open USB disk: {}",
                path.display()
            ));

        let buf = MmapMut::map_anon(4096 * 4096)
            .expect("failed to map read buffer");

        disks.push((
            path,
            file,
            buf,
            0u128,
        ));
    }

    loop {
        let date = Local::now();
        for (path, file, buf, speed) in disks.iter_mut() {
            file.seek(SeekFrom::Start(0)).expect(&format!(
                "failed to seek USB disk: {}",
                path.display()
            ));

            let elapsed = {
                let instant = Instant::now();
                file.read(buf).expect(&format!(
                    "failed to read USB disk: {}",
                    path.display()
                ));
                instant.elapsed()
            };

            let nanos = elapsed.as_nanos();
            *speed = (buf.len() as u128 * 1_000_000_000u128) / nanos;
        }

        eprintln!();
        eprintln!("\x1B[1m{}\x1B[0m", date.format("%Y-%m-%d %H:%M:%S"));
        for (path, _file, _buf, speed) in disks.iter() {
            eprintln!("{}: {}", path.display(), format_speed(*speed));
        }
    }
}
