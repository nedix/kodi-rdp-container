#!/usr/bin/env sh

: ${DISPLAY:=":0.0"}
: ${XDG_RUNTIME_DIR:="$(/usr/bin/mkrundir)"}
: ${WAYLAND_DISPLAY:="wayland-0"}

eval "export $(/usr/bin/dbus-launch)"

mkdir -p \
    /run/kodi/environment \
    /run/labwc/environment \
    /run/pipewire/environment \
    /run/wayvnc/environment

echo "$SWAYSOCK"        > /run/kodi/environment/SWAYSOCK
echo "$WAYLAND_DISPLAY" > /run/kodi/environment/WAYLAND_DISPLAY
echo "$XDG_RUNTIME_DIR" > /run/kodi/environment/XDG_RUNTIME_DIR
echo /root              > /run/kodi/environment/HOME

echo "$DBUS_SESSION_BUS_ADDRESS" > /run/pipewire/environment/DBUS_SESSION_BUS_ADDRESS
echo "$DBUS_SESSION_BUS_PID"     > /run/pipewire/environment/DBUS_SESSION_BUS_PID
echo "$XDG_RUNTIME_DIR"          > /run/pipewire/environment/XDG_RUNTIME_DIR

echo "$WAYLAND_DISPLAY" > /run/wayvnc/environment/WAYLAND_DISPLAY
echo "$XDG_RUNTIME_DIR" > /run/wayvnc/environment/XDG_RUNTIME_DIR
echo "wayland"          > /run/wayvnc/environment/XDG_SESSION_TYPE

echo "$DBUS_SESSION_BUS_ADDRESS" > /run/labwc/environment/DBUS_SESSION_BUS_ADDRESS
echo "$DBUS_SESSION_BUS_PID"     > /run/labwc/environment/DBUS_SESSION_BUS_PID
echo "$WAYLAND_DISPLAY"          > /run/labwc/environment/WAYLAND_DISPLAY
echo "$XDG_RUNTIME_DIR"          > /run/labwc/environment/XDG_RUNTIME_DIR
echo ":0.0"                      > /run/labwc/environment/DISPLAY
echo "headless,libinput"         > /run/labwc/environment/WLR_BACKENDS
echo "wayland"                   > /run/labwc/environment/XDG_SESSION_TYPE
echo 1                           > /run/labwc/environment/WLR_HEADLESS_OUTPUTS
echo 1                           > /run/labwc/environment/WLR_LIBINPUT_NO_DEVICES
echo 1                           > /run/labwc/environment/WLR_NO_HARDWARE_CURSORS

exec env -i \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME="$(( 60 * 1000 ))" \
    /init
