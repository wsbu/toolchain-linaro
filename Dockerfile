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

FROM wsbu/toolchain-native:v0.2.2

ENV WSBU_C_COMPILER=/opt/linaro/bin/arm-linux-gnueabihf-gcc \
  WSBU_CXX_COMPILER=/opt/linaro/bin/arm-linux-gnueabihf-g++ \
  WSBU_EMULATOR=/usr/bin/qemu-arm \
  QEMU_LD_PREFIX=/opt/linaro/arm-linux-gnueabihf/libc \
  CMAKE_TOOLCHAIN_FILE=/opt/toolchain-linaro-armhf.cmake

ENV CONAN_CMAKE_TOOLCHAIN_FILE="${CMAKE_TOOLCHAIN_FILE}" \
  CC="${WSBU_C_COMPILER}" \
  CXX="${WSBU_CXX_COMPILER}"

# Replace native-oritented build configurations
COPY toolchain.cmake "${CMAKE_TOOLCHAIN_FILE}"
COPY conan/sitara_profile "${HOME}/.conan/profiles/sitara"

RUN apt-get update && apt-get install --yes --no-install-recommends \
      qemu-system-arm \
      qemu-user \
    && rm --recursive --force /var/lib/apt/lists/* \
  && git clone https://github.com/wsbu/linaro-release.git \
      --branch gcc-linaro-4.9.4-2017.01-x86_64_arm-linux-gnueabihf \
      --depth 1 \
      /opt/linaro \
    && rm -rf /opt/linaro/.git \
  && wget https://d1b0l86ne08fsf.cloudfront.net/mender-artifact/2.2.0/mender-artifact -O /usr/bin/mender-artifact \
  && chmod 0755 /usr/bin/mender-artifact \
  && mkdir --parents $HOME/.ssh \
  && sed -i 's;@GCC_INSTALL_ROOT@;/opt/linaro;' "${CMAKE_TOOLCHAIN_FILE}" \
  && ln -sf "${HOME}/.conan/profiles/sitara" "${HOME}/.conan/profiles/default" \
  && chown --recursive captain:captain "$HOME" \
  && chmod --recursive 777 "$HOME"

RUN groupadd --gid 1001 cocap1 \
  && groupadd --gid 1002 cocap2 \
  && groupadd --gid 1003 cocap3 \
  && groupadd --gid 1004 cocap4 \
  && groupadd --gid 1005 cocap5 \
  && useradd --home-dir "${HOME}" --uid 1001 --gid 1001 cocap1 --groups 1000 \
  && useradd --home-dir "${HOME}" --uid 1002 --gid 1002 cocap2 --groups 1000 \
  && useradd --home-dir "${HOME}" --uid 1003 --gid 1003 cocap3 --groups 1000 \
  && useradd --home-dir "${HOME}" --uid 1004 --gid 1004 cocap4 --groups 1000 \
  && useradd --home-dir "${HOME}" --uid 1005 --gid 1005 cocap5 --groups 1000
