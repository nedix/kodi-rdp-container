ARG ALPINE_VERSION=3.20
ARG NOVNC_VERSION=1.5.0
ARG WEBSOCKIFY_VERSION=0.12.0

FROM alpine:${ALPINE_VERSION}

ARG NOVNC_VERSION
ARG WEBSOCKIFY_VERSION

RUN apk add \
        dbus-x11 \
        freerdp \
        kodi-wayland \
        mesa-dri-gallium \
        pipewire-pulse \
        vulkan-tools \
        wayvnc \
        weston \
        weston-backend-drm \
        weston-shell-desktop

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && apk add \
        kodi-inputstream-adaptive \
        mkrundir \
        s6-overlay

#RUN apk add \
#        weston-xwayland \
#    && setup-devd udev \
#    && setup-xorg-base

RUN mkdir -p /opt/novnc/utils/websockify \
    && wget -qO- https://github.com/novnc/noVNC/archive/refs/tags/v${NOVNC_VERSION}.tar.gz \
    | tar xzf - --strip-components=1 -C /opt/novnc \
    && wget -qO- https://github.com/novnc/websockify/archive/refs/tags/v${WEBSOCKIFY_VERSION}.tar.gz \
    | tar xzf - --strip-components=1 -C /opt/novnc/utils/websockify

RUN apk add \
        seatd \
        weston-backend-headless \
        weston-backend-wayland

RUN apk add bash py3-numpy

RUN apk add labwc

RUN rm -rf /var/cache/apk/*

COPY /rootfs/ /

ENV UID=1001
ENV GID=1001

RUN addgroup \
        --gid="$GID" \
        kodi \
    && adduser \
        --disabled-password \
        --gecos="" \
        --home=/home/kodi \
        --ingroup=kodi \
        --uid="$UID" \
        kodi

ENTRYPOINT ["/entrypoint.sh"]

# RDP
EXPOSE 3389

# TODO
EXPOSE 5000

# TODO
EXPOSE 5100

# VNC
EXPOSE 5900

# NoVNC
EXPOSE 6080

# TODO
EXPOSE 7000

# Swayvnc
EXPOSE 7023
