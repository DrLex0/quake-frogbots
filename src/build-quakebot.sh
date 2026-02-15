#!/bin/bash -xe
# Convenience script for building a NetQuake Frogbots runtime and optionally deploying it

fteqcc.bin -DQUAKE=1 -O3 -srcfile progs-quake.src "$@"

# Instant deploy: set TARGET_DIR to the desired game dir within your netquake install dir

# === Uncomment and update path to enable auto-deploy ===
#TARGET_DIR=your_quake_dir/frogbot
#cp -pvr ../{progs.dat,frogbot-quake.cfg,configs-quake,doc,sound} "${TARGET_DIR}/"
