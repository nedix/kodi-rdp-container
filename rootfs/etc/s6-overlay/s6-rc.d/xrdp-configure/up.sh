#!/usr/bin/env sh

mkdir -p /var/xrdp/certs

if ! openssl x509 -in /var/xrdp/certs/cert.pem -noout; then
    openssl req -x509 -newkey rsa:2048 -nodes -keyout /var/xrdp/certs/key.pem -out /var/xrdp/certs/cert.pem -subj / -days 365
fi
