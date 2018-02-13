set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM_PROCESSOR arm)

set(CMAKE_C_COMPILER   "$ENV{WSBU_C_COMPILER}")
set(CMAKE_CXX_COMPILER "$ENV{WSBU_CXX_COMPILER}")

set(CMAKE_FIND_ROOT_PATH "$ENV{GCC_PREFIX}/arm-linux-gnueabihf")

# Discard path returned by pkg-config and associated with HINTS in module
# like FindOpenSSL.
set(CMAKE_IGNORE_PATH "/usr/lib/x86_64-linux-gnu/" "/usr/lib/x86_64-linux-gnu/lib/")

# adjust the default behaviour of the FIND_XXX() commands:
# search headers and libraries in the target environment, search
# programs in the host environment
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY BOTH)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE BOTH)

set(CMAKE_CROSSCOMPILING_EMULATOR "$ENV{EMULATOR}")
