#!/usr/bin/env sh

set -x

export LIBGL_DEBUG=verbose
export LD_LIBRARY_PATH="/lib/x86_64-linux-gnu:${LD_LIBRARY_PATH}"

/usr/bin/xcalib -d "$DISPLAY" /usr/share/color/icc/colord/sRGB.icc

/usr/bin/pulseaudio --disallow-exit --disable-shm --exit-idle-time=-1 &

sleep 1

/usr/libexec/pulseaudio-module-xrdp/load_pa_modules.sh

exec /usr/bin/kodi --standalone
