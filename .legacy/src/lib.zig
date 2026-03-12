const std = @import("std");
const builtin = @import("builtin");
const posix = std.posix;

/// Terminal size in rows and columns
pub const TerminalSize = struct {
    rows: u16,
    cols: u16,
};

/// Maximum trail length for a column
pub const MAX_TRAIL_LENGTH: usize = 25;

/// Character pool for digital rain (numbers 0-9)
pub const CHAR_POOL = "0123456789";

/// Digital rain column
pub const Column = struct {
    x: u16, // Column position (horizontal)
    y: i32, // Current head position (vertical, can be negative when starting)
    length: u8, // Trail length
    speed: u8, // Fall speed (frames to wait between moves)
    frame_count: u8, // Current frame counter for speed control
    chars: [MAX_TRAIL_LENGTH]u8, // Characters in the column
};

// ANSI escape codes for terminal control
pub const CLEAR_SCREEN = "\x1b[2J\x1b[H"; // Clear screen + move cursor to home
pub const HIDE_CURSOR = "\x1b[?25l"; // Hide cursor
pub const SHOW_CURSOR = "\x1b[?25h"; // Show cursor
pub const ALT_SCREEN_ENTER = "\x1b[?1049h"; // Enter alternate screen buffer
pub const ALT_SCREEN_EXIT = "\x1b[?1049l"; // Exit alternate screen buffer
pub const WHITE = "\x1b[1;97m"; // Bright white (for head)
pub const BRIGHT_GREEN = "\x1b[1;92m"; // Bold bright green
pub const GREEN = "\x1b[92m"; // Bright green (no bold)
pub const NORMAL_GREEN = "\x1b[32m"; // Normal green
pub const DARK_GREEN = "\x1b[2;92m"; // Dim bright green
pub const DARKER_GREEN = "\x1b[2;32m"; // Dim normal green
pub const RESET_COLOR = "\x1b[0m"; // Reset all attributes

/// Platform-specific termios type
pub const Termios = if (builtin.os.tag == .windows)
    struct {} // Dummy struct for Windows
else
    posix.termios;

/// Initialize terminal for Matrix display (raw mode, hide cursor)
/// Returns the original termios settings for later restoration
pub fn initTerminal() !Termios {
    if (builtin.os.tag == .windows) {
        // On Windows, just use ANSI codes (modern Windows Terminal supports them)
        std.debug.print("{s}{s}{s}", .{ ALT_SCREEN_ENTER, HIDE_CURSOR, CLEAR_SCREEN });
        return .{};
    } else {
        // Unix/POSIX systems
        const stdin_fd = posix.STDIN_FILENO;

        // Get current terminal settings
        const original_termios = try posix.tcgetattr(stdin_fd);
        var raw = original_termios;

        // Configure raw mode
        raw.lflag.ICANON = false; // Disable canonical mode (line buffering)
        raw.lflag.ECHO = false; // Disable echo
        raw.lflag.ISIG = false; // Disable signal generation (Ctrl+C, etc)
        raw.cc[@intFromEnum(posix.V.MIN)] = 0; // Minimum bytes for read
        raw.cc[@intFromEnum(posix.V.TIME)] = 0; // Timeout for read (deciseconds)

        // Apply new settings
        try posix.tcsetattr(stdin_fd, .FLUSH, raw);

        // Enter alternate screen, hide cursor, and clear screen
        std.debug.print("{s}{s}{s}", .{ ALT_SCREEN_ENTER, HIDE_CURSOR, CLEAR_SCREEN });

        return original_termios;
    }
}

/// Get terminal size (rows and columns)
/// Returns default 24x80 if detection fails
pub fn getTerminalSize() TerminalSize {
    if (builtin.os.tag == .windows) {
        // On Windows, return a reasonable default
        // TODO: Use Windows Console API (GetConsoleScreenBufferInfo) for actual size
        return TerminalSize{
            .rows = 24,
            .cols = 80,
        };
    } else {
        // Unix/POSIX systems
        const stdout_fd = posix.STDOUT_FILENO;

        var winsize: posix.winsize = undefined;
        const result = std.posix.system.ioctl(stdout_fd, std.posix.system.T.IOCGWINSZ, @intFromPtr(&winsize));

        if (result == 0 and winsize.row > 0 and winsize.col > 0) {
            return TerminalSize{
                .rows = winsize.row,
                .cols = winsize.col,
            };
        }

        // Fallback to default size
        return TerminalSize{
            .rows = 24,
            .cols = 80,
        };
    }
}

/// Get a random character from the character pool
pub fn randomChar(rng: std.Random) u8 {
    const index = rng.intRangeAtMost(usize, 0, CHAR_POOL.len - 1);
    return CHAR_POOL[index];
}

