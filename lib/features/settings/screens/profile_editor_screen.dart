import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileEditorScreen extends ConsumerStatefulWidget {
  final String? profileId;

  const ProfileEditorScreen({
    super.key,
    this.profileId,
  });

  @override
  ConsumerState<ProfileEditorScreen> createState() => _ProfileEditorScreenState();
}

class _ProfileEditorScreenState extends ConsumerState<ProfileEditorScreen> {
  final _nameController = TextEditingController();
  String _selectedQuality = '1080p';
  String _selectedCodec = 'vp9';
  bool _audioOnly = false;
  String _selectedContainer = 'mkv';

  @override
  void initState() {
    super.initState();
    if (widget.profileId != null) {
      _nameController.text = 'Custom HD Video';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.profileId == null ? 'Create Preset' : 'Edit Preset'),
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
                'PRESET DETAILS',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Preset Name',
                  labelStyle: TextStyle(color: colorScheme.outline),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.primary),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'QUALITY OPTIONS',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile.adaptive(
                title: const Text('Audio Only'),
                subtitle: const Text('Discard video stream after download'),
                value: _audioOnly,
                onChanged: (val) {
                  setState(() => _audioOnly = val);
                },
                activeTrackColor: colorScheme.primary,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              if (!_audioOnly) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Quality Ceiling', style: textTheme.bodyLarge),
                    DropdownButton<String>(
                      value: _selectedQuality,
                      dropdownColor: colorScheme.surfaceContainerHigh,
                      items: const [
                        DropdownMenuItem(value: '4k', child: Text('4K Ultra HD')),
                        DropdownMenuItem(value: '1080p', child: Text('1080p Full HD')),
                        DropdownMenuItem(value: '720p', child: Text('720p HD')),
                        DropdownMenuItem(value: 'best', child: Text('Best Available')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedQuality = val);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Preferred Codec', style: textTheme.bodyLarge),
                    DropdownButton<String>(
                      value: _selectedCodec,
                      dropdownColor: colorScheme.surfaceContainerHigh,
                      items: const [
                        DropdownMenuItem(value: 'av01', child: Text('AV1 (Maximum Compression)')),
                        DropdownMenuItem(value: 'vp9', child: Text('VP9 (Balanced)')),
                        DropdownMenuItem(value: 'h264', child: Text('H.264 (Universal)')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCodec = val);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Preferred Container', style: textTheme.bodyLarge),
                  DropdownButton<String>(
                    value: _selectedContainer,
                    dropdownColor: colorScheme.surfaceContainerHigh,
                    items: const [
                      DropdownMenuItem(value: 'mkv', child: Text('MKV')),
                      DropdownMenuItem(value: 'mp4', child: Text('MP4')),
                      DropdownMenuItem(value: 'webm', child: Text('WebM')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedContainer = val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 48),
              Row(
                children: [
                  if (widget.profileId != null) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Preset deleted')),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Delete'),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_nameController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a preset name')),
                          );
                          return;
                        }
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Preset saved successfully')),
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
                      child: const Text('Save Preset'),
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
}
