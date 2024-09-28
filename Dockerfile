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
    && meson build \
        --prefix=/usr \
        -Db_lto=true \
    && DESTDIR=/build/libglvnd/output ninja -C build install

FROM alpine:${ALPINE_VERSION} AS mesa

COPY --link --from=libglvnd /build/libglvnd/output/ /

RUN apk add \
        bison \
        clang17-dev \
        cmake \
        flex-dev \
        g++ \
        glslang-dev \
        libclc-dev \
        libdrm-dev \
        libelf \
        libx11-dev \
        libxcb-dev \
        libxext-dev \
        libxfixes-dev \
        libxrandr-dev \
        libxshmfence-dev \
        libxxf86vm-dev \
        llvm17-dev \
        mesa-egl \
        meson \
        musl-dev \
        ninja-build \
        pkgconf \
        py3-pip \
        python3 \
        rustfmt \
        spirv-llvm-translator-dev \
        vulkan-loader-dev \
        wayland-dev \
        wayland-protocols \
    && pip install --break-system-packages \
        mako \
        ply \
        pyaml \
        pycparser

RUN apk add libvdpau-dev libva-dev
RUN apk add rust-bindgen

WORKDIR /build/mesa

ARG MESA_VERSION

RUN wget -qO- "https://gitlab.freedesktop.org/mesa/mesa/-/archive/mesa-${MESA_VERSION}/mesa-mesa-${MESA_VERSION}.tar.gz" \
    | tar -xzf - --strip-components=1 \
    && export CFLAGS="-O2 -g1" \
    && export CXXFLAGS="-O2 -g1" \
    && export CPPFLAGS="$CPPFLAGS -O2 -g1" \
    && meson setup build \
        --prefix=/usr \
        -Db_lto=true \
        -Db_ndebug=true \
        -Dbackend_max_links=2 \
        -Ddri-drivers-path=/usr/lib/xorg/modules/dri \
        -Degl=enabled \
        -Dgallium-drivers=nouveau,swrast,tegra,v3d,vc4,zink \
        -Dgallium-extra-hud=true \
        -Dgallium-nine=true \
        -Dgallium-rusticl=true \
        -Dgallium-va=enabled \
        -Dgallium-vdpau=enabled \
        -Dgallium-xa=enabled \
        -Dgbm=enabled \
        -Dgles1=enabled \
        -Dgles2=enabled \
        -Dglx=dri \
        -Dllvm=enabled \
        -Dopengl=true \
        -Dosmesa=true \
        -Dplatforms=x11 \
        -Drust_std=2021 \
        -Dshared-glapi=enabled \
        -Dshared-llvm=enabled \
        -Dvideo-codecs=all \
        -Dvulkan-drivers=amd,swrast,intel,broadcom \
        -Dvulkan-layers=device-select,overlay \
    && DESTDIR=/build/mesa/output ninja -C build install

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
        -Db_lto=true \
        -Dlibseat-logind=elogind \
        -Dlibseat-builtin=enabled \
    && DESTDIR=/build/seatd/output ninja -C build install

FROM alpine:${ALPINE_VERSION} AS xrdp

ARG XRDP_VERSION

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

WORKDIR /build/xorg-server

ARG XORG_SERVER_VERSION

