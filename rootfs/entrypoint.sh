#!/usr/bin/env sh

XDG_RUNTIME_DIR=$(/usr/bin/mkrundir)
WAYLAND_DISPLAY=wayland-1
eval "export $(/usr/bin/dbus-launch)"

mkdir -p \
    /run/kodi/environment \
    /run/pipewire/environment \
    /run/wayvnc/environment \
    /run/weston/environment

#echo "$SWAYSOCK"        > /run/sway/environment/SWAYSOCK
#echo "$WAYLAND_DISPLAY" > /run/sway/environment/WAYLAND_DISPLAY
#echo "$XDG_RUNTIME_DIR" > /run/sway/environment/XDG_RUNTIME_DIR
#echo "headless"         > /run/sway/environment/WLR_BACKENDS
#echo 1                  > /run/sway/environment/WLR_LIBINPUT_NO_DEVICES
#echo "$HOME"            > /run/sway/environment/HOME
#
#echo "$SWAYSOCK"        > /run/wayvnc/environment/SWAYSOCK
#echo "$WAYLAND_DISPLAY" > /run/wayvnc/environment/WAYLAND_DISPLAY

#echo "$DBUS_SESSION_BUS_ADDRESS"
#echo "$DBUS_SESSION_BUS_PID"
#
#echo "$DBUS_SESSION_BUS_ADDRESS" > /run/kodi/environment/DBUS_SESSION_BUS_ADDRESS
#echo "$DBUS_SESSION_BUS_PID"     > /run/kodi/environment/DBUS_SESSION_BUS_PID

echo /root              > /run/kodi/environment/HOME
echo "$SWAYSOCK"        > /run/kodi/environment/SWAYSOCK
echo "$WAYLAND_DISPLAY" > /run/kodi/environment/WAYLAND_DISPLAY
echo "$XDG_RUNTIME_DIR" > /run/kodi/environment/XDG_RUNTIME_DIR

echo "$DBUS_SESSION_BUS_ADDRESS" > /run/pipewire/environment/DBUS_SESSION_BUS_ADDRESS
echo "$DBUS_SESSION_BUS_PID"     > /run/pipewire/environment/DBUS_SESSION_BUS_PID
echo "$XDG_RUNTIME_DIR"          > /run/pipewire/environment/XDG_RUNTIME_DIR

echo "$XDG_RUNTIME_DIR" > /run/wayvnc/environment/XDG_RUNTIME_DIR
echo "$WAYLAND_DISPLAY" > /run/wayvnc/environment/WAYLAND_DISPLAY

echo headless           > /run/weston/environment/WLR_BACKENDS
echo 1                  > /run/weston/environment/WLR_NO_HARDWARE_CURSORS
echo 1                  > /run/weston/environment/WLR_LIBINPUT_NO_DEVICES
echo 1                  > /run/weston/environment/WLR_HEADLESS_OUTPUTS
echo "$DBUS_SESSION_BUS_ADDRESS" > /run/weston/environment/DBUS_SESSION_BUS_ADDRESS
echo "$DBUS_SESSION_BUS_PID"     > /run/weston/environment/DBUS_SESSION_BUS_PID
echo "$XDG_RUNTIME_DIR"          > /run/weston/environment/XDG_RUNTIME_DIR
echo "$WAYLAND_DISPLAY"          > /run/weston/environment/WAYLAND_DISPLAY
echo ":0.0"                      > /run/weston/environment/DISPLAY

exec /init
