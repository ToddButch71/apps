#!/usr/bin/env python3
"""
update_inventory.py

Small CLI to add a title to an existing artist or create a new record.
It avoids duplicate titles and avoids duplicate serial_number by auto-assigning
a new serial (max+1) when a provided serial_number conflicts.

Usage examples:
  python update_inventory.py --artist "New Artist" --title "New Track" --media digital --year 2025 --serial 1001 --genre electronic
  python update_inventory.py --artist "The Beatles" --title "Here Comes the Sun"

By default: if artist exists, the title is appended (if not already present).
If artist does not exist, a new record is created. If `--serial` is given and
conflicts, the script will assign the next available serial number unless
`--no-auto-resolve` is provided.
"""
import argparse
import json
import tempfile
import sys
from pathlib import Path
from typing import Optional

DEFAULT_PATH = Path("/Volumes/data/github/apps/music_inventory/music_inventory.json")


def load(read_path: Path = DEFAULT_PATH):
    try:
        text = read_path.read_text(encoding="utf-8")
        return json.loads(text)
    except FileNotFoundError:
        return {}


def save(data, write_path: Path = DEFAULT_PATH):
    write_path.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"Saved {write_path}")


def next_serial(data):
    recs = data.get("music_inventory", [])
    nums = [r.get("serial_number", 0) for r in recs if isinstance(r.get("serial_number", None), int)]
    return (max(nums) + 1) if nums else 1


def list_serials(data):
    return {r.get("serial_number") for r in data.get("music_inventory", []) if r.get("serial_number") is not None}


def sort_inventory(data):
    """Sort and regroup inventory records by artist, then by media/year/genre.
    Records for the same artist are kept together, sorted by year then media type.
    Returns a new dict with sorted records; does not modify input.
    """
    result = {"music_inventory": []}
    recs = data.get("music_inventory", [])
    
    # Group by artist first
    by_artist = {}
    for rec in recs:
        artist = rec.get("artist", "")
        if artist not in by_artist:
            by_artist[artist] = []
        by_artist[artist].append(rec)
    
    # Sort artists alphabetically and sort each artist's albums by year/media
    for artist in sorted(by_artist.keys()):
        albums = by_artist[artist]
        sorted_albums = sorted(
            albums,
            key=lambda r: (r.get("year", 0), r.get("media", ""), r.get("genre", ""))
        )
        result["music_inventory"].extend(sorted_albums)
    
    return result


def list_albums_by_artist(data, artist):
    """List all albums by the given artist, grouped by media type.
    Returns a list of albums, empty if artist not found.
    """
    matches = []
    for rec in data.get("music_inventory", []):
        if rec.get("artist") == artist:
            matches.append({
                "media": rec.get("media", "unknown"),
                "year": rec.get("year", 0),
                "genre": rec.get("genre", ""),
                "serial": rec.get("serial_number"),
                "titles": rec.get("titles", [])
            })
    
    return sorted(matches, key=lambda r: (r["year"], r["media"]))


