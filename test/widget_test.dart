import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perplexity_clone/main.dart';

void main() {
  testWidgets('Home page shows title and search bar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Where knowledge begins'), findsOneWidget);
    expect(
      find.text('Ask anything. Get clear, AI-powered answers.'),
      findsOneWidget,
    );
    expect(find.byType(TextField), findsOneWidget);
  });
}
