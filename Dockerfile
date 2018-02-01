FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install --yes --no-install-recommends \
    automake \
    bc \
    bison \
    ca-certificates \
    ccache \
    flex \
    gawk \
    gettext \
    git-core \
    intltool \
    liblist-moreutils-perl \
    liblzo2-dev \
    libtool \
    libxml-dom-perl \
    libxml2-utils \
    lua5.3 \
    make \
    mtd-utils \
    net-tools \
    nodejs \
    pkg-config \
    qemu-system-arm \
    qemu-user \
    rsync \
    scons \
    sudo \
    u-boot-tools \
    uuid-dev \
    wget \
    xutils-dev \
    xz-utils \
    zlib1g-dev \
  && rm --recursive --force /var/lib/apt/lists/* \
  && ln -sf /usr/bin/lua5.3 /usr/bin/lua \
  && ln -sf /usr/bin/nodejs /usr/bin/node \
  && ln -sf /bin/bash /bin/sh

ENV HOME=/home/captain \
  WSBU_C_COMPILER=/opt/linaro/bin/arm-linux-gnueabihf-gcc \
  WSBU_CXX_COMPILER=/opt/linaro/bin/arm-linux-gnueabihf-g++ \
  WSBU_EMULATOR=/usr/bin/qemu-arm \
  QEMU_LD_PREFIX=/opt/linaro/arm-linux-gnueabihf/libc \
  CMAKE_TOOLCHAIN_FILE=/opt/toolchain-linaro-armhf.cmake

COPY toolchain.cmake "$CMAKE_TOOLCHAIN_FILE"

RUN git clone https://github.com/wsbu/linaro-release.git \
    --branch gcc-linaro-4.9.4-2017.01-x86_64_arm-linux-gnueabihf \
    --depth 1 \
    /opt/linaro \
  && rm -rf /opt/linaro/.git

RUN git clone https://github.com/wsbu/mtd-utils.git \
    --branch v2.0.1 \
    --depth 1 \
    /src \
  && cd /src \
  && ./autogen.sh \
  && ./configure \
  && make \
  && make install \
  && cd - \
  && rm -rf /src

RUN git clone https://github.com/wsbu/cross-browser.git \
    --branch x419_z1 \
    --depth 1 \
    /src \
  && cd /src/x/xc \
  && gcc -c xc.c -O2 \
  && gcc -o xc xc.o -O2 \
  && cp --force xc /bin \
  && strip /bin/xc \
  && mkdir --parents /lib/crossbrowser \
  && cp --archive /src/x/lib/*.js /lib/crossbrowser \
  && cp --archive /src/x/lib/old/*.js /lib/crossbrowser \
  && cd - \
  && rm -rf /src

RUN wget --quiet -O /tmp/cmake.sh https://cmake.org/files/v3.10/cmake-3.10.1-Linux-x86_64.sh \
  && sh /tmp/cmake.sh --prefix=/usr/local --exclude-subdir --skip-license \
  && rm /tmp/cmake.sh

RUN groupadd --gid 1000 captain \
  && useradd --home-dir "$HOME" \
    --uid 1000 --gid 1000 \
    captain \
  && mkdir --parents \
    $HOME/.ccache \
    $HOME/.ssh \
  && chown --recursive captain:captain "$HOME" \
  && chmod --recursive 777 "$HOME" \
  && echo "ALL ALL=NOPASSWD: ALL" >> /etc/sudoers
