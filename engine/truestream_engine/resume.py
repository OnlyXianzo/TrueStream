import os
import time


def scan_resume_candidates(cache_dir: str) -> dict:
    candidates = []
    now = time.time()
    max_age = 86400  # 24h

    if not os.path.isdir(cache_dir):
        return {"success": True, "candidates": []}

    for entry in os.listdir(cache_dir):
        if not entry.endswith(".part"):
            continue

        filepath = os.path.join(cache_dir, entry)
        try:
            stat = os.stat(filepath)
        except OSError:
            continue

        age = now - stat.st_mtime
        candidates.append({
            "filename": entry,
            "filepath": filepath,
            "size_bytes": stat.st_size,
            "age_seconds": int(age),
            "likely_url": None,
            "expired": age > max_age,
        })

    return {"success": True, "candidates": candidates}
