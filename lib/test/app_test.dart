import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_shopping_list_flutter/ui/home.dart';

void main() {
  testWidgets('Home as expected elements', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Home()));

    // Create the Finders.
    final inputFinder = find.byType(TextField);
    final addButtonFinder = find.byKey(const Key("add"));

    expect(inputFinder, findsOneWidget);
    expect(addButtonFinder, findsOneWidget);
  });
}
