#!/usr/bin/env sh

XDG_RUNTIME_DIR=$(mkrundir)
SWAYSOCK="${XDG_RUNTIME_DIR}/sway-ipc.sock"
WAYLAND_DISPLAY=wayland-1

mkdir -p \
    /run/sway/environment \
    /run/wayvnc/environment \
    /run/kodi/environment \
    /run/pipewire/environment

echo "$SWAYSOCK"        > /run/sway/environment/SWAYSOCK
echo "$WAYLAND_DISPLAY" > /run/sway/environment/WAYLAND_DISPLAY
echo "$XDG_RUNTIME_DIR" > /run/sway/environment/XDG_RUNTIME_DIR
echo "headless"         > /run/sway/environment/WLR_BACKENDS
echo 1                  > /run/sway/environment/WLR_LIBINPUT_NO_DEVICES
echo "$HOME"            > /run/sway/environment/HOME

echo "$SWAYSOCK"        > /run/wayvnc/environment/SWAYSOCK
echo "$WAYLAND_DISPLAY" > /run/wayvnc/environment/WAYLAND_DISPLAY

echo "$SWAYSOCK"        > /run/kodi/environment/SWAYSOCK
echo "$WAYLAND_DISPLAY" > /run/kodi/environment/WAYLAND_DISPLAY

echo "$XDG_RUNTIME_DIR" > /run/pipewire/environment/XDG_RUNTIME_DIR

exec /init
