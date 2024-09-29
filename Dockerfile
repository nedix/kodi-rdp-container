ARG ALPINE_VERSION=3.20
ARG ARCHITECTURE
ARG FREERDP_VERSION=3.8.0
ARG LIBGLVND_VERSION=1.7.0
ARG MESA_VERSION=24.1.7
ARG PULSEAUDIO_MODULE_XRDP_VERSION=0.7
ARG PULSEAUDIO_VERSION=17.0
ARG SEATD_VERSION=0.8.0
ARG XORGXRDP_VERSION=0.10.2
ARG XORG_SERVER_VERSION=21.1.13
ARG XRDP_VERSION=0.10.1

FROM alpine:${ALPINE_VERSION} AS build-base

# seatd
RUN apk add \
        g++ \
        meson \
        scdoc \
        elogind-dev \
        linux-headers \
        samurai

# xorg-server, xrdp, xorgxrdp, pulseaudio, pulseaudio-module-xrdp
RUN apk add \
        autoconf \
        automake \
        check-dev \
        cmocka-dev \
        doxygen \
        eudev-dev \
        fdk-aac-dev \
        fuse-dev \
        g++ \
        git \
        lame-dev \
        libdrm-dev \
        libepoxy-dev \
        libice-dev \
        libjpeg-turbo-dev \
        libpciaccess-dev \
        libsm-dev \
        libsndfile-dev \
        libtool \
        libx11-dev \
        libxau-dev \
        libxcb-dev \
        libxcvt-dev \
        libxdmcp-dev \
        libxext-dev \
        libxfixes-dev \
        libxfont2-dev \
        libxkbfile-dev \
        libxrandr-dev \
        libxshmfence-dev \
        libxtst-dev \
        linux-headers \
        linux-pam-dev \
        make \
        mesa-dev \
        meson \
        nasm \
        nettle-dev \
        openssl-dev \
        opus-dev \
        perl-xml-parser \
        pixman-dev \
        pkgconf \
        samurai \
        tdb-dev \
        xcb-util-dev \
        xcb-util-image-dev \
        xcb-util-keysyms-dev \
        xcb-util-renderutil-dev \
        xcb-util-wm-dev \
        xkbcomp-dev \
        xorg-server-dev \
        xorgproto \
        xtrans

FROM build-base AS seatd

WORKDIR /build/seatd

ARG SEATD_VERSION

RUN wget -qO- "https://git.sr.ht/~kennylevinsen/seatd/archive/${SEATD_VERSION}.tar.gz" \
    | tar -xzf - --strip-components=1 \
    && export CFLAGS="-O2 -g1 -Wno-error=unused-parameter" CXXFLAGS="-O2 -g1" CPPFLAGS="-O2 -g1" \
    && meson setup build \
        --prefix=/usr \
        -Db_lto=true \
        -Db_ndebug=true \
        -Dlibseat-logind=elogind \
        -Dlibseat-builtin=enabled \
    && DESTDIR=/build/seatd/output ninja -C build install

FROM build-base AS xorg-server

WORKDIR /build/xorg-server

ARG XORG_SERVER_VERSION

RUN wget -qO- "https://gitlab.freedesktop.org/xorg/xserver/-/archive/xorg-server-${XORG_SERVER_VERSION}/xserver-xorg-server-${XORG_SERVER_VERSION}.tar.gz" \
    | tar -xzf - --strip-components=1 \
    && export CFLAGS="-O2 -g1" CXXFLAGS="-O2 -g1" CPPFLAGS="-O2 -g1" \
    && meson setup build \
        --prefix=/usr \
        -Db_lto=true \
        -Db_ndebug=true \
        -Ddefault_font_path=/usr/share/fonts/misc,/usr/share/fonts/100dpi:unscaled,/usr/share/fonts/75dpi:unscaled,/usr/share/fonts/TTF,/usr/share/fonts/Type1 \
        -Ddpms=true \
        -Ddri1=true \
        -Ddri2=true \
        -Ddri3=true \
        -Dglamor=true \
        -Dglx=true \
        -Dhal=false \
        -Dipv6=true \
        -Dlisten_local=true \
        -Dlisten_tcp=false \
        -Dlisten_unix=true \
        -Dpciaccess=true \
        -Dsecure-rpc=false \
        -Dsuid_wrapper=true \
        -Dsystemd_logind=false \
        -Dudev=true \
        -Dxcsecurity=true \
        -Dxdm-auth-1=true \
        -Dxdmcp=false \
        -Dxephyr=false \
        -Dxkb_dir=/usr/share/X11/xkb \
        -Dxkb_output_dir=/var/lib/xkb \
        -Dxnest=false \
        -Dxorg=true \
        -Dxvfb=true \
        -Dxwin=false \
    && DESTDIR=/build/xorg-server/output ninja -C build install

FROM build-base AS xrdp

COPY --link --from=xorg-server /build/xorg-server/output/ /

WORKDIR /build/xrdp

ARG XRDP_VERSION

RUN git init "$PWD" \
    && git remote add -f origin -t \* https://github.com/neutrinolabs/xrdp.git \
    && git checkout "tags/v${XRDP_VERSION}" \
    && git submodule update --init --recursive \
    && export CFLAGS="-O2 -g1 -Wno-error=cpp" CXXFLAGS="-O2 -g1" CPPFLAGS="-O2 -g1" \
    && ./bootstrap \
    && ./configure \
        --localstatedir=/var \
        --prefix=/usr \
        --sbindir=/usr/sbin \
        --sysconfdir=/etc \
        --enable-fdkaac \
        --enable-glamor \
        --enable-ipv6 \
        --enable-mp3lame \
        --enable-opus \
        --enable-pam \
        --enable-pixman \
        --enable-rfxcodec \
        --enable-tests \
        --enable-tjpeg \
        --enable-vsock \
    && make -j $(( $(nproc) + 1 )) \
    && make DESTDIR=/build/xrdp/output install

