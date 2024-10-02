#!/usr/bin/env sh

set -x

: ${EGL_PLATFORM:="$(cat /run/s6/container_environment/EGL_PLATFORM)"}
: ${GALLIUM_DRIVER:="$(cat /run/s6/container_environment/GALLIUM_DRIVER)"}
: ${GLAMOR_DEBUG:="true"}
: ${LIBGL_DEBUG:="verbose"}
: ${LIBVA_DRIVER_NAME:="$(cat /run/s6/container_environment/LIBVA_DRIVER_NAME)"}
: ${MESA_LOADER_DRIVER_OVERRIDE:="$(cat /run/s6/container_environment/MESA_LOADER_DRIVER_OVERRIDE)"}
: ${NOUVEAU_USE_ZINK:="$(cat /run/s6/container_environment/NOUVEAU_USE_ZINK)"}
: ${VK_ICD_FILENAMES:="$(cat /run/s6/container_environment/VK_ICD_FILENAMES)"}
: ${VK_LAYER_PATH:="$(cat /run/s6/container_environment/VK_LAYER_PATH)"}
: ${XDG_RUNTIME_DIR:="$(/usr/bin/mkrundir)"}
: ${XDG_SESSION_TYPE:="$(cat /run/s6/container_environment/XDG_SESSION_TYPE)"}
: ${__GLX_VENDOR_LIBRARY_NAME:="$(cat /run/s6/container_environment/__GLX_VENDOR_LIBRARY_NAME)"}

/usr/bin/xcalib -d "$DISPLAY" /usr/share/color/icc/colord/sRGB.icc

/usr/bin/vglrun +glx eglinfo egl -B

/usr/bin/glxinfo -B

vulkaninfo --summary

/usr/libexec/pulseaudio-module-xrdp/load_pa_modules.sh

/usr/bin/kodi

cat /home/kodi/.kodi/temp/kodi.log
cat /home/kodi/.xorgxrdp.1.log
