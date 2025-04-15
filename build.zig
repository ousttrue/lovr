const std = @import("std");
const build_lua = @import("build_lua.zig").build_lua;

const FILES = .{
    "src/main.c",
    //
    "src/util.c",
    "src/core/os_win32.c",
    "src/core/gpu_vk.c",
    "src/core/spv.c",
    "src/core/job.c",
    "src/core/fs.c",
    "src/api/api.c",
    "src/api/l_event.c",
    "src/api/l_math.c",
    "src/api/l_math_vectors.c",
    "src/api/l_math_randomGenerator.c",
    "src/api/l_math_curve.c",
    "src/api/l_lovr.c",
    "src/api/l_headset.c",
    "src/api/l_headset_layer.c",
    "src/modules/headset/headset_simulator.c",
    "src/api/l_audio.c",
    "src/api/l_audio_source.c",
    "src/modules/audio/audio.c",
    "src/modules/audio/spatializer_simple.c",
    "src/api/l_graphics.c",
    "src/api/l_graphics_buffer.c",
    "src/api/l_graphics_pass.c",
    "src/api/l_graphics_font.c",
    "src/api/l_graphics_material.c",
    "src/api/l_graphics_mesh.c",
    "src/api/l_graphics_model.c",
    "src/api/l_graphics_readback.c",
    "src/api/l_graphics_sampler.c",
    "src/api/l_graphics_shader.c",
    "src/api/l_graphics_texture.c",
    "src/api/l_data.c",
    "src/api/l_data_image.c",
    "src/api/l_data_rasterizer.c",
    "src/api/l_data_modelData.c",
    "src/api/l_data_sound.c",
    "src/api/l_data_blob.c",
    "src/api/l_system.c",
    "src/api/l_thread.c",
    "src/api/l_thread_channel.c",
    "src/api/l_thread_thread.c",
    "src/api/l_timer.c",
    "src/api/l_filesystem.c",
    "src/api/l_filesystem_file.c",
    "src/api/l_event.c",
    "src/modules/data/modelData.c",
    "src/modules/data/modelData_gltf.c",
    "src/modules/data/modelData_obj.c",
    "src/modules/data/modelData_stl.c",
    "src/modules/data/image.c",
    "src/modules/data/blob.c",
    "src/modules/data/rasterizer.c",
    "src/modules/data/sound.c",
    "src/modules/graphics/graphics.c",
    "src/modules/event/event.c",
    "src/modules/thread/thread.c",
    "src/modules/math/math.c",
    "src/modules/system/system.c",
    "src/modules/timer/timer.c",
    "src/modules/filesystem/filesystem.c",
    "src/modules/headset/headset.c",
    "src/lib/luax/lutf8lib.c",
    "src/lib/jsmn/jsmn.c",
    "src/lib/stb/stb_image.c",
    "src/lib/stb/stb_truetype.c",
    "src/lib/stb/stb_vorbis.c",
    "src/lib/miniaudio/miniaudio.c",
    "src/lib/minimp3/minimp3.c",
    "src/lib/noise/simplexnoise1234.c",
    "src/lib/dmon/dmon.c",
    "src/lib/miniz/miniz_tinfl.c",
    "deps/msdfgen/core/Contour.cpp",
    "deps/msdfgen/core/EdgeHolder.cpp",
    "deps/msdfgen/core/MSDFErrorCorrection.cpp",
    "deps/msdfgen/core/Projection.cpp",
    "deps/msdfgen/core/Scanline.cpp",
    "deps/msdfgen/core/Shape.cpp",
    "deps/msdfgen/core/SignedDistance.cpp",
    "deps/msdfgen/core/Vector2.cpp",
    "deps/msdfgen/core/contour-combiners.cpp",
    "deps/msdfgen/core/edge-coloring.cpp",
    "deps/msdfgen/core/edge-segments.cpp",
    "deps/msdfgen/core/edge-selectors.cpp",
    "deps/msdfgen/core/equation-solver.cpp",
    "deps/msdfgen/core/msdf-error-correction.cpp",
    "deps/msdfgen/core/msdfgen-c.cpp",
    "deps/msdfgen/core/msdfgen.cpp",
    "deps/msdfgen/core/rasterization.cpp",
    "deps/msdfgen/core/render-sdf.cpp",
    "deps/msdfgen/core/sdf-error-estimation.cpp",
    "deps/msdfgen/core/shape-description.cpp",
    // "deps/msdfgen/ext/import-font.cpp",
    // "deps/msdfgen/ext/import-svg.cpp",
    "deps/msdfgen/ext/resolve-shape-geometry.cpp",
    "deps/msdfgen/ext/save-png.cpp",
    "deps/glfw/src/context.c",
    "deps/glfw/src/init.c",
    "deps/glfw/src/input.c",
    "deps/glfw/src/monitor.c",
    "deps/glfw/src/platform.c",
    "deps/glfw/src/vulkan.c",
    "deps/glfw/src/window.c",
    "deps/glfw/src/egl_context.c",
    "deps/glfw/src/osmesa_context.c",
    "deps/glfw/src/null_init.c",
    "deps/glfw/src/null_monitor.c",
    "deps/glfw/src/null_window.c",
    "deps/glfw/src/null_joystick.c",
    "deps/glfw/src/win32_module.c",
    "deps/glfw/src/win32_time.c",
    "deps/glfw/src/win32_thread.c",
    "deps/glfw/src/win32_init.c",
    "deps/glfw/src/win32_joystick.c",
    "deps/glfw/src/win32_monitor.c",
    "deps/glfw/src/win32_window.c",
    "deps/glfw/src/wgl_context.c",
    // "deps/glslang/MachineIndependent/glslang.y",
    "deps/glslang/glslang/MachineIndependent/glslang_tab.cpp",
    "deps/glslang/glslang/MachineIndependent/attribute.cpp",
    "deps/glslang/glslang/MachineIndependent/Constant.cpp",
    "deps/glslang/glslang/MachineIndependent/iomapper.cpp",
    "deps/glslang/glslang/MachineIndependent/InfoSink.cpp",
    "deps/glslang/glslang/MachineIndependent/Initialize.cpp",
    "deps/glslang/glslang/MachineIndependent/IntermTraverse.cpp",
    "deps/glslang/glslang/MachineIndependent/Intermediate.cpp",
    "deps/glslang/glslang/MachineIndependent/ParseContextBase.cpp",
    "deps/glslang/glslang/MachineIndependent/ParseHelper.cpp",
    "deps/glslang/glslang/MachineIndependent/PoolAlloc.cpp",
    "deps/glslang/glslang/MachineIndependent/RemoveTree.cpp",
    "deps/glslang/glslang/MachineIndependent/Scan.cpp",
    "deps/glslang/glslang/MachineIndependent/ShaderLang.cpp",
    "deps/glslang/glslang/MachineIndependent/SpirvIntrinsics.cpp",
    "deps/glslang/glslang/MachineIndependent/SymbolTable.cpp",
    "deps/glslang/glslang/MachineIndependent/Versions.cpp",
    "deps/glslang/glslang/MachineIndependent/intermOut.cpp",
    "deps/glslang/glslang/MachineIndependent/limits.cpp",
    "deps/glslang/glslang/MachineIndependent/linkValidate.cpp",
    "deps/glslang/glslang/MachineIndependent/parseConst.cpp",
    "deps/glslang/glslang/MachineIndependent/reflection.cpp",
    "deps/glslang/glslang/MachineIndependent/preprocessor/Pp.cpp",
    "deps/glslang/glslang/MachineIndependent/preprocessor/PpAtom.cpp",
    "deps/glslang/glslang/MachineIndependent/preprocessor/PpContext.cpp",
    "deps/glslang/glslang/MachineIndependent/preprocessor/PpScanner.cpp",
    "deps/glslang/glslang/MachineIndependent/preprocessor/PpTokens.cpp",
    "deps/glslang/glslang/MachineIndependent/propagateNoContraction.cpp",
    "deps/glslang/glslang/CInterface/glslang_c_interface.cpp",
    "deps/glslang/glslang/ResourceLimits/resource_limits_c.cpp",
    "deps/glslang/SPIRV/GlslangToSpv.cpp",
    "deps/glslang/SPIRV/InReadableOrder.cpp",
    "deps/glslang/SPIRV/Logger.cpp",
    "deps/glslang/SPIRV/SpvBuilder.cpp",
    "deps/glslang/SPIRV/SpvPostProcess.cpp",
    "deps/glslang/SPIRV/doc.cpp",
    "deps/glslang/SPIRV/SpvTools.cpp",
    "deps/glslang/SPIRV/disassemble.cpp",
    "deps/glslang/SPIRV/CInterface/spirv_c_interface.cpp",
    "deps/glslang/SPIRV/SPVRemapper.cpp",
    "deps/glslang/SPIRV/doc.cpp",
    "deps/glslang/glslang/GenericCodeGen/CodeGen.cpp",
    "deps/glslang/glslang/GenericCodeGen/Link.cpp",
    "deps/glslang/glslang/ResourceLimits/ResourceLimits.cpp",
};

