import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              _SettingSwitch(
                icon: Icons.cloud_outlined,
                title: 'Wi-Fi Only Downloads',
                subtitle: 'Prevent data usage for downloads',
                value: settings.wifiOnly,
                onChanged: () => ref.read(settingsProvider.notifier).toggleWifiOnly(),
                colorScheme: colorScheme,
              ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1),
              _SettingSwitch(
                icon: Icons.speed,
                title: 'Enable Turbo Download Mode',
                subtitle: 'Accelerate speed with multi-threading',
                value: settings.turboMode,
                onChanged: () => ref.read(settingsProvider.notifier).toggleTurboMode(),
                colorScheme: colorScheme,
              ).animate().fadeIn(delay: 80.ms, duration: 300.ms).slideX(begin: 0.1),
              _SettingNavItem(
                icon: Icons.folder_outlined,
                title: 'Download Path',
                subtitle: settings.downloadPath,
                colorScheme: colorScheme,
              ).animate().fadeIn(delay: 160.ms, duration: 300.ms).slideX(begin: 0.1),
              _SettingSwitch(
                icon: Icons.notifications_outlined,
                title: 'Download Completion Alerts',
                subtitle: 'Notify when a file finishes',
                value: settings.completionAlerts,
                onChanged: () => ref.read(settingsProvider.notifier).toggleCompletionAlerts(),
                colorScheme: colorScheme,
              ).animate().fadeIn(delay: 240.ms, duration: 300.ms).slideX(begin: 0.1),
              _SettingAction(
                icon: Icons.history,
                title: 'Clear Search History',
                colorScheme: colorScheme,
              ).animate().fadeIn(delay: 320.ms, duration: 300.ms).slideX(begin: 0.1),
              const SizedBox(height: 32),
              // Version badge
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    'Version 1.0.0 (Stable)',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingSwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final VoidCallback onChanged;
  final ColorScheme colorScheme;

  const _SettingSwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: colorScheme.outline, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.bodyLarge),
                Text(
                  subtitle,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: (_) => onChanged(),
            activeTrackColor: colorScheme.primaryContainer,
          ),
        ],
      ),
    );
  }
}

class _SettingNavItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final ColorScheme colorScheme;

  const _SettingNavItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: colorScheme.outline, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.bodyLarge),
                Text(
                  subtitle,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: colorScheme.outline, size: 20),
        ],
      ),
    );
  }
}

class _SettingAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final ColorScheme colorScheme;

  const _SettingAction({
    required this.icon,
    required this.title,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: colorScheme.outline, size: 20),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
