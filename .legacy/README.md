# neo

> Matrix digital rain terminal effect

![Demo](docs/.images/demo.gif)

## Overview

**neo** is a terminal application that displays the iconic Matrix digital rain effect. Watch cascading green numbers flow down your screen in an authentic Matrix-style animation.

Features:

- Full-screen cascading number animation
- Authentic Matrix color fade (white → bright green → green → dim green)
- Smooth 20 FPS animation
- Terminal resize support
- Clean alternate screen buffer (restores terminal on exit)
- Cross-platform: Linux, macOS, Windows

## Installation

Install using the one-line installer:

```bash
curl -sSL https://github.com/skapoor8/neo/raw/main/install.sh | bash
```

Or build from source:

```bash
git clone https://github.com/skapoor8/neo.git
cd neo
just setup
just build
```

See the [Development Guide](docs/development-guide.md) for detailed build instructions.

## Usage

Run the Matrix effect:

```bash
neo
```

Show help:

```bash
neo --help
```

**Controls:**

- `Ctrl+C` or `ESC` - Exit the Matrix and return to your normal terminal

## Contributing

Contributions are welcome! See the [Development Guide](docs/development-guide.md) for:
- Setting up your development environment
- Building and testing
- Publishing releases
- Architecture overview

See [CONTRIBUTING.md](CONTRIBUTING.md) for our contribution process.

## Documentation

- [Development Guide](docs/development-guide.md) - Setup, building, testing, and publishing
- [Infrastructure](docs/infrastructure.md) - Build system, CI/CD, and release automation

## License

MIT License - see [LICENSE](LICENSE) for details

## References

- [Zig Language](https://ziglang.org/)
- [just command runner](https://github.com/casey/just)
