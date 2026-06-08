import os
import tempfile
from truestream_engine.resume import scan_resume_candidates
from truestream_engine.site_profiles import (
    load_site_profiles,
    load_profiles_from_disk,
    save_profiles_to_disk,
)
from truestream_engine.po_token import generate_po_token
from truestream_engine.bootstrap import bootstrap, _detect_js_runtime
from truestream_engine.paths import set_paths, _paths


class TestScanResumeCandidates:
    def test_empty_cache_dir(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            result = scan_resume_candidates(tmpdir)
            assert result["success"] is True
            assert result["candidates"] == []

    def test_nonexistent_dir(self):
        result = scan_resume_candidates("/nonexistent/path/12345")
        assert result["success"] is True
        assert result["candidates"] == []

    def test_ignores_non_part_files(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            open(os.path.join(tmpdir, "video.mp4"), "w").close()
            result = scan_resume_candidates(tmpdir)
            assert len(result["candidates"]) == 0

    def test_detects_part_file(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            path = os.path.join(tmpdir, "video.f137.part")
            open(path, "w").close()
            result = scan_resume_candidates(tmpdir)
            assert len(result["candidates"]) == 1
            assert result["candidates"][0]["filename"] == "video.f137.part"
            assert result["candidates"][0]["size_bytes"] == 0

    def test_marks_expired_files(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            path = os.path.join(tmpdir, "old.part")
            with open(path, "w") as f:
                f.write("data")
            old_mtime = 1000  # way in the past
            os.utime(path, (old_mtime, old_mtime))
            result = scan_resume_candidates(tmpdir)
            assert len(result["candidates"]) == 1
            assert result["candidates"][0]["expired"] is True


class TestSiteProfiles:
    def test_load_default_profiles(self):
        profiles = load_site_profiles()
        assert "YouTube 1080p" in profiles
        assert "YouTube 4K" in profiles
        assert "Podcast Audio" in profiles
        assert "Lossless FLAC" in profiles
        assert "Opus Compact" in profiles
        assert "Twitter/X Video" in profiles

    def test_youtube_1080p_format(self):
        profiles = load_site_profiles()
        cfg = profiles["YouTube 1080p"]
        assert "1080" in cfg["format_code"]
        assert cfg["container"] == "mp4"

    def test_youtube_4k_format(self):
        profiles = load_site_profiles()
        cfg = profiles["YouTube 4K"]
        assert "2160" in cfg["format_code"]
        assert cfg["container"] == "mkv"

    def test_save_and_load_from_disk(self):
        profiles = {"Custom": {"format_code": "best", "container": "mp4"}}
        with tempfile.TemporaryDirectory() as tmpdir:
            path = os.path.join(tmpdir, "profiles.json")
            save_profiles_to_disk(profiles, path)
            loaded = load_profiles_from_disk(path)
            assert loaded == profiles

    def test_load_from_disk_missing_file(self):
        result = load_profiles_from_disk("/nonexistent/profiles.json")
        assert result == {}


class TestGeneratePoToken:
    def test_returns_none(self):
        assert generate_po_token("https://youtube.com/watch?v=abc") is None


class TestBootstrap:
    def test_returns_error_when_not_initialized(self):
        _paths["data_dir"] = None
        result = bootstrap()
        assert result["success"] is False
        assert result["error_type"] == "ERROR_BOOTSTRAP_FAILED"

    def test_returns_success_when_initialized(self):
        set_paths(
            data_dir="/tmp/data",
            output_dir="/tmp/output",
            ffmpeg_path="/usr/bin/ffmpeg",
            cache_dir="/tmp/cache",
        )
        result = bootstrap()
        assert result["success"] is True
        assert "yt_dlp_version" in result
        assert "js_runtime" in result
        assert result["contract_version"] == "1.0"

    def test_detect_js_runtime_default_none(self):
        result = _detect_js_runtime()
        assert result["name"] in ("quickjs", "none")
