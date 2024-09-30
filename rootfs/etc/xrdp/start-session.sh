#!/usr/bin/env sh

set -x

export LIBGL_DEBUG="verbose"
export GLAMOR_DEBUG="true"

/usr/bin/xcalib -d "$DISPLAY" /usr/share/color/icc/colord/sRGB.icc

/usr/bin/pulseaudio --disallow-exit --disable-shm --exit-idle-time=-1 &

sleep 1

/usr/libexec/pulseaudio-module-xrdp/load_pa_modules.sh

ls -hal /dev/dri

/usr/bin/kodi --standalone

cat /home/kodi/.kodi/temp/kodi.log
