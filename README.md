# Dinix Gastos

Aplicativo Flutter de controle de gastos pessoais.

## Stack

- Flutter + BLoC (sem `BlocProvider` na árvore)
- `muller_package` (layout, HTTP, navegação)
- API REST Dinix (`/api/v1`)

## Como rodar

```bash
flutter pub get
flutter run
```

A URL da API está em `lib/app_config/const/app_endpoints.dart`:

- Emulador Android: `http://10.0.2.2:8080`
- iOS Simulator / desktop: `http://localhost:8080`
- Celular físico: IP da máquina na LAN

## Documentação

- [Arquitetura mobile](docs/ARQUITETURA_FLUTTER_MOBILE.md)
- [Guia da API](docs/GUIA_API_DINIX.md)
- [Apple Intelligence / Siri](docs/apple-intelligence.md)
