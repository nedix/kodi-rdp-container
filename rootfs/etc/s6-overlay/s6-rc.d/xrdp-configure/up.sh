#!/usr/bin/env sh

mkdir -p /var/xrdp/certs

if ! openssl x509 -in /var/xrdp/certs/cert.pem -noout &> /dev/null; then
    openssl req -x509 -newkey rsa:2048 -nodes -keyout /var/xrdp/certs/key.pem -out /var/xrdp/certs/cert.pem -subj / -days 365
fi

if ls /dev/dri 2> /dev/null | grep -qE "renderD[0-9]+"; then
    GPU="$(ls /dev/dri | grep -E "renderD[0-9]+" | head -n 1)"
    sed -E \
        -e "s|(GPUDevice \"\")|#\1|" \
        -e "s|(Option \"AutoAddGPU\").*$|\1 \"on\"|" \
        -e "s|(Option \"DRMAllowList\").*$|\1 \"nvidia amdgpu i915 radeon msm\"|" \
        -e "s|(Option \"DRMDevice\").*$|\1 \"/dev/dri/${GPU}\"|" \
        -e "s|Option \"DRI3\" \"1\"|Option \"DRI2\" \"1\"|" \
        -i /etc/X11/xrdp/xorg.conf
fi
