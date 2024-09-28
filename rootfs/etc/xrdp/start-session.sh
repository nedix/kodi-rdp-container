#!/usr/bin/env sh

set -x

export LIBGL_DEBUG=verbose

/usr/bin/xcalib -d "$DISPLAY" /usr/share/color/icc/colord/sRGB.icc

/usr/libexec/pulseaudio-module-xrdp/load_pa_modules.sh

exec /usr/bin/kodi --standalone
