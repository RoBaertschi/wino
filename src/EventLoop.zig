const std = @import("std");
const Event = @import("EventLoop/Event.zig");

const Self = @This();

events: std.ArrayList(Event),

pub fn init(allocator: std.mem.Allocator) Self {
    return Self{
        .events = std.ArrayList(Event).init(allocator),
    };
}
