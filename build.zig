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

    // Allow undefined symbols - they will be resolved at runtime by the host application
    // This is essential for mods that reference functions/variables exported by the client
    lib.linker_allow_shlib_undefined = true;

    b.installArtifact(lib);
}
