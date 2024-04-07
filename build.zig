const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addModule("wino", .{
        .root_source_file = .{ .path = "src/wino.zig" },
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    const zigwin32 = b.dependency("zigwin32", .{
        .target = target,
        .optimize = optimize,
    });
    // lib.root_module.addImport("win32", zigwin32.module("zigwin32"));
    lib.addImport("win32", zigwin32.module("zigwin32"));

    const lib_unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/wino.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);

    addExample(b, lib, "main", "examples/main.zig", target, optimize);
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
