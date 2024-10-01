ARG ALPINE_VERSION=3.20
ARG ARCHITECTURE
ARG LIBGLVND_VERSION=1.7.0
ARG MESA_VERSION=24.1.7
ARG NVIDIA_VERSION=560.35.03
ARG PULSEAUDIO_MODULE_XRDP_VERSION=0.7
ARG PULSEAUDIO_VERSION=17.0
ARG SEATD_VERSION=0.8.0
ARG VIRTUALGL_VERSION=3.1.1
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

RUN wget -qO- "https://github.com/kennylevinsen/seatd/tarball/${SEATD_VERSION}" \
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
    && sed -E \
        -e "s|#define MIN_MS_BETWEEN_FRAMES 40|#define MIN_MS_BETWEEN_FRAMES 10|" \
        -i /build/xrdp/xrdp/xrdp_mm.c \
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
    && sed -E \
        -e "s|#define MIN_MS_BETWEEN_FRAMES 40|#define MIN_MS_BETWEEN_FRAMES 10|" \
        -i /build/xorgxrdp/module/rdpClientCon.c \
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

FROM build-base AS libglvnd

WORKDIR /build/libglvnd

ARG LIBGLVND_VERSION

RUN wget -qO- "https://github.com/NVIDIA/libglvnd/tarball/v${LIBGLVND_VERSION}" \
    | tar -xzf - --strip-components=1 \
    && export CFLAGS="-O2 -g1" CXXFLAGS="-O2 -g1" CPPFLAGS="-O2 -g1" \
    && meson build \
        --prefix=/usr \
        -Db_lto=true \
        -Db_ndebug=true \
    && DESTDIR=/build/libglvnd/output ninja -C build install

FROM alpine:${ALPINE_VERSION} AS nvidia

RUN apk add \
        zstd

WORKDIR /build/nvidia

ARG ARCHITECTURE
ARG NVIDIA_VERSION

RUN test -n "$ARCHITECTURE" || case $(uname -m) in \
        aarch64) NVIDIA_ARCHITECTURE="Linux-aarch64"; ;; \
        amd64)   NVIDIA_ARCHITECTURE="Linux-x86_64"; ;; \
        arm64)   NVIDIA_ARCHITECTURE="Linux-aarch64"; ;; \
        armv8b)  NVIDIA_ARCHITECTURE="Linux-aarch64"; ;; \
        armv8l)  NVIDIA_ARCHITECTURE="Linux-aarch64"; ;; \
        x86_64)  NVIDIA_ARCHITECTURE="Linux-x86_64"; ;; \
        *) echo "Unsupported architecture, exiting..."; exit 1; ;; \
    esac \
    && wget -q "https://download.nvidia.com/XFree86/${NVIDIA_ARCHITECTURE}/${NVIDIA_VERSION}/NVIDIA-${NVIDIA_ARCHITECTURE}-${NVIDIA_VERSION}.run" \
    && chmod +x "NVIDIA-${NVIDIA_ARCHITECTURE}-${NVIDIA_VERSION}.run" \
    && "./NVIDIA-${NVIDIA_ARCHITECTURE}-${NVIDIA_VERSION}.run" --extract-only \
    && rm "NVIDIA-${NVIDIA_ARCHITECTURE}-${NVIDIA_VERSION}.run" \
    && ( \
        cd "NVIDIA-${NVIDIA_ARCHITECTURE}-${NVIDIA_VERSION}" \
        && install -Dm644 "10_nvidia.json"                           -t "/build/nvidia/output/usr/share/glvnd/egl_vendor.d" \
        && install -Dm644 "20_nvidia_xcb.json"                       -t "/build/nvidia/output/usr/share/egl/egl_external_platform.d" \
        && install -Dm644 "20_nvidia_xlib.json"                      -t "/build/nvidia/output/usr/share/egl/egl_external_platform.d" \
        && install -Dm644 "nvidia_icd.json"                          -t "/build/nvidia/output/usr/share/vulkan/icd.d" \
        && install -Dm644 "nvidia_layers.json"                       -t "/build/nvidia/output/usr/share/vulkan/implicit_layer.d" \
        && install -Dm755 "libEGL_nvidia.so.${NVIDIA_VERSION}"       -t "/build/nvidia/output/usr/lib" \
        && install -Dm755 "libGLESv1_CM_nvidia.so.${NVIDIA_VERSION}" -t "/build/nvidia/output/usr/lib" \
        && install -Dm755 "libGLESv2_nvidia.so.${NVIDIA_VERSION}"    -t "/build/nvidia/output/usr/lib" \
        && install -Dm755 "libGLX_nvidia.so.${NVIDIA_VERSION}"       -t "/build/nvidia/output/usr/lib" \
        && install -Dm755 "libglxserver_nvidia.so.${NVIDIA_VERSION}" -t "/build/nvidia/output/usr/lib/nvidia/xorg" \
        && install -Dm755 "libnvidia-allocator.so.${NVIDIA_VERSION}" -t "/build/nvidia/output/usr/lib" \
        && install -Dm755 "libnvidia-api.so.1"                       -t "/build/nvidia/output/usr/lib" \
        && install -Dm755 "libnvidia-cfg.so.${NVIDIA_VERSION}"       -t "/build/nvidia/output/usr/lib" \
        && install -Dm755 "libnvidia-egl-xcb.so.1"                   -t "/build/nvidia/output/usr/lib" \
        && install -Dm755 "libnvidia-egl-xlib.so.1"                  -t "/build/nvidia/output/usr/lib" \
        && install -Dm755 "libnvidia-eglcore.so.${NVIDIA_VERSION}"   -t "/build/nvidia/output/usr/lib" \
        && install -Dm755 "libnvidia-encode.so.${NVIDIA_VERSION}"    -t "/build/nvidia/output/usr/lib" \
        && install -Dm755 "libnvidia-fbc.so.${NVIDIA_VERSION}"       -t "/build/nvidia/output/usr/lib" \
        && install -Dm755 "libnvidia-glcore.so.${NVIDIA_VERSION}"    -t "/build/nvidia/output/usr/lib" \
        && install -Dm755 "libnvidia-glsi.so.${NVIDIA_VERSION}"      -t "/build/nvidia/output/usr/lib" \
        && install -Dm755 "libnvidia-glvkspirv.so.${NVIDIA_VERSION}" -t "/build/nvidia/output/usr/lib" \
        && install -Dm755 "libnvidia-gpucomp.so.${NVIDIA_VERSION}"   -t "/build/nvidia/output/usr/lib" \
        && install -Dm755 "libnvidia-ml.so.${NVIDIA_VERSION}"        -t "/build/nvidia/output/usr/lib" \
        && install -Dm755 "libvdpau_nvidia.so.${NVIDIA_VERSION}"     -t "/build/nvidia/output/usr/lib/vdpau" \
        && install -Dm755 "nvidia_drv.so"                            -t "/build/nvidia/output/usr/lib/xorg/modules/drivers" \
        && ln -s "libglxserver_nvidia.so.${NVIDIA_VERSION}" "/build/nvidia/output/usr/lib/nvidia/xorg/libglxserver_nvidia.so.1" \
        && ln -s "libglxserver_nvidia.so.${NVIDIA_VERSION}" "/build/nvidia/output/usr/lib/nvidia/xorg/libglxserver_nvidia.so" \
    )

