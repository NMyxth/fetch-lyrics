#!/bin/sh
# fetch-lyrics installer for macOS / Linux.
# Installs to ~/.local/bin, adds it to PATH, and if Python 3.10+ is missing it
# fetches a private copy with uv. Nothing else needs to be installed.
set -eu

REPO="NMyxth/fetch-lyrics"
BASE="${FL_BASE:-https://github.com/$REPO/releases/latest/download}"
BIN="$HOME/.local/bin"
LIB="$HOME/.local/lib/fetch-lyrics"
UV_DIR="$LIB/uv"
UV="$UV_DIR/uv"

mkdir -p "$BIN" "$LIB"

fetch() {  # fetch <url> <dest>
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$1" -o "$2"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "$2" "$1"
    else
        echo "error: need curl or wget to download" >&2
        return 1
    fi
}

echo "Downloading fetch-lyrics -> $LIB"
fetch "$BASE/fetch-lyrics.py" "$LIB/fetch-lyrics.py"

# --- Python 3.10+ -----------------------------------------------------------
PY=""
if command -v python3 >/dev/null 2>&1; then
    if python3 -c 'import sys; raise SystemExit(0 if sys.version_info >= (3, 10) else 1)' 2>/dev/null; then
        PY="$(command -v python3)"
    fi
fi

if [ -z "$PY" ]; then
    echo "No Python 3.10+ found. Getting a private copy (no sudo needed) ..."
    if [ ! -x "$UV" ]; then
        mkdir -p "$UV_DIR"
        if ! curl -LsSf https://astral.sh/uv/install.sh \
                | env UV_INSTALL_DIR="$UV_DIR" UV_NO_MODIFY_PATH=1 sh; then
            echo "error: could not download uv. Install Python 3.10+ and re-run." >&2
            exit 1
        fi
    fi
    "$UV" python install 3.12 >/dev/null 2>&1 || true
    PY="$("$UV" python find 3.12 2>/dev/null || true)"
    if [ -z "$PY" ] || [ ! -x "$PY" ]; then
        echo "error: could not set up Python. Install Python 3.10+ and re-run." >&2
        exit 1
    fi
    echo "Using a private Python: $PY"
fi

# --- launcher ---------------------------------------------------------------
cat > "$BIN/fetch-lyrics" <<EOF
#!/bin/sh
exec "$PY" "$LIB/fetch-lyrics.py" "\$@"
EOF
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
echo "Done. Open a NEW terminal, then run:"
echo "    fetch-lyrics"
echo
echo "Optional: for embedded lyrics tags, install mutagen:  python3 -m pip install --user mutagen"
