#!/usr/bin/env sh

mkdir -p /var/xrdp/certs

if ! openssl x509 -in /var/xrdp/certs/cert.pem -noout; then
    openssl req -x509 -newkey rsa:2048 -nodes -keyout /var/xrdp/certs/key.pem -out /var/xrdp/certs/cert.pem -subj / -days 365
fi

if ls /dev/dri | grep -E "renderD[0-9]+" &> /dev/null; then
    GPU="$(ls /dev/dri | grep -E "renderD[0-9]+" | head -n 1)"
    sed -E \
        -e "s|(GPUDevice \"\")|#\1|" \
        -e "s|(Option \"DRMAllowList\").*$|\1 \"nvidia amdgpu i915 radeon msm zink mesa\"|" \
        -e "s|(Option \"DRMDevice\").*$|\1 \"/dev/dri/${GPU}\"|" \
        -e "s|^(Section \"Module\")$|\1\n    Load \"glamoregl\"|" \
        -i /etc/X11/xrdp/xorg.conf
fi
