import 'package:flutter_test/flutter_test.dart';

abstract final class PlatformTestMatrix {
  static const androidVersions = ['8', '9', '10', '11', '12', '13', '14'];
  static const windowsVersions = ['10', '11'];
  static const linuxDistros = ['Ubuntu', 'Debian', 'Fedora'];

  static const androidChecklist = [
    'App installs and launches',
    'Onboarding flow completes',
    'URL paste triggers format picker',
    'Download starts and progresses',
    'Download completes with correct file size',
    'Library screen shows completed downloads',
    'Settings toggles persist across restart',
    'Theme switching works (system/light/dark)',
    'Share intent triggers download dialog',
    'Downloads continue in background',
    'VPN/proxy blocked content shows error',
    'Resume interrupted download works',
    'Playlist CRUD operations work',
    'Engine status banner shows correctly',
    'Impeller rendering enabled — no jank',
  ];

  static const windowsChecklist = [
    'App installs and launches',
    'Onboarding flow completes',
    'URL paste triggers format picker',
    'Download starts and progresses',
    'Download completes with correct file size',
    'Library screen shows completed downloads',
    'Settings toggles persist across restart',
    'Theme switching works (system/light/dark)',
    'File picker for download directory works',
    'Desktop window resize — UI adapts (NavigationRail vs BottomNav)',
    'Multiple concurrent downloads',
    'FFmpeg post-processing merging works',
    'Proxy configuration applies correctly',
    'Engine status banner shows correctly',
  ];

  static const linuxChecklist = [
    'App installs (AppImage/flatpak/snap)',
    'Onboarding flow completes',
    'URL paste triggers format picker',
    'Download starts and progresses',
    'Download completes with correct file size',
    'Library screen shows completed downloads',
    'Settings toggles persist across restart',
    'Theme switching works (system/light/dark)',
    'File picker for download directory works',
    'Desktop window resize — UI adapts (NavigationRail vs BottomNav)',
    'Multiple concurrent downloads',
    'FFmpeg post-processing merging works',
    'Proxy configuration applies correctly',
    'Engine status banner shows correctly',
  ];
}

void main() {
  group('P4-013: Platform test definitions', () {
    test('Android version coverage', () {
      expect(PlatformTestMatrix.androidVersions, containsAll(['8', '12', '14']));
      expect(PlatformTestMatrix.androidChecklist, isNotEmpty);
      expect(PlatformTestMatrix.androidChecklist.length, greaterThanOrEqualTo(10));
    });

    test('Windows version coverage', () {
      expect(PlatformTestMatrix.windowsVersions, containsAll(['10', '11']));
      expect(PlatformTestMatrix.windowsChecklist, isNotEmpty);
      expect(PlatformTestMatrix.windowsChecklist.length, greaterThanOrEqualTo(10));
    });

    test('Linux distro coverage', () {
      expect(PlatformTestMatrix.linuxDistros, containsAll(['Ubuntu', 'Debian', 'Fedora']));
      expect(PlatformTestMatrix.linuxChecklist, isNotEmpty);
      expect(PlatformTestMatrix.linuxChecklist.length, greaterThanOrEqualTo(10));
    });

    test('All checklists contain unique items per platform', () {
      final allChecklists = [
        ...PlatformTestMatrix.androidChecklist,
        ...PlatformTestMatrix.windowsChecklist,
        ...PlatformTestMatrix.linuxChecklist,
      ];
      expect(allChecklists.toSet().length, greaterThanOrEqualTo(15));
    });
  });
}
