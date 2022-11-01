// multiboot and "kernel" code

const vga = @import("vga.zig");

const MultiBoot = packed struct {
    magic: c_long,
    flags: c_long,
    checksum: c_long,
};

const ALIGN = 1 << 0;
const MEMINFO = 1 << 1;
const MAGIC = 0x1badb002;
const FLAGS = ALIGN|MEMINFO;

export var multiboot align(4) linksection(".multiboot") = MultiBoot{
    .magic = MAGIC,
    .flags = FLAGS,
    .checksum = -(MAGIC + FLAGS),
};

export var stack_bytes: [16 * 1024]u8 align(16) linksection(".bss") = undefined;
const stack_bytes_slice = stack_bytes[0..];

export fn _start() callconv(.Naked) noreturn {
    @call(.{ .stack = stack_bytes_slice }, kernel_main, .{});

    while (true) {}
}

fn kernel_main() void {
    vga.terminal.clear();
    vga.terminal.set_color(.light_blue, .black);
    vga.terminal.write("user");
    vga.terminal.set_color(.green, .black);
    vga.terminal.write(">");
}

