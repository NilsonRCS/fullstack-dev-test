/// Representa os possíveis estados da tela de sugestões.
/// sealed class garante que o switch seja exaustivo — sem state não tratado.
sealed class SuggestionState {}

/// Estado inicial — nada foi requisitado ainda
class SuggestionInitial extends SuggestionState {}

/// Aguardando resposta do backend
class SuggestionLoading extends SuggestionState {}

/// LLM respondeu com sucesso (ou fallback)
class SuggestionSuccess extends SuggestionState {
  final List<String> suggestions;
  final bool isFallback;

  SuggestionSuccess({required this.suggestions, this.isFallback = false});
}

/// Erro de rede ou resposta inválida do backend
class SuggestionError extends SuggestionState {
  final String message;

  SuggestionError(this.message);
}
