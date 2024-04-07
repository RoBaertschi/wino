const std = @import("std");
const os = @import("builtin").os;
const wino = @import("wino.zig");

pub const Options = struct {
    name: []const u8,
    hide: bool = false,
    pos: wino.math.Vec2(?i32) = .{ .x = null, .y = null },
    size: wino.math.Vec2(?i32) = .{ .x = null, .y = null },
};

const WindowBackendEnum = enum { windows };

const WindowBackend = switch (wino.platform) {
    .windows => @import("platform/windows/WindowsWindow.zig"),
};

pub const CreateWindowError = WindowBackend.BackendCreateError;
pub const DestroyWindowError = WindowBackend.BackendDestroyError;

const Window = @This();

backend: *WindowBackend,
event_loop: wino.EventLoop,

pub inline fn create(context: *wino.Context, options: Options) CreateWindowError!*Window {
    const window = try context.allocator.create(Window);
    errdefer context.allocator.destroy(window);

    window.* = .{
        .backend = try WindowBackend.create(context, options, window),
    };

    return window;
}

pub inline fn destroy(self: *Window, context: *wino.Context) DestroyWindowError!void {
    try self.backend.destory(context);
    context.allocator.destroy(self);
}
