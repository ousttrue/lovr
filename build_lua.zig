const std = @import("std");

const files: []const []const u8 = &.{
    "deps/lua/lapi.c",
    "deps/lua/lauxlib.c",
    "deps/lua/lbaselib.c",
    "deps/lua/lcode.c",
    "deps/lua/ldblib.c",
    "deps/lua/ldebug.c",
    "deps/lua/ldo.c",
    "deps/lua/ldump.c",
    "deps/lua/lfunc.c",
    "deps/lua/lgc.c",
    "deps/lua/linit.c",
    "deps/lua/liolib.c",
    "deps/lua/llex.c",
    "deps/lua/lmathlib.c",
    "deps/lua/lmem.c",
    "deps/lua/loadlib.c",
    "deps/lua/lobject.c",
    "deps/lua/lopcodes.c",
    "deps/lua/loslib.c",
    "deps/lua/lparser.c",
    "deps/lua/lstate.c",
    "deps/lua/lstring.c",
    "deps/lua/lstrlib.c",
    "deps/lua/ltable.c",
    "deps/lua/ltablib.c",
    "deps/lua/ltm.c",
    "deps/lua/lundump.c",
    "deps/lua/lvm.c",
    "deps/lua/lzio.c",
};

const flags: []const []const u8 = &.{
    "-DWIN32",
    "-DLUA_USE_WINDOWS",
    "-D_WINDOWS",
    "-DUNICODE=1",
    "-D_UNICODE=1",
    "-DLUA_BUILD_AS_DLL=1",
    "-Dlua_EXPORTS",
    "-fno-sanitize=all",
};

pub fn build_lua(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) *std.Build.Step.Compile {
    const c = b.addSharedLibrary(.{
        .name = "lua",
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    c.addCSourceFiles(.{
        .files = files,
        .flags = flags,
    });
    c.addIncludePath(b.path("deps/lua"));
    c.installHeader(b.path("deps/lua/lua.h"), "lua.h");
    c.installHeader(b.path("deps/lua/luaconf.h"), "luaconf.h");
    c.installHeader(b.path("deps/lua/lauxlib.h"), "lauxlib.h");
    c.installHeader(b.path("deps/lua/lualib.h"), "lualib.h");

    return c;
}
