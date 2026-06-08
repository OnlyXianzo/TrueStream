class TrueStreamError(Exception):
    def __init__(self, error_type: str, message: str, recoverable: bool = True):
        self.error_type = error_type
        self.message = message
        self.recoverable = recoverable

    def to_dict(self) -> dict:
        return {
            "error_type": self.error_type,
            "error_message": self.message,
            "recoverable": self.recoverable,
        }


_ERROR_MAP = {
    "not available in your country": ("ERROR_GEO_BLOCKED", True),
    "sign in to confirm your age": ("ERROR_AGE_RESTRICTED", True),
    "this video is private": ("ERROR_PRIVATE", True),
    "video unavailable": ("ERROR_UNAVAILABLE", False),
    "HTTP Error 429": ("ERROR_RATE_LIMITED", True),
    "HTTP Error 403": ("ERROR_FORBIDDEN", True),
    "no video formats found": ("ERROR_FORMAT_UNAVAILABLE", True),
    "drm": ("ERROR_DRM", False),
    "jsinterpreter": ("ERROR_JS_RUNTIME", True),
    "unable to download": ("ERROR_NETWORK", True),
    "file sharing violation": ("ERROR_FILE_LOCKED", True),
    "quota exceeded": ("ERROR_QUOTA_EXCEEDED", False),
    "no space left": ("ERROR_QUOTA_EXCEEDED", False),
}


def classify_error(exc: Exception, stderr: str = "") -> TrueStreamError:
    msg = str(exc)
    combined = (msg + " " + stderr).lower()

    for keyword, (error_type, recoverable) in _ERROR_MAP.items():
        if keyword.lower() in combined:
            return TrueStreamError(error_type, msg, recoverable)

    if "HTTP Error" in combined:
        return TrueStreamError("ERROR_NETWORK", msg, True)

    return TrueStreamError("ERROR_UNKNOWN", msg, True)
