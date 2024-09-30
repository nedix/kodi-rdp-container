#!/usr/bin/env sh

export HOME=/home/kodi

touch ~/.Xauthority

/usr/bin/xauth add :0.0 . $(xxd -l 16 -p /dev/urandom)
