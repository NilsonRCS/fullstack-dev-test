import { Router } from 'express';
import type { Request, Response } from 'express';
import { getSuggestions } from '../services/llm';

const router = Router();

// Mensagens genéricas usadas quando o LLM não está disponível
const FALLBACK_SUGGESTIONS = [
  'Wishing you all the best on this special occasion!',
  'Hope this little gift brings a big smile to your face.',
  'Thinking of you and sending lots of love your way!',
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
