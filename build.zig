const std = @import("std");
const build_lua = @import("build_lua.zig");
const build_ddx = @import("build_ddx.zig");
const build_glfw = @import("build_glfw.zig").build_glfw;
const build_glslang = @import("build_glslang.zig").build;
const build_msdf = @import("build_msdf.zig").build_msdf;
const zcc = @import("compile_commands.zig");

pub fn build(b: *std.Build) void {
    var targets = std.ArrayList(*std.Build.Step.Compile).init(b.allocator);
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "lovr",
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    targets.append(exe) catch @panic("OOM");

    const lua = build_lua.liblua(b, target, optimize, b.path("deps/lua"));
    exe.linkLibrary(lua);

    exe.addCSourceFiles(.{
        .root = b.path("src"),
        .files = &.{
            "main.c",
            "util.c",
            "core/os_win32.c",
            "core/gpu_vk.c",
            "core/spv.c",
            "core/job.c",
            "core/fs.c",
            "api/api.c",
            "api/l_event.c",
            "api/l_math.c",
            "api/l_math_vectors.c",
            "api/l_math_randomGenerator.c",
            "api/l_math_curve.c",
            "api/l_lovr.c",
            "api/l_headset.c",
            "api/l_headset_layer.c",
            "modules/headset/headset_simulator.c",
            "api/l_audio.c",
            "api/l_audio_source.c",
            "modules/audio/audio.c",
            "modules/audio/spatializer_simple.c",
            "api/l_graphics.c",
            "api/l_graphics_buffer.c",
            "api/l_graphics_pass.c",
            "api/l_graphics_font.c",
            "api/l_graphics_material.c",
            "api/l_graphics_mesh.c",
            "api/l_graphics_model.c",
            "api/l_graphics_readback.c",
            "api/l_graphics_sampler.c",
            "api/l_graphics_shader.c",
            "api/l_graphics_texture.c",
            "api/l_data.c",
            "api/l_data_image.c",
            "api/l_data_rasterizer.c",
            "api/l_data_modelData.c",
            "api/l_data_sound.c",
            "api/l_data_blob.c",
            "api/l_system.c",
            "api/l_thread.c",
            "api/l_thread_channel.c",
            "api/l_thread_thread.c",
            "api/l_timer.c",
            "api/l_filesystem.c",
            "api/l_filesystem_file.c",
            "api/l_event.c",
            "modules/data/modelData.c",
            "modules/data/modelData_gltf.c",
            "modules/data/modelData_obj.c",
            "modules/data/modelData_stl.c",
            "modules/data/image.c",
            "modules/data/blob.c",
            "modules/data/rasterizer.c",
            "modules/data/sound.c",
            "modules/graphics/graphics.c",
            "modules/event/event.c",
            "modules/thread/thread.c",
            "modules/math/math.c",
            "modules/system/system.c",
            "modules/timer/timer.c",
            "modules/filesystem/filesystem.c",
            "modules/headset/headset.c",
            "lib/luax/lutf8lib.c",
            "lib/jsmn/jsmn.c",
            "lib/stb/stb_image.c",
            "lib/stb/stb_truetype.c",
            "lib/stb/stb_vorbis.c",
            "lib/miniaudio/miniaudio.c",
            "lib/minimp3/minimp3.c",
            "lib/noise/simplexnoise1234.c",
            "lib/dmon/dmon.c",
            "lib/miniz/miniz_tinfl.c",
        },
        .flags = &.{
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
        },
    });
    exe.addIncludePath(b.path("src"));
    exe.addIncludePath(b.path("src/modules"));
    exe.addIncludePath(b.path("src/lib/std"));
    exe.addIncludePath(b.path("etc"));
    exe.addIncludePath(b.path("deps/vulkan-headers/include"));

    const ddx = build_ddx.build_exe(b);

    const boot_lua_h = build_ddx.to_header(b, ddx, "etc/boot.lua");
    exe.step.dependOn(&boot_lua_h.step);

    const ttf_h = build_ddx.to_header(b, ddx, "etc/VarelaRound.ttf");
    exe.step.dependOn(&ttf_h.step);

    const SHADERS = [_][]const u8{
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
    };
    for (SHADERS) |shd| {
        const h = build_ddx.to_header(b, ddx, shd);
        exe.step.dependOn(&h.step);
    }

    exe.linkLibrary(build_msdf(b, target, optimize));
    exe.linkLibrary(build_glfw(b, target, optimize));
    const glslang = build_glslang(b, target, optimize);
    exe.linkLibrary(glslang);
    // exe.addIncludePath(glslang.getEmittedIncludeTree().path(b, "Include"));
    // exe.addIncludePath(glslang.getEmittedIncludeTree().path(b, "PUblic"));
    exe.addIncludePath(b.path("deps/glslang/glslang/Include"));
    exe.addIncludePath(b.path("deps/glslang/glslang/Public"));

    exe.linkSystemLibrary("Dwmapi");
    exe.linkSystemLibrary("Ole32");
    exe.linkSystemLibrary("Gdi32");

    b.installArtifact(exe);

    // add a step called "cdb" (Compile commands DataBase) for making
    // compile_commands.json. could be named anything. cdb is just quick to type
    const cdb_step = zcc.createStep(b, "cdb", targets.toOwnedSlice() catch @panic("OOM"));

    // wait all code generations
    for (exe.step.dependencies.items) |d| {
        cdb_step.dependOn(d);
    }
    // cdb_step.dependOn(&boot_lua_h.run.step);
    // cdb_step.dependOn(&ttf_h.run.step);
    cdb_step.dependOn(&glslang.step);
}


