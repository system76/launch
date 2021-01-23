#!/usr/bin/env bash

set -ex

./scripts/lvfs.sh "Built from scripts/fwupd.sh"
sudo fwupdtool install build/lvfs/launch_launch_1.0.cab
