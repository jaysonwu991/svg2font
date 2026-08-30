# AGENTS.md

## Architecture

Rust-first, JS wrappers. The actual SVG→iconfont converter is Rust (`src/`, root `Cargo.toml`) with three targets:

- native CLI binary: `svg2font` (bin, `src/main.rs`)
- WASM module (`src/wasm.rs`, `.rs` `wasm` feature) → `packages/svg2font/wasm/svg2font_wasm.js`
- NAPI module (`src/napi.rs`, `napi` feature) — compile-checked in CI but not published

npm packages are thin wrappers that load the compiled Rust output:

- `@jayson991/svg2font` (lib): `require`s the WASM module and calls `wasm.generateFromSvgs` (packages/svg2font/src/index.ts).
- `@jayson991/svg2font-cli` (CLI): `spawnSync`s the per-platform native binary, resolved via `optionalDependencies` or `SVG2FONT_BINARY` env (packages/svg2font-cli/src/svg2font.ts).

Real app/library entrypoints: Rust `src/lib.rs`; TS wrappers `packages/svg2font/src/index.ts` and `packages/svg2font-cli/src/svg2font.ts`.

## Commands

Two toolchains; CI (`check` + `check-ts`) runs both.

Rust core:
- `cargo build --release` — native CLI binary
- `cargo test`
- `cargo clippy --all-targets -- -D warnings`
- `cargo fmt --all -- --check`
- `cargo check --lib --features wasm --no-default-features --target wasm32-unknown-unknown`

TypeScript wrappers (pnpm workspace):
- `pnpm typecheck` / `pnpm lint` / `pnpm format` / `pnpm format:check`
- `pnpm build` — builds all `packages/*`
- per-package: `pnpm --filter @jayson991/svg2font build` (lib), `pnpm --filter @jayson991/svg2font-cli build` (CLI)
- WASM artifact build (CI uses wasm-pack): `wasm-pack build --target nodejs --out-dir packages/svg2font/wasm --out-name svg2font_wasm -- --features wasm --no-default-features`

Order matters: `pnpm format:check` → `pnpm lint` → `pnpm typecheck` matches CI; Rust `cargo fmt` / `cargo clippy` / `cargo test` in that order.

## Gotchas

- `packages/svg2font/wasm/` is **not** in git and is produced by wasm-pack (CI only). The library won't run locally until you build WASM first; otherwise `require ../wasm/svg2font_wasm.js` throws.
- `packages/svg2font-cli/bin/svg2font.js` is gitignored build output (`vite build` → `bin/`). Build the CLI package before testing it.
- CLI needs the per-platform native binary in `packages/svg2font-cli/npm/<platform>/svg2font(.exe)` or an `SVG2FONT_BINARY` override; only `darwin-arm64` is currently committed.
- Publishing is tag-driven (`.github/workflows/publish.yml`, tag `v*`): cross-build CLI binaries per target, wasm-pack the lib, stamp versions, then publish the platform packages, CLI, and lib in that order.
- `scripts/install.sh` (~Volta `curl | bash`) installs the CLI from GitHub release assets. The `build-cli` job packages each binary as `svg2font-<vX>-<target>.tar.gz`/`.zip` and the `release` job attaches them plus a `svg2font-manifest` to the tagged release. Installer env overrides: `SVG2FONT_HOME`, `SVG2FONT_INSTALL_DIR`, `SVG2FONT_VERSION`. All 5 platform tarballs must be uploaded or the installer can't resolve its platform.
- `pnpm-workspace.yaml` lists a nonexistent `packages/svg2font/npm/*` glob (matches nothing); root `npm/` dir is a stale duplicate of `packages/svg2font-cli/npm/` — the publish flow uses `packages/svg2font-cli/npm/`.
