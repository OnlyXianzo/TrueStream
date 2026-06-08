import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/engine/engine_provider.dart';
import '../../../providers/download_provider.dart';

const _uuid = Uuid();

class FormatPickerScreen extends ConsumerStatefulWidget {
  final String url;
  final String title;

  const FormatPickerScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  ConsumerState<FormatPickerScreen> createState() => _FormatPickerScreenState();
}

class _FormatPickerScreenState extends ConsumerState<FormatPickerScreen> {
  String? _selectedVideoFormat;
  String? _selectedAudioFormat;
  String _selectedContainer = 'mkv';
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _videoFormats = [];
  List<Map<String, dynamic>> _audioFormats = [];
  String _fetchedTitle = '';

  @override
  void initState() {
    super.initState();
    _fetchFormats();
  }

  Future<void> _fetchFormats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final engine = ref.read(engineProvider);
      final result = await engine.getFormats(
        url: widget.url,
        config: {
          'cookies_path': null,
          'proxy': null,
          'verbose': false,
        },
      );

      if (result['success'] == true) {
        final formats = (result['formats'] as List).cast<Map<String, dynamic>>();
        _videoFormats = formats.where((f) => f['stream_type'] == 'video').toList();
        _audioFormats = formats.where((f) => f['stream_type'] == 'audio').toList();
        _fetchedTitle = result['title'] as String? ?? widget.title;
        _selectedVideoFormat = result['recommended_video_format_id'] as String?;
        _selectedAudioFormat = result['recommended_audio_format_id'] as String?;
      } else {
        _error = result['error_message'] as String? ?? 'Failed to load formats';
      }
    } catch (e) {
      _error = 'Error: $e';
    }

    if (mounted) setState(() => _isLoading = false);
  }

  String _formatSize(int? bytes) {
    if (bytes == null) return 'Unknown size';
    final double mb = bytes / (1024 * 1024);
    if (mb > 1024) {
      return '${(mb / 1024).toStringAsFixed(1)} GB';
    }
    return '${mb.toStringAsFixed(0)} MB';
  }

  Future<void> _startDownload() async {
    if (_selectedVideoFormat == null && _selectedAudioFormat == null) return;

    final downloadId = _uuid.v4();
    final engine = ref.read(engineProvider);

    final config = <String, dynamic>{
      'container': _selectedContainer,
      'explicit_format_id': _selectedVideoFormat,
      'explicit_audio_format_id': _selectedAudioFormat,
    };

    final result = await engine.startDownload(
      url: widget.url,
      downloadId: downloadId,
      config: config,
      networkType: 'wifi',
    );

    if (result['success'] == true) {
      ref.read(downloadProvider.notifier).addDownload(
        DownloadItem(
          id: downloadId,
          title: _fetchedTitle.isNotEmpty ? _fetchedTitle : widget.title,
          url: widget.url,
          status: 'downloading',
        ),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download started')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Format Picker'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.primary,
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                          const SizedBox(height: 16),
                          Text(_error!, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: _fetchFormats,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _fetchedTitle.isNotEmpty ? _fetchedTitle : widget.title,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.url,
                          style: textTheme.mono.copyWith(
                            color: colorScheme.outline,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 24),
                        if (_videoFormats.isNotEmpty) ...[
                          Text(
                            'VIDEO STREAMS',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ..._videoFormats.map((fmt) => _buildFormatRow(fmt, true, colorScheme, textTheme)),
                        ],
                        if (_audioFormats.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Text(
                            'AUDIO STREAMS',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ..._audioFormats.map((fmt) => _buildFormatRow(fmt, false, colorScheme, textTheme)),
                        ],
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Preferred Container:', style: textTheme.bodyMedium),
                            DropdownButton<String>(
                              value: _selectedContainer,
                              dropdownColor: colorScheme.surfaceContainerHigh,
                              items: const [
                                DropdownMenuItem(value: 'mkv', child: Text('MKV (Recommended)')),
                                DropdownMenuItem(value: 'mp4', child: Text('MP4')),
                                DropdownMenuItem(value: 'webm', child: Text('WebM')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedContainer = val);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: (_selectedVideoFormat != null || _selectedAudioFormat != null)
                                ? _startDownload
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Download Now'),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildFormatRow(
    Map<String, dynamic> fmt,
    bool isVideo,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final formatId = fmt['format_id'] as String;
    final isSelected = isVideo
        ? _selectedVideoFormat == formatId
        : _selectedAudioFormat == formatId;
    final isHdr = isVideo && fmt['dynamic_range'] != 'SDR';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? colorScheme.primaryContainer.withValues(alpha: 0.1)
            : colorScheme.surfaceContainerLowest,
        border: Border.all(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => setState(() {
          if (isVideo) {
            _selectedVideoFormat = formatId;
          } else {
            _selectedAudioFormat = formatId;
          }
        }),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _buildRadio(isSelected, colorScheme),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isVideo
                              ? '$formatId · ${fmt['height']}p${fmt['fps']}'
                              : '$formatId · ${fmt['acodec']} · ${(fmt['abr'] as num).toInt()}kbps',
                          style: textTheme.mono.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (isHdr) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorScheme.tertiaryContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              fmt['dynamic_range'],
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onTertiaryContainer,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      isVideo
                          ? '${fmt['vcodec']} · ${fmt['ext']} · ${_formatSize(fmt['filesize'])}'
                          : '${fmt['ext']} · ${_formatSize(fmt['filesize'])}',
                      style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadio(bool isSelected, ColorScheme colorScheme) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? colorScheme.primary : colorScheme.outline.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: isSelected
          ? Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary,
              ),
            )
          : null,
    );
  }
}
