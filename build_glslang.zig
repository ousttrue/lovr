const std = @import("std");

const flags = [_][]const u8{
    "-DENABLE_OPT=1",
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

pub fn lib(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    build_info: *std.Build.Step.ConfigHeader,
) *std.Build.Step.Compile {
    const root = b.path("deps/glslang");

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
            "glslang/ResourceLimits/ResourceLimits.cpp",
            "glslang/ResourceLimits/resource_limits_c.cpp",
        },
    });
    c.addCSourceFiles(.{
        .root = root.path(b, "SPIRV"),
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
            "SPVRemapper.cpp",
            "doc.cpp",
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

pub fn standalone(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    glslang: *std.Build.Step.Compile,
) *std.Build.Step.Compile {
    const exe = b.addExecutable(.{
        .name = "glslang-standalone",
        .target = target,
        .optimize = optimize,
    });
    const root = b.path("deps/glslang");
    exe.addCSourceFiles(.{
        .root = root,
        .files = &.{
            "StandAlone/StandAlone.cpp",
            "glslang/OSDependent/Windows/ossource.cpp",
        },
        .flags = &flags,
    });
    exe.linkLibCpp();
    exe.addIncludePath(root);
    exe.linkLibrary(glslang);

    const py = b.addSystemCommand(&.{"py"});
    py.addFileArg(root.path(b, "gen_extension_headers.py"));
    py.addArg("-i");
    py.addDirectoryArg(root.path(b, "glslang/ExtensionHeaders"));
    py.addArg("-o");
    const glsl_intrinsic_header_h = py.addOutputFileArg("glslang/glsl_intrinsic_header.h");
    exe.addIncludePath(glsl_intrinsic_header_h.dirname().dirname());

    return exe;
}
