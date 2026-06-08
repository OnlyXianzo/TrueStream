from truestream_engine.playlist import detect_playlist


class TestDetectPlaylist:
    def test_youtube_playlist_list_param(self):
        assert detect_playlist("https://youtube.com/watch?v=abc&list=PLxyz") is True

    def test_youtube_playlist_path(self):
        assert detect_playlist("https://youtube.com/playlist?list=PLxyz") is True

    def test_youtube_channel(self):
        assert detect_playlist("https://youtube.com/channel/UCxyz") is True

    def test_youtube_custom_url(self):
        assert detect_playlist("https://youtube.com/c/ChannelName") is True

    def test_youtube_handle(self):
        assert detect_playlist("https://youtube.com/@ChannelName") is True

    def test_youtube_user(self):
        assert detect_playlist("https://youtube.com/user/username") is True

    def test_single_video_not_playlist(self):
        assert detect_playlist("https://youtube.com/watch?v=dQw4w9WgXcQ") is False

    def test_shortened_url_not_playlist(self):
        assert detect_playlist("https://youtu.be/dQw4w9WgXcQ") is False

    def test_twitter_url_not_playlist(self):
        assert detect_playlist("https://twitter.com/username/status/123") is False

    def test_generic_url_not_playlist(self):
        assert detect_playlist("https://example.com/video.mp4") is False

    def test_sets_url(self):
        assert detect_playlist("https://example.com/sets/abc") is True
