//! Ugaris Zig Demo Mod
//!
//! A demonstration of native mod development using Zig.
//! Shows basic API usage: commands, rendering, and game data access.
//!
//! Commands:
//!   #hello   - Display a greeting message
//!   #stats   - Show current HP/Mana/Gold
//!   #overlay - Toggle a simple HUD overlay

const std = @import("std");

// ============================================================================
// Constants
// ============================================================================

const V_HP: usize = 0;
const V_MANA: usize = 2;
const V_WIS: usize = 3;
const V_INT: usize = 4;
const V_AGI: usize = 5;
const V_STR: usize = 6;
const V_MAX: usize = 200;
const DOT_TL: c_int = 0;

// Color helper (RGB 5-5-5)
fn irgb(r: u16, g: u16, b: u16) u16 {
    return (r << 10) | (g << 5) | b;
}

// ============================================================================
// FFI Declarations
// ============================================================================

// Logging functions (variadic in C, but we'll use single string versions)
extern fn note(format: [*:0]const u8, ...) c_int;
extern fn addline(format: [*:0]const u8, ...) void;

// Rendering
extern fn render_rect(sx: c_int, sy: c_int, ex: c_int, ey: c_int, color: u16) void;
extern fn render_line(fx: c_int, fy: c_int, tx: c_int, ty: c_int, color: u16) void;
extern fn render_text(sx: c_int, sy: c_int, color: u16, flags: c_int, text: [*:0]const u8) c_int;

// GUI helpers
extern fn dotx(didx: c_int) c_int;
extern fn doty(didx: c_int) c_int;

// Utilities
extern fn exp2level(val: c_int) c_int;

// Game state
extern var hp: c_int;
extern var mana: c_int;
extern var gold: c_int;
extern var experience: c_int;
extern var value: [2][V_MAX]c_int;
extern var username: [40]u8;

// Colors
extern var whitecolor: u16;
extern var textcolor: u16;
extern var healthcolor: u16;
extern var manacolor: u16;

// ============================================================================
// Mod State
// ============================================================================

var show_overlay: bool = false;
var frame_count: u32 = 0;

// Buffer for formatted strings
var format_buf: [256]u8 = undefined;

fn formatText(comptime fmt: []const u8, args: anytype) [*:0]const u8 {
    const slice = std.fmt.bufPrint(&format_buf, fmt, args) catch return "???";
    // Ensure null termination
    if (slice.len < format_buf.len) {
        format_buf[slice.len] = 0;
    }
    return @ptrCast(&format_buf);
}

// ============================================================================
// Mod Callbacks
// ============================================================================

export fn amod_version() [*:0]const u8 {
    return "Zig Demo Mod 1.0.0";
}

export fn amod_init() void {
    _ = note("Zig Demo Mod initializing...");
}

export fn amod_exit() void {
    _ = note("Zig Demo Mod shutting down.");
}

export fn amod_gamestart() void {
    // Get username as a Zig slice
    const name_slice = std.mem.sliceTo(&username, 0);
    _ = note("Zig Demo Mod: Game started! Welcome, %s", name_slice.ptr);
    addline("Zig Demo Mod loaded. Type #hello for commands.");
}

export fn amod_tick() void {
    // Called 24 times per second
}

export fn amod_frame() void {
    frame_count +%= 1;

    if (!show_overlay) {
        return;
    }

    const x = dotx(DOT_TL) + 10;
    const y = doty(DOT_TL) + 10;
    const w: c_int = 180;
    const h: c_int = 80;

    // Panel background
    render_rect(x, y, x + w, y + h, irgb(4, 4, 6));

    // Panel border
    const border_color = irgb(12, 12, 16);
    render_line(x, y, x + w, y, border_color);
    render_line(x, y + h, x + w, y + h, border_color);
    render_line(x, y, x, y + h, border_color);
    render_line(x + w, y, x + w, y + h, border_color);

    // Title
    _ = render_text(x + 4, y + 4, whitecolor, 0, "Zig Demo Mod");

    var text_y = y + 20;

    // HP
    _ = render_text(x + 4, text_y, healthcolor, 0, formatText("HP: {d} / {d}", .{ hp, value[0][V_HP] }));
    text_y += 14;

    // Mana
    _ = render_text(x + 4, text_y, manacolor, 0, formatText("Mana: {d} / {d}", .{ mana, value[0][V_MANA] }));
    text_y += 14;

    // Gold
    _ = render_text(x + 4, text_y, irgb(31, 31, 0), 0, formatText("Gold: {d}", .{gold}));
    text_y += 14;

    // Frame counter
    _ = render_text(x + 4, text_y, textcolor, 0, formatText("Frame: {d}", .{frame_count}));
}

export fn amod_mouse_move(x: c_int, y: c_int) void {
    _ = x;
    _ = y;
}

export fn amod_mouse_click(x: c_int, y: c_int, what: c_int) c_int {
    _ = x;
    _ = y;
    _ = what;
    return 0;
}

export fn amod_keydown(key: c_int) c_int {
    _ = key;
    return 0;
}

export fn amod_keyup(key: c_int) c_int {
    _ = key;
    return 0;
}

export fn amod_client_cmd(buf: [*:0]const u8) c_int {
    const cmd = std.mem.span(buf);

    if (std.mem.eql(u8, cmd, "#hello")) {
        addline("=== Zig Demo Mod Commands ===");
        addline("#hello   - Show this help");
        addline("#stats   - Display current stats");
        addline("#overlay - Toggle HUD overlay");
        return 1;
    }

    if (std.mem.eql(u8, cmd, "#stats")) {
        const level = exp2level(experience);
        addline("=== Player Stats (from Zig) ===");
        addline(formatText("Level: {d}  Experience: {d}", .{ level, experience }));
        addline(formatText("HP: {d}/{d}  Mana: {d}/{d}", .{ hp, value[0][V_HP], mana, value[0][V_MANA] }));
        addline(formatText("STR: {d}  AGI: {d}  INT: {d}  WIS: {d}", .{
            value[0][V_STR],
            value[0][V_AGI],
            value[0][V_INT],
            value[0][V_WIS],
        }));
        addline(formatText("Gold: {d}", .{gold}));
        return 1;
    }

    if (std.mem.eql(u8, cmd, "#overlay")) {
        show_overlay = !show_overlay;
        if (show_overlay) {
            addline("Overlay: ON");
        } else {
            addline("Overlay: OFF");
        }
        return 1;
    }

    return 0;
}
