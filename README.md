# Huma-volve E-commerce App

A cross-platform e-commerce app built with Flutter and Dart as part of the Huma-volve training project. It connects to the Platzi Fake Store API for authentication, categories, and products.

## Features

- Login and sign-up with form validation and readable API error messages.
- Secure access and refresh token storage with `flutter_secure_storage` and session restoration.
- User profile, token refresh, and logout.
- Category and product browsing with `flutter_bloc` Cubit state management.
- Clean Architecture (data / domain / presentation) for the auth and home features.
- Product details with image gallery, category, price, and description.
- Loading, empty, and error states, plus pull-to-refresh.

## API

Uses the [Platzi Fake Store API](https://api.escuelajs.co/docs).

| Feature | Endpoint |
| --- | --- |
| Login | `POST auth/login` |
| Sign up | `POST users/` after checking `POST users/is-available` |
| Current user | `GET auth/profile` |
| Refresh session | `POST auth/refresh-token` |
| Categories | `GET categories` |
| Products by category | `GET categories/{id}/products` |

## Architecture

The app follows **Clean Architecture**. Each feature is split into three layers, and each layer only depends on the one below it:

```
presentation  ->  domain  <-  data
(UI + Cubit)     (entities,     (models, data sources,
                  use cases,     repository implementations)
                  repository
                  contracts)
```

- **Domain** (pure Dart): entities, abstract repositories and one use case per action (`LoginUseCase`, `GetProductsUseCase`, ...).
- **Data**: remote/local data sources (Dio / secure storage), models that extend the entities and parse JSON, and repository implementations that turn errors into a `Failure`.
- **Presentation**: screens and widgets that only talk to Cubits; Cubits only talk to use cases.
- Errors travel as `Result<T>` (success or `Failure`) instead of exceptions.
- `core/di/injection.dart` builds every object in one place (data sources -> repositories -> use cases -> cubits).

```
lib/
├── core/
│   ├── di/injection.dart          # dependency injection
│   ├── error/                     # Failure + guardResult
│   ├── network/                   # ApiClient, ApiException, safeApiCall
│   ├── storage/token_storage.dart
│   ├── usecase/usecase.dart       # UseCase<T, Params> + NoParams
│   └── utils/                     # Result, validators
└── features/
    ├── auth/
    │   ├── data/          # datasources, models, repositories
    │   ├── domain/        # entities, repositories, usecases
    │   └── presentation/  # cubit (login, sign up), screens
    ├── home/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/  # cubit, screens, widgets
    └── profile/presentation/  # ProfileCubit uses the auth use cases
```

## Run locally

```bash
flutter pub get
flutter run
```

## Tests

```bash
flutter test
```

## Sample account

The API provides this demo account:

- Email: `john@mail.com`
- Password: `changeme`

Authentication and product data depend on the external demo API.
