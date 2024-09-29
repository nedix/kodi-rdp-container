#!/usr/bin/env sh

: ${LIBVA_DRIVER}
: ${MESA_DRIVER}

adduser -D -h /var/run/pulse -s /sbin/nologin pulse
addgroup pulse-access
addgroup pulse audio
addgroup pulse pulse
addgroup pulse pulse-access
addgroup root pulse-access

echo "root:secret" | chpasswd

exec env -i \
    HOME="/root" \
    LD_LIBRARY_PATH="/lib/x86_64-linux-gnu:${LD_LIBRARY_PATH}" \
    LIBGL_ALWAYS_INDIRECT="1" \
    LIBGL_DEBUG="verbose" \
    LIBSEAT_BACKEND="builtin" \
    LIBVA_DRIVER_NAME="$LIBVA_DRIVER" \
    MESA_LOADER_DRIVER_OVERRIDE="$MESA_DRIVER" \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME="$(( 60 * 1000 ))" \
    SEATD_VTBOUND="0" \
    XDG_RUNTIME_DIR="$(/usr/bin/mkrundir)" \
    XDG_SESSION_TYPE="x11" \
    /init
