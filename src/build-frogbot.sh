#!/bin/bash -xe

fteqcc.bin -O3 "$@"

# Instant package & deploy: set TARGET_PATH to where you want to deploy frogbot.pk3.
# The PK3 (which is just a zip archive) should only contain:
# - qwprogs.dat
# - frogbot.cfg
# - configs
# - doc
# - sound
# (Not sure what's in gfx. Not included in nQuake frogbot distribution, hence omit.)

#TARGET_PATH="../frogbot.pk3"
#cd ../
#rm -f "${TARGET_PATH}"
#zip -r "${TARGET_PATH}" * -x README.md -x gfx/\* src/\* waypoint/\*