const FLAGS = .{
    // "-DGLFW_DLL",
    "-DLOVR_DISABLE_PHYSICS",
    "-DLOVR_USE_GLFW",
    "-DLOVR_USE_GLSLANG",
    "-DLOVR_USE_SIMULATOR",
    "-DLOVR_VK",
    "-DMSDFGEN_COPYRIGHT_YEAR=2025",
    "-DMSDFGEN_PUBLIC=", //__declspec(dllimport)",
    "-DMSDFGEN_VERSION=1.10.0",
    "-DMSDFGEN_VERSION_MAJOR=1",
    "-DMSDFGEN_VERSION_MINOR=10",
    "-DMSDFGEN_VERSION_REVISION=0",
    "-D_CRT_NONSTDC_NO_WARNINGS",
    "-D_CRT_SECURE_NO_WARNINGS",
    "-D_GLFW_WIN32",
};

const TO_HEX = [_][]const u8{
    "etc/boot.lua",
    "etc/shaders/unlit.vert",
    "etc/shaders/unlit.frag",
    "etc/shaders/normal.frag",
    "etc/shaders/font.frag",
    "etc/shaders/cubemap.vert",
    "etc/shaders/cubemap.frag",
    "etc/shaders/equirect.frag",
    "etc/shaders/fill.vert",
    "etc/shaders/fill_array.frag",
    "etc/shaders/mask.vert",
    "etc/shaders/animator.comp",
    "etc/shaders/blender.comp",
    "etc/shaders/tallymerge.comp",
    "etc/shaders/lovr.glsl",
    "etc/VarelaRound.ttf",
};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "lovr",
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(exe);

    const ddx = b.addExecutable(.{
        .target = b.graph.host,
        .name = "ddx",
        .root_source_file = b.path("ddx.zig"),
    });
    for (TO_HEX) |src| {
        const run = b.addRunArtifact(ddx);
        exe.step.dependOn(&run.step);
        run.addDirectoryArg(b.path(""));
        run.addArg(src);
        const out_file = std.mem.concat(
            b.allocator,
            u8,
            &.{ src, ".h" },
        ) catch @panic("concat");
        // std.debug.print("=>'{s}'\n", .{out_file});
        const generated = run.addOutputFileArg(out_file);
        if (std.mem.indexOf(u8, src, "shaders")) |_| {
            exe.addIncludePath(generated.dirname().dirname());
        } else {
            exe.addIncludePath(generated.dirname());
        }
    }

    const lua = build_lua(b, target, optimize);
    b.installArtifact(lua);
    exe.step.dependOn(&lua.step);
    exe.linkLibrary(lua);
    exe.addIncludePath(lua.getEmittedIncludeTree());

    exe.linkLibC();
    exe.linkLibCpp();
    exe.addIncludePath(b.path("src/modules"));
    exe.addIncludePath(b.path("src"));
    exe.addIncludePath(b.path("src/lib/std"));
    exe.addCSourceFiles(.{
        .files = &FILES,
        .flags = &FLAGS,
    });
    exe.addIncludePath(b.path("etc"));
    exe.addIncludePath(b.path("deps/msdfgen"));
    exe.addIncludePath(b.path("deps/vulkan-headers/include"));
    exe.addIncludePath(b.path("deps/glslang/glslang/Include"));
    exe.addIncludePath(b.path("deps/glslang/glslang/Public"));
    exe.addIncludePath(b.path("deps/glslang"));
    exe.addIncludePath(b.path("deps/glfw/include"));

    exe.linkSystemLibrary("Dwmapi");
    exe.linkSystemLibrary("Ole32");
    exe.linkSystemLibrary("Gdi32");

    // glslang/build_info.h
    const glslang_build_info_h = b.addConfigHeader(.{
        .style = .{
            .cmake = b.path("deps/glslang/build_info.h.tmpl"),
        },
        .include_path = "glslang/build_info.h",
    }, .{
        .major = "14",
        .minor = "2",
        .patch = "0",
        .flavor = "2024-05-02",
    });
    exe.addConfigHeader(glslang_build_info_h);

    const luai = b.addExecutable(.{
        .name = "luai",
        .target = target,
        .optimize = optimize,
    });
    luai.addCSourceFile(.{
        .file = b.path("deps/lua/lua.c"),
    });
    luai.linkLibrary(lua);
    b.installArtifact(luai);
}
