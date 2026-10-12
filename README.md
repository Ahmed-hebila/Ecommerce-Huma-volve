# Huma-volve E-commerce App

A cross-platform e-commerce app built with Flutter and Dart as part of the Huma-volve training project. It connects to the Platzi Fake Store API for authentication, categories, and products.

## Features

- Login and sign-up with form validation and readable API error messages.
- Secure access and refresh token storage with `flutter_secure_storage` and session restoration.
- User profile, token refresh, and logout.
- Category and product browsing with `flutter_bloc` Cubit state management.
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

- `ApiClient` centralizes Dio requests and logging.
- `AuthService` and `HomeService` handle API operations.
- `HomeCubit` manages category and product loading states.
- Feature code is organized under `lib/features/`; shared networking, storage, constants, and validators are under `lib/core/`.

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
