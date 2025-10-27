import json
import tempfile
import unittest
from pathlib import Path

from update_inventory import sort_inventory, list_albums_by_artist


class InventorySortingTests(unittest.TestCase):
    def setUp(self):
        self.sample_data = {
            "music_inventory": [
                {
                    "artist": "ZZ Top",
                    "titles": ["Track 1"],
                    "media": "cd",
                    "year": 2020,
                    "serial_number": 1,
                    "genre": "rock"
                },
                {
                    "artist": "Beatles",
                    "titles": ["Track 2"],
                    "media": "vinyl",
                    "year": 1969,
                    "serial_number": 2,
                    "genre": "rock"
                },
                {
                    "artist": "Beatles",
                    "titles": ["Track 3"],
                    "media": "cd",
                    "year": 1969,
                    "serial_number": 3,
                    "genre": "rock"
                }
            ]
        }

    def test_sort_inventory(self):
        result = sort_inventory(self.sample_data)
        recs = result["music_inventory"]
        
        # Records should be sorted by artist (Beatles before ZZ Top)
        self.assertEqual(recs[0]["artist"], "Beatles")
        self.assertEqual(recs[1]["artist"], "Beatles")
        self.assertEqual(recs[2]["artist"], "ZZ Top")
        
        # For same artist and year, should sort by media (cd before vinyl)
        beatles = [r for r in recs if r["artist"] == "Beatles"]
        self.assertEqual(beatles[0]["media"], "cd")
        self.assertEqual(beatles[1]["media"], "vinyl")

    def test_list_albums_by_artist(self):
        albums = list_albums_by_artist(self.sample_data, "Beatles")
        
        self.assertEqual(len(albums), 2)
        self.assertEqual(albums[0]["media"], "cd")
        self.assertEqual(albums[1]["media"], "vinyl")
        self.assertEqual(albums[0]["year"], 1969)
        self.assertEqual(albums[0]["titles"], ["Track 3"])
        
        # Test non-existent artist
        no_albums = list_albums_by_artist(self.sample_data, "Non Existent")
        self.assertEqual(len(no_albums), 0)


if __name__ == "__main__":
    unittest.main()