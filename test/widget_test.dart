import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truestream/main.dart';
import 'package:truestream/providers/settings_provider.dart';

void main() {
  testWidgets('App renders onboarding text', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'onboardingCompleted': false,
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const TrueStreamApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('TrueStream'), findsOneWidget);
  });
}

