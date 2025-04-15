const std = @import("std");

pub fn build_msdf(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
) *std.Build.Step.Compile {
    const c = b.addStaticLibrary(.{
        .name = "msdf",
        .target = target,
        .optimize = optimize,
    });
    c.addCSourceFiles(.{
        .root = b.path("deps/msdfgen"),
        .files = &FILES,
        .flags = &.{
            "-DMSDFGEN_PUBLIC=",
        },
    });
    c.linkLibCpp();
    c.installHeader(b.path("deps/msdfgen/msdfgen-c.h"), "msdfgen-c.h");

    return c;
}

const FILES = [_][]const u8{
    "core/Contour.cpp",
    "core/EdgeHolder.cpp",
    "core/MSDFErrorCorrection.cpp",
    "core/Projection.cpp",
    "core/Scanline.cpp",
    "core/Shape.cpp",
    "core/SignedDistance.cpp",
    "core/Vector2.cpp",
    "core/contour-combiners.cpp",
    "core/edge-coloring.cpp",
    "core/edge-segments.cpp",
    "core/edge-selectors.cpp",
    "core/equation-solver.cpp",
    "core/msdf-error-correction.cpp",
    "core/msdfgen-c.cpp",
    "core/msdfgen.cpp",
    "core/rasterization.cpp",
    "core/render-sdf.cpp",
    "core/sdf-error-estimation.cpp",
    "core/shape-description.cpp",
    "ext/resolve-shape-geometry.cpp",
    "ext/save-png.cpp",
    // "deps/msdfgen/ext/import-font.cpp",
    // "deps/msdfgen/ext/import-svg.cpp",
};
