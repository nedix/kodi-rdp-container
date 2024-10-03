#!/usr/bin/env sh

: ${EGL_PLATFORM}
: ${GALLIUM_DRIVER}
: ${LIBVA_DRIVER_NAME}
: ${MESA_LOADER_DRIVER_OVERRIDE}
: ${NOUVEAU_USE_ZINK}
: ${PASSWORD_HASH}
: ${VGL_GLLIB:="/usr/lib64/libGL.so.1"}
: ${__GLX_VENDOR_LIBRARY_NAME}

groupadd pulse-access

useradd -m -d /home/kodi -s /bin/sh kodi
useradd -m -d /var/run/pulse -s /sbin/nologin pulse

chown -R kodi /home/kodi
chown -R pulse /var/run/pulse

usermod -aG pulse-access kodi
usermod -aG audio pulse
usermod -aG pulse pulse
usermod -aG pulse-access pulse

echo "kodi:${PASSWORD_HASH}" | chpasswd -e
echo "kodi ALL=(ALL:ALL) ALL" >> /etc/sudoers

exec env -i \
    EGL_PLATFORM="$EGL_PLATFORM" \
    GALLIUM_DRIVER="$GALLIUM_DRIVER" \
    GLAMOR_DEBUG="true" \
    LIBGL_DEBUG="verbose" \
    LIBSEAT_BACKEND="builtin" \
    LIBVA_DRIVER_NAME="$LIBVA_DRIVER_NAME" \
    MESA_LOADER_DRIVER_OVERRIDE="$MESA_LOADER_DRIVER_OVERRIDE" \
    NOUVEAU_USE_ZINK="$NOUVEAU_USE_ZINK" \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME="$(( 60 * 1000 ))" \
    SEATD_VTBOUND="0" \
    VGL_GLLIB="$VGL_GLLIB" \
    VK_ICD_FILENAMES="$VK_ICD_FILENAMES" \
    VK_LAYER_PATH="$VK_LAYER_PATH" \
    XDG_RUNTIME_DIR="$(/usr/local/bin/mkrundir)" \
    XDG_SESSION_TYPE="x11" \
    __GLX_VENDOR_LIBRARY_NAME="$__GLX_VENDOR_LIBRARY_NAME" \
    /init
