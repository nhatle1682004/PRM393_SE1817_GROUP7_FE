import 'package:flutter_test/flutter_test.dart';

import 'package:waste_collection_management_system/main.dart';

void main() {
  testWidgets('Login screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const EcoCollectApp());

    expect(find.text('EcoCollect'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
  });
}
