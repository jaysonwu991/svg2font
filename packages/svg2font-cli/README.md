# @jayson991/svg2font-cli

> Convert SVG icon sets into complete iconfont bundles — CLI tool

[![npm version](https://img.shields.io/npm/v/@jayson991/svg2font-cli.svg)](https://www.npmjs.com/package/@jayson991/svg2font-cli)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Node.js Version](https://img.shields.io/node/v/@jayson991/svg2font-cli.svg)](https://nodejs.org/)

A pre-compiled Rust binary distributed as a platform-specific npm package. No Node.js build tools or native compilation required at install time.

For the programmatic TypeScript/napi API, see [`@jayson991/svg2font`](../svg2font/README.md).

## Requirements

- Node.js 18 or higher
- One of: macOS (arm64/x64), Linux (arm64/x64), Windows (x64)

## Installation

### Via npm

```bash
# Global CLI
npm install -g @jayson991/svg2font-cli

# Or with pnpm
pnpm add -g @jayson991/svg2font-cli

# Or with yarn
yarn global add @jayson991/svg2font-cli
```

### Via curl (no npm)

Install the pre-compiled native binary straight from the GitHub release — no Node.js or npm required:

```bash
curl -fsSL https://raw.githubusercontent.com/jaysonwu991/svg2font/main/scripts/install.sh | bash
```

The installer detects your OS and architecture, downloads the matching binary from the latest
release, and adds it to your `PATH` (installed to `~/.svg2font/bin`). Environment overrides:

| Variable | Description | Default |
|----------|-------------|---------|
| `SVG2FONT_HOME` | Install root directory | `~/.svg2font` |
| `SVG2FONT_INSTALL_DIR` | Destination directory | `$SVG2FONT_HOME/bin` |
| `SVG2FONT_VERSION` | Pin a release (e.g. `1.2.3` or `v1.2.3`) | latest |

## Quick Start

**Step 1:** Place your SVG icons in a folder:

```
icons/
├── home.svg
├── user.svg
└── settings.svg
```

**Step 2:** Run the command:

```bash
svg2font --src "icons/**/*.svg" --dist dist --font-name myicons
```

**Step 3:** Unzip and use the output:

```
dist/
└── myicons/
    ├── myicons.ttf
    ├── myicons.woff
    ├── myicons.woff2
    ├── myicons.eot
    ├── myicons.svg
    ├── myicons.css
    ├── myicons.js
    ├── myicons.symbol.svg
    ├── myicons.json
    ├── demo.html
    └── demo.css
```

Open `demo.html` to preview all icons and copy usage code snippets.

## CLI Options

| Option | Alias | Default | Description |
|--------|-------|---------|-------------|
| `--src` | `-s` | `svg/**/*.svg` | Glob pattern for source SVG files |
| `--dist` | `-d` | `dist` | Output directory |
| `--font-name` | `-n` | `iconfont` | Font family name (used in file names and CSS) |
| `--prefix` | `-p` | `icon` | CSS class prefix (e.g. `icon-home`) |
| `--start-unicode` | — | `e001` | Starting Unicode codepoint (hex, e.g. `e001`) |
| `--help` | `-h` | — | Show help |
| `--version` | `-V` | — | Show version |

## Output Bundle

The command generates a directory at `dist/{font-name}/` containing:

| File | Description |
|------|-------------|
| `{name}.ttf` | TrueType font |
| `{name}.woff` | WOFF font (zlib compressed) |
| `{name}.woff2` | WOFF2 font (brotli compressed) |
| `{name}.eot` | EOT font (IE11 support) |
| `{name}.svg` | SVG font |
| `{name}.css` | Stylesheet with `@font-face` and all three usage methods |
| `{name}.js` | SVG sprite auto-injector script |
| `{name}.symbol.svg` | SVG sprite definitions |
| `{name}.json` | Glyph metadata (names, codepoints) |
| `demo.html` | Interactive preview page |
| `demo.css` | Demo page styles |

## Three Usage Methods

### 1. Unicode Mode

```html
<link rel="stylesheet" href="myicons.css">
<span class="iconfont">&#xe001;</span>
```

### 2. Font Class Mode (recommended)

```html
<link rel="stylesheet" href="myicons.css">
<i class="iconfont icon-home"></i>
<i class="iconfont icon-user"></i>
```

### 3. SVG Symbol Mode

```html
<script src="myicons.js"></script>
<svg class="icon" aria-hidden="true">
  <use href="#icon-home"></use>
</svg>
```

## SVG File Requirements

- Valid SVG with `<path>` elements
- `viewBox` attribute (or `width`/`height`)
- No external dependencies (linked images, external CSS)
- Single color recommended for font mode

Filenames are automatically converted to kebab-case:
- `home.svg` → `.icon-home`
- `Arrow Right.svg` → `.icon-arrow-right`

## Platform Support

| Platform | Architecture |
|----------|-------------|
| macOS | arm64 (Apple Silicon) |
| macOS | x64 (Intel) |
| Linux | x64 |
| Linux | arm64 |
| Windows | x64 |

## License

MIT © [Jayson Wu](https://github.com/jaysonwu991)
