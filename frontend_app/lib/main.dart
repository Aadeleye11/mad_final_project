import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/attractions_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/itinerary_repository.dart';
import 'data/repositories/preferences_repository.dart';
import 'data/repositories/profile_repository.dart';
import 'features/discover/domain/repositories/attraction_repository.dart';
import 'features/discover/presentation/bloc/discover_bloc.dart';
import 'firebase_options.dart';
import 'injection_container.dart' as di;
import 'logic/blocs/auth/auth_bloc.dart';
import 'logic/blocs/home/home_bloc.dart';
import 'logic/blocs/interests/interests_bloc.dart';
import 'logic/blocs/plan/plan_bloc.dart';
import 'logic/blocs/profile/profile_bloc.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/signup_screen.dart';
import 'presentation/screens/discover/attraction_detail_screen.dart';
import 'presentation/screens/main_shell.dart';
import 'presentation/screens/onboarding/interest_selection_screen.dart';
import 'presentation/screens/plan/qr_code_screen.dart';
import 'presentation/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enable offline reads/writes from local cache (Required for offline QR itinerary)
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  final prefs = await SharedPreferences.getInstance();
  await di.init();
  runApp(
    MyApp(
      preferencesRepository: PreferencesRepository(prefs),
      profileRepository: ProfileRepository(prefs),
    ),
  );
}

class MyApp extends StatelessWidget {
  final PreferencesRepository preferencesRepository;
  final ProfileRepository profileRepository;

  const MyApp({
    super.key,
    required this.preferencesRepository,
    required this.profileRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider.value(value: preferencesRepository),
        RepositoryProvider(
          // Pulled from the container so the shared SharedPreferences instance
          // and the Discover catalogue are reused rather than rebuilt.
          create: (_) => ItineraryRepository(
            prefs: di.sl<SharedPreferences>(),
            attractions: di.sl<AttractionRepository>(),
          ),
        ),
        RepositoryProvider(create: (_) => AttractionsRepository()),
        RepositoryProvider.value(value: profileRepository),
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
            create: (context) =>
                HomeBloc(context.read<AttractionsRepository>()),
          ),
          BlocProvider(
            create: (context) => PlanBloc(context.read<ItineraryRepository>()),
          ),
          BlocProvider(
            create: (context) => ProfileBloc(context.read<ProfileRepository>()),
          ),
          BlocProvider<DiscoverBloc>(
            create: (_) => di.sl<DiscoverBloc>()..add(const DiscoverStarted()),
          ),
        ],
        child: MaterialApp(
          title: 'RwandaGo',
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