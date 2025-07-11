import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/widgets/loading_widget.dart';
import 'features/authentication/data/auth_service.dart';
import 'features/authentication/data/auth_repository.dart';
import 'features/authentication/presentation/cubit/auth_cubit.dart';
import 'features/authentication/presentation/cubit/auth_state.dart';
import 'features/authentication/presentation/pages/auth_welcome_screen.dart';
import 'features/authentication/presentation/pages/home_screen.dart';
import 'features/authentication/presentation/pages/login_screen.dart';
import 'features/authentication/presentation/pages/signup_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => AuthCubit(
            AuthRepositoryImpl(AuthRemoteDataSourceImpl(FirebaseAuth.instance)),
          )..checkAuthStatus(),
      child: MaterialApp(
        title: 'Weather App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const AuthWrapper(),
        routes: {
          '/welcome': (context) => const AuthWelcomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/home': (context) => const HomeScreen(),
        },
        debugShowCheckedModeBanner: false,
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
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            backgroundColor: Color(0xFF010C2A),
            body: LoadingWidget(message: 'Loading...'),
          );
        } else if (state is AuthAuthenticated) {
          return const HomeScreen();
        } else {
          return const AuthWelcomeScreen();
        }
      },
    );
  }
}
