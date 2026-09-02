# Integração Dinix × Apple Intelligence / Siri

O Dinix se integra à Siri e à Apple Intelligence por **App Intents**, **App Entities** e **App Shortcuts**. A Siri interpreta a linguagem natural; o app executa a ação contra a **API Dinix**, que continua sendo a fonte da verdade.

```
Usuário → Siri / Apple Intelligence → App Intent → DinixAPIClient (iOS)
        → GET/POST https://dinix.api.convertix.net.br/api/v1 → backend → resposta falada
```

Nada disso altera o Android. O código nativo vive só em `ios/`.

## 1. Arquitetura

| Camada | Onde | Papel |
|---|---|---|
| Siri / Shortcuts / Spotlight | Sistema Apple | Interpreta a frase e preenche parâmetros |
| App Intents / Entities | `ios/Runner/AppleIntelligence/` | Contrato com o sistema |
| Sessão nativa | `DinixSessionStore` + Keychain | Token do usuário autenticado |
| Cliente HTTP | `DinixAPIClient` | Mesmos headers e endpoints do Flutter |
| Flutter | `lib/app_config/apple_intelligence_bridge.dart` | Espelha login/logout e contexto da tela |

A lógica financeira **não** foi reescrita em Swift. Totais mensais vêm de `GET /painel` e `GET /patrimonio`. Filtros por data usam `GET /transacoes/busca` ou `GET /compras`.

## 2. Entidades reais do Dinix

Não existe `DespesaModel` no app. O mapeamento oficial é:

| Linguagem do usuário | Entidade Swift | Modelo / endpoint |
|---|---|---|
| Despesa / gasto pontual | `CompraEntity` | `CompraModel` → `/compras` |
| Receita / ganho | `ReceitaEntity` | `ReceitaModel` → `/receitas` |
| Conta a pagar | `GastoMensalEntity` | `GastoMensalModel` → `/despesas-recorrentes` |
| Assinatura | `AssinaturaEntity` | `AssinaturaModel` → `/assinaturas` |
| Categoria | `CategoriaEntity` | `CategoriaModel` → `/categorias` |
| Estabelecimento | `LocalEntity` | `LocalModel` → `/locais` |
| Conta bancária / carteira | `ContaBancariaEntity` | `ContaModel` → `/contas` |

**Não criados de propósito**

- `ExpenseEntity` — gasto pontual é compra.
- `BillEntity` — “conta a pagar” é despesa recorrente, não `ContaModel`.
- `InstallmentEntity` — não há `ParcelaModel` no app.
- `ProductEntity` — endpoint `/produtos` existe, mas o Flutter não implementa o recurso.
- `InvestmentEntity` — não há CRUD de investimento no app; só totais em `/patrimonio` e `/painel`.
- `PurchaseTypeEntity` — o tipo de compra no Dinix é a categoria.

## 3. Intents

### Consultas

| Intent | Uso |
|---|---|
| `ConsultarGastosIntent` | Total, lista ou maior gasto por período, categoria ou local |
| `ConsultarReceitasIntent` | Total, lista ou maior receita |
| `ConsultarSaldoIntent` | Saldo das contas, disponível do mês, entrou/saiu, resumo |
| `ConsultarContasPagarIntent` | Pendentes, hoje, amanhã, semana, atrasadas, próxima, total |
| `ConsultarAssinaturasIntent` | Lista, total mensal, próxima, vencem esta semana |
| `ConsultarComprasIntent` | Últimas, total, maior, parceladas |
| `ConsultarParcelasIntent` | Compras com `qtd_parcelas > 1` (limitação abaixo) |
| `ConsultarInvestimentosIntent` | Totais de patrimônio / painel / transações `tipo=investimento` |
| `ConsultarLocaisIntent` | Gasto em um local ou local com maior gasto |
| `ConsultarCategoriasIntent` | Gastos do painel por categoria |
| `PesquisarNoDinixIntent` | `GET /transacoes/busca?busca=` |

### Ações

| Intent | Endpoint | Confirmação |
|---|---|---|
| `RegistrarDespesaIntent` | `POST /compras` | Sim (iOS 17+) |
| `RegistrarReceitaIntent` | `POST /receitas` | Sim |
| `RegistrarContaPagarIntent` | `POST /despesas-recorrentes` | Sim |
| `RegistrarAssinaturaIntent` | `POST /assinaturas` | Sim |
| `RegistrarInvestimentoIntent` | — | Não cadastra; explica a limitação |
| `ExcluirRegistroIntent` | `DELETE` do recurso | Sempre |

Intents de abertura (`AbrirCompraIntent` etc.) implementam `OpenIntent` para Spotlight.

