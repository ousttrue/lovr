# lua
add_library(
  lua STATIC
  lua/lapi.c
  lua/lauxlib.c
  lua/lbaselib.c
  lua/lcode.c
  lua/ldblib.c
  lua/ldebug.c
  lua/ldo.c
  lua/ldump.c
  lua/lfunc.c
  lua/lgc.c
  lua/linit.c
  lua/liolib.c
  lua/llex.c
  lua/lmathlib.c
  lua/lmem.c
  lua/loadlib.c
  lua/lobject.c
  lua/lopcodes.c
  lua/loslib.c
  lua/lparser.c
  lua/lstate.c
  lua/lstring.c
  lua/lstrlib.c
  lua/ltable.c
  lua/ltablib.c
  lua/ltm.c
  lua/lundump.c
  lua/lvm.c
  lua/lzio.c)
target_include_directories(lua PUBLIC lua)

# GLFW settings
set(GLFW_BUILD_EXAMPLES
    OFF
    CACHE BOOL "")
set(GLFW_BUILD_TESTS
    OFF
    CACHE BOOL "")
set(GLFW_BUILD_DOCS
    OFF
    CACHE BOOL "")
set(GLFW_INSTALL
    OFF
    CACHE BOOL "")
set(BUILD_SHARED_LIBS
    ON
    CACHE BOOL "")
add_subdirectory(glfw)

# glslang settings
set(ENABLE_HLSL
    OFF
    CACHE BOOL "")
set(ENABLE_SPVREMAPPER
    OFF
    CACHE BOOL "")
set(ENABLE_GLSLANG_BINARIES
    ON
    CACHE BOOL "")
set(ENABLE_GLSLANG_INSTALL
    OFF
    CACHE BOOL "")
set(ENABLE_OPT
    OFF
    CACHE BOOL "")
set(ENABLE_CTEST
    OFF
    CACHE BOOL "")
set(BUILD_EXTERNAL
    OFF
    CACHE BOOL "")
set(BUILD_SHARED_LIBS OFF)
add_subdirectory(glslang)

# msdfgen ode
set(BUILD_SHARED_LIBS ON)
subdirs(msdfgen ode openxr)
