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
        // .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(exe);

    // exe.linkLibrary(luajit);
    exe.addIncludePath(luajit.getEmittedIncludeTree());
    exe.linkLibC();
    exe.addIncludePath(b.path("src/modules"));

    to_hex(b, exe, b.path("etc/boot.lua"), "etc_boot_lua", "boot.lua.h");
    // exe.addCSourceFile(.{
    //     .file = boot_lua_h,
    // });
    exe.addCSourceFiles(.{
        .files = &.{
            "src/main.c",
        },
    });
}

fn to_hex(b: *std.Build, exe: *std.Build.Step.Compile, src: std.Build.LazyPath, array_name: []const u8, dst: []const u8) void {
    const ddx = b.addExecutable(.{
        .target = b.host,
        .name = "ddx",
        .root_source_file = b.path("ddx.zig"),
    });
    const run = b.addRunArtifact(ddx);
    exe.step.dependOn(&run.step);
    run.addFileArg(src);
    run.addArg(array_name);
    const generated = run.addOutputFileArg(dst);
    exe.addIncludePath(generated.dirname());
}
