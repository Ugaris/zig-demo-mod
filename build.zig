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

    // Allow undefined symbols (they'll be resolved by the host application)
    lib.linker_module.pic = true;

    b.installArtifact(lib);

    // Add a run step for testing
    const run_cmd = b.addRunArtifact(lib);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the library");
    run_step.dependOn(&run_cmd.step);
}
