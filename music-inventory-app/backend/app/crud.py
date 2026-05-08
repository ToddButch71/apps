import json, os
from pathlib import Path
from typing import List
import shutil
import tempfile
from datetime import datetime, timedelta
import fcntl
import time
import glob

DB_PATH = Path("/data/music_inventory.json")
LOCK_PATH = Path("/data/.music_inventory.lock")

class FileLock:
    """Context manager for file locking."""
    def __init__(self, lock_path, timeout=10):
        self.lock_path = lock_path
        self.timeout = timeout
        self.lock_file = None
    
    def __enter__(self):
        start_time = time.time()
        while True:
            try:
                # Open lock file (create if doesn't exist)
                self.lock_file = open(self.lock_path, 'w')
                # Try to acquire exclusive lock (non-blocking)
                fcntl.flock(self.lock_file.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)
                return self
            except (IOError, OSError):
                # Lock is held by another process
                if time.time() - start_time > self.timeout:
                    raise TimeoutError(f"Could not acquire lock after {self.timeout} seconds")
                time.sleep(0.1)  # Wait 100ms before retrying
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        if self.lock_file:
            try:
                fcntl.flock(self.lock_file.fileno(), fcntl.LOCK_UN)
                self.lock_file.close()
            except:
                pass
        return False

def _load():
    if not DB_PATH.exists():
        return {"music_inventory": []}
    return json.loads(DB_PATH.read_text(encoding="utf-8"))

def _cleanup_old_backups(days=1):
    """Delete backup files older than specified number of days."""
    try:
        backup_pattern = str(DB_PATH.parent / f"{DB_PATH.name}.backup_*")
        backup_files = glob.glob(backup_pattern)
        
        cutoff_time = datetime.now() - timedelta(days=days)
        deleted_count = 0
        
        for backup_file in backup_files:
            try:
                # Extract timestamp from filename
                timestamp_str = backup_file.split('.backup_')[-1]
                backup_time = datetime.strptime(timestamp_str, "%Y%m%d_%H%M%S")
                
                # Delete if older than cutoff
                if backup_time < cutoff_time:
                    os.remove(backup_file)
                    deleted_count += 1
            except (ValueError, IndexError):
                # Skip files that don't match expected format
                continue
        
        if deleted_count > 0:
            print(f"Cleaned up {deleted_count} old backup(s)")
    except Exception as e:
        print(f"Warning: Could not cleanup old backups: {e}")

def _save(data):
    """
    Safely save data to JSON file using atomic write:
    1. Write to temporary file
    2. Validate JSON
    3. Atomically replace original file
    """
    # Backup creation disabled per user request
    # if DB_PATH.exists():
    #     timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    #     backup_path = DB_PATH.parent / f"{DB_PATH.name}.backup_{timestamp}"
    #     try:
    #         shutil.copy2(DB_PATH, backup_path)
    #         # Cleanup old backups after creating new one
    #         _cleanup_old_backups(days=1)
    #     except Exception as e:
    #         print(f"Warning: Could not create backup: {e}")
    
    # Write to temporary file in same directory (ensures same filesystem for atomic move)
    temp_fd, temp_path = tempfile.mkstemp(
        dir=DB_PATH.parent,
        prefix=".music_inventory_",
        suffix=".json.tmp"
    )
    
    try:
        # Write data to temporary file
        with os.fdopen(temp_fd, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
            f.flush()
            os.fsync(f.fileno())  # Force write to disk before moving
        
        # Validate the temporary file before moving
        temp_path_obj = Path(temp_path)
        try:
            json.loads(temp_path_obj.read_text(encoding="utf-8"))
        except json.JSONDecodeError as e:
            raise ValueError(f"Generated invalid JSON: {e}")
        
        # Use os.replace() with retry for robustness (handles file locking issues)
        max_retries = 5
        retry_delay = 0.1
        last_error = None
        
        for attempt in range(max_retries):
            try:
                if attempt > 0:
                    time.sleep(retry_delay)
                
                # Atomic replace operation
                os.replace(temp_path, str(DB_PATH))
                break  # Success!
                
            except OSError as e:
                last_error = e
                if e.errno == 16:  # Resource busy
                    if attempt < max_retries - 1:
                        print(f"File busy, retrying ({attempt + 1}/{max_retries})...")
                        continue
                raise  # Re-raise if not resource busy or out of retries
        else:
            # All retries exhausted
            raise OSError(f"Failed to replace file after {max_retries} attempts: {last_error}")
        
    except Exception as e:
        # Clean up temp file on error
        try:
            if os.path.exists(temp_path):
                Path(temp_path).unlink(missing_ok=True)
        except:
            pass
        raise e

def get_inventory() -> List[dict]:
    return _load()["music_inventory"]

def search_inventory(term: str) -> List[dict]:
    term = term.lower()
    return [rec for rec in get_inventory() if any(term in str(v).lower() for v in rec.values())]

def create_record(record: dict) -> dict:
    with FileLock(LOCK_PATH):
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
    with FileLock(LOCK_PATH):
        data = _load()
        recs = data.get("music_inventory", [])
        for idx, r in enumerate(recs):
            if str(r["serial_number"]) == str(serial):
                recs[idx] = new_data
                _save(data)
                return new_data
        raise ValueError("Record not found")

def delete_record(serial):
    with FileLock(LOCK_PATH):
        data = _load()
        recs = data.get("music_inventory", [])
        new_recs = [r for r in recs if str(r["serial_number"]) != str(serial)]
        data["music_inventory"] = new_recs
        _save(data)

