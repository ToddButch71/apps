import json
import tempfile
import unittest
from pathlib import Path

from update_inventory import add_or_append


class AlbumGroupingTests(unittest.TestCase):
    def setUp(self):
        self.tmpdir = tempfile.TemporaryDirectory()
        self.root = Path(self.tmpdir.name)

    def tearDown(self):
        self.tmpdir.cleanup()

    def _read_json(self, p: Path):
        return json.loads(p.read_text(encoding="utf-8"))

    def test_group_albums_by_media_and_year(self):
        """Test that albums are correctly grouped for the same artist based on media/year/genre"""
        read_path = self.root / "inventory.json"
        initial = {
            "music_inventory": [
                {
                    "artist": "Test Artist",
                    "titles": ["Album 1 Track 1"],
                    "media": "cd",
                    "year": 2020,
                    "serial_number": 1,
                    "genre": "rock"
                }
            ]
        }
        read_path.write_text(json.dumps(initial), encoding="utf-8")
        write_path = self.root / "out.json"

        # Add a track to the same CD album (should append)
        add_or_append(
            artist="Test Artist",
            title="Album 1 Track 2",
            media="cd",
            year=2020,
            genre="rock",
            merge=True,
            read_path=read_path,
            write_path=write_path,
        )

        # Add a track to a different album (different year, should create new)
        add_or_append(
            artist="Test Artist",
            title="Album 2 Track 1",
            media="cd",
            year=2021,
            genre="rock",
            merge=True,
            read_path=write_path,
            write_path=write_path,
        )

        # Add a vinyl release (different media, should create new)
        add_or_append(
            artist="Test Artist",
            title="Vinyl Track",
            media="vinyl",
            year=2020,
            genre="rock",
            merge=True,
            read_path=write_path,
            write_path=write_path,
        )

        data = self._read_json(write_path)
        recs = data.get("music_inventory", [])
        
        # Should have 3 records for the artist
        artist_records = [r for r in recs if r["artist"] == "Test Artist"]
        self.assertEqual(len(artist_records), 3)
        
        # First album should have both tracks
        cd_2020 = next(r for r in artist_records if r["media"] == "cd" and r["year"] == 2020)
        self.assertEqual(set(cd_2020["titles"]), {"Album 1 Track 1", "Album 1 Track 2"})
        
        # Second album should be the 2021 CD
        cd_2021 = next(r for r in artist_records if r["media"] == "cd" and r["year"] == 2021)
        self.assertEqual(cd_2021["titles"], ["Album 2 Track 1"])
        
        # Third should be the vinyl
        vinyl = next(r for r in artist_records if r["media"] == "vinyl")
        self.assertEqual(vinyl["titles"], ["Vinyl Track"])


if __name__ == "__main__":
    unittest.main()