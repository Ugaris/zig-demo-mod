# Ugaris Zig Demo Mod

A native mod written in Zig demonstrating the Ugaris Client mod API. This showcases Zig's safety features, performance, and exceptional cross-compilation capabilities.

## Features

- **Safety** - Compile-time and runtime safety checks
- **Performance** - Zero-overhead abstractions, no hidden control flow
- **Cross-Compilation** - Build for any platform from any platform
- **C Interop** - Seamless interaction with C APIs

## Commands

| Command | Description |
|---------|-------------|
| `#hello` | Display available commands |
| `#stats` | Show current player stats |
| `#overlay` | Toggle the HUD overlay |

## Installation

### Via Ugaris Launcher

1. Open the Ugaris Launcher
2. Go to **Options > Developer > Enable Mod Manager**
3. Navigate to the **Mods** section
4. Click **Install from URL**
5. Enter: `ugaris/ugaris-zig-demo-mod`

## Building from Source

### Requirements

- Zig 0.13.0+ (download from [ziglang.org](https://ziglang.org/))

### Build Commands

```bash
# Debug build
zig build

# Release build
zig build -Doptimize=ReleaseFast

# Cross-compile for different targets
zig build -Doptimize=ReleaseFast -Dtarget=x86_64-windows
zig build -Doptimize=ReleaseFast -Dtarget=x86_64-macos
zig build -Doptimize=ReleaseFast -Dtarget=aarch64-macos
zig build -Doptimize=ReleaseFast -Dtarget=x86_64-linux
```

### Output Location

- `zig-out/lib/bmod.dll` (Windows)
- `zig-out/lib/libbmod.dylib` (macOS, rename to `bmod.dylib`)
- `zig-out/lib/libbmod.so` (Linux, rename to `bmod.so`)

## Project Structure

```
ugaris-zig-demo-mod/
├── .github/workflows/build.yml
├── src/
│   └── main.zig               # Main implementation
├── build.zig                  # Zig build configuration
├── mod.json
├── README.md
└── LICENSE
```

## Zig-Specific Considerations

### Exporting Functions

Use the `export` keyword for C-callable functions:

```zig
export fn amod_version() [*:0]const u8 {
    return "Zig Demo Mod 1.0.0";
}
```

### C Interop

Declare external C functions and variables:

```zig
extern fn note(format: [*:0]const u8, ...) c_int;
extern var hp: c_int;
```

### String Handling

Zig uses slices, C uses null-terminated pointers:

```zig
// Null-terminated string literal
const msg: [*:0]const u8 = "Hello";

// Convert C string to Zig slice
const cmd = std.mem.span(c_string);

// Compare strings
if (std.mem.eql(u8, cmd, "#hello")) { ... }
```

### Formatted Output

Use `std.fmt.bufPrint` with a buffer:

```zig
var buf: [256]u8 = undefined;
const text = std.fmt.bufPrint(&buf, "HP: {d}", .{hp}) catch "???";
```

## Why Zig for Mods?

1. **Best-in-Class Cross-Compilation** - Build for any OS from any OS
2. **No Hidden Control Flow** - Explicit is better than implicit
3. **Memory Safety** - Optional safety checks, no undefined behavior
4. **C ABI Compatible** - Direct interop without wrappers
5. **Small Binaries** - No runtime, minimal overhead

## Comparison with Other Languages

| Aspect | Zig | C | Rust |
|--------|-----|---|------|
| Cross-compile | Excellent | Difficult | Good |
| Binary size | Small | Small | Medium |
| Safety | Optional | None | Enforced |
| C interop | Native | Native | FFI |
| Learning curve | Medium | Low | High |

## License

MIT License - See [LICENSE](LICENSE) file for details.