## 4. Parâmetros

Tipos nativos, não `String` genérico:

- `PeriodoConsulta` (enum)
- `Date` / `DateInterval`
- `Decimal` para valores
- `Int` para parcelas e dia de vencimento
- `AppEntity` para categoria, local, conta, compra, receita, assinatura

Exemplo: “Quanto gastei com alimentação nos últimos 7 dias?”

```
ConsultarGastosIntent
  periodo = ultimos7Dias
  categoria = Alimentação
```

A Siri preenche os parâmetros. Não há parser de frases no app.

## 5. App Shortcuts

Atalhos descobríveis (não um atalho por frase):

- Consultar gastos
- Consultar receitas
- Consultar saldo
- Consultar contas
- Consultar assinaturas
- Consultar investimentos
- Registrar despesa
- Registrar receita
- Pesquisar

As frases do `AppShortcutsProvider` incluem `applicationName` (“Dinix”). A Apple Intelligence generaliza variações a partir do título, da descrição e desses atalhos.

## 6. Autenticação

1. O Flutter guarda o JWT em `flutter_secure_storage` (`auth_token`).
2. No login/logout, `onSessaoNativaAlterada` chama `syncAppleIntelligenceSession()`.
3. O token vai para o Keychain nativo (`com.net.convertix.dinix.siri`), acessível após o primeiro desbloqueio do aparelho.
4. Metadados não sensíveis (dia da sessão, device id, URL da API) ficam no App Group `group.com.net.convertix.dinix`.
5. A sessão diária do app é respeitada: se `auth_saved_day` não for hoje, a Siri pede para abrir o Dinix.
6. Intents financeiros usam `IntentAuthenticationPolicy.requiresAuthentication`.
7. Sem token: *“Abra o Dinix e faça login para consultar seus dados.”*

Não há usuário global, token no código-fonte nem log de token.

O App Group precisa ser criado no Apple Developer (Identifiers → App Groups) e associado ao App ID `com.net.convertix.dinix`. Sem isso, o fallback é `UserDefaults.standard` no mesmo processo do app — suficiente para App Intents in-process.

## 7. Comunicação com o backend

Mesmos headers do Flutter (`getAuthHeaders()`):

```
autorizacao: Bearer {token}
X-Client-Id / X-Client-Secret
X-App-Version / X-Platform: ios / X-Device-Id
Accept: application/json
```

Base: valor de `server` em `app_endpoints.dart`, enviado no sync (hoje `https://dinix.api.convertix.net.br`).

Valores são enviados como string com 2 casas (`"187.50"`), iguais ao `toStringAsFixed(2)` do Dart. Cálculos no iOS usam centavos (`DinixMoney`), não `Double`.

Datas usam o fuso do aparelho (`TimeZone.current`), formato `YYYY-MM-DD`. Não se assume UTC.

## 8. Privacidade

- Spotlight indexa **apenas nomes** de categorias, locais, assinaturas e gastos mensais. Valores monetários não entram no índice.
- Contexto na tela envia tipo, id e título — sem valor.
- Intents exigem autenticação do dispositivo.
- Exclusão e criação pedem confirmação no iOS 17+.
- A biometria do AuthGate continua só no cold start do Flutter; a Siri usa a política nativa de autenticação do intent.

## 9. Limitações conhecidas

1. **Não existe App Schema de finanças.** Mail, Photos e Messages têm schemas oficiais; finanças pessoais não. Os intents são customizados + App Shortcuts. A Apple Intelligence usa título, descrição e parâmetros — não um domínio financeiro pré-treinado.
2. **Flutter não anota views com `.appEntity`.** O contexto de “isso / essa compra” usa `NSUserActivity` + entidade aberta no cadastro. Funciona ao editar um registro existente, não em listas Flutter.
3. **Parcelas.** Só existem `qtd_parcelas` e `valor_parcela` na compra. Não há saldo restante nem status por parcela no client. A Siri não inventa “quanto ainda falta”.
4. **Investimentos.** Sem model/service de CRUD. Dá para consultar totais; não dá para cadastrar.
5. **Produtos.** Endpoint declarado, sem implementação no app.
6. **Relatórios** (`/relatorios/*`) não são consumidos pelo Flutter; a Siri usa painel, patrimônio e transações.
7. **Foundation Models** não são usados. Contas (`SUM`) são determinísticas. Um LLM no aparelho poderia só explicar um número já calculado — isso ficou de fora de propósito.
8. **Compilação iOS.** Este repositório é desenvolvido também no Windows. `flutter build ios` precisa de macOS + Xcode.

## 10. Requisitos de iOS

