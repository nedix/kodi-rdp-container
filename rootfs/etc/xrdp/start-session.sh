#!/usr/bin/env sh

set -x

export EGL_PLATFORM="$(cat /run/s6/container_environment/EGL_PLATFORM)"
export GALLIUM_DRIVER="$(cat /run/s6/container_environment/GALLIUM_DRIVER)"
export GLAMOR_DEBUG="true"
export LIBGL_DEBUG="verbose"
export LIBVA_DRIVER_NAME="$(cat /run/s6/container_environment/LIBVA_DRIVER_NAME)"
export MESA_LOADER_DRIVER_OVERRIDE="$(cat /run/s6/container_environment/MESA_LOADER_DRIVER_OVERRIDE)"
export NOUVEAU_USE_ZINK="$(cat /run/s6/container_environment/NOUVEAU_USE_ZINK)"
export XDG_RUNTIME_DIR="$(/usr/bin/mkrundir)"
export XDG_SESSION_TYPE="$(cat /run/s6/container_environment/XDG_SESSION_TYPE)"
export __GLX_VENDOR_LIBRARY_NAME="$(cat /run/s6/container_environment/__GLX_VENDOR_LIBRARY_NAME)"

/usr/bin/xcalib -d "$DISPLAY" /usr/share/color/icc/colord/sRGB.icc

/usr/bin/eglinfo -B

/usr/bin/glxinfo -B

/usr/libexec/pulseaudio-module-xrdp/load_pa_modules.sh

/usr/bin/vglrun -glx /usr/bin/kodi

cat /home/kodi/.kodi/temp/kodi.log
cat /home/kodi/.xorgxrdp.1.log
