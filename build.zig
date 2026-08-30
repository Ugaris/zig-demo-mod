const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addSharedLibrary(.{
        .name = "bmod",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    if (target.result.os.tag == .windows) {
        // Windows mods must link the client's import library (lib/moac.lib
        // or lib/moac.a from the client release's mod-sdk.zip): PE has no
        // runtime resolution against the host executable, so a DLL with
        // unresolved client symbols crashes the game on the first API call.
        lib.addLibraryPath(b.path("lib"));
        lib.linkSystemLibrary("moac");
    } else {
        // ELF/Mach-O: symbols resolve against the client at load time.
        lib.linker_allow_shlib_undefined = true;
    }

    b.installArtifact(lib);
}
