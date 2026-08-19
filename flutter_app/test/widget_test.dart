import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/app.dart';

void main() {
  testWidgets('App loads Login Screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ScamShieldApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('UPI Scam Analyzer'), findsOneWidget);
  });
}
