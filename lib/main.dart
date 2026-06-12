import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/catalog/presentation/cubit/catalog_cubit.dart';
import 'features/catalog/presentation/pages/main_navigation_page.dart';
import 'features/cart/presentation/cubit/cart_cubit.dart';
import 'features/assistant/presentation/cubit/assistant_cubit.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => di.sl<AuthCubit>()..appStarted(),
        ),
        BlocProvider<CatalogCubit>(
          create: (_) => di.sl<CatalogCubit>()..loadCatalog(),
        ),
        BlocProvider<CartCubit>(
          create: (_) => di.sl<CartCubit>()..loadCart(),
        ),
        BlocProvider<AssistantCubit>(
          create: (_) => di.sl<AssistantCubit>()..loadChat(),
        ),
      ],
      child: MaterialApp(
        title: 'IntelliCart Mobile',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            ),
          );
        } else if (state is AuthAuthenticated) {
          return const MainNavigationPage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