def add_or_append(artist: str,
                  title: str,
                  media: str = "cd",
                  year: Optional[int] = None,
                  serial_number: Optional[int] = None,
                  genre: Optional[str] = None,
                  auto_resolve_serial_conflict: bool = True,
                  merge: bool = False,
                  read_path: Path = DEFAULT_PATH,
                  write_path: Path = DEFAULT_PATH):
    """If merge==True, try to find a matching artist record. For the same artist:
    - If an album with matching media/year/genre exists, append the title to it
    - Otherwise create a new album entry for that artist
    If merge==False or artist not found, create a new record.
    In all cases, serial_number is kept unique; if it conflicts and auto_resolve_serial_conflict
    is True, a new serial (max+1) will be assigned.
    """
    data = load(read_path)
    recs = data.setdefault("music_inventory", [])

    if merge:
        # Find artist and try to group with matching album if exists
        for idx, rec in enumerate(recs):
            if rec.get("artist") == artist:
                # Check if we have a matching album entry (same media/year/genre)
                if (rec.get("media") == media and 
                    rec.get("year") == (year or 0) and 
                    rec.get("genre") == (genre or "")):
                    # Found matching album, append title
                    rec.setdefault("titles", [])
                    if title not in rec["titles"]:
                        rec["titles"].append(title)
                        print(f'Appended "{title}" to existing {media} album for "{artist}"')
                    else:
                        print(f'Title "{title}" already exists in album')
                    save(data, write_path)
                    return
                else:
                    # Create new album entry for this artist
                    if serial_number is None:
                        serial_number = next_serial(data)
                    else:
                        existing = list_serials(data)
                        if serial_number in existing:
                            if auto_resolve_serial_conflict:
                                new_serial = next_serial(data)
                                print(f"Serial {serial_number} exists; assigning {new_serial}.")
                                serial_number = new_serial
                            else:
                                raise ValueError(f"Serial {serial_number} exists (auto-resolve=False)")
                    
                    new_album = {
                        "media": media,
                        "artist": artist,
                        "titles": [title],
                        "year": year or 0,
                        "serial_number": serial_number,
                        "genre": genre or ""
                    }
                    # Insert new album right after the existing record for this artist
                    recs.insert(idx + 1, new_album)
                    print(f'Added new {media} album for "{artist}" with serial {serial_number}')
                    save(data, write_path)
                    return

    # Create new record (either merge was false or artist not found)
    if serial_number is None:
        serial_number = next_serial(data)
    else:
        existing = list_serials(data)
        if serial_number in existing:
            if auto_resolve_serial_conflict:
                new_serial = next_serial(data)
                print(f"Serial {serial_number} exists; assigning {new_serial}.")
                serial_number = new_serial
            else:
                raise ValueError(f"Serial {serial_number} exists (auto-resolve=False)")

    new = {
        "media": media,
        "artist": artist,
        "titles": [title],
        "year": year or 0,
        "serial_number": serial_number,
        "genre": genre or ""
    }
    recs.append(new)
    print(f'Created new record for "{artist}" with serial_number {serial_number}.')
    save(data, write_path)


