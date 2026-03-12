# neo — User Guide

`neo` is a Matrix digital rain terminal effect written in Zig. This guide covers installation, usage, controls, and how to use neo as a Zig library.

## Features

- Full-screen cascading number animation
- Authentic Matrix color fade (white → bright green → green → dim green)
- Smooth 20 FPS animation with randomized column speeds
- Terminal resize support — adapts to window size changes dynamically
- Clean alternate screen buffer — restores terminal state on exit
- Cross-platform: Linux, macOS, Windows

## Installation

### Quick Install (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/cloudvoyant/neo/main/install.sh | bash
```

This script detects your OS and architecture, downloads the appropriate binary from GitHub Releases, and installs it to `~/.local/bin` or `/usr/local/bin`.

### Manual Installation

Download the binary for your platform from [GitHub Releases](https://github.com/cloudvoyant/neo/releases):

- `neo-linux-x86_64`
- `neo-linux-aarch64`
- `neo-macos-x86_64`
- `neo-macos-aarch64`
- `neo-windows-x86_64.exe`

Then make it executable and add to your PATH:

```bash
mv neo-* ~/.local/bin/neo
chmod +x ~/.local/bin/neo
```

### Build from Source

```bash
git clone https://github.com/cloudvoyant/neo.git
cd neo
mise install
mise run build
# Binary is at zig-out/bin/neo
```

## Usage

Start the Matrix rain effect:

```bash
neo
```

Show help:

```bash
neo --help
```

## Controls

| Key | Action |
|-----|--------|
| `Ctrl+C` | Exit the Matrix |
| `ESC` | Exit the Matrix |

Both methods cleanly restore your terminal to its previous state (cursor, alternate screen, raw mode).

## How It Works

### Terminal Control

- Raw terminal mode disables line buffering and echo, enabling frame-by-frame rendering
- The cursor is hidden for clean visualization
- An alternate screen buffer is used (like vim/less), so your shell history is preserved on exit

### Animation Loop

- Each column falls at a different speed, randomized on initialization
- Characters randomly change as they fall (digits 0–9)
- Color fades from white (head) → bright green → green → dark green (tail)
- Renders at ~20 FPS with a 50ms sleep between frames

### Resize Support

- Detects terminal size changes every frame via `ioctl TIOCGWINSZ`
- Dynamically reallocates and reinitializes columns when the terminal is resized
- Seamlessly adapts to new dimensions without restarting

## Using neo as a Zig Library

neo exposes its core types and functions as an importable Zig module.

### Step 1: Add the dependency

```bash
zig fetch --save "git+https://github.com/cloudvoyant/neo#main"
```

### Step 2: Configure your build.zig

```zig
const neo = b.dependency("neo", .{
    .target = target,
    .optimize = optimize,
});

exe.root_module.addImport("neo", neo.module("neo"));
```

### Step 3: Import in your source

```zig
const neo = @import("neo");

// Available types: TerminalSize, Column
// Available functions: initTerminal, cleanupTerminal, getTerminalSize,
//   randomChar, initColumn, updateColumn, renderColumns, shouldExit
```

## Development

See [docs/development-guide.md](development-guide.md) for build system details, task runner commands, and CI/CD configuration.
