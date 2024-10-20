#!/usr/bin/env sh

while IFS= read -r ENV_VAR; do
    ENV_KEY="${ENV_VAR%%=*}"
    [ -z "${!ENV_KEY}" ] && export "$ENV_VAR"
done < <(/command/s6-envdir /run/s6/container_environment /usr/bin/env)

export XDG_RUNTIME_DIR="$(/usr/local/bin/mkrundir)"

exec /usr/bin/kodi --windowing=x11 --gl-interface=egl
