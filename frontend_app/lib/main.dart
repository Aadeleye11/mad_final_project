import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'logic/blocs/counter/counter_bloc.dart';
import 'presentation/screens/counter_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => CounterBloc())],
      child: MaterialApp(
        title: 'Rwanda Go',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: const CounterScreen(),
      ),
    );
  }
}
