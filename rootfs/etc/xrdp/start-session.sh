#!/usr/bin/env sh

set -x

while IFS= read -r ENV_VAR; do
    ENV_KEY="${ENV_VAR%%=*}"
    test -z "${!ENV_KEY}" && export "$ENV_VAR"
done < <(/command/s6-envdir /run/s6/container_environment /usr/bin/env)

export XDG_RUNTIME_DIR="$(/usr/local/bin/mkrundir)"




/usr/bin/kodi --windowing=x11 --gl-interface=egl

