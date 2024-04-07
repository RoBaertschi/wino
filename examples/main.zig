const std = @import("std");
const wino = @import("wino");

pub fn main() !void {
    var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = general_purpose_allocator.allocator();
    var wino_context = wino.init(allocator, std.io.getStdOut(), true);
    var window = try wino.Window.create(&wino_context, .{
        .name = "Hello World",
    });
    defer window.destroy(&wino_context) catch std.debug.panic("Failed to destroy error: {}", .{wino_context.getLastError()});
}
