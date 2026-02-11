#!/usr/bin/env sh

: ${EGL_PLATFORM:="x11"}
: ${GALLIUM_DRIVER}
: ${GLAMOR_DEBUG:="all"}
: ${LIBGL_DEBUG:="verbose"}
: ${LIBGL_KOPPER_DRI2}
: ${LIBSEAT_BACKEND:="builtin"}
: ${LIBVA_DRIVER_NAME}
: ${MESA_LOADER_DRIVER_OVERRIDE}
: ${NOUVEAU_USE_ZINK}
: ${PASSWORD_HASH}
: ${VDPAU_DRIVER}
: ${VDPAU_QUIRKS:="AvoidVA,XCloseDisplay"}
: ${VGL_GLLIB}
: ${XDG_SESSION_TYPE:="x11"}
: ${USERNAME}
: ${__GLX_VENDOR_LIBRARY_NAME}
: ${__GL_SYNC_TO_VBLANK}

useradd -M -d "/home/${USERNAME}" -s /bin/sh "$USERNAME"
chown -R "$USERNAME" "/home/${USERNAME}"
printf "%s:%s" "$USERNAME" "$PASSWORD_HASH" | chpasswd -e

useradd -m -d /var/run/pulse -s /sbin/nologin pulse
chown -R pulse /var/run/pulse
usermod -aG audio pulse
usermod -aG pulse pulse

groupadd pulse-access
usermod -aG pulse-access "$USERNAME"
usermod -aG pulse-access pulse

exec env -i \
    EGL_PLATFORM="$EGL_PLATFORM" \
    GALLIUM_DRIVER="$GALLIUM_DRIVER" \
    GLAMOR_DEBUG="$GLAMOR_DEBUG" \
    LD_LIBRARY_PATH="/lib/x86_64-linux-gnu:/usr/lib64:/usr/lib" \
    LIBGL_DEBUG="$LIBGL_DEBUG" \
    LIBGL_KOPPER_DRI2="$LIBGL_KOPPER_DRI2" \
    LIBSEAT_BACKEND="$LIBSEAT_BACKEND" \
    LIBVA_DRIVER_NAME="$LIBVA_DRIVER_NAME" \
    MESA_LOADER_DRIVER_OVERRIDE="$MESA_LOADER_DRIVER_OVERRIDE" \
    NOUVEAU_USE_ZINK="$NOUVEAU_USE_ZINK" \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME="$(( 60 * 1000 ))" \
    S6_STAGE2_HOOK="/usr/bin/s6-stage2-hook" \
    SEATD_VTBOUND="0" \
    USERNAME="$USERNAME" \
    VDPAU_DRIVER="$VDPAU_DRIVER" \
    VDPAU_QUIRKS="$VDPAU_QUIRKS" \
    VGL_GLLIB="$VGL_GLLIB" \
    VK_ICD_FILENAMES="$VK_ICD_FILENAMES" \
    VK_LAYER_PATH="$VK_LAYER_PATH" \
    XDG_SESSION_TYPE="$XDG_SESSION_TYPE" \
    __GLX_VENDOR_LIBRARY_NAME="$__GLX_VENDOR_LIBRARY_NAME" \
    __GL_SYNC_TO_VBLANK="$__GL_SYNC_TO_VBLANK" \
    /init
