import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> getDefaultDownloadPath() async {
  if (Platform.isAndroid) {
    final dir = Directory('/storage/emulated/0/Download/TrueStream');
    if (!await dir.exists()) {
      try {
        await dir.create(recursive: true);
      } catch (_) {
        final appDoc = await getApplicationDocumentsDirectory();
        return '${appDoc.path}/Downloads';
      }
    }
    return dir.path;
  } else {
    final downloadsDir = await getDownloadsDirectory();
    if (downloadsDir != null) {
      final dir = Directory('${downloadsDir.path}/TrueStream');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return dir.path;
    }
    final docDir = await getApplicationDocumentsDirectory();
    return '${docDir.path}/Downloads';
  }
}


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
  final bool autoStartDownloadOnShare;
  final String? cookiesPath;
  final bool youtubeLoggedIn;
  final bool instagramLoggedIn;
  final bool twitterLoggedIn;
  final bool bilibiliLoggedIn;
  final bool twitchLoggedIn;

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
    this.autoStartDownloadOnShare = false,
    this.cookiesPath,
    this.youtubeLoggedIn = false,
    this.instagramLoggedIn = false,
    this.twitterLoggedIn = false,
    this.bilibiliLoggedIn = false,
    this.twitchLoggedIn = false,
  });

  static const Object _sentinel = Object();

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
    bool? autoStartDownloadOnShare,
    Object? cookiesPath = _sentinel,
    bool? youtubeLoggedIn,
    bool? instagramLoggedIn,
    bool? twitterLoggedIn,
    bool? bilibiliLoggedIn,
    bool? twitchLoggedIn,
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
      autoStartDownloadOnShare: autoStartDownloadOnShare ?? this.autoStartDownloadOnShare,
      cookiesPath: cookiesPath == _sentinel ? this.cookiesPath : (cookiesPath as String?),
      youtubeLoggedIn: youtubeLoggedIn ?? this.youtubeLoggedIn,
      instagramLoggedIn: instagramLoggedIn ?? this.instagramLoggedIn,
      twitterLoggedIn: twitterLoggedIn ?? this.twitterLoggedIn,
      bilibiliLoggedIn: bilibiliLoggedIn ?? this.bilibiliLoggedIn,
      twitchLoggedIn: twitchLoggedIn ?? this.twitchLoggedIn,
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
    final autoStartDownloadOnShare = _prefs.getBool('autoStartDownloadOnShare') ?? false;
    final cookiesPath = _prefs.getString('cookiesPath');
    final youtubeLoggedIn = _prefs.getBool('youtubeLoggedIn') ?? false;
    final instagramLoggedIn = _prefs.getBool('instagramLoggedIn') ?? false;
    final twitterLoggedIn = _prefs.getBool('twitterLoggedIn') ?? false;
    final bilibiliLoggedIn = _prefs.getBool('bilibiliLoggedIn') ?? false;
    final twitchLoggedIn = _prefs.getBool('twitchLoggedIn') ?? false;
    
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
      autoStartDownloadOnShare: autoStartDownloadOnShare,
      cookiesPath: cookiesPath,
      youtubeLoggedIn: youtubeLoggedIn,
      instagramLoggedIn: instagramLoggedIn,
      twitterLoggedIn: twitterLoggedIn,
      bilibiliLoggedIn: bilibiliLoggedIn,
      twitchLoggedIn: twitchLoggedIn,
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

  void toggleAutoStartDownloadOnShare() {
    final newValue = !state.autoStartDownloadOnShare;
    _prefs.setBool('autoStartDownloadOnShare', newValue);
    state = state.copyWith(autoStartDownloadOnShare: newValue);
  }

  void setCookiesPath(String? path) {
    if (path == null) {
      _prefs.remove('cookiesPath');
    } else {
      _prefs.setString('cookiesPath', path);
    }
    state = state.copyWith(cookiesPath: path);
  }

  void setYoutubeLoggedIn(bool value) {
    _prefs.setBool('youtubeLoggedIn', value);
    state = state.copyWith(youtubeLoggedIn: value);
  }

  void setInstagramLoggedIn(bool value) {
    _prefs.setBool('instagramLoggedIn', value);
    state = state.copyWith(instagramLoggedIn: value);
  }

  void setTwitterLoggedIn(bool value) {
    _prefs.setBool('twitterLoggedIn', value);
    state = state.copyWith(twitterLoggedIn: value);
  }

  void setBilibiliLoggedIn(bool value) {
    _prefs.setBool('bilibiliLoggedIn', value);
    state = state.copyWith(bilibiliLoggedIn: value);
  }

  void setTwitchLoggedIn(bool value) {
    _prefs.setBool('twitchLoggedIn', value);
    state = state.copyWith(twitchLoggedIn: value);
  }

  Future<void> clearAllCookies(String appDir) async {
    final defaultCookiesFile = File('$appDir/cookies.txt');
    try {
      if (await defaultCookiesFile.exists()) {
        await defaultCookiesFile.delete();
      }
    } catch (_) {}

    final customPath = state.cookiesPath;
    if (customPath != null && customPath != defaultCookiesFile.path) {
      try {
        final customCookiesFile = File(customPath);
        if (await customCookiesFile.exists()) {
          await customCookiesFile.delete();
        }
      } catch (_) {}
    }

    await _prefs.remove('cookiesPath');
    await _prefs.setBool('youtubeLoggedIn', false);
    await _prefs.setBool('instagramLoggedIn', false);
    await _prefs.setBool('twitterLoggedIn', false);
    await _prefs.setBool('bilibiliLoggedIn', false);
    await _prefs.setBool('twitchLoggedIn', false);

    state = state.copyWith(
      cookiesPath: null,
      youtubeLoggedIn: false,
      instagramLoggedIn: false,
      twitterLoggedIn: false,
      bilibiliLoggedIn: false,
      twitchLoggedIn: false,
    );
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsNotifier(prefs);
});
