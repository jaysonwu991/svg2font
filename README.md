# svg2font

> Convert SVG icon sets into complete iconfont bundles (TTF/WOFF/WOFF2/EOT/SVG) with CSS, demos, and sprites

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A monorepo containing two packages:

| Package | Description |
|---------|-------------|
| [`@jayson991/svg2font-cli`](packages/svg2font-cli) | CLI tool — `svg2font` command |
| [`@jayson991/svg2font`](packages/svg2font) | TypeScript/WASM library for programmatic use |

## Packages

### [@jayson991/svg2font-cli](packages/svg2font-cli/README.md)

Install globally and run from the command line:

```bash
npm install -g @jayson991/svg2font-cli
svg2font --src "icons/**/*.svg" --dist dist --font-name myicons
```

Or install the native CLI with a single curl pipeline (like Volta). No Node.js or npm needed — the installer detects your OS/architecture and downloads the right binary from the latest GitHub release:

```bash
curl -fsSL https://raw.githubusercontent.com/jaysonwu991/svg2font/main/scripts/install.sh | bash
```

The installer installs to `~/.svg2font/bin` and adds it to your `PATH`. Variables: `SVG2FONT_HOME` (install root), `SVG2FONT_INSTALL_DIR` (binary directory), and `SVG2FONT_VERSION` (pin a specific release).

### [@jayson991/svg2font](packages/svg2font/README.md)

Import as a Node.js module:

```typescript
import { generate } from '@jayson991/svg2font';

const result = await generate({
  src: 'icons/**/*.svg',
  dist: 'dist',
  fontName: 'myicons',
});

console.log(`Generated ${result.glyphs.length} icons → ${result.zipPath}`);
```

## Development

```bash
# Clone
git clone https://github.com/jaysonwu991/svg2font.git
cd svg2font

# Build CLI binary
cargo build --release

# Build WASM module
cargo build --release --features wasm

# Run tests
cargo test

# Lint (native targets)
cargo clippy --all-targets -- -D warnings

# Check WASM feature compiles
cargo check --lib --features wasm --no-default-features --target wasm32-unknown-unknown
```

## License

MIT © [Jayson Wu](https://github.com/jaysonwu991)
