#!/bin/bash -xe

fteqcc.bin -DWAYPOINT_BUILD=1 -O3 -srcfile progs-waypoint.src "$@"

# Instant deploy: set TARGET_DIR to the desired game dir within your netquake install dir

#TARGET_DIR=your_quake_dir/waypoint
#cp -p ../waypoint/{progs.dat,autoexec.cfg} "${TARGET_DIR}/"
