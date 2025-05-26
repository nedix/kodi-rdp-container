#!/usr/bin/env sh

: ${EGL_PLATFORM:="x11"}
: ${GALLIUM_DRIVER}
: ${LIBGL_KOPPER_DRI2}
: ${LIBVA_DRIVER_NAME}
: ${MESA_LOADER_DRIVER_OVERRIDE}
: ${NOUVEAU_USE_ZINK}
: ${PASSWORD_HASH}
: ${VDPAU_DRIVER}
: ${VDPAU_QUIRKS:="AvoidVA,XCloseDisplay"}
: ${VGL_GLLIB}
: ${__GLX_VENDOR_LIBRARY_NAME}
: ${__GL_SYNC_TO_VBLANK}

useradd -m -d /home/kodi -s /bin/sh kodi
chown -R kodi /home/kodi

groupadd pulse-access
useradd -m -d /var/run/pulse -s /sbin/nologin pulse
usermod -aG audio pulse
usermod -aG pulse pulse
usermod -aG pulse-access kodi
usermod -aG pulse-access pulse
chown -R pulse /var/run/pulse

echo "kodi:${PASSWORD_HASH}" | chpasswd -e
echo "kodi ALL=(ALL:ALL) ALL" >> /etc/sudoers

XDG_RUNTIME_DIR="/run/user-$(id -u)"
mkdir -pm 0700 "$XDG_RUNTIME_DIR"

exec env -i \
    EGL_PLATFORM="$EGL_PLATFORM" \
    GALLIUM_DRIVER="$GALLIUM_DRIVER" \
    GLAMOR_DEBUG="all" \
    LD_LIBRARY_PATH="/lib/x86_64-linux-gnu:/usr/lib64:/usr/lib" \
    LIBGL_DEBUG="verbose" \
    LIBGL_KOPPER_DRI2="$LIBGL_KOPPER_DRI2" \
    LIBSEAT_BACKEND="builtin" \
    LIBVA_DRIVER_NAME="$LIBVA_DRIVER_NAME" \
    MESA_LOADER_DRIVER_OVERRIDE="$MESA_LOADER_DRIVER_OVERRIDE" \
    NOUVEAU_USE_ZINK="$NOUVEAU_USE_ZINK" \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME="$(( 60 * 1000 ))" \
    S6_STAGE2_HOOK="/usr/sbin/s6-stage2-hook" \
    SEATD_VTBOUND="0" \
    VDPAU_DRIVER="$VDPAU_DRIVER" \
    VDPAU_QUIRKS="$VDPAU_QUIRKS" \
    VGL_GLLIB="$VGL_GLLIB" \
    VK_ICD_FILENAMES="$VK_ICD_FILENAMES" \
    VK_LAYER_PATH="$VK_LAYER_PATH" \
    XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
    XDG_SESSION_TYPE="x11" \
    __GLX_VENDOR_LIBRARY_NAME="$__GLX_VENDOR_LIBRARY_NAME" \
    __GL_SYNC_TO_VBLANK="$__GL_SYNC_TO_VBLANK" \
    /init
