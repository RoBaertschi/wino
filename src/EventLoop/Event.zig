const wino = @import("../wino.zig");
const Window = wino.Window;

const Self = @This();

const EventType = enum { close };

window: *Window,
event: union(EventType) { close: void },
