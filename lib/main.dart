import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xall_call/core/config/env_config.dart';
import 'package:xall_call/core/config/environment.dart';
import 'package:xall_call/core/styles/app_theme.dart';
import 'package:xall_call/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:xall_call/features/auth/presentation/bloc/auth_event.dart';
import 'package:xall_call/features/auth/presentation/bloc/auth_state.dart';
import 'package:xall_call/features/auth/presentation/pages/home_page.dart';
import 'package:xall_call/features/auth/presentation/pages/signin_page.dart';
import 'package:xall_call/features/auth/presentation/pages/signup_page.dart';
import 'package:xall_call/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.load();

  // set this via --dart-define in build commands
  // flutter build web --dart-define=ENVIRONMENT=development
  // flutter build web --dart-define=ENVIRONMENT=staging --release
  // local run
  // flutter build web --dart-define=ENVIRONMENT=production --release
  // flutter run -d chrome --dart-define=ENVIRONMENT=development
  // flutter run -d chrome --dart-define=ENVIRONMENT=staging
  // const String env = String.fromEnvironment(
  //   'ENVIRONMENT',
  //   defaultValue: 'development',
  // );
  String envEnv = EnvConfig.environment;
  switch (envEnv) {
    case 'production':
      AppEnvironment.initialize(Environment.production);
      break;
    case 'staging':
      AppEnvironment.initialize(Environment.staging);
      break;
    default:
      AppEnvironment.initialize(Environment.development);
  }

  await initializeDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<AuthBloc>()..add(CheckAuthStatus()),
        ),
      ],
      child: MaterialApp(
        title: 'Xall Call',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const AuthWrapper(),
        routes: {
          '/signin': (context) => const SignInPage(),
          '/signup': (context) => const SignUpPage(),
          '/home': (context) => const HomePage(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        // Handle navigation based on auth state
        if (state is AuthUnauthenticated) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/signin',
            (route) => false,
          );
        }
      },
      builder: (context, state) {
        // Show loading while checking auth
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If authenticated, show home page
        if (state is AuthAuthenticated) {
          return const HomePage();
        }

        // Default to loading. will redirect to signin via listener
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
