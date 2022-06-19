const std = @import("std");
const builtin = @import("builtin");

const flags = .{"-lmirkoSDK"};
const devkitpro = "/opt/devkitpro";

pub fn build(b: *std.build.Builder) void {
    const mode = b.standardReleaseOptions();

    const obj = b.addObject("zig-gp32", "src/main.zig");
    obj.setOutputDir("zig-out");
    obj.linkLibC();
    obj.setLibCFile(std.build.FileSource{ .path = "libc.txt" });
    obj.addIncludeDir(devkitpro ++ "/libmirko/include");
    obj.addIncludeDir(devkitpro ++ "/portlibs/gp32/include");
    obj.addIncludeDir(devkitpro ++ "/portlibs/armv4/include");
    obj.setTarget(.{
        .cpu_arch = .thumb,
        .os_tag = .freestanding,
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.arm9tdmi },
    });
    obj.setBuildMode(mode);

    const extension = if (builtin.target.os.tag == .windows) ".exe" else "";
    const elf = b.addSystemCommand(&(.{
        devkitpro ++ "/devkitARM/bin/arm-none-eabi-gcc" ++ extension,
        "-g",
        "-mthumb",
        "-mthumb-interwork",
        "-Wl,-Map,zig-out/zig-gp32.map",
        "-specs=" ++ devkitpro ++ "/devkitARM/arm-none-eabi/lib/gp32.specs",
        "zig-out/zig-gp32.o",
        "-L" ++ devkitpro ++ "/libmirko/lib",
        "-L" ++ devkitpro ++ "/portlibs/gp32/lib",
        "-L" ++ devkitpro ++ "/portlibs/armv4/lib",
    } ++ flags ++ .{
        "-o",
        "zig-out/zig-gp32.elf",
    }));

    const bin = b.addSystemCommand(&.{
        devkitpro ++ "/devkitARM/bin/arm-none-eabi-objcopy",
        "-O",
        "binary",
        "zig-out/zig-gp32.elf",
        "zig-out/zig-gp32.bin",
    });

    const fxe = b.addSystemCommand(&.{
        devkitpro ++ "/tools/bin/b2fxec",
        "zig-out/zig-gp32.bin",
        "zig-out/zig-gp32.fxe",
    });
    fxe.stdout_action = .ignore;

    b.default_step.dependOn(&fxe.step);
    fxe.step.dependOn(&bin.step);
    bin.step.dependOn(&elf.step);
    elf.step.dependOn(&obj.step);
}
