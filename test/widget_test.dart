import 'package:flutter_test/flutter_test.dart';
import 'package:omni_delivery_mobile/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const OmniDeliveryApp());
    expect(find.byType(OmniDeliveryApp), findsOneWidget);
  });
}
