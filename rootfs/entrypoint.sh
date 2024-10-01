#!/usr/bin/env sh

: ${EGL_PLATFORM}
: ${GALLIUM_DRIVER:="nouveau"}
: ${LIBVA_DRIVER_NAME:="nouveau"}
: ${MESA_LOADER_DRIVER_OVERRIDE:="nouveau"}
: ${NOUVEAU_USE_ZINK:="0"}
: ${PASSWORD_HASH}
: ${__GLX_VENDOR_LIBRARY_NAME:="mesa"}

addgroup pulse-access

adduser -D -h /home/kodi -s /bin/sh kodi
adduser -D -h /var/run/pulse -s /sbin/nologin pulse

addgroup kodi pulse-access
addgroup pulse audio
addgroup pulse pulse
addgroup pulse pulse-access

echo "kodi:${PASSWORD_HASH}" | chpasswd -e
echo "kodi ALL=(ALL:ALL) ALL" >> /etc/sudoers

exec env -i \
    EGL_PLATFORM="$EGL_PLATFORM" \
    GALLIUM_DRIVER="$GALLIUM_DRIVER" \
    GLAMOR_DEBUG="true" \
    LD_LIBRARY_PATH="/lib/x86_64-linux-gnu:/lib/nvidia:/lib/x86_64-linux-gnu/nvidia/xorg" \
    LIBGL_DEBUG="verbose" \
    LIBSEAT_BACKEND="builtin" \
    LIBVA_DRIVER_NAME="$LIBVA_DRIVER_NAME" \
    MESA_LOADER_DRIVER_OVERRIDE="$MESA_LOADER_DRIVER_OVERRIDE" \
    NOUVEAU_USE_ZINK="$NOUVEAU_USE_ZINK" \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME="$(( 60 * 1000 ))" \
    SEATD_VTBOUND="0" \
    XDG_RUNTIME_DIR="$(/usr/bin/mkrundir)" \
    XDG_SESSION_TYPE="x11" \
    __GLX_VENDOR_LIBRARY_NAME="$__GLX_VENDOR_LIBRARY_NAME" \
    /init
