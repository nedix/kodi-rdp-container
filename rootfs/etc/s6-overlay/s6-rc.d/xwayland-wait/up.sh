#!/usr/bin/env sh

until xset -q -display :1.0 &>/dev/null; do sleep 5; done
