const std = @import("std");
const Scanner = @import("zig-wayland").Scanner;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const wino = b.addModule("wino", .{
        .root_source_file = .{ .path = "src/wino.zig" },
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    const lib = b.addStaticLibrary(.{
        .root_source_file = .{ .path = "src/wino.zig" },
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .name = "wino",
    });

    wino.linkLibrary(lib);

    switch (target.result.os.tag) {
        .windows => {
            const zigwin32 = b.dependency("zigwin32", .{
                .target = target,
                .optimize = optimize,
            });
            // lib.root_module.addImport("win32", zigwin32.module("zigwin32"));
            wino.addImport("win32", zigwin32.module("zigwin32"));
        },
        .linux => {
            const scanner = Scanner.create(b, .{});
            const wayland = b.createModule(.{ .root_source_file = scanner.result });

            scanner.addSystemProtocol("stable/xdg-shell/xdg-shell.xml");

            scanner.generate("wl_shm", 1);
            scanner.generate("wl_compositor", 1);
            scanner.generate("xdg_wm_base", 1);

            wino.addImport("wayland", wayland);
            lib.linkSystemLibrary("wayland-client");
            scanner.addCSource(lib);
        },
        else => @panic("Unsupported target"),
    }

    const lib_unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/wino.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);

    addExample(b, wino, "main", "examples/main.zig", target, optimize);
}

fn addExample(b: *std.Build, lib: *std.Build.Module, comptime name: []const u8, source: []const u8, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) void {
    const exe = b.addExecutable(.{
        .name = name,
        .root_source_file = .{ .path = source },
        .target = target,
        .optimize = optimize,
    });

    exe.root_module.addImport("wino", lib);
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run-example-" ++ name, "Run the app");
    run_step.dependOn(&run_cmd.step);
}
