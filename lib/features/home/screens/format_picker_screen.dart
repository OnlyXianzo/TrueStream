import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/text_styles.dart';

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

  // Mock formats for demonstration/fallback
  final List<Map<String, dynamic>> _mockVideoFormats = [
    {
      'format_id': '401',
      'ext': 'mp4',
      'vcodec': 'av01',
      'height': 2160,
      'fps': 60,
      'filesize': 2254857830,
      'dynamic_range': 'SDR'
    },
    {
      'format_id': '337',
      'ext': 'mp4',
      'vcodec': 'vp9',
      'height': 2160,
      'fps': 60,
      'filesize': 3650722201,
      'dynamic_range': 'HDR10'
    },
    {
      'format_id': '248',
      'ext': 'webm',
      'vcodec': 'vp9',
      'height': 1080,
      'fps': 30,
      'filesize': 854857830,
      'dynamic_range': 'SDR'
    },
    {
      'format_id': '137',
      'ext': 'mp4',
      'vcodec': 'h264',
      'height': 1080,
      'fps': 30,
      'filesize': 624857830,
      'dynamic_range': 'SDR'
    },
  ];

  final List<Map<String, dynamic>> _mockAudioFormats = [
    {'format_id': '251', 'ext': 'webm', 'acodec': 'opus', 'abr': 160.0, 'filesize': 34567890},
    {'format_id': '140', 'ext': 'm4a', 'acodec': 'aac', 'abr': 128.0, 'filesize': 28901230},
    {'format_id': '139', 'ext': 'm4a', 'acodec': 'aac', 'abr': 48.0, 'filesize': 10567890},
  ];

  @override
  void initState() {
    super.initState();
    // Pre-select best recommendations
    if (_mockVideoFormats.isNotEmpty) {
      _selectedVideoFormat = _mockVideoFormats.first['format_id'];
    }
    if (_mockAudioFormats.isNotEmpty) {
      _selectedAudioFormat = _mockAudioFormats.first['format_id'];
    }
  }

  String _formatSize(int? bytes) {
    if (bytes == null) return 'Unknown size';
    final double mb = bytes / (1024 * 1024);
    if (mb > 1024) {
      return '${(mb / 1024).toStringAsFixed(1)} GB';
    }
    return '${mb.toStringAsFixed(0)} MB';
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
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
              Text(
                'VIDEO STREAMS',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              ..._mockVideoFormats.map((fmt) {
                final isSelected = _selectedVideoFormat == fmt['format_id'];
                final isHdr = fmt['dynamic_range'] != 'SDR';
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
                    onTap: () => setState(() => _selectedVideoFormat = fmt['format_id']),
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
                                      '${fmt['format_id']} · ${fmt['height']}p${fmt['fps']}',
                                      style: textTheme.mono.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
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
                                  '${fmt['vcodec']} · ${fmt['ext']} · ${_formatSize(fmt['filesize'])}',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
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
              ..._mockAudioFormats.map((fmt) {
                final isSelected = _selectedAudioFormat == fmt['format_id'];
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
                    onTap: () => setState(() => _selectedAudioFormat = fmt['format_id']),
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
                                Text(
                                  '${fmt['format_id']} · ${fmt['acodec']} · ${fmt['abr'].toInt()}kbps',
                                  style: textTheme.mono.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${fmt['ext']} · ${_formatSize(fmt['filesize'])}',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Preferred Container:',
                    style: textTheme.bodyMedium,
                  ),
                  DropdownButton<String>(
                    value: _selectedContainer,
                    dropdownColor: colorScheme.surfaceContainerHigh,
                    items: const [
                      DropdownMenuItem(value: 'mkv', child: Text('MKV (Recommended)')),
                      DropdownMenuItem(value: 'mp4', child: Text('MP4')),
                      DropdownMenuItem(value: 'webm', child: Text('WebM')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedContainer = val);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Preset saved successfully')),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colorScheme.primary),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Save as Preset'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Starting download...')),
                        );
                      },
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
