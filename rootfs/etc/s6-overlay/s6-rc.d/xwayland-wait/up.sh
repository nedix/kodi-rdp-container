#!/usr/bin/env sh

until xset -q -display :2.0 &>/dev/null; do sleep 5; done
