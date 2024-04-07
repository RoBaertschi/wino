pub const Window = @import("window.zig");
pub const EventLoop = @import("EventLoop.zig");
pub const math = @import("math.zig");

const std = @import("std");
const builtin = @import("builtin");

const SupportedPlatforms = enum { windows };
const PlatformError = union(SupportedPlatforms) {
    windows: @import("win32").foundation.WIN32_ERROR,
};

pub const Context = struct {
    initalized: bool = false,
    out: ?std.fs.File = null,
    platformErrorLogging: bool = true,
    platformError: PlatformError,
    allocator: std.mem.Allocator,

    pub fn getLastError(self: Context) PlatformError {
        return self.platformError;
    }
};

pub const platform: SupportedPlatforms = switch (builtin.os.tag) {
    .windows => .windows,
    else => @compileError("Unsupported wino backend " ++ @tagName(builtin.os.tag)),
};

fn errorPrinting() void {
    std.debug.print("Error: could not print to user provided out", .{});
}

pub fn printError(context: *Context, comptime message: []const u8, args: anytype) void {
    if (!context.platformErrorLogging) {
        return;
    }
    var out = context.out;
    if (!context.initalized) {
        out = std.io.getStdErr();
    }

    var writer = out.?.writer();
    writer.print(message, args) catch return errorPrinting();

    if (!context.initalized) {
        writer.print("IMPORTANT WARNING: You did not initalize the library with 'wino.init()'", .{}) catch return errorPrinting();
    }
}

// The allocator is not used in this function but is used later for other stuff
pub fn init(allocator: std.mem.Allocator, out: std.fs.File, platformErrorLogging: bool) Context {
    return Context{
        .platformError = switch (platform) {
            .windows => .{ .windows = .NO_ERROR },
        },
        .initalized = true,
        .out = out,
        .allocator = allocator,
        .platformErrorLogging = platformErrorLogging,
    };
}
