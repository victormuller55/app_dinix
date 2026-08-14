# Guia da API Dinix (frontend)

Base: `http://localhost:8080` (emulador Android: `http://10.0.2.2:8080`).

Prefixo de negócio: `/api/v1`. JSON snake_case em português.

## Autenticação

Header em toda rota autenticada:

```
autorizacao: Bearer {token}
Content-Type: application/json
```

Rotas sem token: `POST /api/v1/autenticacao/registrar` e `POST /api/v1/autenticacao/entrar`.

### Registrar — 201

```json
{ "nome": "Victor", "email": "victor@email.com", "senha": "senha1234" }
```

Senha mínimo 8 caracteres. E-mail repetido → 409.

### Entrar — 200

```json
{ "email": "victor@email.com", "senha": "senha1234" }
```

Senha errada → 401.

Resposta (registrar/entrar): `token`, `tipo_token`, `id_usuario`, `nome`, `email`, `expira_em`.

### Perfil — `GET /api/v1/usuarios/eu`

Usado no splash e no perfil.

## Regras gerais

- Datas: `YYYY-MM-DD` (timezone `America/Sao_Paulo`).
- Valores: decimal com 2 casas.
- IDs: UUID string.
- Nunca enviar `id_usuario` (vem do JWT).
- 401: limpar token e ir para o login.
- Listagens: envelope `{ itens, num_pag, max_pag, max_itens, itens_pag }`. Página começa em 1.

## Erros

```json
{
  "data_hora": "2026-08-13T22:30:00",
  "status": 400,
  "erro": "erro_validacao",
  "mensagem": "Dados inválidos",
  "erros_campos": { "nome": "não deve estar em branco" }
}
```

| HTTP | `erro` | Front |
|------|--------|--------|
| 400 | `erro_validacao` | Mostrar `erros_campos` |
| 401 | `nao_autorizado` | Login |
| 409 | `conflito` | E-mail já cadastrado |
| 422 | `erro_negocio` | Mostrar `mensagem` |

## Regras financeiras

1. Transferência não é despesa.
2. Compra no crédito não baixa saldo na hora; altera limite do cartão.
3. Parcela entra só no mês correspondente.
4. Saldo da conta só muda ao pagar fatura/parcela ou em compra à vista.
5. Front mostra `saldo_atual`; não envia saldo no update.

Endpoints centralizados em `lib/app_config/const/app_endpoints.dart`.