FROM build-base AS xorgxrdp

COPY --link --from=xorg-server /build/xorg-server/output/ /
COPY --link --from=xrdp /build/xrdp/output/ /

WORKDIR /build/xorgxrdp

ARG XORGXRDP_VERSION

RUN wget -qO- "https://github.com/neutrinolabs/xorgxrdp/tarball/v${XORGXRDP_VERSION}" \
    | tar -xzf - --strip-components=1 \
    && export CFLAGS="-O2 -g1 $(pkg-config --cflags libdrm)" CXXFLAGS="-O2 -g1" CPPFLAGS="-O2 -g1" \
    && ./bootstrap \
    && ./configure \
        --libdir=/usr/lib/xorg/modules \
        --localstatedir=/var \
        --mandir=/usr/share/man \
        --prefix=/usr \
        --sysconfdir=/etc \
        --enable-glamor \
    && make -j $(( $(nproc) + 1 )) \
    && make DESTDIR=/build/xorgxrdp/output install \
    && sed -E \
        -e "s|^(Section \"Module\")$|\1\n    Load \"glamoregl\"|" \
        -e "s|(Option \"DRMAllowList\").*$|\1 \"nvidia amdgpu i915 radeon msm vc4 v3d\"|" \
        -i /build/xorgxrdp/output/etc/X11/xrdp/xorg.conf

FROM build-base AS pulseaudio

WORKDIR /build/pulseaudio

ARG PULSEAUDIO_VERSION

RUN wget -qO- "https://freedesktop.org/software/pulseaudio/releases/pulseaudio-${PULSEAUDIO_VERSION}.tar.gz" \
    | tar -xzf - --strip-components=1 \
    && sed -E \
        -e "s|libintl_dep = .*|libintl_dep = cc.find_library('intl')|" \
        -i meson.build \
    && export CFLAGS="-O2 -g1" CXXFLAGS="-O2 -g1" CPPFLAGS="-O2 -g1" \
    && meson setup build  \
        --prefix=/usr \
        -Db_lto=true \
        -Db_ndebug=true \
    && DESTDIR=/build/pulseaudio/output ninja -C build install

FROM build-base AS pulseaudio-module-xrdp

COPY --link --from=pulseaudio /build/pulseaudio/ /build/pulseaudio/
COPY --link --from=pulseaudio /build/pulseaudio/output/ /
COPY --link --from=xrdp /build/xrdp/output/ /

WORKDIR /build/pulseaudio-module-xrdp

ARG PULSEAUDIO_MODULE_XRDP_VERSION

RUN wget -qO- "https://github.com/neutrinolabs/pulseaudio-module-xrdp/tarball/v${PULSEAUDIO_MODULE_XRDP_VERSION}" \
    | tar -xzf - --strip-components=1 \
    && export CFLAGS="-O2 -g1" CXXFLAGS="-O2 -g1" CPPFLAGS="-O2 -g1" \
    && ./bootstrap \
    && ./configure \
        PULSE_DIR=/build/pulseaudio \
        --libdir=/usr/lib/xorg/modules \
        --localstatedir=/var \
        --mandir=/usr/share/man \
        --prefix=/usr \
        --sysconfdir=/etc \
    && make -j $(( $(nproc) + 1 )) \
    && make DESTDIR=/build/pulseaudio-module-xrdp/output install

FROM alpine:${ALPINE_VERSION}

RUN apk add \
        colord \
        dbus-x11 \
        fdk-aac \
        fuse \
        gsm \
        krb5 \
        lame-libs \
        libcrypto3 \
        libdrm \
        libepoxy \
        libssl3 \
        libturbojpeg \
        libx11 \
        libxcb \
        libxcvt \
        libxdamage \
        libxext \
        libxfixes \
        libxfont2 \
        libxkbfile \
        libxrandr \
        libxtst \
        libxv \
        llvm17-libs \
        mesa-dri-gallium \
        mesa-egl \
        mesa-gl \
        mesa-va-gallium \
        mesa-vdpau-gallium \
        opus \
        pixman \
        vulkan-loader \
        xauth \
        xcalib \
        xcb-util-keysyms \
        xkbcomp \
        xkeyboard-config \
        xrandr \
        xset

RUN apk add libelogind

RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
    && echo "https://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    && apk add \
        s6-overlay

RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && cat /etc/apk/repositories \
    && apk add \
        kodi-inputstream-adaptive \
        kodi-x11 \
        mkrundir \
        skalibs-dev

RUN rm -rf /var/cache/apk/*

COPY --link --from=seatd /build/seatd/output/ /
COPY --link --from=xorg-server /build/xorg-server/output/ /
COPY --link --from=xrdp /build/xrdp/output/ /
COPY --link --from=xorgxrdp /build/xorgxrdp/output/ /
COPY --link --from=pulseaudio /build/pulseaudio/output/ /
COPY --link --from=pulseaudio-module-xrdp /build/pulseaudio-module-xrdp/output/ /

COPY /rootfs/ /

ENTRYPOINT ["/entrypoint.sh"]

# RDP
EXPOSE 3389
