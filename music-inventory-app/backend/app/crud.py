import json, os
from pathlib import Path
from typing import List

DB_PATH = Path("/data/music_inventory.json")

def _load():
    if not DB_PATH.exists():
        return {"music_inventory": []}
    return json.loads(DB_PATH.read_text(encoding="utf-8"))

def _save(data):
    DB_PATH.write_text(json.dumps(data, indent=2), encoding="utf-8")

def get_inventory() -> List[dict]:
    return _load()["music_inventory"]

def search_inventory(term: str) -> List[dict]:
    term = term.lower()
    return [rec for rec in get_inventory() if any(term in str(v).lower() for v in rec.values())]

def create_record(record: dict) -> dict:
    data = _load()
    recs = data.setdefault("music_inventory", [])
    # ensure unique serial - compare as strings
    existing = {str(r["serial_number"]) for r in recs}
    if str(record.get("serial_number")) in existing:
        raise ValueError("Duplicate serial")
    recs.append(record)
    _save(data)
    return record

def update_record(serial, new_data: dict) -> dict:
    data = _load()
    recs = data.get("music_inventory", [])
    for idx, r in enumerate(recs):
        if str(r["serial_number"]) == str(serial):
            recs[idx] = new_data
            _save(data)
            return new_data
    raise ValueError("Record not found")

def delete_record(serial):
    data = _load()
    recs = data.get("music_inventory", [])
    new_recs = [r for r in recs if str(r["serial_number"]) != str(serial)]
    data["music_inventory"] = new_recs
    _save(data)

