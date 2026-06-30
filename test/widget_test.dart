import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:volte/app.dart';

void main() {
  testWidgets('App renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(const VolteApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
