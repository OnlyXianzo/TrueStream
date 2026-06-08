_paths = {
    "data_dir": None,
    "output_dir": None,
    "ffmpeg_path": None,
    "cache_dir": None,
    "cookies_path": None,
    "aria2c_path": None,
    "po_token": None,
}


def set_paths(
    data_dir: str,
    output_dir: str,
    ffmpeg_path: str,
    cache_dir: str,
    cookies_path: str | None = None,
    aria2c_path: str | None = None,
    po_token: str | None = None,
) -> dict:
    _paths["data_dir"] = data_dir
    _paths["output_dir"] = output_dir
    _paths["ffmpeg_path"] = ffmpeg_path
    _paths["cache_dir"] = cache_dir
    _paths["cookies_path"] = cookies_path
    _paths["aria2c_path"] = aria2c_path
    _paths["po_token"] = po_token
    return {"success": True}


def get_paths() -> dict:
    return dict(_paths)


def is_initialized() -> bool:
    return _paths["data_dir"] is not None
