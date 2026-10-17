import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/check_auth_status_usecase.dart';
import '../../features/auth/domain/usecases/get_profile_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/auth/presentation/cubit/login_cubit.dart';
import '../../features/auth/presentation/cubit/sign_up_cubit.dart';
import '../../features/details/data/datasources/product_details_remote_data_source.dart';
import '../../features/details/data/repositories/product_details_repository_impl.dart';
import '../../features/details/domain/repositories/product_details_repository.dart';
import '../../features/details/domain/usecases/get_product_details_usecase.dart';
import '../../features/details/presentation/cubit/product_details_cubit.dart';
import '../../features/home/data/datasources/home_remote_data_source.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/entities/product_entity.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_categories_usecase.dart';
import '../../features/home/domain/usecases/get_products_usecase.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../network/api_client.dart';
import '../storage/token_storage.dart';

/// The only place that knows how to build the app's objects
/// (a simple service locator). Each layer only receives what it needs:
/// data sources -> repositories -> use cases -> cubits.
///
/// Static fields are created lazily the first time they are used.
class Injection {
  Injection._();

  // Core
  static final ApiClient apiClient = ApiClient.instance;
  static final TokenStorage tokenStorage = TokenStorage.instance;

  // Auth
  static final AuthRemoteDataSource authRemoteDataSource =
      AuthRemoteDataSourceImpl(apiClient.dio);
  static final AuthLocalDataSource authLocalDataSource =
      AuthLocalDataSourceImpl(tokenStorage);
  static final AuthRepository authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
    localDataSource: authLocalDataSource,
  );
  static final LoginUseCase loginUseCase = LoginUseCase(authRepository);
  static final SignUpUseCase signUpUseCase = SignUpUseCase(authRepository);
  static final GetProfileUseCase getProfileUseCase = GetProfileUseCase(
    authRepository,
  );
  static final LogoutUseCase logoutUseCase = LogoutUseCase(authRepository);
  static final CheckAuthStatusUseCase checkAuthStatusUseCase =
      CheckAuthStatusUseCase(authRepository);

  // Home
  static final HomeRemoteDataSource homeRemoteDataSource =
      HomeRemoteDataSourceImpl(apiClient.dio);
  static final HomeRepository homeRepository = HomeRepositoryImpl(
    homeRemoteDataSource,
  );
  static final GetCategoriesUseCase getCategoriesUseCase =
      GetCategoriesUseCase(homeRepository);
  static final GetProductsUseCase getProductsUseCase = GetProductsUseCase(
    homeRepository,
  );

  // Product details
  static final ProductDetailsRemoteDataSource productDetailsRemoteDataSource =
      ProductDetailsRemoteDataSourceImpl(apiClient.dio);
  static final ProductDetailsRepository productDetailsRepository =
      ProductDetailsRepositoryImpl(productDetailsRemoteDataSource);
  static final GetProductDetailsUseCase getProductDetailsUseCase =
      GetProductDetailsUseCase(productDetailsRepository);

  // Cubits: a new instance every time a screen needs one.
  static LoginCubit loginCubit() => LoginCubit(loginUseCase);

  static SignUpCubit signUpCubit() => SignUpCubit(signUpUseCase);

  static HomeCubit homeCubit() => HomeCubit(
    getCategoriesUseCase: getCategoriesUseCase,
    getProductsUseCase: getProductsUseCase,
  );

  static ProductDetailsCubit productDetailsCubit({
    required int productId,
    ProductEntity? initialProduct,
  }) => ProductDetailsCubit(
    getProductDetailsUseCase: getProductDetailsUseCase,
    productId: productId,
    initialProduct: initialProduct,
  );

  static ProfileCubit profileCubit() => ProfileCubit(
    getProfileUseCase: getProfileUseCase,
    logoutUseCase: logoutUseCase,
  );
}
