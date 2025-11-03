# neo

> Matrix digital rain terminal effect

## Overview

**neo** is a terminal application that displays the iconic Matrix digital rain effect. Watch cascading green numbers flow down your screen in an authentic Matrix-style animation.

Features:
- Full-screen cascading number animation
- Authentic Matrix color fade (white → bright green → green → dim green)
- Smooth 20 FPS animation
- Terminal resize support
- Clean alternate screen buffer (restores terminal on exit)
- Exit with Ctrl+C or ESC

### Project Structure

```
.
├── docs/          # Documentation
├── scripts/       # Utility scripts and CI/CD hooks
├── src/           # Zig source code
├── build.zig      # Zig build configuration
├── build.zig.zon  # Zig package manifest
├── justfile       # Build recipes
├── .envrc         # Key env vars and shell config
└── version.txt    # Project version
```

## Prerequisites

- bash 3.2+
- just
- Zig 0.15.1 or later
- [List other project-specific dependencies]

## Setup

Run `just setup` or `./scripts/setup.sh` to install remaining dependencies (just, direnv, Zig).

Optional: `just setup --dev` for development tools (ZLS language server), `just setup --template` for template testing.

## Quick Start

### Installation

```bash
# Install using the install script
curl -sSL https://github.com/YOUR_ORG/neo/raw/main/install.sh | bash

# Or build from source
just build
```

### Usage

```bash
# Run the Matrix effect
neo

# Show help
neo --help
```

**Controls:**
- `Ctrl+C` or `ESC` - Exit the Matrix and return to your normal terminal

### Development

Build, run, and test with `just`:

```bash
# Build the project
just build

# Run locally
just run

# Run tests
just test

# Clean build artifacts
just clean
```

## Publishing

Commit using conventional commits (`feat:`, `fix:`, `docs:`). Merge/push to main and CI/CD will run automatically bumping your project version and publishing a package.

### Release Process

1. **Make changes** on a feature branch
2. **Commit with conventional commits**:
   - `feat: add new feature` → minor version bump
   - `fix: resolve bug` → patch version bump
   - `feat!: breaking change` or `BREAKING CHANGE:` in footer → major version bump
3. **Push to GitHub** and create a pull request
4. **Merge to main** - the CI/CD pipeline will:
   - Run tests
   - Build artifacts
   - Generate changelog
   - Create GitHub release
   - Publish to registry (if configured)

### Manual Publishing

To publish manually:

```bash
# Ensure you're on main branch with clean working directory
just publish
```

This will publish a pre-release package version.

### Registry Configuration

Publishing is configured for both GitHub Releases (binaries) and optionally GCP Artifact Registry.

**GitHub Releases** (default):
- Multi-platform binaries are automatically built and uploaded to GitHub Releases
- Users can install with: `curl -sSL https://github.com/YOUR_ORG/neo/raw/main/install.sh | bash`

**GCP Artifact Registry** (optional):
- Configure in `.envrc`: Set `GCP_REGISTRY_PROJECT_ID`, `GCP_REGISTRY_REGION`, `GCP_REGISTRY_NAME`
- Add `GCP_SA_KEY` secret to GitHub repository for automated publishing

**Pre-built binaries:**
- Multi-platform binaries are automatically built and uploaded to GitHub Releases
- Install with the one-line installer above or download directly from releases

## Documentation

To learn more about using this template, read the docs:

- [User Guide](docs/user-guide.md) - Complete setup and usage guide
- [Architecture](docs/architecture.md) - Design and implementation details

## References

- [Zig Language](https://ziglang.org/)
- [Zig Build System](https://ziglang.org/learn/build-system/)
- [Zig Package Manager](https://github.com/ziglang/zig/wiki/Package-Manager)
- [ZLS (Zig Language Server)](https://github.com/zigtools/zls)
- [just command runner](https://github.com/casey/just)
- [direnv environment management](https://direnv.net/)
- [semantic-release](https://semantic-release.gitbook.io/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub Actions](https://docs.github.com/en/actions)
