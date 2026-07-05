import 'package:flutter_test/flutter_test.dart';

import 'package:waste_collection_management_system/main.dart';

void main() {
  testWidgets('Login screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const WasteCollectionApp());

    expect(find.text('Waste Collection'), findsOneWidget);
  });
}
