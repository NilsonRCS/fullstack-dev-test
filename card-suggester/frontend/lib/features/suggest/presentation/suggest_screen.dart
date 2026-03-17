import 'package:flutter/material.dart';
import '../data/suggest_api.dart';
import '../domain/suggestion_state.dart';

class SuggestScreen extends StatefulWidget {
  final SuggestApi api;

  const SuggestScreen({super.key, required this.api});

  @override
  State<SuggestScreen> createState() => _SuggestScreenState();
}

class _SuggestScreenState extends State<SuggestScreen> {
  final _occasionController = TextEditingController();
  final _relationshipController = TextEditingController();
  SuggestionState _state = SuggestionInitial();

  @override
  void dispose() {
    _occasionController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  Future<void> _fetchSuggestions() async {
    final occasion = _occasionController.text.trim();
    final relationship = _relationshipController.text.trim();

    if (occasion.isEmpty || relationship.isEmpty) {
      setState(() => _state = SuggestionError('Preencha todos os campos.'));
      return;
    }

    setState(() => _state = SuggestionLoading());

    try {
      final result = await widget.api.getSuggestions(
        occasion: occasion,
        relationship: relationship,
      );
      setState(() => _state = SuggestionSuccess(
            suggestions: result.suggestions,
            isFallback: result.isFallback,
          ));
    } catch (e) {
      setState(
        () => _state = SuggestionError(
          'Não foi possível conectar ao servidor. Verifique sua conexão.',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sugestor de Cartão-Presente'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Gere mensagens personalizadas para seu cartão-presente',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _occasionController,
                decoration: const InputDecoration(
                  labelText: 'Ocasião',
                  hintText: 'Ex: aniversário, casamento, formatura',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.celebration),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _relationshipController,
                decoration: const InputDecoration(
                  labelText: 'Relacionamento',
                  hintText: 'Ex: amigo, colega, pai, namorada',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.people),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _fetchSuggestions(),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed:
                    _state is SuggestionLoading ? null : _fetchSuggestions,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Sugerir Mensagens'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 32),
              _buildResult(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResult() {
    return switch (_state) {
      SuggestionInitial() => const SizedBox.shrink(),
      SuggestionLoading() => const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          ),
        ),
      SuggestionError(:final message) => _ErrorCard(message: message),
      SuggestionSuccess(:final suggestions, :final isFallback) =>
        _SuggestionsCard(suggestions: suggestions, isFallback: isFallback),
    };
  }
}

class _SuggestionsCard extends StatelessWidget {
  final List<String> suggestions;
  final bool isFallback;

  const _SuggestionsCard({
    required this.suggestions,
    required this.isFallback,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.card_giftcard, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Text(
                  'Sugestões',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            if (isFallback) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Sugestão genérica — serviço de IA indisponível',
                  style: TextStyle(fontSize: 12, color: Colors.deepOrange),
                ),
              ),
            ],
            const SizedBox(height: 16),
            ...suggestions.asMap().entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.deepPurple,
                          child: Text(
                            '${e.key + 1}',
                            style: const TextStyle(
                                fontSize: 11, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(e.value,
                              style: const TextStyle(fontSize: 15)),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message,
                  style: const TextStyle(color: Colors.red, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }
}
