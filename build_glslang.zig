const std = @import("std");

const flags = [_][]const u8{
    "-DENABLE_OPT=1",
};

fn config_build_info(b: *std.Build) *std.Build.Step.ConfigHeader {
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

pub fn build(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
) *std.Build.Step.Compile {
    const build_info = config_build_info(b);
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

    // const py = b.addSystemCommand(&.{"py"});
    // py.addFileArg(b.path("gen_extension_headers.py"));
    // py.addArg("-i");
    // py.addDirectoryArg(b.path("glslang/ExtensionHeaders"));
    // py.addArg("-o");
    // const glsl_intrinsic_header_h = py.addOutputFileArg("glslang/glsl_intrinsic_header.h");
    // // glslang/glsl_intrinsic_header.h
    // // glsl_intrinsic_header.h
    // // set(GLSLANG_INTRINSIC_H          "${GLSLANG_GENERATED_INCLUDEDIR}/glslang/glsl_intrinsic_header.h")
    // // set(GLSLANG_INTRINSIC_PY         "${CMAKE_CURRENT_SOURCE_DIR}/../gen_extension_headers.py")
    // // set(GLSLANG_INTRINSIC_HEADER_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../glslang/ExtensionHeaders")

    // // add_custom_command(
    // //     OUTPUT  ${GLSLANG_INTRINSIC_H}
    // //     COMMAND Python3::Interpreter "${GLSLANG_INTRINSIC_PY}"
    // //             "-i" ${GLSLANG_INTRINSIC_HEADER_DIR}
    // //             "-o" ${GLSLANG_INTRINSIC_H}
    // //     DEPENDS ${GLSLANG_INTRINSIC_PY}
    // //     COMMENT "Generating ${GLSLANG_INTRINSIC_H}")
    // exe.step.dependOn(&py.step);
    // exe.addIncludePath(glsl_intrinsic_header_h.dirname().dirname());

    // c.linkLibrary(build_limits(b, target, optimize));
    // const machine_independent = build_machine_independent(b, target, optimize);
    // machine_independent.addConfigHeader(build_info);
    // exe.linkLibrary(machine_independent);
    // const spirv = build_spirv(b, target, optimize);
    // spirv.addConfigHeader(build_info);
    // exe.linkLibrary(spirv);
    //
    // b.installArtifact(exe);
    return c;
}

// exe.addCSourceFiles(.{
//     .files = &.{
//         "StandAlone/StandAlone.cpp",
//     },
//     .flags = &flags,
// });
// exe.linkLibCpp();
// exe.addIncludePath(b.path(""));
// exe.addConfigHeader(build_info);
