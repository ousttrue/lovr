const std = @import("std");

const FILES = .{
    "src/main.c",
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
};

const FLAGS = .{
    "-D_WIN32",
    "-DLOVR_DISABLE_AUDIO",
    // "-DLOVR_DISABLE_DATA",
    // "-DLOVR_DISABLE_EVENT",
    // "-DLOVR_DISABLE_FILESYSTEM",
    // "-DLOVR_DISABLE_GRAPHICS",
    "-DLOVR_DISABLE_HEADSET",
    // "-DLOVR_DISABLE_MATH",
    "-DLOVR_DISABLE_PHYSICS",
    // "-DLOVR_DISABLE_SYSTEM",
    // "-DLOVR_DISABLE_THREAD",
    // "-DLOVR_DISABLE_TIMER",
    // "-DLOVR_DISABLE_UTF8",
    "-DMSDFGEN_PUBLIC=",
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

    const lang: []const u8 = "luajit";
    const lua_dep = b.dependency("ziglua", .{
        .target = target,
        .optimize = optimize,
        .lang = lang,
    });
    const luajit = lua_dep.artifact("lua");

    const exe = b.addExecutable(.{
        .name = "lovr",
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(exe);

    const ddx = b.addExecutable(.{
        .target = b.host,
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

    exe.linkLibrary(luajit);
    exe.addIncludePath(luajit.getEmittedIncludeTree());
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

    exe.linkSystemLibrary("Dwmapi");
    exe.linkSystemLibrary("Ole32");
}
