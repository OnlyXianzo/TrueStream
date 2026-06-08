from truestream_engine.format_selector import build_format_string


class TestBuildFormatString:
    def test_audio_only_opus(self):
        cfg = {"audio_only": True, "audio_format": "opus"}
        result = build_format_string(cfg)
        assert result == "bestaudio[ext=webm]/bestaudio"

    def test_audio_only_m4a(self):
        cfg = {"audio_only": True, "audio_format": "m4a"}
        result = build_format_string(cfg)
        assert result == "bestaudio[ext=m4a]/bestaudio"

    def test_audio_only_flac(self):
        cfg = {"audio_only": True, "audio_format": "flac"}
        result = build_format_string(cfg)
        assert "flac" in result

    def test_audio_only_mp3(self):
        cfg = {"audio_only": True, "audio_format": "mp3"}
        result = build_format_string(cfg)
        assert result == "bestaudio[ext=mp3]/bestaudio"

    def test_video_4k(self):
        cfg = {"audio_only": False, "quality_ceiling": "4k"}
        result = build_format_string(cfg)
        assert "height<=2160" in result

    def test_video_1080p(self):
        cfg = {"audio_only": False, "quality_ceiling": "1080p"}
        result = build_format_string(cfg)
        assert "height<=1080" in result

    def test_video_720p(self):
        cfg = {"audio_only": False, "quality_ceiling": "720p"}
        result = build_format_string(cfg)
        assert "height<=720" in result

    def test_video_best(self):
        cfg = {"audio_only": False, "quality_ceiling": "best"}
        result = build_format_string(cfg)
        assert result == "bestvideo+bestaudio/best"

    def test_explicit_video_format(self):
        cfg = {"explicit_format_id": "137"}
        result = build_format_string(cfg)
        assert result == "137"

    def test_explicit_video_and_audio_format(self):
        cfg = {"explicit_format_id": "137", "explicit_audio_format_id": "140"}
        result = build_format_string(cfg)
        assert result == "137+140"

    def test_explicit_overrides_audio_only(self):
        cfg = {
            "audio_only": True,
            "audio_format": "opus",
            "explicit_format_id": "137",
            "explicit_audio_format_id": "140",
        }
        result = build_format_string(cfg)
        assert result == "137+140"
