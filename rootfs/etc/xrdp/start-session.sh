#!/usr/bin/env sh

set -x

export LIBGL_DEBUG="verbose"
export GLAMOR_DEBUG="true"

/usr/bin/xcalib -d "$DISPLAY" /usr/share/color/icc/colord/sRGB.icc

/usr/bin/eglinfo -B

/usr/bin/glxinfo -B

/usr/libexec/pulseaudio-module-xrdp/load_pa_modules.sh

/usr/bin/kodi

cat /home/kodi/.kodi/temp/kodi.log
cat /home/kodi/.xorgxrdp.1.log
