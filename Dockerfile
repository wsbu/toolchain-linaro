# wsbu/toolchain-linaro:4.9
#
# Example invocation of this image might look like:
#
#     ```sh
#     docker run -it --rm \
#         -e uid=$(id -u) \
#         -e gid=$(id -g) \
#         -e SSH_AUTH_SOCK=/tmp/ssh_auth.sock \
#         -v "${SSH_AUTH_SOCK}":/tmp/ssh_auth.sock \
#         -v $HOME/.ssh/known_hosts:/home/captain/.ssh/known_hosts \
#         -w /opt/project \
#         -v `pwd`:/opt/project \
#         -v $HOME/.conan/data:/home/captain/.conan/data \
#         -v $HOME/.conan/registry.txt:/home/captain/.conan/registry.txt \
#         -v $HOME/.conan/.conan.db:/home/captain/.conan/.conan.db \
#         wsbu/toolchain-linaro \
#         "$@"
#     ```
#

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
    openssh-client \
    pkg-config \
    python-pip \
    python-setuptools \
    python-wheel \
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

COPY toolchain.cmake "${CMAKE_TOOLCHAIN_FILE}"
RUN sed -i 's;@GCC_INSTALL_ROOT@;/opt/linaro;' "${CMAKE_TOOLCHAIN_FILE}"

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

# Install Conan
RUN pip install conan==1.0.4
ENV CONAN_CMAKE_TOOLCHAIN_FILE="${CMAKE_TOOLCHAIN_FILE}" \
  CONAN_PRINT_RUN_COMMANDS=1 \
  CC="${WSBU_C_COMPILER}" \
  CXX="${WSBU_CXX_COMPILER}"
COPY conan/sitara_profile "${HOME}/.conan/profiles/sitara"
COPY conan/settings.yml "${HOME}/.conan/settings.yml"
COPY conan/registry.txt "${HOME}/.conan/registry.txt"
RUN ln -s "${HOME}/.conan/profiles/sitara" "${HOME}/.conan/profiles/default"

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

COPY start.sh /start.sh
ENTRYPOINT ["/start.sh"]

