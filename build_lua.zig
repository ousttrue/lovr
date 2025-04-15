const std = @import("std");

pub fn liblua(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    root: std.Build.LazyPath,
) *std.Build.Step.Compile {
    const c = b.addStaticLibrary(.{
        .name = "lua",
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    c.addCSourceFiles(.{
        .root = root,
        .files = &.{
            "lapi.c",
            "lcode.c",
            "ldebug.c",
            "ldo.c",
            "ldump.c",
            "lfunc.c",
            "lgc.c",
            "llex.c",
            "lmem.c",
            "lobject.c",
            "lopcodes.c",
            "lparser.c",
            "lstate.c",
            "lstring.c",
            "ltable.c",
            "ltm.c",
            "lundump.c",
            "lvm.c",
            "lzio.c",
            "lauxlib.c",
            "lbaselib.c",
            "ldblib.c",
            "liolib.c",
            "lmathlib.c",
            "loslib.c",
            "ltablib.c",
            "lstrlib.c",
            "loadlib.c",
            "linit.c",
        },
    });
    c.installHeader(root.path(b, "lua.h"), "lua.h");
    c.installHeader(root.path(b, "luaconf.h"), "luaconf.h");
    c.installHeader(root.path(b, "lauxlib.h"), "lauxlib.h");
    c.installHeader(root.path(b, "lualib.h"), "lualib.h");
    c.addIncludePath(root);

    return c;
}

// pub fn build(b: *std.Build) void {
//     const target = b.standardTargetOptions(.{});
//     const optimize = b.standardOptimizeOption(.{});
//
//     const exe = b.addExecutable(.{
//         .name = "lua",
//         .target = target,
//         .optimize = optimize,
//         .link_libc = true,
//     });
//     // This declares intent for the executable to be installed into the
//     // standard location when the user invokes the "install" step (the default
//     // step when running `zig build`).
//     b.installArtifact(exe);
//
//     const lib = liblua(b, target, optimize);
//     exe.linkLibrary(lib);
//     b.installArtifact(lib);
//
//     exe.addCSourceFiles(.{
//         .files = &.{
//             "lua.c",
//         },
//     });
// }
