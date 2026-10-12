# ecommerce_app_huma_volve

A Flutter e-commerce app built during the Huma-volve training.

## Day 1 Task – Auth feature using the API

Login and sign up are connected to the [Platzi Fake Store API](https://api.escuelajs.co/docs).

| Feature | Endpoint |
| --- | --- |
| Login | `POST auth/login` |
| Sign up | `POST users/` (after checking `POST users/is-available`) |
| Current user | `GET auth/profile` |
| Refresh session | `POST auth/refresh-token` |

### What's included

- **Login**: validates the form, calls the API, saves the access and refresh tokens, then opens the home screen.
- **Sign up**: checks that the email isn't already used, creates the account, then logs in automatically.
- **Secure session**: tokens are stored with `flutter_secure_storage`; the splash screen opens the home screen directly if the user is already logged in.
- **Profile**: shows the logged-in user's name, email and avatar from `auth/profile`; refreshes the token once if it expired.
- **Logout**: clears the saved tokens and returns to the login screen.
- **Error handling**: API and network errors (wrong password, no internet, timeout, validation errors) are shown as readable messages, and the button shows a loader while a request is running.

### Project structure

```
lib/
├── core/
│   ├── constants/api_constants.dart   # base URL + endpoints
│   ├── network/api_client.dart        # Dio + logger
│   ├── network/api_exception.dart     # DioException -> readable message
│   ├── storage/token_storage.dart     # secure token storage
│   └── utils/validators.dart          # form validators
└── features/auth/
    ├── data/auth_service.dart         # login, sign up, profile, refresh, logout
    ├── data/models/                   # AuthTokens, UserModel, SignUpRequest
    ├── login/screens/login_screen.dart
    └── sign_up/screens/sign_up_screen.dart
```

### Test account

You can log in with the API's sample user:

- Email: `john@mail.com`
- Password: `changeme`

## Day 2 Task – Home feature using the API + State Management (Cubit)

The home screen now gets its data from the API and is managed with **Cubit** (`flutter_bloc`).

| Data | Endpoint |
| --- | --- |
| Categories | `GET categories` |
| Products of a category | `GET categories/{id}/products` |

### How it works

- `HomeService` talks to the API (uses the shared `ApiClient`) and returns `CategoryModel` / `ProductModel` lists.
- `HomeCubit` is the only thing the UI talks to. `loadHomeData()` loads the categories, then the products of the first category. `getProducts(categoryId)` loads the products when a category is tapped.
- States (`home_state.dart`): `HomeInitial`, `CategoriesLoading / CategoriesSuccess / CategoriesError`, `ProductsLoading / ProductsSuccess / ProductsError`.
- `BlocProvider` (in `MainNavigationScreen`) creates the cubit for the home screen.
- Two `BlocBuilder`s with `buildWhen`: one rebuilds the categories only on categories states, the other rebuilds the products grid only on products states.
- Tapping a category shows its products, with a loader, an empty message and an error message with "Try again". Pull down to refresh.
- Product details show the API images (swipe between them), category, price and description.

```
lib/features/home/
├── cubit/home_cubit.dart
├── cubit/home_state.dart
├── models/category_model.dart
├── models/product_model.dart
├── services/home_service.dart
├── screens/home_screen.dart
└── widgets/
```

## Run

```bash
flutter pub get
flutter run
```
