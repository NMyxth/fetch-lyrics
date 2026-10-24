# fetch-lyrics

Fetch `.lrc` lyrics for your whole music folder — synced when a synced version
exists. Works with any player that reads `.lrc` files sitting next to the song.

No account, no API key, no packages.

## Install

**macOS / Linux** — paste this in Terminal:

```sh
curl -fsSL https://github.com/NMyxth/fetch-lyrics/releases/latest/download/install.sh | sh
```

**Windows** — paste this in **PowerShell** (not Command Prompt):

```powershell
iwr -useb https://github.com/NMyxth/fetch-lyrics/releases/latest/download/install.ps1 | iex
```

Both installers put `fetch-lyrics` on your `PATH` and set up Python for you if
it is missing. No admin rights, nothing else to install.

## Use it

1. Open a **new** terminal, so the updated `PATH` is picked up.
2. Type `fetch-lyrics`.
3. Pick an option:

```
fetch-lyrics  interactive

  1  Search a song
  2  Browse a music folder
  3  Quit
```

- **Search a song** — type a name, pick the right result, save the `.lrc`.
- **Browse a music folder** — point it at your music, see which tracks are
  missing lyrics, fetch them all or just the ones you pick.

Prefer no menus? Point it at a folder:

```sh
fetch-lyrics ~/Music
```

## FAQ

**`'iwr' is not recognized as an internal or external command`**
You are in Command Prompt. Open PowerShell instead (`Win` → type `powershell`),
then run the Windows install command.

**"No lyrics found"**
Use `1 Search a song` and pick a result by hand. The automatic match is strict
about song duration on purpose, so it will not save the wrong lyrics.

**Where does the file go?**
Next to the song, with the same name: `Song.mp3` → `Song.lrc`.

**Will it overwrite my files?**
No. Existing `.lrc` files are skipped unless you pass `--force`.

**Does it upload anything?**
No. It only sends the artist and title to the lyrics services.

<details>
<summary><b>Advanced: batch flags, config, matching</b></summary>

### Batch usage

```sh
fetch-lyrics ~/Music
fetch-lyrics ~/Music/Album1 ~/Music/Album2
fetch-lyrics ~/Music --dry-run          # show what would be written, write nothing
fetch-lyrics ~/Music --force            # overwrite existing .lrc
fetch-lyrics ~/Music --sources LRCLIB,lyrics.ovh
fetch-lyrics ~/Music --min-score 0.8
fetch-lyrics ~/Music --delay 0.6        # starting gap between requests, in seconds
fetch-lyrics ~/Music --embed            # also embed lyrics into the audio tags
fetch-lyrics ~/Music --jobs 4           # fetch with 4 parallel workers
fetch-lyrics --retry-misses             # only re-try paths in lyrics-misses.txt
fetch-lyrics ~/Music --no-recursive
fetch-lyrics ~/Music --m3u playlist.m3u
```

Scriptable search — print matches and exit, no prompt:

```sh
fetch-lyrics --search "billie eilish bad guy"
```

Interactive saves go to the current folder, or `-o DIR`:

```sh
fetch-lyrics -i -o ~/Downloads
```

### Flags

| Flag | Meaning |
|---|---|
| `--force` | Overwrite existing sibling `.lrc` files |
| `--dry-run` | Fetch and report, but write nothing |
| `--sources A,B` | Source order (default `LRCLIB,lyrics.ovh`) |
| `--min-score N` | Minimum match score for the fuzzy fallback |
| `--delay S` | Starting gap between requests (default `0.6`; raises itself on 429/503) |
| `--embed` | Also write lyrics into the audio file tags (needs mutagen) |
| `--jobs N` | Parallel fetch workers (default `1`) |
| `--retry-misses [FILE]` | Only re-try paths listed in `FILE` (default `lyrics-misses.txt`) |
| `-i, --interactive` | Numbered menu: search a song or browse a folder |
| `--search QUERY` | Print LRCLIB matches for `QUERY` and exit (no prompt) |
| `-o DIR` | Interactive: folder for downloaded `.lrc` files (default: cwd) |
| `--no-recursive` | Do not descend into subfolders |
| `--m3u FILE` | Also read paths from an m3u playlist (repeatable) |
| `--config FILE` | Config file (default `~/.config/fetch-lyrics/config`) |
| `--no-config` | Ignore the config file |

### Config

Optional INI file at `~/.config/fetch-lyrics/config`. Command-line flags win:

```ini
[defaults]
sources = LRCLIB,lyrics.ovh
min_score = 0.70
delay = 0.6
```

### Sources

Tried in order, first hit wins:

1. **LRCLIB** — exact lookup, then a fuzzy search that is duration-guarded.
   Synced lyrics are preferred.
2. **lyrics.ovh** — plain text only.

No API key or account is needed for either. The only header sent is a
`User-Agent`; nothing personal is read or transmitted.

### Matching

- Reads `artist`/`title`/`album`/`duration` from tags; falls back to filename parsing.
- Cleans YouTube-style noise (`(Official Video)`, `[Lyrics]`, `Sped Up`, `Slowed`, `Lirik`, ...) for searching.
- Splits multi-artist tags on `/ , & ;` (e.g. `A/fss` is also tried as just `A`).
- The fuzzy fallback only accepts a hit when the **title is a strong match and the
  duration is within 3 s**. This rejects wrong-song matches with a common title.

### Output

- Writes `<same stem>.lrc` beside each audio file.
- Prints one line per track: `OK synced|plain -> name.lrc` or `MISS`.
- Prints a `SUMMARY written=.. skipped_existing=.. not_found=.. total=..`.
- Writes the not-found paths to `./lyrics-misses.txt`.

With `--embed`, lyrics are also written into the audio file itself:

- **MP3** — `USLT` (plain) plus `SYLT` (synced, when available).
- **FLAC / OGG / Opus** — `LYRICS` (synced) or `UNSYNCEDLYRICS` (plain).
- **M4A / MP4** — `©lyr`.

### Rate limits

- Requests are paced adaptively: `--delay` is the starting gap, it grows by
  0.5 s after a `429`/`503` (up to 3 s) and drifts back down after 10 clean
  requests. Retries back off 1 → 2 → 4 → 8 → 16 s with jitter.
- If a host fails two requests in a row, it is skipped for 60 s instead of
  stalling on every remaining track.
- Rate limits are per requesting IP. `--jobs N` still respects the shared pacing,
  so parallel workers cannot burst past it.

### From source

```sh
git clone https://github.com/NMyxth/fetch-lyrics.git
cd fetch-lyrics
./src/fetch-lyrics ~/Music
```

On Windows use `src\fetch-lyrics.cmd`. Update anytime with `git pull` — there is
no build step and no packages.

</details>

## About

This project was **generated with AI** (vibe-coded). It started as a personal tool and
was shared as-is; the maintainer does not write code by hand. Best-effort.

## License

MIT. See [`LICENSE`](LICENSE).
