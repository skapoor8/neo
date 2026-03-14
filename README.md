# neo

Matrix digital rain effect for your terminal.

![demo](docs/.images/demo.gif)

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/skapoor8/neo/main/install.sh | bash
```

Or build from source:

```bash
mise install && mise run build && zig-out/bin/neo
```

## Usage

```
neo          # start the rain
neo --help   # show help
```

Press **ESC** or **Ctrl+C** to exit.

## Development

See [docs/user-guide.md](docs/user-guide.md) for setup and development workflow.

Generated from [mise-lib-template](https://github.com/cloudvoyant/mise-lib-template).
