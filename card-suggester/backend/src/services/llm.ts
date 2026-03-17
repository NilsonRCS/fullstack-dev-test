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
  const prompt = `You are a gift card message writer. 
Generate exactly 3 short, warm, and personal gift card messages (1-2 sentences each) for the following context:
- Occasion: ${occasion}
- Relationship between sender and recipient: ${relationship}

Rules:
- Each message must be on its own line, starting with a number and a period (e.g. "1. ...")
- Do not add any extra explanation or formatting
- Keep each message under 30 words`;

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
