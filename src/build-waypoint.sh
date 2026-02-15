#!/bin/bash -xe
# Convenience script for building the waypoint tool and optionally deploying it

mkdir -p ../Release/waypoint
fteqcc.bin -DWAYPOINT_BUILD=1 -O3 -srcfile progs-waypoint.src "$@"

# Instant deploy: set TARGET_DIR to the desired game dir within your netquake install dir
# (create it first in the same directory as the id1 dir).

# === Uncomment and update path to enable auto-deploy ===
#TARGET_DIR=your_quake_dir/waypoint
#cp ../Release/waypoint/progs.dat "${TARGET_DIR}/"
#cp ../waypoint/autoexec.cfg "${TARGET_DIR}/"
