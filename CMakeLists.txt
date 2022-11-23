cmake_minimum_required(VERSION 3.22.1)
project(lovr)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_C_STANDARD 11)
add_compile_options("$<$<C_COMPILER_ID:MSVC>:/utf-8>")
add_compile_options("$<$<CXX_COMPILER_ID:MSVC>:/utf-8>")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_DEBUG ${CMAKE_BINARY_DIR}/Debug/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_DEBUG ${CMAKE_BINARY_DIR}/Debug/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG ${CMAKE_BINARY_DIR}/Debug/bin)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE ${CMAKE_BINARY_DIR}/Release/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELEASE ${CMAKE_BINARY_DIR}/Release/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE ${CMAKE_BINARY_DIR}/Release/bin)

add_library(vk INTERFACE)
target_include_directories(vk INTERFACE $ENV{VULKAN_SDK}/include)

add_subdirectory(deps)

add_executable(
  lovr
  deps/glslang/StandAlone/ResourceLimits.cpp
  deps/glslang/StandAlone/resource_limits_c.cpp
  src/main.cpp
  src/util.c
  src/api/api.c
  src/api/l_lovr.c
  src/api/l_event.c
  src/api/l_timer.c
  src/api/l_system.c
  src/api/l_thread.c
  src/api/l_thread_thread.c
  src/api/l_thread_channel.c
  src/api/l_headset.c
  src/api/l_audio.c
  src/api/l_audio_source.c
  src/api/l_data.c
  src/api/l_data_blob.c
  src/api/l_data_sound.c
  src/api/l_data_image.c
  src/api/l_data_modelData.c
  src/api/l_data_rasterizer.c
  src/api/l_filesystem.c
  src/api/l_graphics.c
  src/api/l_graphics_buffer.c
  src/api/l_graphics_texture.c
  src/api/l_graphics_pass.c
  src/api/l_graphics_model.c
  src/api/l_graphics_tally.c
  src/api/l_graphics_readback.c
  src/api/l_graphics_font.c
  src/api/l_graphics_material.c
  src/api/l_graphics_sampler.c
  src/api/l_graphics_shader.c
  src/api/l_math.c
  src/api/l_math_randomGenerator.c
  src/api/l_math_vectors.c
  src/api/l_math_curve.c
  src/api/l_physics.c
  src/api/l_physics_shapes.c
  src/api/l_physics_joints.c
  src/api/l_physics_collider.c
  src/api/l_physics_world.c
  src/core/os_win32.c
  src/core/gpu_vk.c
  src/core/spv.c
  src/core/zip.c
  src/core/fs.c
  src/modules/event/event.c
  src/modules/timer/timer.c
  src/modules/math/math.c
  src/modules/math/curve.c
  src/modules/math/randomGenerator.c
  src/modules/math/pool.c
  src/modules/filesystem/filesystem.c
  src/modules/filesystem/file.c
  src/modules/system/system.c
  src/modules/thread/thread.c
  src/modules/thread/channel.c
  src/modules/data/blob.c
  src/modules/data/image.c
  src/modules/data/rasterizer.c
  src/modules/data/modelData.c
  src/modules/data/modelData_gltf.c
  src/modules/data/modelData_obj.c
  src/modules/data/modelData_stl.c
  src/modules/data/sound.c
  src/modules/graphics/graphics.c
  src/modules/headset/headset.c
  src/modules/headset/headset_desktop.c
  src/modules/physics/physics.c
  src/modules/audio/audio.c
  src/modules/audio/spatializer_simple.c
  src/lib/tinycthread/tinycthread.c
  src/lib/stb/stb_image.c
  src/lib/stb/stb_truetype.c
  src/lib/stb/stb_vorbis.c
  src/lib/miniaudio/miniaudio.c
  src/lib/minimp3/minimp3.c
  src/lib/jsmn/jsmn.c
  src/lib/noise/simplexnoise1234.c
  #
)
target_compile_options(lovr PRIVATE /wd4244 /MP)
target_compile_definitions(lovr PRIVATE LOVR_USE_DESKTOP LOVR_VK)
target_include_directories(lovr PRIVATE src src/modules etc src/lib/stdatomic
                                        deps/ode/include)
target_link_libraries(lovr PRIVATE lua glfw vk glslang msdfgen ode)
