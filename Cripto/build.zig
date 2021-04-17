const std = @import("std");

const Builder = std.build.Builder;

const CrossTarget = std.zig.CrossTarget;
const Mode = std.builtin.Mode;

var target: CrossTarget = undefined;
var mode: Mode = undefined;

pub fn build(b: *Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    mode = b.standardReleaseOptions();

    myBuild(b, "main", "runs main.zig code (probably testing code)");
    myBuild(b, "gram-schmidt", "runs gram-schmidt code");
    myBuild(b, "lattice", "runs lattice code");
    myBuild(b, "gaussian-reduction", "runs gaussian-reduction code");
}

fn myBuild(b: *Builder, comptime name: []const u8, comptime description: []const u8) void {
    const exe = b.addExecutable(name, "src/" ++ name ++ ".zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step(name, description);
    run_step.dependOn(&run_cmd.step);
}
