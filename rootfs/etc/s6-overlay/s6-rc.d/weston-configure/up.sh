#!/usr/bin/env sh

sed -e "s|^backend=$|backend=${WESTON_BACKEND}|" -i /etc/weston/weston.ini
sed -e "s|^renderer=$|renderer=${WESTON_RENDERER}|" -i /etc/weston/weston.ini
