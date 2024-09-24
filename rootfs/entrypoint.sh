#!/usr/bin/env sh

adduser root audio

exec env -i \
    DISPLAY=":1.0" \
    HOME="/root" \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME="$(( 60 * 1000 ))" \
    WAYLAND_DISPLAY="wayland-1" \
    XDG_RUNTIME_DIR="$(/usr/bin/mkrundir)" \
    XDG_SESSION_TYPE="wayland" \
    _XWAYLAND_GLOBAL_OUTPUT_SCALE="2" \
    /init
