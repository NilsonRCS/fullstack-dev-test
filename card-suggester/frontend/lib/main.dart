import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'features/suggest/data/suggest_api.dart';
import 'features/suggest/presentation/suggest_screen.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');
  runApp(const CardSuggesterApp());
}

class CardSuggesterApp extends StatelessWidget {
  const CardSuggesterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sugestor de Cartão-Presente',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: SuggestScreen(api: SuggestApi()),
    );
  }
}
