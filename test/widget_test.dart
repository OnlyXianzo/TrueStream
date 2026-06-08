import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truestream/main.dart';

void main() {
  testWidgets('App renders hero text', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: TrueStreamApp()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Your Library'), findsOneWidget);
  });
}
