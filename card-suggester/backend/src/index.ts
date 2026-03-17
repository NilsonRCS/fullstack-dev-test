import express from 'express';
import type { Request, Response } from 'express';
import dotenv from 'dotenv';
import suggestRouter from './routes/suggest';

dotenv.config();

const app = express();

app.use(express.json());

app.get('/health', (_: Request, res: Response) => {
  res.json({ status: 'ok' });
});

app.use('/suggest', suggestRouter);

const PORT = process.env.PORT ? Number(process.env.PORT) : 3000;

if (process.env.NODE_ENV !== 'test') {
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
}

export default app;