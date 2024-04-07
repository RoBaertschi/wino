const std = @import("std");
const Event = @import("EventLoop/Event.zig");

const Self = @This();

events: std.ArrayList(Event),

pub fn init() Self {}
