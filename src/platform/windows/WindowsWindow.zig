const win32 = @import("win32");
const std = @import("std");
const wino = @import("../../wino.zig");

const fundation = win32.foundation;
const window = win32.ui.windows_and_messaging;
const library_loader = win32.system.library_loader;

const unicode = std.unicode;
const toUtf16 = unicode.utf8ToUtf16LeAllocZ;

const Self = @This();
pub var hInstance: ?fundation.HINSTANCE = null;

hwnd: fundation.HWND,

pub const BackendCreateError = error{ ClassRegistrationError, WindowCreationError, InvalidUtf8 } || std.mem.Allocator.Error;
pub const BackendDestroyError = error{DestroyWindowError};

fn WNDPROC(
    hwnd: fundation.HWND,
    uMsg: u32,
    wParam: fundation.WPARAM,
    lParam: fundation.LPARAM,
) callconv(std.os.windows.WINAPI) fundation.LRESULT {
    switch (uMsg) {
        window.WM_CLOSE => {},
        window.WM_DESTROY => {
            window.PostQuitMessage(0);
            return 0;
        },
        window.WM_PAINT => {
            return 0;
        },
        else => {},
    }
    return window.DefWindowProc(hwnd, uMsg, wParam, lParam);
}

pub fn create(context: *wino.Context, options: wino.Window.Options, wino_window: *wino.Window) BackendCreateError!*Self {
    if (hInstance == null) {
        hInstance = library_loader.GetModuleHandle(null);
    }
    const className = try toUtf16(context.allocator, options.name);

    const wc = window.WNDCLASS{
        .lpfnWndProc = WNDPROC,
        .lpszClassName = className,
        .hInstance = hInstance,
        .cbClsExtra = 0,
        .cbWndExtra = 0,
        .hIcon = null,
        .hCursor = null,
        .hbrBackground = null,
        .lpszMenuName = null,
        .style = window.WNDCLASS_STYLES{},
    };

    const class = window.RegisterClass(&wc);
    if (class == 0) {
        const err = fundation.GetLastError();
        context.platformError.windows = err;
        wino.printError(context, "Got win32 Error while registering class: {}", .{err});
        return BackendCreateError.ClassRegistrationError;
    }

    const hwnd = window.CreateWindowEx(
        window.WINDOW_EX_STYLE{},
        className,
        className,
        window.WS_OVERLAPPEDWINDOW,
        if (options.pos.x != null) options.pos.x.? else window.CW_USEDEFAULT,
        if (options.pos.y != null) options.pos.y.? else window.CW_USEDEFAULT,
        if (options.size.x != null) options.size.x.? else window.CW_USEDEFAULT,
        if (options.size.y != null) options.size.y.? else window.CW_USEDEFAULT,
        null,
        null,
        hInstance,
        wino_window,
    );

    if (hwnd == null) {
        const err = fundation.GetLastError();
        context.platformError.windows = err;
        wino.printError(context, "Failed to create window: {}", .{err});
        return BackendCreateError.WindowCreationError;
    }

    const self: *Self = try context.allocator.create(Self);
    errdefer context.allocator.destroy(self);

    self.* = .{
        .hwnd = hwnd.?,
    };

    _ = window.ShowWindow(self.hwnd, window.SW_NORMAL);
    if (options.hide) {
        _ = window.ShowWindow(self.hwnd, window.SW_HIDE);
    }

    return self;
}

pub fn destory(self: *Self, context: *wino.Context) BackendDestroyError!void {
    if (window.DestroyWindow(self.hwnd) == 0) {
        const err = fundation.GetLastError();
        context.platformError.windows = err;
        wino.printError(context, "Failed to destroy window: {}", .{err});
        return BackendDestroyError.DestroyWindowError;
    }
    context.allocator.destroy(self);
}
