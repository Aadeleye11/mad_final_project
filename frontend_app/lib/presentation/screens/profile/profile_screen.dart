import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../logic/blocs/auth/auth_bloc.dart';
import '../../../logic/blocs/home/home_bloc.dart';
import '../../../logic/blocs/profile/profile_bloc.dart';
import 'about_screen.dart';
import 'edit_profile_screen.dart';
import 'offline_data_screen.dart';
import 'saved_itineraries_screen.dart';

/// Profile tab: account info and a settings list.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    final email = context.read<AuthBloc>().state.user?.email ?? '';
    context.read<ProfileBloc>().add(ProfileStarted(email: email));
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You can log back in any time.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Log out',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<AuthBloc>().add(const AuthLogoutRequested());
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthBloc bloc) => bloc.state.user);
    final trip = context.select((HomeBloc bloc) => bloc.state.trip);

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, profileState) {
        final profile = profileState.profile;
        final displayName = profile.displayName.isNotEmpty
            ? profile.displayName
            : (user?.name ?? 'Traveler');
        final initials = displayName
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
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white,
                          backgroundImage: profile.hasAvatar
                              ? FileImage(File(profile.avatarPath))
                              : null,
                          child: profile.hasAvatar
                              ? null
                              : Text(
                                  initials.isEmpty ? 'T' : initials,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                        ),
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const EditProfileScreen(),
                              ),
                            ),
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: AppColors.primaryDark,
                              child: Icon(
                                Icons.edit,
                                size: 13,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
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
                          if (profile.bio.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              profile.bio,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.settings_outlined),
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              if (trip != null)
                Transform.translate(
                  offset: const Offset(0, -18),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          _StatItem(
                            value: '${trip.activitiesCount}',
                            label: 'Activities',
                          ),
                          _StatDivider(),
                          _StatItem(
                            value: '${trip.durationDays}',
                            label: 'Days',
                          ),
                          _StatDivider(),
                          _StatItem(
                            value: profile.location.isEmpty
                                ? '—'
                                : profile.location,
                            label: 'Home city',
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                const SizedBox(height: 12),
              _SettingsTile(
                icon: Icons.tune,
                title: 'My Interests',
                onTap: () => Navigator.of(
                  context,
                ).pushNamed('/interests', arguments: true),
              ),
              _SettingsTile(
                icon: Icons.bookmark_outline,
                title: 'Saved Itineraries',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SavedItinerariesScreen(),
                  ),
                ),
              ),
              _SettingsTile(
                icon: Icons.language,
                title: 'Language',
                trailingText: profile.language,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                ),
              ),
              _SettingsTile(
                icon: Icons.download_outlined,
                title: 'Offline Data',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const OfflineDataScreen()),
                ),
              ),
              _SettingsTile(
                icon: Icons.info_outline,
                title: 'About',
                onTap: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const AboutScreen())),
              ),
              _SettingsTile(
                icon: Icons.logout,
                title: 'Logout',
                color: AppColors.error,
                onTap: () => _confirmLogout(context),
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
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 28, width: 1, color: const Color(0xFFE5E9E8));
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailingText;
  final Color? color;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailingText,
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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) ...[
            Text(
              trailingText!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Icon(Icons.chevron_right, color: color ?? AppColors.textSecondary),
        ],
      ),
      onTap: onTap,
    );
  }
}
