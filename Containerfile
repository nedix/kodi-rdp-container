ARG FEDORA_VERSION=42
ARG LIBVDPAU_VA_GL_VERSION=769abad3207cb3e99c4ed7d21369e0859b75b548
ARG PULSEAUDIO_MODULE_XRDP_VERSION=0.7
ARG PULSEAUDIO_VERSION=17.0
ARG S6_OVERLAY_VERSION=3.2.0.0
ARG XORGXRDP_VERSION=fb49d67b6c94217cb64020986c983abe52ce06f2
ARG XRDP_VERSION=1c33f3d9af22cac303803a4132a6b1aea5ebf1ce
ARG XORG_SERVER_VERSION=21.1.12

FROM registry.fedoraproject.org/fedora-minimal:${FEDORA_VERSION} AS base

ARG BUILD_DEPENDENCIES=" \
    tar \
    xz \
"

ARG FEDORA_VERSION

RUN sed -E \
        -e "s|(\[main\])|\1\ndeltarpm=1|" \
        -e "s|(\[main\])|\1\nfastestmirror=1|" \
        -e "s|(\[main\])|\1\ninstall_weak_deps=0|" \
        -e "s|(\[main\])|\1\nmax_parallel_downloads=10|" \
        -e "s|(\[main\])|\1\nmetadata_expire=-1|" \
        -i /etc/dnf/dnf.conf \
    && dnf install -y \
        dnf5-plugins \
        "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VERSION}.noarch.rpm" \
        $BUILD_DEPENDENCIES \
    && for PREVIOUS_FEDORA_VERSION in $(seq $(( FEDORA_VERSION - 2 )) "$FEDORA_VERSION"); do \
        sed -E \
            -e "s|\\\$releasever|${PREVIOUS_FEDORA_VERSION}|g" \
            -e "s|^\[fedora|\[fedora-${PREVIOUS_FEDORA_VERSION}|g" \
            /etc/yum.repos.d/fedora.repo \
            > "/etc/yum.repos.d/fedora-${PREVIOUS_FEDORA_VERSION}.repo" \
        && dnf config-manager setopt "fedora-${PREVIOUS_FEDORA_VERSION}.enabled=1" \
        && sed -E \
            -e "s|\\\$releasever|${PREVIOUS_FEDORA_VERSION}|g" \
            -e "s|^\[updates|\[fedora-${PREVIOUS_FEDORA_VERSION}-updates|g" \
            /etc/yum.repos.d/fedora-updates.repo \
            > "/etc/yum.repos.d/fedora-${PREVIOUS_FEDORA_VERSION}-updates.repo" \
        && dnf config-manager setopt "fedora-${PREVIOUS_FEDORA_VERSION}-updates.enabled=1" \
        && sed -E \
            -e "s|\\\$releasever|${PREVIOUS_FEDORA_VERSION}|g" \
            -e "s|^\[rpmfusion-free|\[fedora-${PREVIOUS_FEDORA_VERSION}-rpmfusion-free|g" \
            /etc/yum.repos.d/rpmfusion-free.repo \
            > "/etc/yum.repos.d/fedora-${PREVIOUS_FEDORA_VERSION}-rpmfusion-free.repo" \
        && dnf config-manager setopt "fedora-${PREVIOUS_FEDORA_VERSION}-rpmfusion-free.enabled=1" \
        && sed -E \
            -e "s|\\\$releasever|${PREVIOUS_FEDORA_VERSION}|g" \
            -e "s|^\[rpmfusion-free-updates|\[fedora-${PREVIOUS_FEDORA_VERSION}-rpmfusion-free-updates|g" \
            /etc/yum.repos.d/rpmfusion-free-updates.repo \
            > "/etc/yum.repos.d/fedora-${PREVIOUS_FEDORA_VERSION}-rpmfusion-free-updates.repo" \
        && dnf config-manager setopt "fedora-${PREVIOUS_FEDORA_VERSION}-rpmfusion-free-updates.enabled=1" \
    ; done \
    && dnf config-manager setopt "fedora-cisco-openh264.enabled=0" \
    && dnf config-manager setopt "fedora.enabled=0" \
    && dnf config-manager setopt "updates.enabled=0" \
    && dnf config-manager setopt "updates-testing.enabled=0" \
    && dnf config-manager setopt "rpmfusion-free.enabled=0" \
    && dnf config-manager setopt "rpmfusion-free-updates.enabled=0" \
    && dnf config-manager setopt "rpmfusion-free-updates-testing.enabled=0" \
    && rm \
        /etc/yum.repos.d/fedora-cisco-openh264.repo \
        /etc/yum.repos.d/fedora.repo \
        /etc/yum.repos.d/fedora-updates.repo \
        /etc/yum.repos.d/fedora-updates-testing.repo \
        /etc/yum.repos.d/rpmfusion-free.repo \
        /etc/yum.repos.d/rpmfusion-free-updates.repo \
        /etc/yum.repos.d/rpmfusion-free-updates-testing.repo \
    && dnf makecache --refresh

ARG S6_OVERLAY_VERSION

RUN case "$(uname -m)" in \
        aarch64|arm*) \
            CPU_ARCHITECTURE="aarch64" \
        ;; x86_64) \
            CPU_ARCHITECTURE="x86_64" \
        ;; *) echo "Unsupported architecture: $(uname -m)"; exit 1; ;; \
    esac \
    && curl -fsSL "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz" \
    | tar -xpJf- -C / \
    && curl -fsSL "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${CPU_ARCHITECTURE}.tar.xz" \
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
        nasm \
        openssl-devel \
        pam-devel \
        pixman-devel \
        turbojpeg-devel \
        yasm-devel

RUN dnf install -y x264-devel
RUN dnf install -y libxkbfile-devel
RUN dnf install -y clang-analyzer

COPY --link --from=xorg-server /build/xorg-server/output/ /

WORKDIR /build/xrdp

ARG XRDP_VERSION

RUN git init "$PWD" \
    && git remote add origin https://github.com/nedix/xrdp-fork.git \
    && git fetch origin "$XRDP_VERSION" --no-tags \
    && git checkout -b main "$XRDP_VERSION" \
    && git submodule update --init --recursive --depth=1 \
    && sed -E \
        -e "s|#define MIN_MS_BETWEEN_FRAMES 40|#define MIN_MS_BETWEEN_FRAMES 10|" \
        -i /build/xrdp/xrdp/xrdp_mm.c

RUN export CFLAGS="-O2 -g1" CPPFLAGS="-O2 -g1" CXXFLAGS="-O2 -g1" \
    && ./bootstrap \
    && ./configure \
        --localstatedir=/var \
        --prefix=/usr \
        --sbindir=/usr/sbin \
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

RUN curl -fsSL "https://github.com/nedix/xorgxrdp-fork/tarball/${XORGXRDP_VERSION}" \
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

RUN dnf install -y openssh-server sudo
RUN dnf install -y kodi kodi-inputstream-adaptive
RUN dnf install -y gdb strace top ps valgrind

#RUN dnf install -y ffmpeg-libs x264-libs x265-libs
#RUN dnf install -y VirtualGL
#RUN dnf install -y egl-utils glx-utils vulkan-tools
#RUN dnf install -y mesa-vulkan-drivers

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

# SSH
EXPOSE 22

# RDP
EXPOSE 3389
