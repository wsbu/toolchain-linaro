FROM wsbu/toolchain-native:v0.3.2

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
