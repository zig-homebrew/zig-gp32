const c = @import("gp32/c.zig");

export fn main(_: c_int, _: [*]const [*:0]const u8) void {
    var framebuffer: c_int = c.FRAMEBUFFER;
    c.gp_setCpuspeed(33);
    _ = c.gp_initFramebuffer(@ptrCast(*anyopaque, &framebuffer), 16, 80);
    c.gp_clearFramebuffer16(framebuffer, 0xFFFF);
    c.gp_drawString(10, 100, 12, "Hello, Zig"[0], 0xF800, @ptrCast(*anyopaque, &framebuffer));

    while (true) {}
}
