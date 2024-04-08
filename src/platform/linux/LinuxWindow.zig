const wino = @import("../../wino.zig");
const wayland = @import("wayland");
const std = @import("std");
const wl = wayland.client.wl;
const xdg = wayland.client.xdg;

const Self = @This();

pub const BackendCreateError = error{} || std.mem.Allocator.Error;
pub const BackendDestroyError = error{} || std.mem.Allocator.Error;

pub fn create(context: *wino.Context, _: wino.Window.Options, _: *wino.Window) BackendCreateError!*Self {
    const self: *Self = try context.allocator.create(Self);
    errdefer context.allocator.destroy(self);

    return self;
}

pub fn destory(self: *Self, context: *wino.Context) BackendDestroyError!void {
    context.allocator.destroy(self);
}
