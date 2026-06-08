import json
import queue as _queue


_POSTPROCESSOR_STAGES = {
    "after_move": ("merging", "Merging streams..."),
    "after_thumbnail": ("embedding_thumbnail", "Embedding thumbnail..."),
    "after_video": ("muxing", "Muxing video & audio..."),
    "after_audio": ("extracting_audio", "Extracting audio..."),
}


def build_progress_hook(queue: _queue.Queue):
    from yt_dlp import YoutubeDL

    def progress_hook(d: dict):
        status = d.get("status", "")
        download_id = d.get("info_dict", {}).get("__download_id", "")

        if status == "downloading":
            queue.put(json.dumps({
                "type": "event",
                "event": "downloading",
                "download_id": download_id,
                "downloaded_bytes": d.get("downloaded_bytes", 0),
                "total_bytes": d.get("total_bytes") or d.get("total_bytes_estimate", 0),
                "total_bytes_is_estimate": d.get("total_bytes") is None,
                "speed": d.get("speed", 0),
                "eta": d.get("eta", 0),
                "filename": d.get("filename", ""),
                "fragment_index": d.get("fragment_index"),
                "fragment_count": d.get("fragment_count"),
                "stream": d.get("info_dict", {}).get("__stream_type"),
            }))

        elif status == "finished":
            queue.put(json.dumps({
                "type": "event",
                "event": "finished",
                "download_id": download_id,
                "filename": d.get("filename", ""),
                "total_bytes": d.get("total_bytes", 0),
            }))

        elif status == "error":
            queue.put(json.dumps({
                "type": "event",
                "event": "error",
                "download_id": download_id,
                "error_type": "ERROR_DOWNLOAD",
                "error_message": d.get("error", "Unknown error"),
                "recoverable": True,
            }))

    def postprocessor_hook(d: dict):
        status = d.get("status", "")
        pp_key = d.get("postprocessor", "")
        stage, label = _POSTPROCESSOR_STAGES.get(status, ("", "Processing..."))

        if status == "started":
            queue.put(json.dumps({
                "type": "event",
                "event": "postprocessing",
                "download_id": download_id,
                "stage": stage or pp_key,
                "stage_label": label,
            }))

    return progress_hook
