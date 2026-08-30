#!/usr/bin/env bash
#
# svg2font installer
#
# Installs the native `svg2font` CLI by downloading the binary matching the
# current platform from the latest GitHub release, in the same spirit as Volta
# (`curl https://get.volta.sh | bash`).
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/jaysonwu991/svg2font/main/scripts/install.sh | bash
#
# Environment overrides:
#   SVG2FONT_HOME          install root          (default: "$HOME/.svg2font")
#   SVG2FONT_INSTALL_DIR   destination directory (default: "$SVG2FONT_HOME/bin")
#   SVG2FONT_VERSION       specific version      (default: latest via manifest)
#
set -euo pipefail

REPO="jaysonwu991/svg2font"
BASE_URL="https://github.com/${REPO}"
MANIFEST_NAME="svg2font-manifest"
DEFAULT_HOME="${HOME}/.svg2font"

HOME_DIR="${SVG2FONT_HOME:-${DEFAULT_HOME}}"
BIN_DIR="${SVG2FONT_INSTALL_DIR:-${HOME_DIR}/bin}"

err()   { echo "error: $*" >&2; exit 1; }
info()  { echo "==> $*"; }
say()   { echo "    $*"; }

# Global scratch dir so the EXIT trap can always clean it up, even after `main`
# returns and its locals go out of scope.
TMP_DIR=""

detect_os() {
  case "$(uname -s)" in
    Linux)  os="linux" ;;
    Darwin) os="darwin" ;;
    *) err "unsupported OS: $(uname -s)" ;;
  esac
}

detect_arch() {
  case "$(uname -m)" in
    x86_64|amd64) arch="x64" ;;
    arm64|aarch64) arch="arm64" ;;
    *) err "unsupported architecture: $(uname -m)" ;;
  esac
}

# Given a manifest body, print the asset URL for `<os>-<arch>`.
asset_url_from_manifest() {
  local body="$1"
  local version key name
  version="$(printf '%s\n' "${body}" | awk -F': ' '/^version:/ {print $2; exit}')"
  [ -n "${version}" ] || err "could not read version from manifest (has a release been published?)"

  key="${os}-${arch}"
  name="$(printf '%s\n' "${body}" | awk -F': ' -v k="${key}" '$1 == k {sub(/^[[:space:]]*/, "", $2); sub(/[[:space:]]*$/, "", $2); print $2; exit}')"
  [ -n "${name}" ] || err "no asset for ${key}; supported targets: darwin-arm64, darwin-x64, linux-x64, linux-arm64, win32-x64"

  printf '%s/releases/download/%s/%s' "${BASE_URL}" "${version}" "${name}"
}

download() {
  local url="$1" out="$2"
  info "Downloading $(basename "${url}")"
  curl -fsSL "${url}" -o "${out}"
}

extract() {
  local file="$1" dest="$2"
  info "Extracting $(basename "${file}")"
  mkdir -p "${dest}"
  case "${file}" in
    *.zip)    unzip -oq "${file}" -d "${dest}" ;;
    *.tar.gz|*.tgz) tar -xzf "${file}" -C "${dest}" ;;
    *) err "unrecognized archive type: ${file}" ;;
  esac
}

ensure_path() {
  local shell_rc rc_line
  rc_line="export PATH=\"${BIN_DIR}:\$PATH\""
  case "${SHELL:-}" in
    */zsh)  shell_rc="${HOME}/.zshrc" ;;
    */bash) shell_rc="${HOME}/.bashrc" ;;
    */fish) shell_rc="${HOME}/.config/fish/config.fish" ;;
    *)      shell_rc="" ;;
  esac

  if [ -n "${shell_rc}" ] && ! grep -qF "${BIN_DIR}" "${shell_rc}" 2>/dev/null; then
    info "Adding ${BIN_DIR} to PATH in ${shell_rc}"
    printf '\n# svg2font\nexport PATH="%s:$PATH"\n' "${BIN_DIR}" >> "${shell_rc}"
  elif [ -z "${shell_rc}" ]; then
    echo "    Add ${BIN_DIR} to your PATH manually."
  fi
}

main() {
  detect_os
  detect_arch
  info "Installing svg2font for ${os}/${arch}"

  local url archive
  if [ -n "${SVG2FONT_VERSION:-}" ]; then
    # Explicit version -> deterministic asset name (no manifest required).
    # Normalise a leading "v" so both "v1.2.3" and "1.2.3" work.
    local ver="${SVG2FONT_VERSION#v}" ext="tar.gz"
    [ "${os}" = "win32" ] && ext="zip"
    url="${BASE_URL}/releases/download/v${ver}/svg2font-v${ver}-${os}-${arch}.${ext}"
  else
    info "Fetching ${MANIFEST_NAME}"
    url="$(asset_url_from_manifest "$(curl -fsSL "${BASE_URL}/releases/latest/download/${MANIFEST_NAME}")")"
  fi

  TMP_DIR="$(mktemp -d)"
  trap 'rm -rf "${TMP_DIR}"' EXIT

  archive="${TMP_DIR}/${url##*/}"
  download "${url}" "${archive}"

  extract "${archive}" "${TMP_DIR}"
  mkdir -p "${BIN_DIR}"
  install -m 0755 "${TMP_DIR}/svg2font" "${BIN_DIR}/svg2font"

  ensure_path

  echo
  say "Installed svg2font to ${BIN_DIR}/svg2font"
  say "Run '${BIN_DIR}/svg2font --help' to verify, or restart your shell."
}

main "$@"
