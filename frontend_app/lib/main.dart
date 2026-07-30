import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/preferences_repository.dart';
import 'logic/blocs/auth/auth_bloc.dart';
import 'logic/blocs/interests/interests_bloc.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/signup_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/onboarding/interest_selection_screen.dart';
import 'presentation/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(preferencesRepository: PreferencesRepository(prefs)));
}

class MyApp extends StatelessWidget {
  final PreferencesRepository preferencesRepository;

  const MyApp({super.key, required this.preferencesRepository});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider.value(value: preferencesRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(context.read<AuthRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                InterestsBloc(context.read<PreferencesRepository>()),
          ),
        ],
        child: MaterialApp(
          title: 'Rwanda Go',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          initialRoute: '/',
          routes: {
            '/': (_) => const SplashScreen(),
            '/login': (_) => const LoginScreen(),
            '/signup': (_) => const SignupScreen(),
            '/interests': (_) => const InterestSelectionScreen(),
            '/home': (_) => const HomeScreen(),
          },
        ),
      ),
    );
  }
}
