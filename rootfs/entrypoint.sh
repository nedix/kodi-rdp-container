#!/usr/bin/env sh

: ${GALLIUM_DRIVER:="zink"}
: ${LIBVA_DRIVER_NAME}
: ${MESA_LOADER_DRIVER_OVERRIDE:="zink"}
: ${PASSWORD_HASH}
: ${__GLX_VENDOR_LIBRARY_NAME:="mesa"}

addgroup pulse-access

adduser -D -h /home/kodi -s /sbin/nologin kodi
adduser -D -h /var/run/pulse -s /sbin/nologin pulse

addgroup kodi pulse-access
addgroup pulse audio
addgroup pulse pulse
addgroup pulse pulse-access

echo "kodi:${PASSWORD_HASH}" | chpasswd -e

exec env -i \
    GALLIUM_DRIVER="$GALLIUM_DRIVER" \
    LD_LIBRARY_PATH="/lib/x86_64-linux-gnu:${LD_LIBRARY_PATH}" \
    LIBGL_DEBUG="verbose" \
    LIBSEAT_BACKEND="builtin" \
    LIBVA_DRIVER_NAME="$LIBVA_DRIVER_NAME" \
    MESA_LOADER_DRIVER_OVERRIDE="$MESA_LOADER_DRIVER_OVERRIDE" \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME="$(( 60 * 1000 ))" \
    SEATD_VTBOUND="0" \
    XDG_RUNTIME_DIR="$(/usr/bin/mkrundir)" \
    XDG_SESSION_TYPE="x11" \
    __GLX_VENDOR_LIBRARY_NAME="$__GLX_VENDOR_LIBRARY_NAME" \
    /init
