ARG ALPINE_VERSION=3.20
ARG NOVNC_VERSION=1.5.0
ARG WEBSOCKIFY_VERSION=0.12.0

FROM alpine:${ALPINE_VERSION}

ARG NOVNC_VERSION
ARG WEBSOCKIFY_VERSION

RUN apk add \
        bash \
        mesa-dri-gallium \
        pipewire-pulse \
        sway

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && apk add \
        kodi-inputstream-adaptive \
        kodi-wayland \
        mkrundir \
        s6-overlay \
        wayvnc

RUN mkdir -p /opt/novnc/utils/websockify \
    && wget -qO- https://github.com/novnc/noVNC/archive/refs/tags/v${NOVNC_VERSION}.tar.gz \
    | tar xzf - --strip-components=1 -C /opt/novnc \
    && wget -qO- https://github.com/novnc/websockify/archive/refs/tags/v${WEBSOCKIFY_VERSION}.tar.gz \
    | tar xzf - --strip-components=1 -C /opt/novnc/utils/websockify

RUN rm -rf /var/cache/apk/*

COPY /rootfs/ /

ENTRYPOINT ["/entrypoint.sh"]

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
