import { Router } from 'express';
import type { Request, Response } from 'express';

const router = Router();

router.post('/', (req: Request, res: Response) => {
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

  res.json({
    suggestions: [
      `Placeholder para: ocasião="${occasion}", relacionamento="${relationship}"`,
    ],
  });
});

export default router;
