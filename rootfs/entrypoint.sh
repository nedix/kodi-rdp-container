#!/usr/bin/env sh

adduser -D -h /var/run/pulse -s /sbin/nologin pulse
addgroup pulse-access
addgroup pulse audio
addgroup pulse pulse
addgroup pulse pulse-access
addgroup root pulse-access

echo "root:secret" | chpasswd

exec env -i \
    HOME="/root" \
    LIBGL_ALWAYS_INDIRECT="1" \
    LIBGL_DEBUG="verbose" \
    LIBSEAT_BACKEND="builtin" \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME="$(( 60 * 1000 ))" \
    SEATD_VTBOUND="0" \
    XDG_RUNTIME_DIR="$(/usr/bin/mkrundir)" \
    XDG_SESSION_TYPE="x11" \
    /init
