// https://github.com/KhronosGroup/glslang/pull/3644
const std = @import("std");

const flags = [_][]const u8{
    "-DENABLE_SPIRV=1",
    "-DENABLE_OPT=0",
    "-std=c++17",
    "-fno-exceptions",
    "-fno-rtti",
};

fn config_build_info(b: *std.Build) *std.Build.Step.ConfigHeader {
    // 15.2.0 2024-02-24
    const glslang_build_info_h = b.addConfigHeader(.{
        .style = .{
            .cmake = b.path("deps/glslang/build_info.h.tmpl"),
        },
        .include_path = "glslang/build_info.h",
    }, .{
        .major = "15",
        .minor = "2",
        .patch = "0",
        .flavor = "2024-02-24",
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

fn build_generic_codegen(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    root: std.Build.LazyPath,
) *std.Build.Step.Compile {
    const c = b.addStaticLibrary(.{
        .name = "GenericCodeGen",
        .target = target,
        .optimize = optimize,
    });
    c.linkLibCpp();
    c.addCSourceFiles(.{
        .root = root,
        .files = &.{
            "CodeGen.cpp",
            "Link.cpp",
        },
        .flags = &flags,
    });
    c.addIncludePath(root);
    return c;
}

fn build_machine_independent(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    root: std.Build.LazyPath,
    build_info: *std.Build.Step.ConfigHeader,
) *std.Build.Step.Compile {
    const c = b.addStaticLibrary(.{
        .name = "MachineIndependent",
        .target = target,
        .optimize = optimize,
    });
    c.linkLibCpp();
    c.addCSourceFiles(.{
        .root = root,
        .files = &.{
            // MachineIndependent/glslang.y
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
        .flags = &flags,
    });
    c.addIncludePath(root);
    c.addIncludePath(root.dirname().dirname());
    c.addConfigHeader(build_info);
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
        .flags = &flags,
    });
    c.addIncludePath(root.path(b, ".."));
    return c;
}

// target_link_libraries(MachineIndependent PRIVATE OSDependent GenericCodeGen)
fn lib(
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
            "glslang/CInterface/glslang_c_interface.cpp",
        },
    });
    c.addIncludePath(root);
    c.linkLibrary(build_machine_independent(b, target, optimize, root.path(b, "glslang/MachineIndependent"), build_info));
    c.installHeadersDirectory(b.path("deps/glslang/glslang/Include"), "Include", .{});
    c.installHeadersDirectory(b.path("deps/glslang/glslang/Public"), "PUblic", .{});

    return c;
}

// set(LIBRARIES
//     glslang
//
// if(WIN32)
//     set(LIBRARIES ${LIBRARIES} psapi)
fn standalone(
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

pub fn build(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    root: std.Build.LazyPath,
) struct { lib: *std.Build.Step.Compile, standalone: *std.Build.Step.Compile } {
    const build_info = config_build_info(b);

    const glslang_lib = lib(b, target, optimize, root, build_info);
    glslang_lib.linkLibrary(build_osdep(b, target, optimize, root.path(b, "glslang/OSDependent/Windows")));
    glslang_lib.linkLibrary(build_generic_codegen(b, target, optimize, root.path(b, "glslang/GenericCodeGen")));
    glslang_lib.linkLibrary(build_limits(b, target, optimize, root));
    glslang_lib.linkLibrary(build_spirv(b, target, optimize, root.path(b, "SPIRV"), build_info));

    const glslang_standalone = standalone(
        b,
        target,
        optimize,
        root,
        build_info,
        glslang_lib,
    );

    return .{ .lib = glslang_lib, .standalone = glslang_standalone };
}
