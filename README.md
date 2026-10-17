# Huma-volve E-commerce App

A cross-platform e-commerce app built with Flutter and Dart as part of the Huma-volve training project. It connects to the Platzi Fake Store API for authentication, categories, and products.

## Features

- Login and sign-up with form validation and readable API error messages.
- Secure access and refresh token storage with `flutter_secure_storage` and session restoration.
- User profile, token refresh, and logout.
- Category and product browsing with `flutter_bloc` Cubit state management.
- Infinite scroll pagination for the home products (10 per page), with a loader, retry on failure, and an end-of-list message.
- Clean Architecture (data / domain / presentation) for the auth, home, and product details features.
- Product details with image gallery, category, price, and description.
- Deep linking: `humavolve://huma-volve.com/product/{id}` opens the product details screen, and the details screen can copy this link.
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
| Products by category (paginated) | `GET categories/{id}/products?offset={offset}&limit=10` |
| Product details (deep link) | `GET products/{id}` |

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
│   ├── routing/                   # AppRoutes, DeepLinks, AppRouter
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
    ├── details/
    │   ├── data/          # GET products/{id}
    │   ├── domain/        # GetProductDetailsUseCase
    │   └── presentation/  # ProductDetailsCubit, screen, widgets
    └── profile/presentation/  # ProfileCubit uses the auth use cases
```

## Pagination

The home screen loads products page by page instead of the whole category at once:

1. Selecting a category loads the first page (`offset=0&limit=10`).
2. When the user scrolls close to the end of the grid, `HomeCubit.loadMoreProducts()` asks for the next page (`offset` = products loaded so far) and adds it under the grid.
3. A page smaller than 10 means every product is loaded, so no more requests are sent.

`ProductsSuccess` carries the loaded products plus `hasMore`, `isLoadingMore` and `loadMoreError`, so the screen can show a loader, a retry button or an end-of-list message under the grid. Requests that finish after the user switched category are ignored, and products already shown are never added twice.

## Deep linking

A product link opens its details screen in the app:

```
humavolve://huma-volve.com/product/{id}
```

- **Android**: an `<intent-filter>` in `android/app/src/main/AndroidManifest.xml` registers the `humavolve` scheme and the `huma-volve.com` host, and `flutter_deeplinking_enabled` passes the link to Flutter as a route.
- **Routing** (`core/routing/`): `AppRoutes.productIdFrom()` reads the id from `/product/{id}` or from the full link, and `AppRouter` builds the screens.
  - App closed (cold start): the app still starts on the splash screen to check the session, then opens the product on top of the home (or login) screen, so the back button works.
  - App already open (warm start): the product details screen opens on top of the current screen.
  - Unknown links show a "Page not found" screen.
- **Product details** (Clean Architecture): from the home list the product is passed to the screen and shown at once; from a link only the id is known, so `ProductDetailsCubit` loads it with `GetProductDetailsUseCase` (`GET products/{id}`), with loading, error and retry states. A product id that doesn't exist shows "This product is not available anymore."
- The link button on the details screen copies the product link so it can be shared.

Try it on an emulator or device with the app installed:

```bash
adb shell am start -W -a android.intent.action.VIEW \
  -d "humavolve://huma-volve.com/product/4" com.example.ecommerce_app_huma_volve
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
