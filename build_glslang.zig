// https://github.com/KhronosGroup/glslang/pull/3644
const std = @import("std");

const flags = [_][]const u8{
    "-DENABLE_OPT=0",
    "-Wshorten-64-to-32",
    "-fno-sanitize=undefined",
    "-std=c++17",
    "-fno-exceptions",
    "-fno-rtti",
};

pub fn config_build_info(b: *std.Build) *std.Build.Step.ConfigHeader {
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
    return glslang_build_info_h;
}

fn build_osdep(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    root: std.Build.LazyPath,
) *std.Build.Step.Compile {
    const c = b.addStaticLibrary(.{
        .name = "OSDependent",
        .target = target,
        .optimize = optimize,
    });
    c.linkLibCpp();
    c.addCSourceFiles(.{
        .root = root,
        .files = &.{
            "ossource.cpp",
        },
    });
    c.addIncludePath(root);
    return c;
}

fn build_limits(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    root: std.Build.LazyPath,
) *std.Build.Step.Compile {
    const c = b.addStaticLibrary(.{
        .name = "glslang-default-resource-limits",
        .target = target,
        .optimize = optimize,
    });
    c.linkLibCpp();
    c.addCSourceFiles(.{
        .root = root,
        .files = &.{
            "glslang/ResourceLimits/ResourceLimits.cpp",
            "glslang/ResourceLimits/resource_limits_c.cpp",
        },
    });
    c.addIncludePath(root);
    return c;
}

fn build_spirv(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    root: std.Build.LazyPath,
    build_info: *std.Build.Step.ConfigHeader,
) *std.Build.Step.Compile {
    const c = b.addStaticLibrary(.{
        .name = "SPIRV",
        .target = target,
        .optimize = optimize,
    });
    c.linkLibCpp();
    c.addConfigHeader(build_info);
    c.addCSourceFiles(.{
        .root = root,
        .files = &.{
            "GlslangToSpv.cpp",
            "InReadableOrder.cpp",
            "Logger.cpp",
            "SpvBuilder.cpp",
            "SpvPostProcess.cpp",
            "doc.cpp",
            "SpvTools.cpp",
            "disassemble.cpp",
            "CInterface/spirv_c_interface.cpp",
            // "SPVRemapper.cpp",
            // "doc.cpp",
        },
    });
    c.addIncludePath(root.path(b, ".."));
    return c;
}

// target_link_libraries(MachineIndependent PRIVATE OSDependent GenericCodeGen)
pub fn lib(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    root: std.Build.LazyPath,
    build_info: *std.Build.Step.ConfigHeader,
) *std.Build.Step.Compile {
    const c = b.addStaticLibrary(.{
        .name = "glslang",
        .target = target,
        .optimize = optimize,
    });
    c.linkLibCpp();

    c.addConfigHeader(build_info);
    c.addCSourceFiles(.{
        .root = root,
        .files = &.{
            "glslang/GenericCodeGen/CodeGen.cpp",
            "glslang/GenericCodeGen/Link.cpp",
            "glslang/CInterface/glslang_c_interface.cpp",
        },
    });
    c.addCSourceFiles(.{
        .root = b.path("deps/glslang/glslang/MachineIndependent"),
        .files = &.{
            // "glslang.y",
            "glslang_tab.cpp",
            "attribute.cpp",
            "Constant.cpp",
            "iomapper.cpp",
            "InfoSink.cpp",
            "Initialize.cpp",
            "IntermTraverse.cpp",
            "Intermediate.cpp",
            "ParseContextBase.cpp",
            "ParseHelper.cpp",
            "PoolAlloc.cpp",
            "RemoveTree.cpp",
            "Scan.cpp",
            "ShaderLang.cpp",
            "SpirvIntrinsics.cpp",
            "SymbolTable.cpp",
            "Versions.cpp",
            "intermOut.cpp",
            "limits.cpp",
            "linkValidate.cpp",
            "parseConst.cpp",
            "reflection.cpp",
            "preprocessor/Pp.cpp",
            "preprocessor/PpAtom.cpp",
            "preprocessor/PpContext.cpp",
            "preprocessor/PpScanner.cpp",
            "preprocessor/PpTokens.cpp",
            "propagateNoContraction.cpp",
        },
    });

    c.addIncludePath(root);

    c.installHeadersDirectory(b.path("deps/glslang/glslang/Include"), "Include", .{});
    c.installHeadersDirectory(b.path("deps/glslang/glslang/Public"), "PUblic", .{});

    return c;
}

// set(LIBRARIES
//     glslang
//
// if(WIN32)
//     set(LIBRARIES ${LIBRARIES} psapi)
pub fn standalone(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    root: std.Build.LazyPath,
    build_info: *std.Build.Step.ConfigHeader,
    glslang: *std.Build.Step.Compile,
) *std.Build.Step.Compile {
    const exe = b.addExecutable(.{
        .name = "glslangValidator",
        .target = target,
        .optimize = optimize,
    });
    exe.addConfigHeader(build_info);
    exe.addCSourceFiles(.{
        .root = root,
        .files = &.{
            "StandAlone/StandAlone.cpp",
        },
        .flags = &flags,
    });
    exe.linkLibCpp();
    exe.addIncludePath(root);
    exe.linkLibrary(glslang);
    exe.linkLibrary(build_limits(b, target, optimize, root));
    exe.linkLibrary(build_osdep(b, target, optimize, root.path(b, "glslang/OSDependent/Windows")));
    exe.linkLibrary(build_spirv(b, target, optimize, root.path(b, "SPIRV"), build_info));
    exe.linkSystemLibrary("psapi");

    const py = b.addSystemCommand(&.{"py"});
    py.addFileArg(root.path(b, "gen_extension_headers.py"));
    py.addArg("-i");
    py.addDirectoryArg(root.path(b, "glslang/ExtensionHeaders"));
    py.addArg("-o");
    const glsl_intrinsic_header_h = py.addOutputFileArg("glslang/glsl_intrinsic_header.h");
    exe.addIncludePath(glsl_intrinsic_header_h.dirname().dirname());

    return exe;
}

pub fn make_header(
    b: *std.Build,
    glslang_standalone: *std.Build.Step.Compile,
    path: []const u8,
    name: []const u8,
    is_debug: bool,
) *std.Build.Step.Run {
    const run = b.addRunArtifact(glslang_standalone);
    if (is_debug) {
        run.addArg("-gVS");
    }
    run.addArgs(&.{
        "--quiet",
        "--target-env",
        "vulkan1.1",
        "--vn",
        name,
        "-o",
    });
    run.addFileArg(b.path(b.fmt("{s}.h", .{path})));
    run.addFileArg(b.path(path));
    return run;
}
