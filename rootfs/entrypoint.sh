#!/usr/bin/env sh

: ${WESTON_BACKEND}

adduser root audio

exec env -i \
    DISPLAY=":1.0" \
    GALLIUM_DRIVER="llvmpipe" \
    HOME="/root" \
    LIBGL_ALWAYS_INDIRECT="1" \
    LIBSEAT_BACKEND="builtin" \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME="$(( 60 * 1000 ))" \
    SEATD_VTBOUND="0" \
    WAYLAND_DISPLAY="wayland-1" \
    WESTON_BACKEND="$WESTON_BACKEND" \
    XDG_RUNTIME_DIR="$(/usr/bin/mkrundir)" \
    XDG_SESSION_TYPE="wayland" \
    /init
