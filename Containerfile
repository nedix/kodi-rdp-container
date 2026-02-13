ARG FEDORA_VERSION=42
ARG PULSEAUDIO_MODULE_XRDP_VERSION=0.8
ARG PULSEAUDIO_VERSION=17.0
ARG S6_OVERLAY_VERSION=3.2.2.0
ARG XORGXRDP_VERSION=0.10.5
ARG XRDP_VERSION=0.10.5
ARG XORG_SERVER_VERSION=21.1.21

FROM ghcr.io/nedix/fedora-base-container:${FEDORA_VERSION} AS base

ARG BUILD_DEPENDENCIES=" \
    tar \
    xz \
"

RUN dnf makecache --refresh \
    && dnf install -y $BUILD_DEPENDENCIES

ARG S6_OVERLAY_VERSION

RUN case "$(uname -m)" in \
        aarch64) \
            S6_OVERLAY_ARCHITECTURE="aarch64" \
        ;; arm*) \
            S6_OVERLAY_ARCHITECTURE="arm" \
        ;; x86_64) \
            S6_OVERLAY_ARCHITECTURE="x86_64" \
        ;; *) echo "Unsupported architecture: $(uname -m)"; exit 1; ;; \
    esac \
    && curl -fsSL "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz" \
    | tar -xpJf- -C / \
    && curl -fsSL "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_OVERLAY_ARCHITECTURE}.tar.xz" \
    | tar -xpJf- -C /

RUN dnf remove -y $BUILD_DEPENDENCIES

FROM base AS build-base

RUN dnf install -y \
        automake \
        bison \
        cmake \
        cpio \
        doxygen \
        flex \
        g++ \
        gawk \
        gcc \
        git \
        gzip \
        intltool \
        kernel-headers \
        koji \
        libtool \
        libtool-ltdl-devel \
        m4 \
        make \
        meson \
        pkgconfig \
        rpm2cpio \
        samurai \
        tar \
        xmltoman

FROM build-base AS xorg-server

RUN dnf install -y \
        libXfont2-devel \
        libXi-devel \
        libXinerama-devel \
        libXres-devel \
        libXv-devel \
        libdrm-devel \
        libepoxy-devel \
        libgudev-devel \
        libxcvt-devel \
        libxkbfile-devel \
        libxshmfence-devel \
        mesa-libEGL-devel \
        mesa-libGL-devel \
        mesa-libgbm-devel \
        openssl-devel \
        pixman-devel \
        systemtap-sdt-devel \
        xorg-x11-util-macros \
        xorg-x11-xtrans-devel

WORKDIR /build/xorg-server

ARG XORG_SERVER_VERSION

RUN curl -fsSL "https://gitlab.freedesktop.org/xorg/xserver/-/archive/xorg-server-${XORG_SERVER_VERSION}/xserver-xorg-server-${XORG_SERVER_VERSION}.tar.gz" \
    | tar -xpzf- --strip-components=1 \
    && export CFLAGS="-O2 -g1" CPPFLAGS="-O2 -g1" CXXFLAGS="-O2 -g1" \
    && meson setup build \
        --prefix=/usr \
        -Db_lto=true \
        -Db_ndebug=true \
        -Ddefault_font_path="catalogue:/etc/X11/fontpath.d,built-ins" \
        -Ddpms=true \
        -Ddri1=false \
        -Ddri2=true \
        -Ddri3=true \
        -Dfallback_input_driver=libinput \
        -Dglamor=true \
        -Dglx=true \
        -Dhal=false \
        -Dipv6=true \
        -Dlisten_local=true \
        -Dlisten_tcp=false \
        -Dlisten_unix=true \
        -Dmodule_dir=/usr/lib64/xorg/modules \
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
    && DESTDIR="${PWD}/output" ninja -C build install

FROM build-base AS xrdp

RUN dnf install -y \
        lame-devel \
        libX11-devel \
        libXfixes-devel \
        libXrandr-devel \
        libdrm-devel \
        libepoxy-devel \
        libxkbfile-devel \
        nasm \
        openssl-devel \
        pam \
        pam-devel \
        pixman-devel \
        turbojpeg-devel \
        yasm-devel

COPY --link --from=xorg-server /build/xorg-server/output/ /

WORKDIR /build/xrdp

ARG XRDP_VERSION

RUN git init "$PWD" \
    && git remote add origin https://github.com/neutrinolabs/xrdp.git \
    && git fetch origin \
    && git checkout -b main "v${XRDP_VERSION}" \
    && git submodule update --init --recursive --depth=1 \
    && sed -E \
        -e "s|#define MIN_MS_BETWEEN_FRAMES 40|#define MIN_MS_BETWEEN_FRAMES 10|" \
        -i /build/xrdp/xrdp/xrdp_mm.c

RUN export CFLAGS="-O2 -g1" CPPFLAGS="-O2 -g1" CXXFLAGS="-O2 -g1" \
    && ./bootstrap \
    && ./configure \
        --localstatedir=/var \
        --prefix=/usr \
        --sbindir=/usr/bin \
        --sysconfdir=/etc \
        --enable-glamor \
        --enable-ipv6 \
        --enable-mp3lame \
        --enable-pam \
        --enable-pixman \
        --enable-rfxcodec \
        --enable-tjpeg \
        --enable-vsock \
    && make -j $(( $(nproc) + 1 )) \
    && make DESTDIR="${PWD}/output" install

