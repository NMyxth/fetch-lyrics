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

## Install

One-liner (no dependencies):

```sh
curl -fsSL https://raw.githubusercontent.com/NMyxth/fetch-lyrics/main/fetch-lyrics \
  -o ~/.local/bin/fetch-lyrics && chmod +x ~/.local/bin/fetch-lyrics
```

Make sure `~/.local/bin` is on your `PATH`. The script filename **is** the command
(like `yt-dlp`); there is no alias.

## Usage

```sh
fetch-lyrics ~/Music
fetch-lyrics ~/Music/Album1 ~/Music/Album2
fetch-lyrics ~/Music --dry-run          # show what would be written, write nothing
fetch-lyrics ~/Music --force            # overwrite existing .lrc
fetch-lyrics ~/Music --sources LRCLIB,lyrics.ovh
fetch-lyrics ~/Music --min-score 0.8
fetch-lyrics ~/Music --delay 0.6        # seconds between requests
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

## Notes

- Rate limits are per requesting IP; the default delay keeps you under LRCLIB's.
- LRCLIB and lyrics.ovh are public, keyless endpoints. If they change or go down,
  matching quality drops but nothing breaks.

## About

This project was **generated with AI** (vibe-coded). The maintainer does not write
code by hand; it is shared as-is, best-effort.

## License

MIT. See `LICENSE`.