/// Initialize a column with random properties
pub fn initColumn(rng: std.Random, x: u16, max_rows: u16) Column {
    // Random length between 18 and 25 (very long trails)
    const length = rng.intRangeAtMost(u8, 18, 25);

    // Random starting y position (mostly on screen for very dense effect)
    const y = rng.intRangeAtMost(i32, -5, @as(i32, max_rows));

    // Random speed (4-8 frames delay - slower for more screen time)
    const speed = rng.intRangeAtMost(u8, 4, 8);

    // Initialize character array with random digits
    var chars = [_]u8{0} ** MAX_TRAIL_LENGTH;
    var i: usize = 0;
    while (i < length) : (i += 1) {
        chars[i] = randomChar(rng);
    }

    return Column{
        .x = x,
        .y = y,
        .length = length,
        .speed = speed,
        .frame_count = 0,
        .chars = chars,
    };
}

/// Update a column (move down, wrap around, update characters)
pub fn updateColumn(column: *Column, rng: std.Random, max_rows: u16) void {
    // Increment frame counter
    column.frame_count += 1;

    // Only move if we've waited enough frames (based on speed)
    if (column.frame_count >= column.speed) {
        column.frame_count = 0;
        column.y += 1;

        // Randomly update the leading character (20% chance)
        if (rng.intRangeAtMost(u8, 0, 99) < 20) {
            column.chars[0] = randomChar(rng);
        }

        // If column has scrolled off screen, reset it
        const max_y = @as(i32, max_rows) + @as(i32, column.length);
        if (column.y > max_y) {
            // Reset to top (mostly on screen for continuous dense flow)
            column.y = rng.intRangeAtMost(i32, -5, @as(i32, max_rows));

            // Randomize properties for variety
            column.length = rng.intRangeAtMost(u8, 18, 25);
            column.speed = rng.intRangeAtMost(u8, 4, 8);

            // Refill character array
            var i: usize = 0;
            while (i < column.length) : (i += 1) {
                column.chars[i] = randomChar(rng);
            }
        }
    }
}

/// Render all columns to the screen
/// Uses buffering to reduce flickering by writing all output at once
pub fn renderColumns(columns: []const Column, term_size: TerminalSize) void {
    // Create a fixed buffer for building the entire frame (64KB should be enough)
    var buffer: [65536]u8 = undefined;
    var stream = std.io.fixedBufferStream(&buffer);
    const writer = stream.writer();

    // Clear screen and reset cursor to home
    writer.writeAll(CLEAR_SCREEN) catch return;

    for (columns) |col| {
        // Only render if column head is on or below screen top
        if (col.y < 0) continue;

        // Render each character in the trail
        var i: usize = 0;
        while (i < col.length) : (i += 1) {
            const char_y = col.y - @as(i32, @intCast(i));

            // Skip if this character is above screen
            if (char_y < 0) continue;

            // Skip if this character is below screen
            if (char_y >= term_size.rows) break;

            // Position cursor (ANSI: row;colH - 1-indexed)
            const row = @as(u16, @intCast(char_y)) + 1;
            const col_pos = col.x + 1;

            // Choose color based on position in trail (fade effect)
            const color = if (i == 0)
                WHITE // Head is bright white
            else if (i == 1)
                BRIGHT_GREEN // Position 1: bold bright green
            else if (i <= 3)
                GREEN // Positions 2-3: bright green
            else if (i <= 6)
                NORMAL_GREEN // Positions 4-6: normal green
            else if (i <= 10)
                DARK_GREEN // Positions 7-10: dim bright green
            else
                DARKER_GREEN; // Positions 11+: very dim green

            // Draw character at position
            writer.print("\x1b[{};{}H{s}{c}{s}", .{
                row,
                col_pos,
                color,
                col.chars[i],
                RESET_COLOR,
            }) catch return;
        }
    }

    // Output entire buffer at once to prevent flickering
    std.debug.print("{s}", .{stream.getWritten()});
}

/// Check if a key should trigger exit (Ctrl+C only)
pub fn shouldExit(key: u8) bool {
    return key == 0x03; // Ctrl+C
}

/// Cleanup terminal (restore original settings, show cursor)
pub fn cleanupTerminal(original_termios: Termios) void {
    // Exit alternate screen, show cursor
    std.debug.print("{s}{s}", .{ ALT_SCREEN_EXIT, SHOW_CURSOR });

    if (builtin.os.tag != .windows) {
        // Unix/POSIX systems: restore original terminal settings
        const stdin_fd = posix.STDIN_FILENO;
        posix.tcsetattr(stdin_fd, .FLUSH, original_termios) catch {};
    }
}
