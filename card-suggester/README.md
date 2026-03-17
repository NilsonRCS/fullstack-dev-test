# Card Suggester — Solução

Sugestor de mensagens para cartões-presente com IA, composto por uma API Node.js/TypeScript e um app Flutter.

---

## Estrutura do projeto

```
card-suggester/
  backend/          # API Node.js + TypeScript
  frontend/         # App Flutter
```

---

## Como rodar

### Pré-requisitos

- Node.js v20+
- Flutter 3.38+
- Chave de API da OpenAI

### Backend

```bash
cd backend

# 1. Instale as dependências
npm install

# 2. Configure o .env (copie o exemplo e preencha a chave)
cp .env.example .env
# Edite .env e adicione: OPENAI_API_KEY=sk-...

# 3. Inicie o servidor em modo desenvolvimento
npm run dev
# Servidor disponível em http://localhost:3132
```

### Frontend (Flutter)

```bash
cd frontend

# 1. Instale as dependências
flutter pub get

# 2. Configure a URL do backend no .env
# Web/Chrome:         API_BASE_URL=http://localhost:3132
# Emulador Android:   API_BASE_URL=http://10.0.2.2:3132
# Dispositivo físico: API_BASE_URL=http://SEU_IP_LOCAL:3132

# 3. Rode o app
flutter run -d chrome      # Web
flutter run -d emulator    # Emulador Android
```

### Testes do backend

```bash
cd backend
npm test
```

---

## Arquitetura

```
Flutter App
    │
    │  POST /suggest
    │  { occasion, relationship }
    ▼
Node.js API (Express)
    │
    ├─ Valida entrada (400 se inválida)
    │
    ├─ Chama OpenAI gpt-4o-mini
    │       │
    │       ├─ Sucesso → retorna 2-3 mensagens personalizadas
    │       │
    │       └─ Falha (429/timeout/5xx)
    │               └─ Retorna mensagens genéricas (fallback)
    │
    └─ Responde ao Flutter
       { suggestions: [...], fallback?: true }
```

### Camadas do backend

| Arquivo | Responsabilidade |
|---|---|
| `src/index.ts` | Inicializa o app Express, registra middlewares e rotas |
| `src/routes/suggest.ts` | Recebe a requisição, valida entrada, aciona o service, trata erros |
| `src/services/llm.ts` | Toda a lógica de comunicação com a OpenAI |

### Camadas do Flutter

| Arquivo | Responsabilidade |
|---|---|
| `lib/main.dart` | Ponto de entrada, carrega `.env`, monta o `MaterialApp` |
| `features/suggest/data/suggest_api.dart` | Cliente HTTP — faz o `POST /suggest` |
| `features/suggest/domain/suggestion_state.dart` | Estados da tela: `Initial`, `Loading`, `Success`, `Error` |
| `features/suggest/presentation/suggest_screen.dart` | UI — campos, botão, loading, resultado, erro |

---

## Decisões e trade-offs

### Contrato da API

- **Método:** `POST /suggest`
- **Request:** `{ "occasion": string, "relationship": string }`
- **Response (sucesso):** `{ "suggestions": string[] }`
- **Response (fallback):** `{ "suggestions": string[], "fallback": true }`
- **Response (erro de validação):** `{ "error": string }` com status 400

Escolhi `POST` porque o corpo da requisição contém dados que descrevem uma operação (gerar sugestões), não uma consulta idempotente.

### Tratamento de erros do LLM

Considero **falha do LLM** qualquer situação onde a API externa não entrega sugestões válidas:

- **429 Too Many Requests** — cota esgotada
- **Timeout** — mais de 10 segundos sem resposta (configurado com `timeout: 10_000`)
- **5xx** — erro interno da OpenAI
- **Resposta vazia ou malformada** — o modelo retornou algo inesperado

**Comportamento:** quando qualquer dessas situações ocorre, o `catch` na rota captura o erro, loga internamente (`console.error`) e retorna as mensagens de fallback com `fallback: true`. O cliente sempre recebe um `200` com sugestões — nunca vê stack trace ou detalhes do erro interno.

O campo `fallback: true` permite que o app exiba um aviso discreto ("Sugestão genérica — serviço de IA indisponível") sem quebrar a experiência do usuário.

### Design do prompt

O prompt instrui o modelo a:
- Gerar **exatamente 3 mensagens** numeradas (facilita o parsing)
- Manter cada mensagem em **até 30 palavras** (controle de custo e legibilidade)
- Escrever em **português brasileiro, de forma natural e afetuosa**

O formato numerado (`1. ...`) permite um parsing simples com regex sem depender de estrutura JSON do modelo.

### Custo e caching

**Em produção**, reduziria o custo com:
- **Cache por par `(occasion, relationship)`**: respostas para "aniversário + amigo" são reutilizáveis — um cache Redis com TTL de 24h eliminaria a maioria das chamadas repetidas
- **Modelo mais barato**: `gpt-4o-mini` já é a escolha mais econômica da OpenAI para texto simples
- **Rate limiting**: limitar requisições por IP evita abuso e custos inesperados

**Neste teste**, não implementei cache para manter o escopo simples e focado nos requisitos principais. O trade-off é documentado aqui.

### Gerenciamento de estado no Flutter

Usei `setState` com `sealed class` em vez de um pacote como Riverpod ou Bloc. A justificativa: para uma tela única com estados bem definidos, `sealed class` + `switch` exaustivo do Dart 3 oferece segurança de tipos sem adicionar dependências desnecessárias. O compilador garante que todo estado está tratado.

### URL configurável

A URL do backend é lida do arquivo `.env` via `flutter_dotenv`. Isso cumpre o requisito do teste de ter a URL configurável sem comprometer credenciais no código.

---

## Testes

O backend possui 5 testes automatizados cobrindo:

| Teste | Cenário |
|---|---|
| Happy path | LLM responde → retorna sugestões reais |
| **Fallback** | LLM falha (429/timeout) → retorna mensagens genéricas sem vazar erro |
| Validação | Body sem `occasion` → 400, LLM não é chamado |
| Validação | Body sem `relationship` → 400, LLM não é chamado |
| Validação | Body vazio → 400 |

O LLM é mockado com `jest.mock` — os testes nunca fazem chamadas reais à OpenAI, são rápidos e determinísticos.

```bash
cd backend && npm test
```

---

## Uso de IA durante o teste

Utilizei o **GitHub Copilot** como assistente durante o desenvolvimento para:
- Sugestões de autocompletar durante a escrita do código
- Diagnóstico de erros de configuração (tsconfig, dotenv, CORS)
- Revisão de tipagem TypeScript

Todas as decisões de arquitetura (separação de camadas, design do prompt, estratégia de fallback, escolha de `sealed class` no Flutter) foram tomadas por mim. O código foi revisado, adaptado e entendido antes de ser incorporado.
