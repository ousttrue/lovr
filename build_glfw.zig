const std = @import("std");

pub fn build_glfw(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
) *std.Build.Step.Compile {
    const c = b.addStaticLibrary(.{
        .name = "glfw",
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    c.addCSourceFiles(.{
        .root = b.path("deps/glfw/src"),
        .files = &.{
            "context.c",
            "init.c",
            "input.c",
            "monitor.c",
            "platform.c",
            "vulkan.c",
            "window.c",
            "egl_context.c",
            "osmesa_context.c",
            "null_init.c",
            "null_monitor.c",
            "null_window.c",
            "null_joystick.c",
            "win32_module.c",
            "win32_time.c",
            "win32_thread.c",
            "win32_init.c",
            "win32_joystick.c",
            "win32_monitor.c",
            "win32_window.c",
            "wgl_context.c",
        },
        .flags = &.{
            "-D_GLFW_WIN32",
        },
    });

    c.installHeader(b.path("deps/glfw/include/GLFW/glfw3.h"), "GLFW/glfw3.h");
    c.installHeader(b.path("deps/glfw/include/GLFW/glfw3native.h"), "GLFW/glfw3native.h");

    return c;
}
