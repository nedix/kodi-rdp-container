#!/usr/bin/env sh

until test -S "${XDG_RUNTIME_DIR}/${WAYLAND_DISPLAY}"; do sleep 5; done
