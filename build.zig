const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const mode = b.standardReleaseOptions();
    const target = .{ .cpu_arch = .i386, .os_tag = .freestanding };

    const os = b.addExecutable("os.elf", "src/kernel.zig");
    os.setLinkerScriptPath(.{ .path = "linker.ld" });
    os.code_model = .kernel;
    os.want_lto = false;
    os.setBuildMode(mode);
    os.setTarget(target);
    os.install();

    const run_cmd = b.addSystemCommand(&.{
        "qemu-system-i386",
        "-kernel",
        "zig-out/bin/os.elf",
        "-machine",
        "type=pc-i440fx-3.1",
    });
    run_cmd.step.dependOn(&os.install_step.?.step);

    const run_step = b.step("run", "run in QEMU");
    run_step.dependOn(&run_cmd.step);
}

