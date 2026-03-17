import OpenAI from 'openai';

const client = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

/**
 * Chama o LLM e retorna 2-3 sugestões de mensagem para cartão-presente.
 * Lança um erro se a chamada falhar — o tratamento de fallback fica na rota.
 */
export async function getSuggestions(
  occasion: string,
  relationship: string,
): Promise<string[]> {
  const prompt = `Você é um escritor de mensagens para cartões-presente.
Gere exatamente 3 mensagens curtas, calorosas e pessoais (1 a 2 frases cada) em português brasileiro para o seguinte contexto:
- Ocasião: ${occasion}
- Relacionamento entre remetente e destinatário: ${relationship}

Regras:
- Cada mensagem deve estar em sua própria linha, começando com um número e um ponto (ex: "1. ...")
- Não adicione explicações ou formatações extras
- Mantenha cada mensagem com no máximo 30 palavras
- Escreva em português brasileiro, de forma natural e afetuosa`;

  const response = await client.chat.completions.create(
    {
      model: 'gpt-4o-mini',
      messages: [{ role: 'user', content: prompt }],
      temperature: 0.8,
      max_tokens: 300,
    },
    { timeout: 10_000 }, // 10s — se ultrapassar, lança erro e o fallback entra
  );

  const text = response.choices[0]?.message?.content ?? '';

  // Extrai as linhas numeradas e limpa espaços extras
  const suggestions = text
    .split('\n')
    .map((line) => line.replace(/^\d+\.\s*/, '').trim())
    .filter((line) => line.length > 0);

  return suggestions;
}
