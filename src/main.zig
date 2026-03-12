const std = @import("std");
const builtin = @import("builtin");
const posix = std.posix;
const lib = @import("neo");

pub fn main() !void {
    // Set up allocator for argument parsing
    var gpa_early = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa_early.deinit();
    const allocator_early = gpa_early.allocator();

    // Check for help flag
    const args = try std.process.argsAlloc(allocator_early);
    defer std.process.argsFree(allocator_early, args);

    if (args.len > 1) {
        if (std.mem.eql(u8, args[1], "--help") or std.mem.eql(u8, args[1], "-h")) {
            std.debug.print(
                \\neo - Matrix digital rain terminal effect
                \\
                \\USAGE:
                \\    neo [OPTIONS]
                \\
                \\OPTIONS:
                \\    -h, --help    Show this help message
                \\
                \\CONTROLS:
                \\    Ctrl+C        Exit the matrix
                \\    ESC           Exit the matrix
                \\
                \\Displays cascading green numbers in your terminal.
                \\Press Ctrl+C or ESC to exit and return to normal terminal.
                \\
            , .{});
            return;
        }
    }

    // Initialize terminal (raw mode, hide cursor)
    const original_termios = try lib.initTerminal();
    defer lib.cleanupTerminal(original_termios);

    // Set up allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Initialize random number generator with cross-platform seed
    var prng = std.Random.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        if (builtin.os.tag == .windows) {
            // Use cross-platform random for Windows
            seed = @as(u64, @intCast(std.time.milliTimestamp()));
        } else {
            std.posix.getrandom(std.mem.asBytes(&seed)) catch {
                seed = @as(u64, @intCast(std.time.milliTimestamp()));
            };
        }
        break :blk seed;
    });
    const rng = prng.random();

    // Get initial terminal size and create columns
    var term_size = lib.getTerminalSize();
    var num_columns = term_size.cols / 2;
    var columns = try allocator.alloc(lib.Column, num_columns);
    defer allocator.free(columns);

    // Initialize all columns (spread out horizontally)
    for (columns, 0..) |*col, i| {
        const x_pos = @as(u16, @intCast(i)) * 2; // Every other column
        col.* = lib.initColumn(rng, x_pos, term_size.rows);
    }

    // Main animation loop
    var buf: [1]u8 = undefined;
    var running = true;

    while (running) {
        // Check for terminal resize
        const new_size = lib.getTerminalSize();
        if (new_size.rows != term_size.rows or new_size.cols != term_size.cols) {
            term_size = new_size;

            // Reallocate columns for new width
            allocator.free(columns);
            num_columns = term_size.cols / 2;
            columns = try allocator.alloc(lib.Column, num_columns);

            // Reinitialize all columns
            for (columns, 0..) |*col, i| {
                const x_pos = @as(u16, @intCast(i)) * 2;
                col.* = lib.initColumn(rng, x_pos, term_size.rows);
            }
        }

        // Check for exit key (non-blocking) - Unix only
        if (builtin.os.tag != .windows) {
            const stdin_fd = posix.STDIN_FILENO;
            const bytes_read = posix.read(stdin_fd, &buf) catch 0;
            if (bytes_read > 0) {
                // Check for Ctrl+C
                if (lib.shouldExit(buf[0])) {
                    running = false;
                    break;
                }
                // Check for standalone ESC (not part of escape sequence)
                // ESC sequences have more bytes following immediately
                if (buf[0] == 0x1b) {
                    // Try to read more - if nothing follows, it's standalone ESC
                    var extra_buf: [10]u8 = undefined;
                    const extra_bytes = posix.read(stdin_fd, &extra_buf) catch 0;
                    if (extra_bytes == 0) {
                        // Standalone ESC press
                        running = false;
                        break;
                    }
                    // Otherwise it was an escape sequence, ignore it
                }
            }
        }

        // Update all columns
        for (columns) |*col| {
            lib.updateColumn(col, rng, term_size.rows);
        }

        // Render columns to screen
        lib.renderColumns(columns, term_size);

        // Frame timing: ~50ms for ~20 FPS
        std.Thread.sleep(50 * std.time.ns_per_ms);
    }
}
