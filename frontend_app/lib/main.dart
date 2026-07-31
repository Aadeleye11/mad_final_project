import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'features/discover/presentation/bloc/discover_bloc.dart';
import 'firebase_options.dart';
import 'injection_container.dart' as di;
import 'logic/blocs/auth/auth_bloc.dart';
import 'logic/blocs/plan/plan_bloc.dart';
import 'logic/blocs/home/home_bloc.dart';
import 'presentation/screens/main_shell.dart';
import 'data/repositories/auth_repository.dart';
import 'presentation/screens/splash_screen.dart';
import 'logic/blocs/interests/interests_bloc.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'data/repositories/itinerary_repository.dart';
import 'presentation/screens/auth/signup_screen.dart';
import 'data/repositories/attractions_repository.dart';
import 'data/repositories/preferences_repository.dart';
import 'presentation/screens/plan/qr_code_screen.dart';
import 'presentation/screens/discover/attraction_detail_screen.dart';
import 'presentation/screens/onboarding/interest_selection_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Wrapped so the app still boots before Firebase is fully wired up.
  // Without it, the Discover tab falls back to its bundled seed data.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    debugPrint('Firebase not configured yet — running on local data.');
  }

  final prefs = await SharedPreferences.getInstance();
  await di.init();
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
        RepositoryProvider(create: (_) => ItineraryRepository()),
        RepositoryProvider(create: (_) => AttractionsRepository()),
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
          BlocProvider(
            create: (context) => HomeBloc(
              context.read<AttractionsRepository>(),
              context.read<ItineraryRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => PlanBloc(context.read<ItineraryRepository>()),
          ),
          // Discover feature owns its own DI graph (get_it) so it never
          // touches the shared providers above; only the BLoC is exposed here.
          BlocProvider<DiscoverBloc>(
            create: (_) => di.sl<DiscoverBloc>()..add(const DiscoverStarted()),
          ),
        ],
        child: MaterialApp(
          title: 'Rwanda Go',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          initialRoute: '/',
          routes: {
            '/': (_) => const SplashScreen(),
            '/home': (_) => const MainShell(),
            '/login': (_) => const LoginScreen(),
            '/signup': (_) => const SignupScreen(),
            '/interests': (_) => const InterestSelectionScreen(),
            '/spot': (_) => const AttractionDetailScreen(),
            '/qr': (_) => const QrCodeScreen(),
          },
        ),
      ),
    );
  }
}
