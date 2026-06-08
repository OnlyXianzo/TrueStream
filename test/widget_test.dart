import 'package:flutter_test/flutter_test.dart';
import 'package:truestream/main.dart';

void main() {
  testWidgets('App renders TrueStream text', (WidgetTester tester) async {
    await tester.pumpWidget(const TrueStreamApp());
    expect(find.text('TrueStream'), findsOneWidget);
  });
}