| Recurso | Versão |
|---|---|
| App mínimo do projeto | iOS 15.0 |
| App Intents / Shortcuts | iOS 16.0 |
| Confirmação nativa das ações | iOS 17.0 |
| Apple Intelligence, `IndexedEntity`, indexação semântica | iOS 18.1+ (Apple Intelligence ativo) |
| Schemas avançados / on-screen nativo | iOS 26 / 27 conforme o Xcode do Mac |

No iOS 15 o app abre normalmente; a Siri simplesmente não vê os intents.

## 11. Requisitos de Xcode

- Xcode 16 ou superior (macros de App Intent / schemas).
- Para APIs de WWDC26 (`IndexedEntityQuery`, schemas novos): Xcode 26.
- Capability **Siri** e **App Groups** no App ID.
- Entitlements em `ios/Runner/Runner.entitlements`.

`LastUpgradeCheck` versionado do projeto ainda é 1510; a integração é compatível com o target 15 via `@available`.

## 12. Como testar

### Atalhos (sem Siri)

1. Faça login no Dinix no iPhone.
2. Abra Atalhos → Galeria / app Dinix.
3. Execute “Consultar gastos”, “Consultar saldo”, “Registrar despesa”.

### Siri

Com Apple Intelligence ativo:

- “Ei Siri, quanto eu gastei ontem no Dinix?”
- “Quanto eu recebi esse mês no Dinix?”
- “Qual meu saldo no Dinix?”
- “Registrar uma despesa de 50 reais no Dinix.”

### Testes automatizados

No Mac:

```bash
cd ios
xcodebuild test -workspace Runner.xcworkspace -scheme Runner -destination 'platform=iOS Simulator,name=iPhone 16'
```

Em qualquer máquina:

```bash
flutter test test/apple_intelligence_bridge_test.dart
```

Os testes Swift cobrem: gastos de hoje/ontem/mês, receitas, saldo, criação de despesa/receita, usuário sem login, token 401, API fora do ar, lista vazia e erro de validação.

## 13. Exemplos de comandos

Todas estas frases devem cair no mesmo intent de gastos, com `periodo = ontem`:

- Quanto eu gastei ontem?
- Quanto gastei ontem?
- Qual foi meu gasto ontem?
- Quanto dinheiro eu gastei ontem?
- Me diga meus gastos de ontem.

Outros exemplos alinhados ao domínio real:

| Frase | Intent | Fonte |
|---|---|---|
| Quanto eu gastei esse mês? | Consultar gastos | `GET /painel` |
| Quanto gastei com alimentação? | Consultar gastos | `/transacoes/busca?tipo=despesa` |
| Quanto gastei no supermercado? | Consultar gastos | `/compras` filtrado por local |
| Quanto dinheiro eu tenho? | Consultar saldo (`saldoContas`) | `GET /patrimonio` → `saldo_contas` |
| Quanto tenho disponível? | Consultar saldo (`disponivel`) | `GET /painel` → `disponivel` (receitas − despesas − investimentos do mês) |
| Quais contas vencem hoje? | Consultar contas a pagar | `/despesas-recorrentes/pendentes` |
| Quanto gasto com assinaturas? | Consultar assinaturas | `/assinaturas/resumo` → `total_mensal` |
| Quanto tenho investido? | Consultar investimentos | `/patrimonio` → `valor_investimentos` |

## 14. Como adicionar um intent novo

1. Confirme que o recurso existe no Flutter/API. Não invente endpoint.
2. Prefira um parâmetro/enum em um intent existente a criar um intent por frase.
3. Crie o `AppIntent` em `ios/Runner/AppleIntelligence/Intents/`.
4. Use `DinixAPIClient` e `DinixMoney`. Trate `DinixAPIError` com mensagem amigável.
5. Se for ação destrutiva ou financeira, chame `confirmar` / `confirmarExclusao`.
6. Inclua no `DinixShortcuts` só se for uma capacidade principal.
7. Adicione o arquivo ao target Runner no Xcode (ou no `project.pbxproj`).
8. Documente a limitação se a API da Apple ou do Dinix não cobrir o caso.
9. Escreva um teste de cliente ou de formatação; não teste parser de frase.

## Significado financeiro (para não confundir a Siri)

- **Saldo** = soma dos `saldo_atual` das contas bancárias (`patrimonio.saldo_contas`).
- **Disponível / quanto sobrou** = `painel.disponivel` do mês (não é saldo em conta).
- **Conta** na boca do usuário, neste contexto de “pagar”, é **despesa recorrente**.
- **Conta bancária** é `ContaModel` (Nubank, carteira, etc.).
- Transferência não é despesa (regra da API). A Siri de gastos usa `tipo=despesa` ou compras.
