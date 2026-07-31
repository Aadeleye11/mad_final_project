import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../logic/blocs/auth/auth_bloc.dart';

/// Profile tab: account info and a settings list.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthBloc bloc) => bloc.state.user);
    final initials = (user?.name ?? 'T')
        .trim()
        .split(RegExp(r'\s+'))
        .take(2)
        .map((w) => w.isEmpty ? '' : w[0].toUpperCase())
        .join();

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 28),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'Traveler',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.tune,
            title: 'My Interests',
            onTap: () =>
                Navigator.of(context).pushNamed('/interests', arguments: true),
          ),
          _SettingsTile(
            icon: Icons.bookmark_outline,
            title: 'Saved Itineraries',
            onTap: () {},
          ),
          _SettingsTile(icon: Icons.language, title: 'Language', onTap: () {}),
          _SettingsTile(
            icon: Icons.download_outlined,
            title: 'Offline Data',
            onTap: () {},
          ),
          _SettingsTile(icon: Icons.info_outline, title: 'About', onTap: () {}),
          _SettingsTile(
            icon: Icons.logout,
            title: 'Logout',
            color: AppColors.error,
            onTap: () {
              context.read<AuthBloc>().add(const AuthLogoutRequested());
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'RwandaGo v1.0.0',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? color;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textPrimary),
      title: Text(
        title,
        style: TextStyle(color: color ?? AppColors.textPrimary, fontSize: 15),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: color ?? AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }
}
