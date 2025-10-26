import json
import tempfile
import unittest
from pathlib import Path

from update_inventory import add_or_append

class UpdateInventoryTests(unittest.TestCase):
    def setUp(self):
        self.tmpdir = tempfile.TemporaryDirectory()
        self.root = Path(self.tmpdir.name)

    def tearDown(self):
        self.tmpdir.cleanup()

    def _read_json(self, p: Path):
        return json.loads(p.read_text(encoding="utf-8"))

    def test_create_new_record(self):
        read_path = self.root / "inventory.json"
        read_path.write_text("{}", encoding="utf-8")
        write_path = self.root / "out.json"

        add_or_append(
            artist="New Artist",
            title="New Track",
            media="digital",
            year=2025,
            serial_number=None,
            genre="electronic",
            auto_resolve_serial_conflict=True,
            merge=False,
            read_path=read_path,
            write_path=write_path,
        )

        data = self._read_json(write_path)
        recs = data.get("music_inventory", [])
        self.assertEqual(len(recs), 1)
        rec = recs[0]
        self.assertEqual(rec["artist"], "New Artist")
        self.assertEqual(rec["titles"], ["New Track"])
        self.assertEqual(rec["media"], "digital")
        self.assertEqual(rec["year"], 2025)
        self.assertEqual(rec["genre"], "electronic")
        self.assertIsInstance(rec["serial_number"], int)

    def test_serial_conflict_auto_resolve(self):
        read_path = self.root / "inventory.json"
        initial = {
            "music_inventory": [
                {
                    "artist": "A",
                    "titles": ["t1"],
                    "media": "cd",
                    "year": 2000,
                    "serial_number": 100,
                    "genre": "",
                }
            ]
        }
        read_path.write_text(json.dumps(initial), encoding="utf-8")
        write_path = self.root / "out.json"

        add_or_append(
            artist="B",
            title="t2",
            serial_number=100,
            read_path=read_path,
            write_path=write_path,
        )

        data = self._read_json(write_path)
        recs = data.get("music_inventory", [])
        self.assertTrue(any(r["artist"] == "B" for r in recs))
        brec = next(r for r in recs if r["artist"] == "B")
        self.assertEqual(brec["serial_number"], 101)

    def test_merge_append(self):
        read_path = self.root / "inventory.json"
        initial = {
            "music_inventory": [
                {
                    "artist": "Existing",
                    "titles": ["old"],
                    "media": "vinyl",
                    "year": 1999,
                    "serial_number": 1,
                    "genre": "rock",
                }
            ]
        }
        read_path.write_text(json.dumps(initial), encoding="utf-8")
        write_path = self.root / "out.json"

        add_or_append(
            artist="Existing",
            title="new",
            merge=True,
            read_path=read_path,
            write_path=write_path,
        )

        data = self._read_json(write_path)
        recs = data.get("music_inventory", [])
        rec = next(r for r in recs if r["artist"] == "Existing")
        self.assertIn("new", rec["titles"])

if __name__ == "__main__":
    unittest.main()
