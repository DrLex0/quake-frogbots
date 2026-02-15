#!/bin/bash -xe
# Convenience script for building a QuakeWorld Frogbots runtime and optionally deploying it

fteqcc.bin -O3 "$@"

# Instant package & deploy: set TARGET_PATH to where you want to deploy frogbot.pk3.
# The PK3 (which is just a zip archive) should only contain:
# - qwprogs.dat
# - frogbot.cfg
# - configs-qw
# - doc
# - sound
# (Not sure what's in gfx. Not included in nQuake frogbot distribution, hence omit.)

# === Uncomment and update path to enable auto-deploy ===
#TARGET_PATH="your/ezquake-dir/qw/frogbot.pk3"
#cd ../
#rm -f "${TARGET_PATH}"
#zip -r "${TARGET_PATH}" * -x README.md -x frogbot-quake.cfg configs-quake/\* gfx/\* src/\* waypoint/\*
