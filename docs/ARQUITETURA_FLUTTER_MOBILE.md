# Arquitetura Flutter Mobile — Dinix

Padrão **Muller Package + BLoC** aplicado ao app Dinix.

## Placeholders

| Item | Valor |
|------|--------|
| Pacote Dart | `app_dinix` |
| Título | Dinix Gastos |
| Marca | Dinix |
| Prefixo | dinix |
| API | `http://10.0.2.2:8080` (emulador Android) |
| Primária | `#FF9800` |
| Fundo | `#000000` |

## Princípios

- Feature por pasta em `lib/pages/<feature>/` com 5 arquivos BLoC.
- UI não chama API. Page → BLoC → feature service → `lib/services/`.
- BLoC instanciado na Page (sem `BlocProvider` na árvore).
- Sem rotas nomeadas. Navegação via `open()` do `muller_package`.
- URLs só em `app_endpoints.dart`.
- Header autenticado: `autorizacao: Bearer {token}`.
- 401 → `tratarSessaoExpirada` (limpa token e volta ao login).

## Fluxo inicial

```
main.dart → AppWidget → AuthGatePage
  ├─ sessão válida → HomeShell
  └─ sem sessão    → LoginPage → CadastroUsuarioPage
```

HomeShell: IndexedStack + bottom nav (Início, Extrato, Carteiras, Relatórios, Perfil).

## Tokens de design

- Neutros: `AppColors` do pacote.
- Marca: `DinixColors` em `lib/app_config/const/dinix_colors.dart`.
- Espaçamento, raio e fonte: tokens locais exportados por `app_consts.dart`.
- Pages importam o pacote com `hide AppRadius, AppFontSizes, AppSpacing, AppFormFormatters`.
