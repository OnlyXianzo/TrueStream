import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppSettings {
  final bool wifiOnly;
  final bool turboMode;
  final bool completionAlerts;
  final String downloadPath;

  const AppSettings({
    this.wifiOnly = false,
    this.turboMode = true,
    this.completionAlerts = true,
    this.downloadPath = '/Internal/Videos',
  });

  AppSettings copyWith({
    bool? wifiOnly,
    bool? turboMode,
    bool? completionAlerts,
    String? downloadPath,
  }) {
    return AppSettings(
      wifiOnly: wifiOnly ?? this.wifiOnly,
      turboMode: turboMode ?? this.turboMode,
      completionAlerts: completionAlerts ?? this.completionAlerts,
      downloadPath: downloadPath ?? this.downloadPath,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings());

  void toggleWifiOnly() => state = state.copyWith(wifiOnly: !state.wifiOnly);
  void toggleTurboMode() => state = state.copyWith(turboMode: !state.turboMode);
  void toggleCompletionAlerts() =>
      state = state.copyWith(completionAlerts: !state.completionAlerts);
  void setDownloadPath(String path) =>
      state = state.copyWith(downloadPath: path);
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});
