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
    ffmpeg_path: str | None,
    cache_dir: str,
    cookies_path: str | None = None,
    aria2c_path: str | None = None,
    po_token: str | None = None,
) -> dict:
    import os
    _paths["data_dir"] = data_dir
    _paths["output_dir"] = output_dir
    _paths["cache_dir"] = cache_dir

    bin_dir = os.path.join(data_dir, "bin")
    is_windows = os.name == "nt" or (isinstance(os.environ.get("OS"), str) and "windows" in os.environ.get("OS").lower())
    ext = ".exe" if is_windows else ""

    if ffmpeg_path:
        _paths["ffmpeg_path"] = ffmpeg_path
    else:
        _paths["ffmpeg_path"] = os.path.join(bin_dir, f"ffmpeg{ext}")

    _paths["aria2c_path"] = aria2c_path
    _paths["cookies_path"] = cookies_path
    _paths["po_token"] = po_token

    # Inject binary directory to PATH environment variable
    path_dirs = [bin_dir]
    if _paths["ffmpeg_path"]:
        path_dirs.append(os.path.dirname(_paths["ffmpeg_path"]))
    if _paths["aria2c_path"]:
        path_dirs.append(os.path.dirname(_paths["aria2c_path"]))

    existing_path = os.environ.get("PATH", "")
    for pd in path_dirs:
        if pd and pd not in existing_path:
            existing_path = pd + os.pathsep + existing_path
    os.environ["PATH"] = existing_path

    return {"success": True}


def get_paths() -> dict:
    return dict(_paths)


def is_initialized() -> bool:
    return _paths["data_dir"] is not None
