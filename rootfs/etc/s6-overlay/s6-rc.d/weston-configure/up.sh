#!/usr/bin/env sh

test -d /dev/dri \
    && sed -e "s|^backend=$|backend=drm|" -i /etc/weston/weston.ini \
    || sed -e "s|^backend=$|backend=headless|" -i /etc/weston/weston.ini