if __name__ == "__main__":
    p = argparse.ArgumentParser(description="Add a title to an existing artist or create a new inventory record.")
    p.add_argument("--artist", help="Artist name (will prompt if missing when running interactively)")
    p.add_argument("--title", help="Title to add (will prompt if missing when running interactively)")
    p.add_argument("--media", default="cd", help="Media type (cd, vinyl, digital, dvd, etc.)")
    p.add_argument("--year", type=int, help="Year")
    p.add_argument("--serial", type=int, dest="serial", help="Serial number for new record (optional)")
    p.add_argument("--genre", help="Genre e.g. rock, pop, jazz (optional)")
    p.add_argument("--no-auto-resolve", action="store_true", help="If set and serial conflicts, raise an error instead of auto-assigning")
    p.add_argument("--merge", action="store_true", help="If set, append title to first matching artist record (duplicates allowed). Otherwise create a new record")
    p.add_argument("--path", default=str(DEFAULT_PATH), help="Path to music_inventory.json")
    p.add_argument("--dry-run", action="store_true", help="If set, write output to a temporary file instead of modifying the real inventory")
    p.add_argument("--sort", action="store_true", help="Sort and regroup all records by artist/year/media")
    p.add_argument("--list-artist", help="List all albums by the specified artist")

    args = p.parse_args()
    # If running interactively (TTY), prompt for any missing values; if not a TTY, require artist/title
    def _ask(prompt: str, default: Optional[str] = None) -> str:
        if default is None:
            v = input(f"{prompt}: ").strip()
            return v
        else:
            v = input(f"{prompt} [{default}]: ").strip()
            return v if v != "" else default

    def _ask_int(prompt: str, allow_empty: bool = True, default: Optional[int] = None) -> Optional[int]:
        while True:
            default_text = str(default) if default is not None else None
            v = _ask(prompt, default_text)
            if v == "" and allow_empty:
                return None
            try:
                return int(v)
            except ValueError:
                print("Please enter a valid integer or press Enter to skip.")

    if sys.stdin.isatty():
        # interactive: prompt for missing values
        if not args.artist:
            args.artist = _ask("Artist")
        if not args.title:
            args.title = _ask("Title")
        if not args.media:
            args.media = _ask("Media (cd, vinyl, digital)", "cd")
        # year and serial are optional integers
        if args.year is None:
            args.year = _ask_int("Year (press Enter for none)")
        if args.serial is None:
            args.serial = _ask_int("Serial number (press Enter to auto-assign)")
        if not args.genre:
            args.genre = _ask("Genre (optional)", "")
        # boolean flags: ask yes/no
        if not args.no_auto_resolve:
            ar = _ask("Auto-resolve serial conflicts? (Y/n)", "Y")
            args.no_auto_resolve = False if str(ar).lower().startswith("y") else True
        if not args.merge:
            mg = _ask("Merge (append title to existing artist if present)? (y/N)", "N")
            args.merge = True if str(mg).lower().startswith("y") else False
        # path and dry-run
        args.path = _ask("Inventory path", args.path)
        if not args.dry_run:
            dr = _ask("Dry-run (write to temp file instead of inventory)? (y/N)", "N")
            args.dry_run = True if str(dr).lower().startswith("y") else False
    else:
        # non-interactive: ensure required values provided
        if not args.artist or not args.title:
            p.error("--artist and --title are required when not running interactively")
    read_path_arg = Path(args.path)

    # Handle --list-artist first (read-only operation)
    if args.list_artist:
        data = load(read_path_arg)
        albums = list_albums_by_artist(data, args.list_artist)
        if not albums:
            print(f'No albums found for artist "{args.list_artist}"')
            raise SystemExit(0)
        
        print(f'\nAlbums by {args.list_artist}:')
        print('-' * (len(args.list_artist) + 10))
        current_year = None
        for album in albums:
            if album["year"] != current_year:
                current_year = album["year"]
                print(f"\n{current_year}:")
            titles = ", ".join(album["titles"])
            print(f"  {album['media']:6} | {album['genre']:10} | #{album['serial']:4} | {titles}")
        raise SystemExit(0)

    # Handle --sort (requires write path)
    if args.sort:
        # decide write path: real file or temporary file for dry-run
        if args.dry_run:
            tf = tempfile.NamedTemporaryFile(prefix="music_inventory.sorted.", suffix=".json", delete=False)
            tf.close()
            write_path_arg = Path(tf.name)
            print(f"Dry-run: will write sorted output to {write_path_arg}")
        else:
            write_path_arg = read_path_arg
        
        data = load(read_path_arg)
        sorted_data = sort_inventory(data)
        save(sorted_data, write_path_arg)
        raise SystemExit(0)

    # Regular add/append operation
    # decide write path: real file or temporary file for dry-run
    if args.dry_run:
        tf = tempfile.NamedTemporaryFile(prefix="music_inventory.dryrun.", suffix=".json", delete=False)
        tf.close()
        write_path_arg = Path(tf.name)
        print(f"Dry-run: will write output to {write_path_arg}")
    else:
        write_path_arg = read_path_arg

    try:
        # If interactive, show a short summary and ask for confirmation before saving.
        def _confirm(prompt: str, default: str = "Y") -> bool:
            resp = input(f"{prompt} ({'Y/n' if default.upper() == 'Y' else 'y/N'}): ").strip()
            if resp == "":
                resp = default
            return str(resp).lower().startswith("y")

        if sys.stdin.isatty():
            # Determine whether this will append to an existing artist (merge) or create new
            existing_data = load(read_path_arg)
            exists = any(r.get("artist") == args.artist for r in existing_data.get("music_inventory", []))
            action = "Append title to existing artist record" if (args.merge and exists) else "Create new record"
            serial_text = str(args.serial) if args.serial is not None else "(auto-assigned)"
            dryrun_text = "(dry-run, will write to temp file)" if args.dry_run else "(will write to inventory path)"

            print("\nSummary:\n--------")
            print(f"Action: {action}")
            print(f"Artist: {args.artist}")
            print(f"Title: {args.title}")
            print(f"Media: {args.media}")
            print(f"Year: {args.year or '(none)'}")
            print(f"Serial: {serial_text}")
            print(f"Genre: {args.genre or '(none)'}")
            print(f"Inventory path: {read_path_arg} {dryrun_text}")
            print("--------")

            if not _confirm("Proceed to save?", "Y"):
                print("Aborted by user.")
                raise SystemExit(1)

        add_or_append(
            artist=args.artist,
            title=args.title,
            media=args.media,
            year=args.year,
            serial_number=args.serial,
            genre=args.genre,
            auto_resolve_serial_conflict=(not args.no_auto_resolve),
            merge=args.merge,
            read_path=read_path_arg,
            write_path=write_path_arg,
        )
    except Exception as e:
        print("Error:", e)
        raise