FROM build-base AS virtualgl

RUN apk add \
        cmake \
        g++ \
        glu-dev \
        libjpeg-turbo-dev \
        libx11-dev \
        libxcb-dev \
        libxext-dev \
        libxtst-dev \
        libxv-dev \
        lld \
        make \
        xcb-util-keysyms-dev

WORKDIR /build/virtualgl

ARG VIRTUALGL_VERSION

RUN wget -qO- https://github.com/VirtualGL/virtualgl/tarball/${VIRTUALGL_VERSION} \
    | tar -xzf - --strip-components=1 \
    && cmake \
        -B build \
        -G"Unix Makefiles" \
        -DVGL_FAKEOPENCL="OFF" \
        -DCMAKE_C_FLAGS="-fuse-ld=lld" \
        -DCMAKE_CXX_FLAGS="-fuse-ld=lld" \
    && (cd build && make -j $(( $(nproc) + 1 )))

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
        libelogind \
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
        linux-pam \
        llvm17-libs \
        openssl \
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

RUN apk add \
        x264-libs \
        x265-libs

RUN apk add openssh sudo
RUN apk add libc6-compat
RUN apk add mesa-gl mesa-egl

RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
    && echo "https://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    && apk add \
        s6-overlay

RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && apk add \
        kodi-inputstream-adaptive \
        kodi-x11 \
        mkrundir \
        skalibs-dev

COPY --link --from=seatd /build/seatd/output/ /
COPY --link --from=xorg-server /build/xorg-server/output/ /
COPY --link --from=xrdp /build/xrdp/output/ /
COPY --link --from=xorgxrdp /build/xorgxrdp/output/ /
COPY --link --from=pulseaudio /build/pulseaudio/output/ /
COPY --link --from=pulseaudio-module-xrdp /build/pulseaudio-module-xrdp/output/ /
COPY --link --from=libglvnd /build/libglvnd/output/ /
COPY --link --from=nvidia /build/nvidia/output/ /
COPY --link --from=virtualgl /build/virtualgl/build/bin/vglrun /build/virtualgl/build/bin/vglclient /build/virtualgl/build/bin/vglconfig /usr/bin/
COPY --link --from=virtualgl /build/virtualgl/build/lib/libvglfaker.so /build/virtualgl/build/lib/libdlfaker.so /build/virtualgl/build/lib/libGLdlfakerut.so /usr/lib/

RUN rm -rf /var/cache/apk/*

COPY /rootfs/ /

ENTRYPOINT ["/entrypoint.sh"]

# SSH
EXPOSE 22

# RDP
EXPOSE 3389
