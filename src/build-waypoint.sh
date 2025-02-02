#!/bin/bash -xe

fteqcc.bin -DWAYPOINT_BUILD=1 -O3 -srcfile progs-waypoint.src "$@"
