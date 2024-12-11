const std = @import("std");

pub fn main() !void {
    var arena_state = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    const args = try std.process.argsAlloc(arena);

    if (args.len != 4) fatal("wrong number of arguments", .{});

    const input_file_path = args[1];
    var input_file = try std.fs.cwd().openFile(input_file_path, .{});
    defer input_file.close();
    const stat = try input_file.stat();
    var buf = try arena.alloc(u8, stat.size);
    const size = try input_file.readAll(buf);

    const array_name = args[2];

    const output_file_path = args[3];
    std.debug.print("output_file_path => {s}\n", .{output_file_path});
    var output_file = try std.fs.cwd().createFile(output_file_path, .{});
    defer output_file.close();
    std.debug.print("{s}\n", .{output_file_path});

    var tmp: [1024]u8 = undefined;
    _ = try output_file.write(try std.fmt.bufPrint(&tmp, "const unsigned char {s}[] = {{", .{array_name}));
    for (buf[0..size]) |x| {
        _ = try output_file.write(try std.fmt.bufPrint(&tmp, "0x{x},", .{x}));
    }
    _ = try output_file.write("};\n");
    _ = try output_file.write(try std.fmt.bufPrint(&tmp, "int {s}_len = {};\n", .{ array_name, stat.size }));
    return std.process.cleanExit();
}

fn fatal(comptime format: []const u8, args: anytype) noreturn {
    std.debug.print(format, args);
    std.process.exit(1);
}
