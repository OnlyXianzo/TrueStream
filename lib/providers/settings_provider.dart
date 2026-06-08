import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode {
  system,
  light,
  dark,
}

class AppSettings {
  final bool wifiOnly;
  final bool turboMode;
  final bool completionAlerts;
  final String downloadPath;
  final AppThemeMode themeMode;
  final bool onboardingCompleted;
  final String qualityCeiling;
  final bool audioOnly;
  final String? proxy;
  final bool verbose;

  const AppSettings({
    this.wifiOnly = false,
    this.turboMode = true,
    this.completionAlerts = true,
    this.downloadPath = '/Internal/Videos',
    this.themeMode = AppThemeMode.light,
    this.onboardingCompleted = false,
    this.qualityCeiling = '4k',
    this.audioOnly = false,
    this.proxy,
    this.verbose = false,
  });

  AppSettings copyWith({
    bool? wifiOnly,
    bool? turboMode,
    bool? completionAlerts,
    String? downloadPath,
    AppThemeMode? themeMode,
    bool? onboardingCompleted,
    String? qualityCeiling,
    bool? audioOnly,
    String? proxy,
    bool? verbose,
  }) {
    return AppSettings(
      wifiOnly: wifiOnly ?? this.wifiOnly,
      turboMode: turboMode ?? this.turboMode,
      completionAlerts: completionAlerts ?? this.completionAlerts,
      downloadPath: downloadPath ?? this.downloadPath,
      themeMode: themeMode ?? this.themeMode,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      qualityCeiling: qualityCeiling ?? this.qualityCeiling,
      audioOnly: audioOnly ?? this.audioOnly,
      proxy: proxy ?? this.proxy,
      verbose: verbose ?? this.verbose,
    );
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize shared preferences in main()');
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  final SharedPreferences _prefs;

  SettingsNotifier(this._prefs) : super(const AppSettings()) {
    _loadSettings();
  }

  void _loadSettings() {
    final wifiOnly = _prefs.getBool('wifiOnly') ?? false;
    final turboMode = _prefs.getBool('turboMode') ?? true;
    final completionAlerts = _prefs.getBool('completionAlerts') ?? true;
    final downloadPath = _prefs.getString('downloadPath') ?? '/Internal/Videos';
    final themeIndex = _prefs.getInt('themeMode') ?? AppThemeMode.light.index;
    final onboardingCompleted = _prefs.getBool('onboardingCompleted') ?? false;
    final qualityCeiling = _prefs.getString('qualityCeiling') ?? '4k';
    final audioOnly = _prefs.getBool('audioOnly') ?? false;
    final proxy = _prefs.getString('proxy');
    final verbose = _prefs.getBool('verbose') ?? false;
    
    state = AppSettings(
      wifiOnly: wifiOnly,
      turboMode: turboMode,
      completionAlerts: completionAlerts,
      downloadPath: downloadPath,
      themeMode: AppThemeMode.values[themeIndex],
      onboardingCompleted: onboardingCompleted,
      qualityCeiling: qualityCeiling,
      audioOnly: audioOnly,
      proxy: proxy,
      verbose: verbose,
    );
  }

  void toggleWifiOnly() {
    final newValue = !state.wifiOnly;
    _prefs.setBool('wifiOnly', newValue);
    state = state.copyWith(wifiOnly: newValue);
  }

  void toggleTurboMode() {
    final newValue = !state.turboMode;
    _prefs.setBool('turboMode', newValue);
    state = state.copyWith(turboMode: newValue);
  }

  void toggleCompletionAlerts() {
    final newValue = !state.completionAlerts;
    _prefs.setBool('completionAlerts', newValue);
    state = state.copyWith(completionAlerts: newValue);
  }

  void setDownloadPath(String path) {
    _prefs.setString('downloadPath', path);
    state = state.copyWith(downloadPath: path);
  }

  void setThemeMode(AppThemeMode mode) {
    _prefs.setInt('themeMode', mode.index);
    state = state.copyWith(themeMode: mode);
  }

  void completeOnboarding() {
    _prefs.setBool('onboardingCompleted', true);
    state = state.copyWith(onboardingCompleted: true);
  }

  void setQualityCeiling(String value) {
    _prefs.setString('qualityCeiling', value);
    state = state.copyWith(qualityCeiling: value);
  }

  void toggleAudioOnly() {
    final newValue = !state.audioOnly;
    _prefs.setBool('audioOnly', newValue);
    state = state.copyWith(audioOnly: newValue);
  }

  void setProxy(String? value) {
    if (value == null || value.isEmpty) {
      _prefs.remove('proxy');
    } else {
      _prefs.setString('proxy', value);
    }
    state = state.copyWith(proxy: value);
  }

  void toggleVerbose() {
    final newValue = !state.verbose;
    _prefs.setBool('verbose', newValue);
    state = state.copyWith(verbose: newValue);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsNotifier(prefs);
});
