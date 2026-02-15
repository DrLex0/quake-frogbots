#!/bin/bash -xe
# Convenience script for building a NetQuake Frogbots runtime and optionally deploying it

mkdir -p ../Release/quake
fteqcc.bin -DQUAKE=1 -O3 -srcfile progs-quake.src "$@"

# Instant deploy: set TARGET_DIR to the desired game dir within your netquake install dir
# (create it first in the same directory as the id1 dir).

# === Uncomment and update path to enable auto-deploy ===
#TARGET_DIR="your_quake_dir/frogbot"
#cp ../Release/quake/progs.dat "${TARGET_DIR}/"
#cp -vr ../{frogbot-quake.cfg,configs-quake,doc,sound} "${TARGET_DIR}/"
