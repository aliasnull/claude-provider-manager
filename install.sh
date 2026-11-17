#!/bin/sh
set -eu

PROJECT="Claude Provider Manager"
INSTALL_DIR="${HOME:?HOME is not set}/.local/bin"
INSTALL_PATH="$INSTALL_DIR/claude-provider"
SCRIPT_URL="https://raw.githubusercontent.com/aliasnull/claude-provider-manager/main/claude-provider"
TMP_FILE="$(mktemp)"
trap 'rm -f "$TMP_FILE"' EXIT HUP INT TERM

fail() {
    printf '%s\n' "Error: $1" >&2
    exit 1
}

printf '%s\n' "$PROJECT installer" "------------------------"

command -v python3 >/dev/null 2>&1 || fail "Python 3 is required. Install Python 3 and run this installer again."

python3 -c 'import sys; raise SystemExit(0 if sys.version_info >= (3, 8) else 1)' \
    || fail "Python 3.8 or newer is required."

command -v claude >/dev/null 2>&1 \
    || fail "Claude Code was not found in PATH. Install the official Claude Code CLI first."

# Optional local source override is used for testing the installer before release.
if [ -n "${CLAUDE_PROVIDER_SOURCE:-}" ]; then
    [ -f "$CLAUDE_PROVIDER_SOURCE" ] \
        || fail "CLAUDE_PROVIDER_SOURCE does not point to a file."
    cp "$CLAUDE_PROVIDER_SOURCE" "$TMP_FILE"
else
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$SCRIPT_URL" -o "$TMP_FILE" \
            || fail "Could not download Claude Provider Manager from GitHub."
    elif command -v wget >/dev/null 2>&1; then
        wget -q "$SCRIPT_URL" -O "$TMP_FILE" \
            || fail "Could not download Claude Provider Manager from GitHub."
    else
        fail "curl or wget is required to download the application."
    fi
fi

[ -s "$TMP_FILE" ] || fail "The downloaded application file is empty."
python3 -m py_compile "$TMP_FILE" 2>/dev/null \
    || fail "The downloaded application failed its Python syntax check."

UPGRADE=0

if [ "${1:-}" = "--upgrade" ]; then
    UPGRADE=1
elif [ "$#" -gt 0 ]; then
    fail "Unknown installer option: $1"
fi

if [ -e "$INSTALL_PATH" ] && [ "$UPGRADE" -ne 1 ]; then
    fail "An installation already exists. Use --upgrade to replace it."
fi

mkdir -p "$INSTALL_DIR"
install -m 755 "$TMP_FILE" "$INSTALL_PATH"

add_line_once() {
    config_file=$1
    line=$2
    mkdir -p "$(dirname "$config_file")"
    touch "$config_file"
    if ! grep -Fqx "$line" "$config_file"; then
        printf '\n%s\n' "$line" >> "$config_file"
    fi
}

case ":$PATH:" in
    *":$INSTALL_DIR:"*)
        ;;
    *)
        case "${SHELL##*/}" in
            bash)
                add_line_once "$HOME/.bashrc" 'export PATH="$HOME/.local/bin:$PATH"'
                add_line_once "$HOME/.profile" 'export PATH="$HOME/.local/bin:$PATH"'
                ;;
            zsh)
                add_line_once "$HOME/.zshrc" 'export PATH="$HOME/.local/bin:$PATH"'
                add_line_once "$HOME/.zprofile" 'export PATH="$HOME/.local/bin:$PATH"'
                ;;
            fish)
                add_line_once "$HOME/.config/fish/config.fish" 'fish_add_path "$HOME/.local/bin"'
                ;;
            *)
                add_line_once "$HOME/.profile" 'export PATH="$HOME/.local/bin:$PATH"'
                ;;
        esac
        ;;
esac

printf '\n%s\n' "Installation successful!"
printf 'Installed to: %s\n' "$INSTALL_PATH"
printf '%s\n' "Open a new terminal session to use: claude-provider"
printf '%s\n' "You can also run it now using the full path:"
printf '  %s --help\n' "$INSTALL_PATH"
