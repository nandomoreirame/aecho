#!/usr/bin/env bash
# Install aecho into PREFIX/bin (default: ~/.local/bin).
#
# From a clone it copies the aecho next to this script. Piped from curl there is
# no local copy, so it downloads AECHO_URL (default: the main branch on GitHub).
#
# Usage: ./install.sh [--prefix DIR] [--uninstall]
#        curl -fsSL <raw install.sh URL> | bash -s -- [--prefix DIR]
set -eo pipefail

readonly DEFAULT_URL="https://raw.githubusercontent.com/nandomoreirame/aecho/main/aecho"

usage() {
    cat <<'EOF'
Usage: install.sh [--prefix DIR] [--uninstall]

Install aecho into DIR/bin.

  --prefix DIR   install root (default: ~/.local, so the binary lands in ~/.local/bin)
  --uninstall    remove DIR/bin/aecho
  -h, --help     show this help

Environment:
  AECHO_URL      where to download aecho when no local copy exists
EOF
}

die() {
    printf 'install.sh: %s\n' "$1" >&2
    exit 1
}

prefix="$HOME/.local"
uninstall=0
while (($#)); do
    case "$1" in
        --prefix)
            [[ -n "${2:-}" ]] || { usage >&2; exit 2; }
            prefix="$2"
            shift 2
            ;;
        --uninstall) uninstall=1; shift ;;
        -h | --help) usage; exit 0 ;;
        *) usage >&2; exit 2 ;;
    esac
done

bin_dir="${prefix%/}/bin"
target="$bin_dir/aecho"

if ((uninstall)); then
    rm -f "$target"
    printf 'Removed %s\n' "$target"
    exit 0
fi

# BASH_SOURCE is empty when the script arrives on stdin (curl | bash).
local_copy=""
if [[ -n "${BASH_SOURCE[0]:-}" && -f "${BASH_SOURCE[0]}" ]]; then
    candidate="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/aecho"
    [[ -f "$candidate" ]] && local_copy="$candidate"
fi

mkdir -p "$bin_dir"
tmp="$(mktemp "$bin_dir/.aecho.XXXXXX")"
trap 'rm -f "$tmp"' EXIT

if [[ -n "$local_copy" ]]; then
    cp "$local_copy" "$tmp"
else
    url="${AECHO_URL:-$DEFAULT_URL}"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$url" -o "$tmp" || die "download failed: $url"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "$tmp" "$url" || die "download failed: $url"
    else
        die "curl or wget is required to download aecho"
    fi
    head -n1 "$tmp" | grep -q '^#!/usr/bin/env bash' || die "downloaded file is not the aecho script: $url"
fi

chmod 755 "$tmp"
mv -f "$tmp" "$target"
trap - EXIT
# The banner doubles as a smoke test; an old Bash failing it must not fail the install.
if banner="$("$target" AECHO 2>/dev/null)"; then
    printf '\n%s\n\n' "$banner"
fi
printf 'Installed %s\n' "$target"

# shellcheck disable=SC2016  # $PATH is meant literally in the hint
case ":$PATH:" in
    *":$bin_dir:"*) ;;
    *) printf 'Warning: %s is not on your PATH. Add it to your shell profile:\n  export PATH="%s:$PATH"\n' "$bin_dir" "$bin_dir" ;;
esac
