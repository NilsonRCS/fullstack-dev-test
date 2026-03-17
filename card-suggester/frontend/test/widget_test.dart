import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:card_suggester/features/suggest/data/suggest_api.dart';
import 'package:card_suggester/features/suggest/presentation/suggest_screen.dart';

void main() {
  setUpAll(() async {
    await dotenv.load(fileName: '.env');
  });

  testWidgets('Exibe campos de occasion e relationship', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: SuggestScreen(api: SuggestApi()),
    ));

    expect(find.text('Ocasião'), findsOneWidget);
    expect(find.text('Relacionamento'), findsOneWidget);
    expect(find.text('Sugerir Mensagens'), findsOneWidget);
  });
}
