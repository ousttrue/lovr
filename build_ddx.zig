const std = @import("std");

pub fn build_exe(b: *std.Build) *std.Build.Step.Compile {
    const ddx = b.addExecutable(.{
        .target = b.graph.host,
        .name = "ddx",
        .root_source_file = b.path("ddx.zig"),
    });
    return ddx;
}

pub fn to_header(
    b: *std.Build,
    ddx: *std.Build.Step.Compile,
    src: []const u8,
) *std.Build.Step.Run {
    const run = b.addRunArtifact(ddx);
    // exe.step.dependOn(&run.step);
    run.addDirectoryArg(b.path(""));
    run.addArg(src);
    run.addFileArg(b.path(b.fmt("{s}.h", .{src})));
    return run;
}
