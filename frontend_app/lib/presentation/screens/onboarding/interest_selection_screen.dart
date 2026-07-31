import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_interests.dart';
import '../../../logic/blocs/auth/auth_bloc.dart';
import '../../../logic/blocs/interests/interests_bloc.dart';

/// Shown after first login/signup, or from settings via `arguments: true`
/// (shows a back button and pops instead of continuing to home).
class InterestSelectionScreen extends StatefulWidget {
  const InterestSelectionScreen({super.key});

  @override
  State<InterestSelectionScreen> createState() =>
      _InterestSelectionScreenState();
}

class _InterestSelectionScreenState extends State<InterestSelectionScreen> {
  @override
  void initState() {
    super.initState();
    final email = context.read<AuthBloc>().state.user?.email ?? '';
    context.read<InterestsBloc>().add(InterestsStarted(email: email));
  }

  @override
  Widget build(BuildContext context) {
    final fromSettings =
        (ModalRoute.of(context)?.settings.arguments as bool?) ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: fromSettings
          ? AppBar(
              title: const Text('My Interests'),
              backgroundColor: AppColors.background,
              foregroundColor: AppColors.textPrimary,
            )
          : null,
      body: BlocConsumer<InterestsBloc, InterestsState>(
        listener: (context, state) {
          if (state.status == InterestsStatus.saved) {
            if (fromSettings) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Interests updated'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pushReplacementNamed('/home');
            }
          }
        },
        builder: (context, state) {
          final isSaving = state.status == InterestsStatus.saving;
          final hasSelection = state.selected.isNotEmpty;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    'What are you into?',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Select your interests to personalize your Rwanda '
                    'experience',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final interest in AppInterests.all)
                        FilterChip(
                          label: Text(interest),
                          selected: state.selected.contains(interest),
                          showCheckmark: false,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: state.selected.contains(interest)
                                ? Colors.white
                                : AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                          onSelected: isSaving
                              ? null
                              : (_) => context.read<InterestsBloc>().add(
                                  InterestToggled(interest),
                                ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: hasSelection && !isSaving
                        ? () => context.read<InterestsBloc>().add(
                            const InterestsSubmitted(),
                          )
                        : null,
                    style: ElevatedButton.styleFrom(
                      disabledBackgroundColor: AppColors.primaryLight,
                      disabledForegroundColor: Colors.white,
                    ),
                    child: isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            fromSettings
                                ? 'Save interests'
                                : 'Generate my itinerary',
                          ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
