#!/usr/bin/env sh

if ls /dev/dri/card[0-9]* &> /dev/null; then
    sed -e "s|^backend=$|backend=drm|" -i /etc/weston/weston.ini
else
    sed -e "s|^backend=$|backend=headless|" -i /etc/weston/weston.ini
fi
