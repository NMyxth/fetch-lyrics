# fetch-lyrics

Batch-fetch `.lrc` lyrics for a folder of music, so your local music/media player
picks them up automatically.

The `.lrc` is always written **beside** the audio file with the **same stem**, which is
what local music/media players look for. Alternate or cleaned titles are used for
searching only, never for the output filename.

## Sources

Tried in order, first hit wins:

1. **LRCLIB** — `https://lrclib.net/api/get` (exact) then `https://lrclib.net/api/search` (fuzzy, duration-guarded). Synced lyrics preferred.
2. **lyrics.ovh** — `https://api.lyrics.ovh/v1/{artist}/{title}` (plain only).

No API key or account is needed for either source. The only header sent is a
`User-Agent`. Nothing personal is read or transmitted.

## Requirements

- **Python 3.10+** — standard library only.
- **No packages required.**
- `mutagen` is optional. With it, tags are read properly (artist, title, album,
  duration). Without it, the artist/title are parsed from the filename.
- `mutagen` is **required only** for `--embed` (writing lyrics into the audio
  file's tags).

## Install

### macOS / Linux

Quick install (installs to `~/.local/bin` and adds it to your `PATH` for you):

```sh
curl -fsSL https://github.com/NMyxth/fetch-lyrics/releases/latest/download/install.sh | sh
```

Then open a new terminal and run `fetch-lyrics ~/Music`.

Or do it manually:

```sh
curl -fsSL https://github.com/NMyxth/fetch-lyrics/releases/latest/download/fetch-lyrics \
  -o ~/.local/bin/fetch-lyrics && chmod +x ~/.local/bin/fetch-lyrics
```

Make sure `~/.local/bin` is on your `PATH`. The script filename **is** the command
(like `yt-dlp`); there is no alias.

### Windows

Python is required (`py --version`; install from [python.org](https://www.python.org/downloads/)
or the Microsoft Store if missing). The script is standard-library only, so no
packages are needed.

Quick install (installs to `%LOCALAPPDATA%\Programs\fetch-lyrics` and adds it to
your `PATH` for you):

```powershell
iwr -useb https://github.com/NMyxth/fetch-lyrics/releases/latest/download/install.ps1 | iex
```

Open a **new** terminal, then run `fetch-lyrics "$env:USERPROFILE\Music"`.

Or do it manually. Download both files into the same folder:

```powershell
irm https://github.com/NMyxth/fetch-lyrics/releases/latest/download/fetch-lyrics.py -OutFile fetch-lyrics.py
irm https://github.com/NMyxth/fetch-lyrics/releases/latest/download/fetch-lyrics.cmd -OutFile fetch-lyrics.cmd
```

Then run it:

```powershell
.\fetch-lyrics.cmd "$env:USERPROFILE\Music"
```

Add that folder to your `PATH` for a bare `fetch-lyrics` command. Keep
`fetch-lyrics.py` and `fetch-lyrics.cmd` in the same folder.

Notes:

- `--embed` needs mutagen: `py -m pip install mutagen`.
- If you see a `UnicodeEncodeError`, run `chcp 65001` first, or set `PYTHONUTF8=1`.
- `.lrc` files are always written as UTF-8.

### From source (clone)

Any OS, if you prefer git:

```sh
git clone https://github.com/NMyxth/fetch-lyrics.git
cd fetch-lyrics
./fetch-lyrics ~/Music
```

On Windows use the launcher instead: `.\fetch-lyrics.cmd "$env:USERPROFILE\Music"`.

Update anytime with `git pull` — there is no build step and no dependencies.

## Usage

```sh
fetch-lyrics ~/Music
fetch-lyrics ~/Music/Album1 ~/Music/Album2
fetch-lyrics ~/Music --dry-run          # show what would be written, write nothing
fetch-lyrics ~/Music --force            # overwrite existing .lrc
fetch-lyrics ~/Music --sources LRCLIB,lyrics.ovh
fetch-lyrics ~/Music --min-score 0.8
fetch-lyrics ~/Music --delay 0.6        # seconds between requests
fetch-lyrics ~/Music --embed            # also embed lyrics into the audio tags
fetch-lyrics ~/Music --jobs 4           # fetch with 4 parallel workers
fetch-lyrics --retry-misses             # only re-try paths in lyrics-misses.txt
fetch-lyrics ~/Music --no-recursive
fetch-lyrics ~/Music --m3u playlist.m3u
```

## Flags

| Flag | Meaning |
|---|---|
| `--force` | Overwrite existing sibling `.lrc` files |
| `--dry-run` | Fetch and report, but write nothing |
| `--sources A,B` | Source order (default `LRCLIB,lyrics.ovh`) |
| `--min-score N` | Minimum match score for the fuzzy fallback |
| `--delay S` | Delay between requests |
| `--embed` | Also write lyrics into the audio file tags (needs mutagen) |
| `--jobs N` | Parallel fetch workers (default `1`) |
| `--retry-misses [FILE]` | Only re-try paths listed in `FILE` (default `lyrics-misses.txt`) |
| `--no-recursive` | Do not descend into subfolders |
| `--m3u FILE` | Also read paths from an m3u playlist (repeatable) |
| `--config FILE` | Config file (default `~/.config/fetch-lyrics/config`) |
| `--no-config` | Ignore the config file |

## Config

Optional INI file at `~/.config/fetch-lyrics/config`. Command-line flags win:

```ini
[defaults]
sources = LRCLIB,lyrics.ovh
min_score = 0.70
delay = 0.4
```

## Matching

- Reads `artist`/`title`/`album`/`duration` from tags; falls back to filename parsing.
- Cleans YouTube-style noise (`(Official Video)`, `[Lyrics]`, `Sped Up`, `Slowed`, `Lirik`, ...) for searching.
- Splits multi-artist tags on `/ , & ;` (e.g. `A/fss` is also tried as just `A`).
- The fuzzy fallback only accepts a hit when the **title is a strong match and the
  duration is within 3 s**. This rejects wrong-song matches with a common title.
- Retries with exponential backoff on `429/502/503/504`, honoring `Retry-After`.

Tracks that already have a sibling `.lrc` are skipped unless `--force`.

## Output

- Writes `<same stem>.lrc` beside each audio file.
- Prints one line per track: `OK synced|plain -> name.lrc` or `MISS`.
- Prints a `SUMMARY written=.. skipped_existing=.. not_found=.. total=..`.
- Writes the not-found paths to `./lyrics-misses.txt`.

With `--embed`, lyrics are also written into the audio file itself:

- **MP3** — `USLT` (plain) plus `SYLT` (synced, when available).
- **FLAC / OGG / Opus** — `LYRICS` (synced) or `UNSYNCEDLYRICS` (plain).
- **M4A / MP4** — `©lyr`.

Files that already have lyrics are overwritten only with `--force`.

## Notes

- Rate limits are per requesting IP; the default delay keeps you under LRCLIB's.
- With `--jobs N`, requests are still spaced by `--delay`; raise the delay if you
  see `429`/`503` retries.
- LRCLIB and lyrics.ovh are public, keyless endpoints. If they change or go down,
  matching quality drops but nothing breaks.

## About

This project was **generated with AI** (vibe-coded). It started as a personal tool and
was shared as-is; the maintainer does not write code by hand. Best-effort.

## License

MIT. See `LICENSE`.
