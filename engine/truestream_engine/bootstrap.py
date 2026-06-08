import os

from truestream_engine.paths import get_paths, is_initialized


def bootstrap() -> dict:
    if not is_initialized():
        return {
            "success": False,
            "error_type": "ERROR_BOOTSTRAP_FAILED",
            "error_message": "paths/set not called before bootstrap",
        }

    paths = get_paths()

    ffmpeg_ok = False
    ffmpeg_version = None
    if paths.get("ffmpeg_path"):
        ffmpeg_ok = os.path.isfile(paths["ffmpeg_path"]) and os.access(
            paths["ffmpeg_path"], os.X_OK
        )

    aria2c_ok = False
    aria2c_version = None
    if paths.get("aria2c_path"):
        aria2c_ok = os.path.isfile(paths["aria2c_path"]) and os.access(
            paths["aria2c_path"], os.X_OK
        )

    try:
        from yt_dlp import version as yt_dlp_version

        yt_dlp_ver = yt_dlp_version.__version__
    except (ImportError, AttributeError):
        yt_dlp_ver = "unknown"

    js_runtime = _detect_js_runtime()

    return {
        "success": True,
        "yt_dlp_version": yt_dlp_ver,
        "ffmpeg_ok": ffmpeg_ok,
        "ffmpeg_version": ffmpeg_version,
        "js_runtime": js_runtime["name"],
        "js_runtime_version": js_runtime["version"],
        "aria2c_ok": aria2c_ok,
        "aria2c_version": aria2c_version,
        "needs_update": False,
        "update_components": [],
        "manifest_source": "cache",
        "contract_version": "1.0",
    }


def _detect_js_runtime() -> dict:
    try:
        import quickjs
        return {"name": "quickjs", "version": getattr(quickjs, "__version__", "0.8.0")}
    except ImportError:
        pass
    return {"name": "none", "version": None}
