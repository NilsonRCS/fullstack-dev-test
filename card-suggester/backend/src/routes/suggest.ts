import { Router } from 'express';
import type { Request, Response } from 'express';
import { getSuggestions } from '../services/llm';

const router = Router();

// Mensagens genéricas usadas quando o LLM não está disponível
const FALLBACK_SUGGESTIONS = [
  'Que este presente seja um pequeno símbolo do quanto você significa para mim!',
  'Espero que esse presente traga um grande sorriso ao seu rosto. Você merece!',
  'Com carinho e afeto, desejo a você tudo de melhor nessa ocasião especial!',
];

router.post('/', async (req: Request, res: Response) => {
  const { occasion, relationship } = req.body as {
    occasion?: string;
    relationship?: string;
  };

  if (!occasion || !relationship) {
    res.status(400).json({
      error: 'Os campos "occasion" e "relationship" são obrigatórios.',
    });
    return;
  }

  try {
    const suggestions = await getSuggestions(occasion, relationship);
    res.json({ suggestions });
  } catch (err) {
    // Loga o erro internamente para monitoramento, mas nunca expõe ao cliente
    console.error('[suggest] LLM error:', err);

    res.json({
      suggestions: FALLBACK_SUGGESTIONS,
      fallback: true, // indica ao cliente que são sugestões genéricas
    });
  }
});

export default router;
