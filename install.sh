#!/bin/sh
# fetch-lyrics installer for macOS / Linux.
# Downloads the latest release to ~/.local/bin and makes sure it is on PATH.
set -eu

REPO="NMyxth/fetch-lyrics"
BIN="$HOME/.local/bin"
URL="https://github.com/$REPO/releases/latest/download/fetch-lyrics"

mkdir -p "$BIN"

echo "Downloading fetch-lyrics -> $BIN/fetch-lyrics"
if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$URL" -o "$BIN/fetch-lyrics"
elif command -v wget >/dev/null 2>&1; then
    wget -qO "$BIN/fetch-lyrics" "$URL"
else
    echo "error: need curl or wget to download" >&2
    exit 1
fi
chmod +x "$BIN/fetch-lyrics"

# Make sure ~/.local/bin is on PATH for future shells.
case ":$PATH:" in
    *":$BIN:"*)
        echo "PATH already contains $BIN"
        ;;
    *)
        line='export PATH="$HOME/.local/bin:$PATH"'
        added=0
        for rc in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.profile"; do
            [ -f "$rc" ] || continue
            if ! grep -qF '.local/bin' "$rc"; then
                printf '\n# added by fetch-lyrics installer\n%s\n' "$line" >> "$rc"
                echo "Added $BIN to PATH in $rc"
                added=1
            fi
        done
        if [ "$added" -eq 0 ]; then
            echo "NOTE: add this to your shell profile: $line"
        fi
        ;;
esac

echo
echo "Done. Restart your shell, then run:"
echo "    fetch-lyrics ~/Music"
echo
echo "Optional: for embedded lyrics tags, install mutagen:  python3 -m pip install --user mutagen"
