const std = @import("std");

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
    for (DDX) |src| {
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
    exe.addIncludePath(b.path("src/modules"));
    exe.addIncludePath(b.path("src"));
    exe.addIncludePath(b.path("src/lib/std"));
    exe.addCSourceFiles(.{
        .files = &.{
            "src/main.c",
            "src/util.c",
            "src/core/os_win32.c",
            "src/api/api.c",
            "src/api/l_event.c",
            "src/api/l_math.c",
            "src/api/l_lovr.c",
            "src/modules/data/modelData.c",
            "src/modules/graphics/graphics.c",
        },
    });
    exe.addIncludePath(b.path("etc"));

    exe.linkSystemLibrary("Dwmapi");
    exe.linkSystemLibrary("Ole32");
}

const DDX = [_][]const u8{
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
};
