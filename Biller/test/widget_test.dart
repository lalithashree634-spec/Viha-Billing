import 'package:flutter_test/flutter_test.dart';
import 'package:biller/main.dart';

void main() {
  testWidgets('Biller app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BillerApp());
    expect(find.text('POS Register'), findsOneWidget);
  });
}
