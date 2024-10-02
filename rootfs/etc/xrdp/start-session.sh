#!/usr/bin/env sh

whoami

/command/s6-envdir /run/s6/container_environment /usr/bin/env | while IFS= read -r ENV_VAR; do export $ENV_VAR; done

export XDG_RUNTIME_DIR="$(/usr/local/bin/mkrundir)"

/usr/libexec/pulseaudio-module-xrdp/load_pa_modules.sh

#/usr/bin/glxinfo -B
#
#/usr/bin/eglinfo -B
#
#/usr/bin/vulkaninfo --summary

/usr/bin/kodi --windowing=x11

cat /home/kodi/.kodi/temp/kodi.log
cat /home/kodi/.xorgxrdp.1.log
