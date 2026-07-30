import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../logic/blocs/auth/auth_bloc.dart';

/// Placeholder for the Home dashboard (trip summary, featured spots).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthBloc bloc) => bloc.state.user);

    return Scaffold(
      appBar: AppBar(
        title: Text('Good morning, ${user?.name ?? 'traveler'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(const AuthLogoutRequested());
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.explore_outlined,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Home dashboard coming soon',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            // Temporary entry point; will move to the Profile tab.
            OutlinedButton.icon(
              icon: const Icon(Icons.tune),
              label: const Text('Edit interests'),
              onPressed: () => Navigator.of(context)
                  .pushNamed('/interests', arguments: true),
            ),
          ],
        ),
      ),
    );
  }
}
