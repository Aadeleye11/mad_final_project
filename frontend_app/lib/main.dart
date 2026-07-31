import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/router/app_router.dart';
import 'features/discover/presentation/bloc/discover_bloc.dart';
import 'injection_container.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Wrapped so the app still boots before `flutterfire configure` has run.
  // Without Firebase the Discover tab falls back to its bundled seed data.
  try {
    await Firebase.initializeApp();
  } catch (_) {
    debugPrint('Firebase not configured yet — running on local data.');
  }

  await di.init();
  runApp(const RwandaGoApp());
}

class RwandaGoApp extends StatelessWidget {
  const RwandaGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Provided above the router so DiscoverPage and AttractionDetailPage
        // share one instance — the detail page reads from state already loaded.
        BlocProvider<DiscoverBloc>(
          create: (_) => di.sl<DiscoverBloc>()..add(const DiscoverStarted()),
        ),
        // Saad and Paul add their global BLoCs here, one line each.
      ],
      child: MaterialApp.router(
        title: 'RwandaGo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00A36C)),
        ),
        routerConfig: AppRouter.router,
      ),
    );
  }
}