RUN wget -qO- "https://gitlab.freedesktop.org/xorg/xserver/-/archive/xorg-server-${XORG_SERVER_VERSION}/xserver-xorg-server-${XORG_SERVER_VERSION}.tar.gz" \
    | tar -xzf - --strip-components=1 \
    && meson setup build \
        --prefix=/usr \
        -Db_lto=true \
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
        -Dxvfb=false \
        -Dxwin=false \
    && DESTDIR=/build/xorg-server/output ninja -C build install \
    && cp -r /build/xorg-server/output/* /

WORKDIR /build/xrdp

ARG XRDP_VERSION

RUN git init "$PWD" \
    && git remote add -f origin -t \* https://github.com/neutrinolabs/xrdp.git \
    && git checkout "tags/v${XRDP_VERSION}" \
    && git submodule update --init --recursive \
    && ./bootstrap \
    && CFLAGS=-Wno-error=cpp ./configure \
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
    && make \
    && make DESTDIR=/build/xrdp/output install \
    && cp -r /build/xrdp/output/* /

WORKDIR /build/xorgxrdp

ARG XORGXRDP_VERSION

RUN wget -qO- "https://github.com/neutrinolabs/xorgxrdp/tarball/v${XORGXRDP_VERSION}" \
    | tar -xzf - --strip-components=1 \
    && sed -E \
        -e "s|glamor_init(pScreen, GLAMOR_USE_EGL_SCREEN \| GLAMOR_NO_DRI3)|glamor_init(pScreen, GLAMOR_USE_EGL_SCREEN)|" \
        -i /build/xorgxrdp/xrdpdev/xrdpdev.c \
    && export CFLAGS="$(pkg-config --cflags libdrm)" \
    && ./bootstrap \
    && ./configure \
        --libdir=/usr/lib/xorg/modules \
        --localstatedir=/var \
        --mandir=/usr/share/man \
        --prefix=/usr \
        --sysconfdir=/etc \
        --enable-glamor \
    && make \
    && make DESTDIR=/build/xorgxrdp/output install \
    && sed -E \
        -e "s|^(Section \"Module\")$|\1\n    Load \"glamoregl\"|" \
        -e "s|(Option \"DRMAllowList\").*$|\1 \"nvidia amdgpu i915 radeon msm vc4 v3d\"|" \
        -i /build/xorgxrdp/output/etc/X11/xrdp/xorg.conf \
    && cp -r /build/xorgxrdp/output/* /

WORKDIR /build/pulseaudio

ARG PULSEAUDIO_VERSION

RUN wget -qO- "https://freedesktop.org/software/pulseaudio/releases/pulseaudio-${PULSEAUDIO_VERSION}.tar.gz" \
    | tar -xzf - --strip-components=1 \
    && sed -e "s|libintl_dep = .*|libintl_dep = cc.find_library('intl')|" -i meson.build \
    && meson setup build  \
        --prefix=/usr \
        -Db_lto=true \
    && DESTDIR=/build/pulseaudio/output ninja -C build install \
    && cp -r /build/pulseaudio/output/* /

WORKDIR /build/pulseaudio-module-xrdp

ARG PULSEAUDIO_MODULE_XRDP_VERSION

RUN wget -qO- "https://github.com/neutrinolabs/pulseaudio-module-xrdp/tarball/v${PULSEAUDIO_MODULE_XRDP_VERSION}" \
    | tar -xzf - --strip-components=1 \
    && ./bootstrap \
    && ./configure \
        PULSE_DIR=/build/pulseaudio \
        --libdir=/usr/lib/xorg/modules \
        --localstatedir=/var \
        --mandir=/usr/share/man \
        --prefix=/usr \
        --sysconfdir=/etc \
    && make \
    && make DESTDIR=/build/pulseaudio-module-xrdp/output install

FROM alpine:${ALPINE_VERSION}

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
        libxtst \
        libxv \
        vulkan-loader \
        xcb-util-keysyms \
        xrandr \
        xvfb

# TODO
RUN apk add pipewire pipewire-pulse pipewire-alsa wireplumber
RUN apk add alsa-utils alsaconf
RUN apk add pulseaudio pulseaudio-utils

RUN apk add --virtual pulseaudio-module-xrdp
RUN apk add --virtual xorg-server
RUN apk add --virtual xorgxrdp
RUN apk add --virtual xrdp

RUN apk add xset
RUN apk add rtkit
RUN apk add elogind
RUN apk add polkit-elogind
RUN apk add xinit xauth
RUN apk add lame-libs fdk-aac opus
RUN apk add fuse libcrypto3 libssl3 libxfixes libxrandr linux-pam
RUN apk add libepoxy libxfont2 libdrm libxdamage
RUN apk add libxcvt fuse mesa-egl
RUN apk add llvm17-libs

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

COPY --link --from=libglvnd /build/libglvnd/output/ /
COPY --link --from=mesa /build/mesa/output/ /
COPY --link --from=seatd /build/seatd/output/ /
COPY --link --from=xrdp /build/xorg-server/output/ /
COPY --link --from=xrdp /build/xrdp/output/ /
COPY --link --from=xrdp /build/xorgxrdp/output/ /
COPY --link --from=xrdp /build/pulseaudio-module-xrdp/output/ /

COPY /rootfs/ /

ENTRYPOINT ["/entrypoint.sh"]

# RDP
EXPOSE 3389
