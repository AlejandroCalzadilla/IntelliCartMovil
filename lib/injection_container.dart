import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/api_client.dart';
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/check_login_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';

import 'features/catalog/data/datasources/catalog_remote_data_source.dart';
import 'features/catalog/data/repositories/catalog_repository_impl.dart';
import 'features/catalog/domain/repositories/catalog_repository.dart';
import 'features/catalog/domain/usecases/get_categories_usecase.dart';
import 'features/catalog/domain/usecases/get_products_usecase.dart';
import 'features/catalog/presentation/cubit/catalog_cubit.dart';

import 'features/cart/data/repositories/cart_repository_impl.dart';
import 'features/cart/domain/repositories/cart_repository.dart';
import 'features/cart/presentation/cubit/cart_cubit.dart';

import 'features/assistant/data/repositories/assistant_repository_impl.dart';
import 'features/assistant/domain/repositories/assistant_repository.dart';
import 'features/assistant/domain/usecases/get_history_usecase.dart';
import 'features/assistant/domain/usecases/send_message_usecase.dart';
import 'features/assistant/presentation/cubit/assistant_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features
  // Cubits (Factory)
  sl.registerFactory(() => AuthCubit(
        loginUseCase: sl(),
        logoutUseCase: sl(),
        checkLoginUseCase: sl(),
        authRepository: sl(),
      ));

  sl.registerFactory(() => CatalogCubit(
        getProductsUseCase: sl(),
        getCategoriesUseCase: sl(),
      ));

  sl.registerFactory(() => CartCubit(
        cartRepository: sl(),
      ));

  sl.registerFactory(() => AssistantCubit(
        sendMessageUseCase: sl(),
        getHistoryUseCase: sl(),
        apiClient: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => CheckLoginUseCase(sl()));
  sl.registerLazySingleton(() => GetProductsUseCase(sl()));
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => SendMessageUseCase(sl()));
  sl.registerLazySingleton(() => GetHistoryUseCase(sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
        remoteDataSource: sl(),
        localDataSource: sl(),
      ));
  sl.registerLazySingleton<CatalogRepository>(() => CatalogRepositoryImpl(
        remoteDataSource: sl(),
      ));
  sl.registerLazySingleton<CartRepository>(() => CartRepositoryImpl(
        apiClient: sl(),
        sharedPreferences: sl(),
      ));
  sl.registerLazySingleton<AssistantRepository>(() => AssistantRepositoryImpl(
        apiClient: sl(),
      ));

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(
        apiClient: sl(),
      ));
  sl.registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSourceImpl(
        sharedPreferences: sl(),
      ));
  sl.registerLazySingleton<CatalogRemoteDataSource>(() => CatalogRemoteDataSourceImpl(
        apiClient: sl(),
      ));

  //! Core
  sl.registerLazySingleton(() => ApiClient(
        client: sl(),
        sharedPreferences: sl(),
      ));

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
}
