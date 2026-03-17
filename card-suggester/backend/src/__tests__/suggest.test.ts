import request from 'supertest';
import app from '../index';

// Mocka o módulo inteiro do llm service — assim os testes nunca chamam a OpenAI de verdade
jest.mock('../services/llm');
import { getSuggestions } from '../services/llm';

const mockGetSuggestions = getSuggestions as jest.MockedFunction<typeof getSuggestions>;

describe('POST /suggest', () => {
  afterEach(() => {
    jest.clearAllMocks();
  });

  // ─── Happy path ──────────────────────────────────────────────────────────────

  it('retorna 3 sugestões quando o LLM responde com sucesso', async () => {
    const fakeSuggestions = [
      'Happy birthday! Hope your day is as wonderful as you are.',
      'Wishing you joy and laughter on your special day!',
      'Cheers to another year of amazing adventures, friend!',
    ];
    mockGetSuggestions.mockResolvedValueOnce(fakeSuggestions);

    const res = await request(app)
      .post('/suggest')
      .send({ occasion: 'birthday', relationship: 'friend' });

    expect(res.status).toBe(200);
    expect(res.body.suggestions).toEqual(fakeSuggestions);
    expect(res.body.fallback).toBeUndefined(); // sem fallback no caminho feliz
    expect(mockGetSuggestions).toHaveBeenCalledWith('birthday', 'friend');
  });

  // ─── Fallback path ────────────────────────────────────────────────────────────

  it('retorna fallback quando o LLM lança erro (ex: 429, timeout, 5xx)', async () => {
    mockGetSuggestions.mockRejectedValueOnce(new Error('429 Too Many Requests'));

    const res = await request(app)
      .post('/suggest')
      .send({ occasion: 'wedding', relationship: 'colleague' });

    expect(res.status).toBe(200); // sempre 200 — o cliente não deve receber o erro interno
    expect(res.body.fallback).toBe(true);
    expect(Array.isArray(res.body.suggestions)).toBe(true);
    expect(res.body.suggestions.length).toBeGreaterThan(0);
    // Garante que nenhum dado interno do erro vazou para o cliente
    expect(JSON.stringify(res.body)).not.toContain('429');
    expect(JSON.stringify(res.body)).not.toContain('stack');
  });

  // ─── Validação de entrada ─────────────────────────────────────────────────────

  it('retorna 400 quando "occasion" está ausente', async () => {
    const res = await request(app)
      .post('/suggest')
      .send({ relationship: 'friend' });

    expect(res.status).toBe(400);
    expect(res.body.error).toBeDefined();
    expect(mockGetSuggestions).not.toHaveBeenCalled();
  });

  it('retorna 400 quando "relationship" está ausente', async () => {
    const res = await request(app)
      .post('/suggest')
      .send({ occasion: 'birthday' });

    expect(res.status).toBe(400);
    expect(res.body.error).toBeDefined();
    expect(mockGetSuggestions).not.toHaveBeenCalled();
  });

  it('retorna 400 quando o body está vazio', async () => {
    const res = await request(app).post('/suggest').send({});

    expect(res.status).toBe(400);
    expect(res.body.error).toBeDefined();
  });
});