FROM build-base AS xorgxrdp

RUN dnf install -y \
        libdrm-devel \
        libepoxy-devel \
        mesa-libgbm-devel \
        nasm \
        xorg-x11-server-devel \
        yasm-devel

COPY --link --from=xorg-server /build/xorg-server/output/ /
COPY --link --from=xrdp /build/xrdp/output/ /

WORKDIR /build/xorgxrdp

ARG XORGXRDP_VERSION

RUN curl -fsSL "https://github.com/neutrinolabs/xorgxrdp/tarball/v${XORGXRDP_VERSION}" \
    | tar -xpzf- --strip-components=1 \
    && sed -E \
        -e "s|#define MIN_MS_BETWEEN_FRAMES 40|#define MIN_MS_BETWEEN_FRAMES 10|" \
        -i /build/xorgxrdp/module/rdpClientCon.c \
    && sed -E \
        -e "s|const int vfreq = 50;|const int vfreq = 60;|" \
        -i /build/xorgxrdp/module/rdpRandR.c \
    && export CFLAGS="-O2 -g1 $(pkg-config --cflags libdrm)" CPPFLAGS="-O2 -g1" CXXFLAGS="-O2 -g1" \
    && ./bootstrap \
    && ./configure \
        --libdir=/usr/lib64/xorg/modules \
        --localstatedir=/var \
        --mandir=/usr/share/man \
        --prefix=/usr \
        --sysconfdir=/etc \
        --enable-glamor \
    && make -j $(( $(nproc) + 1 )) \
    && make DESTDIR="${PWD}/output" install \
    && sed -E \
        -e "s|^(Section \"Module\")$|\1\n    Load \"glamoregl\"|" \
        -i /build/xorgxrdp/output/etc/X11/xrdp/xorg.conf

FROM build-base AS pulseaudio

RUN dnf install -y \
        avahi-devel \
        dbus-devel \
        check-devel \
        glib2-devel \
        libICE-devel \
        libSM-devel \
        libX11-devel \
        libXi-devel \
        libXt-devel \
        libXtst-devel \
        libasyncns-devel \
        libatomic_ops-devel \
        libatomic_ops-static \
        libcap-devel \
        libsndfile-devel \
        libtdb-devel \
        openssl-devel \
        orc-devel \
        sbc-devel \
        xcb-util-devel \
        xorg-x11-proto-devel

WORKDIR /build/pulseaudio

ARG PULSEAUDIO_VERSION

RUN curl -fsSL "https://github.com/pulseaudio/pulseaudio/tarball/v${PULSEAUDIO_VERSION}" \
    | gunzip \
    | tar -xvf- --strip-components=1 \
    && export CFLAGS="-O2 -g1" CPPFLAGS="-O2 -g1" CXXFLAGS="-O2 -g1" \
    && meson rewrite kwargs set project / version "$PULSEAUDIO_VERSION" \
    && meson setup build  \
        --prefix=/usr \
        -Db_lto=true \
        -Db_ndebug=true \
    && DESTDIR="${PWD}/output" ninja -C build install

FROM build-base AS pulseaudio-module-xrdp

COPY --link --from=pulseaudio /build/pulseaudio/ /build/pulseaudio/
COPY --link --from=pulseaudio /build/pulseaudio/output/ /
COPY --link --from=xrdp /build/xrdp/output/ /

WORKDIR /build/pulseaudio-module-xrdp

ARG PULSEAUDIO_MODULE_XRDP_VERSION

RUN curl -fsSL "https://github.com/neutrinolabs/pulseaudio-module-xrdp/tarball/v${PULSEAUDIO_MODULE_XRDP_VERSION}" \
    | tar -xpzf- --strip-components=1 \
    && export CFLAGS="-O2 -g1" CXXFLAGS="-O2 -g1" CPPFLAGS="-O2 -g1" \
    && ./bootstrap \
    && ./configure \
        PULSE_DIR=/build/pulseaudio \
        --libdir=/usr/lib64/xorg/modules \
        --localstatedir=/var \
        --mandir=/usr/share/man \
        --prefix=/usr \
        --sysconfdir=/etc \
    && make -j $(( $(nproc) + 1 )) \
    && make DESTDIR="${PWD}/output" install

FROM base

RUN dnf install -y \
        dbus-daemon \
        dbus-x11 \
        libXfont2 \
        libepoxy \
        libxcvt \
        openssl \
        orc \
        pixman \
        seatd \
        turbojpeg \
        xkbcomp \
        xorg-x11-xauth \
        xset \
        xxd

RUN dnf install -y kodi kodi-inputstream-adaptive
RUN dnf install -y ffmpeg-libs x264-libs x265-libs
RUN dnf install -y mkpasswd sudo

COPY --from=xorg-server /build/xorg-server/output/ /
COPY --from=xrdp /build/xrdp/output/ /
COPY --from=xorgxrdp /build/xorgxrdp/output/ /
COPY --from=pulseaudio /build/pulseaudio/output/ /
COPY --from=pulseaudio-module-xrdp /build/pulseaudio-module-xrdp/output/ /

COPY /rootfs/ /

RUN dnf clean all \
    && ldconfig

ENV NVIDIA_DRIVER_CAPABILITIES=compute,graphics,utility,video,display

ENTRYPOINT ["/entrypoint.sh"]

# RDP
EXPOSE 3389

VOLUME /var/kodi-rdp/.kodi/
VOLUME /var/xrdp/certs/
