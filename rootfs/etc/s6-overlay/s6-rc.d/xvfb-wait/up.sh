#!/usr/bin/env sh

until xset -q -display :0.0 &>/dev/null; do sleep 5; done
