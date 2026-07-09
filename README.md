# eazywallet

Simple Flutter wallet demo with MobX state, mocked data, and a PIN-gated report flow.

## 1. How to run it

```bash
flutter pub get
flutter run
```

Run tests with `flutter test`.

## 2. Packages used and why

- `flutter_mobx` and `mobx`: lightweight state management for the dashboard, transaction details, PIN, and report form stores.
- `go_router`: clean navigation between dashboard, transaction details, and report screens.
- `google_fonts`: custom typography.
- `build_runner` and `mockito`: test and codegen support.

## 3. Folder structure

- `lib/main.dart`: app bootstrap and theme setup.
- `lib/core/`: routing, errors, formatters, and shared widgets.
- `lib/features/home/`: dashboard feature.
- `lib/features/transactions/`: transaction data, domain models, stores, and screens.
- `test/`: widget and store tests.

## 4. MobX state management approach

Each feature uses a small store instead of a global app state. The dashboard store loads user + transactions, the details store loads one transaction, the report form store tracks the selected reason/description, and the PIN store manages verification state. UI widgets listen with `Observer` and only rebuild where needed.

## 5. Mock backend / simulated service

`WalletRepositoryImpl` is an in-memory fake backend. It adds a short delay to mimic network latency, returns seeded dashboard and transaction data, and simulates failure states like dashboard errors, server errors, duplicate reports, ineligible reports, and PIN lockout.

## 6. Validation

The report form blocks submit until a reason is chosen and the description is between 20 and 250 characters. The PIN sheet requires exactly 4 digits before confirm is enabled. The repo also re-checks business rules so invalid data still fails safely on submit.

## 7. PIN flow

Reporting a transaction opens a PIN bottom sheet first. The user enters a 4-digit PIN, the app verifies it against the repository, and after three wrong attempts the PIN is locked for the session. A successful PIN check returns to the form and submits the report.

## 8. Edge cases handled

- Missing transaction IDs.
- Transactions that already have an active report.
- Failed or reversed transactions that cannot be reported.
- Double submits while loading or verifying.
- Dashboard and transaction load errors with retry buttons.
- Locked PIN sessions.

## 9. Known trade-offs

The repository is intentionally stateful and in-memory, so refreshes can change local state but nothing is persisted across app restarts. The mock backend is good for demos and tests, but it does not model real auth, retries, or server-side concurrency.

## 10. What I would improve with more time

I would split the repository into a clearer data layer, add persistence for reports and PIN attempts, extract shared form validation helpers, and cover the main flows with more widget tests.
