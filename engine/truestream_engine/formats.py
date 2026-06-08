from yt_dlp import YoutubeDL

from truestream_engine.paths import get_paths
from truestream_engine.format_selector import build_format_string
from truestream_engine.errors import classify_error, TrueStreamError


def get_formats(url: str, config: dict | None = None) -> dict:
    paths = get_paths()
    cfg = config or {}

    opts = {
        "quiet": True,
        "no_warnings": True,
    }

    cookies = cfg.get("cookies_path") or paths.get("cookies_path")
    if cookies:
        opts["cookiefile"] = cookies
    if cfg.get("proxy"):
        opts["proxy"] = cfg["proxy"]

    try:
        with YoutubeDL(opts) as ydl:
            info = ydl.extract_info(url, download=False)

        if info is None:
            return {"success": False, "error_type": "ERROR_UNAVAILABLE", "error_message": "Could not extract info"}

        is_playlist = info.get("_type") == "playlist" or "entries" in info
        formats_raw = info.get("formats", [])
        if is_playlist and not formats_raw:
            first = info.get("entries", [None])[0]
            if first:
                formats_raw = first.get("formats", [])

        parsed = []
        for f in formats_raw:
            if f.get("vcodec") == "none" and f.get("acodec") == "none":
                continue

            parsed.append({
                "format_id": f.get("format_id", ""),
                "ext": f.get("ext", ""),
                "vcodec": f.get("vcodec", "none") or "none",
                "acodec": f.get("acodec", "none") or "none",
                "height": f.get("height"),
                "width": f.get("width"),
                "fps": f.get("fps"),
                "tbr": f.get("tbr"),
                "abr": f.get("abr"),
                "filesize": f.get("filesize"),
                "filesize_is_estimate": f.get("filesize") is None,
                "is_hdr": "hdr" in str(f.get("dynamic_range", "")).lower(),
                "dynamic_range": f.get("dynamic_range", "SDR"),
                "stream_type": "audio" if f.get("vcodec") == "none" else "video",
            })

        # Find recommended formats
        best_video = None
        best_audio = None
        for f in parsed:
            if f["stream_type"] == "video":
                if best_video is None or (f.get("height") or 0) > (best_video.get("height") or 0):
                    best_video = f
            else:
                if best_audio is None or (f.get("abr") or 0) > (best_audio.get("abr") or 0):
                    best_audio = f

        return {
            "success": True,
            "title": info.get("title", ""),
            "duration_seconds": info.get("duration"),
            "thumbnail_url": info.get("thumbnail"),
            "is_live": info.get("is_live", False),
            "is_playlist": is_playlist,
            "formats": parsed,
            "recommended_video_format_id": best_video["format_id"] if best_video else None,
            "recommended_audio_format_id": best_audio["format_id"] if best_audio else None,
        }

    except Exception as exc:
        err = classify_error(exc)
        return {
            "success": False,
            "error_type": err.error_type,
            "error_message": err.message,
        }
