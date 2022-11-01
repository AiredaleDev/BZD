const VGA_WIDTH = 80;
const VGA_HEIGHT = 25;

pub const COLOR = enum(u8) {
    black,
    blue, green, cyan, red, magenta, brown,
    light_grey, dark_grey,
    light_blue, light_green, light_cyan, light_red, light_magenta, light_brown,
    white,
};

pub const terminal = struct {
    var row: usize = 0; var column: usize = 0; var color: u16 = 0x0F;
    const buffer = @intToPtr([*]volatile u16, 0xb8000);

    pub fn clear() void { var i: usize = 0;
        while (i < VGA_WIDTH * VGA_HEIGHT) : (i += 1) {
            buffer[i] = color << 8 | ' ';
        }
    }

    fn new_line() void {
        row += 1;
        column = 0;
    }

    fn inc_cursor() void {
        column += 1;
        if (column >= VGA_WIDTH) {
            new_line();
        }
    }

    pub fn write(text: []const u8) void {
        for (text) |byte| {
            if (byte == '\n') new_line() else {
                const i = row * VGA_WIDTH + column;
                buffer[i] = color << 8 | @as(u16, byte);
                inc_cursor();
            }
        }
        move_cursor(row, column);
    }

    pub fn move_cursor(crow: usize, ccol: usize) void {
        const pos = crow * VGA_WIDTH + ccol;
        outb(0x3d4, 0x0f);
        outb(0x3d5, @truncate(u8, pos));
        outb(0x3d4, 0x0e);
        outb(0x3d5, @truncate(u8, pos >> 8));
    }

    pub fn set_color(foreground: COLOR, background: COLOR) void {
        color = @enumToInt(background) << 4 | @enumToInt(foreground);
    }

    inline fn inb(port: u16) u8 {
        return asm volatile ("inb %[port], %[result]"
            : [result] "={al}" (-> u8),
            : [port] "N{dx}" (port),
        );
    }

    inline fn outb(port: u16, value: u8) void {
        asm volatile ("outb %[value], %[port]"
            :
            : [port] "N{dx}" (port),
              [value] "{al}" (value),
        );
    }
};

