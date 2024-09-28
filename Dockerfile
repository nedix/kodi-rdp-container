ARG ALPINE_VERSION=3.20
ARG ARCHITECTURE
ARG FREERDP_VERSION=3.8.0
ARG LIBGLVND_VERSION=1.7.0
ARG SEATD_VERSION=0.8.0
ARG XORGXRDP_VERSION=0.9.19

FROM alpine:${ALPINE_VERSION} AS libglvnd

RUN apk add \
        gcc \
        libx11-dev \
        libxext-dev \
        meson \
        musl-dev \
        ninja-build

WORKDIR /build/libglvnd

ARG LIBGLVND_VERSION

RUN wget -qO- "https://github.com/NVIDIA/libglvnd/tarball/v${LIBGLVND_VERSION}" \
    | tar -xzf - --strip-components=1 \
    && meson build --prefix=/usr \
    && DESTDIR=/build/libglvnd/output ninja -C build install

FROM alpine:${ALPINE_VERSION} AS seatd

RUN apk add \
        g++ \
        meson \
        scdoc \
        elogind-dev \
        linux-headers \
        samurai

WORKDIR /build/seatd

ARG SEATD_VERSION

RUN wget -qO- "https://git.sr.ht/~kennylevinsen/seatd/archive/${SEATD_VERSION}.tar.gz" \
    | tar -xzf - --strip-components=1 \
    && meson setup build \
        --prefix=/usr \
        -Dlibseat-logind=elogind \
        -Dlibseat-builtin=enabled \
    && DESTDIR=/build/seatd/output ninja -C build install

FROM alpine:${ALPINE_VERSION} AS xorgxrdp

RUN apk add \
        autoconf \
        automake \
        g++ \
        libdrm-dev \
        libepoxy-dev \
        libtool \
        make \
        mesa-dev \
        nasm \
        pkgconf \
        xorg-server-dev \
        xrdp-dev

WORKDIR /build/xorgxrdp

ARG XORGXRDP_VERSION

RUN wget -qO- "https://github.com/neutrinolabs/xorgxrdp/tarball/v${XORGXRDP_VERSION}" \
    | tar -xzf - --strip-components=1 \
    && export CFLAGS="$(pkg-config --cflags libdrm)" \
    && ./bootstrap \
    && ./configure \
        --enable-glamor \
        --libdir=/usr/lib/xorg/modules \
        --localstatedir=/var \
        --mandir=/usr/share/man \
        --prefix=/usr \
        --sysconfdir=/etc \
    && make \
    && make DESTDIR=/build/xorgxrdp/output install

RUN sed -E \
        -e "s|^(Section \"Module\")$|\1\n    Load \"glamoregl\"|" \
        -i /build/xorgxrdp/output/etc/X11/xrdp/xorg.conf

FROM alpine:${ALPINE_VERSION}

COPY --link --from=libglvnd /build/libglvnd/output/ /

RUN apk add \
        dbus-x11 \
        freeglut \
        gsm \
        krb5 \
        libturbojpeg \
        libx11 \
        libxcb \
        libxdamage \
        libxext \
        libxinerama \
        libxtst \
        libxv \
        seatd \
        vulkan-loader \
        weston \
        weston-backend-drm \
        weston-backend-headless \
        weston-xwayland \
        xcb-util-keysyms \
        xrandr \
        xvfb \
        xwayland

# TODO
RUN apk add pipewire pipewire-pulse pipewire-alsa wireplumber
RUN apk add alsa-utils alsaconf
RUN apk add pulseaudio pulseaudio-utils

RUN apk add xset
RUN apk add rtkit
RUN apk add elogind
RUN apk add polkit-elogind
RUN apk add xauth xorg-server xrdp

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    && apk add \
        s6-overlay

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && cat /etc/apk/repositories \
    && apk add \
        kodi-inputstream-adaptive \
        kodi-x11 \
        mkrundir \
        skalibs-dev

RUN rm -rf /var/cache/apk/*

COPY --link --from=seatd /build/seatd/output/ /
COPY --link --from=xorgxrdp /build/xorgxrdp/output/ /

COPY /rootfs/ /

ENTRYPOINT ["/entrypoint.sh"]

# RDP
EXPOSE 3389
