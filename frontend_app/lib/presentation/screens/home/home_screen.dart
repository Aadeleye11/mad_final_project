import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/trip.dart';
import '../../../logic/blocs/auth/auth_bloc.dart';
import '../../../logic/blocs/home/home_bloc.dart';
import '../../../logic/blocs/plan/plan_bloc.dart';
import '../../widgets/spot_card.dart';
import '../plan/plan_form_screen.dart';

/// Home dashboard: greeting, trip summary, and featured spots.
class HomeScreen extends StatefulWidget {
  final ValueChanged<int> onNavigateToTab;

  const HomeScreen({super.key, required this.onNavigateToTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const HomeStarted());
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _tripLine(Trip trip) {
    final start = trip.startDate;
    final end = trip.endDate;
    final range = start.month == end.month
        ? '${_months[start.month - 1]} ${start.day}-${end.day}'
        : '${_months[start.month - 1]} ${start.day} - '
              '${_months[end.month - 1]} ${end.day}';
    return '${trip.name} · $range · ${trip.durationDays} days';
  }

  /// With no plan yet this opens the builder; otherwise the Plan tab is where
  /// the itinerary is actually edited.
  void _buildOrOpenPlan(Trip? trip) {
    if (trip == null) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const PlanFormScreen()),
      );
    } else {
      widget.onNavigateToTab(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthBloc bloc) => bloc.state.user);
    // PlanBloc owns the trip, so the dashboard can never disagree with the
    // Plan tab about how many activities are booked.
    final trip = context.select((PlanBloc bloc) => bloc.state.trip);

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Extra bottom padding lets the summary card overlap the header.
              Container(
                width: double.infinity,
                color: AppColors.primary,
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 64),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_greeting()}, ${user?.name ?? 'traveler'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      trip != null
                          ? _tripLine(trip)
                          : 'Plan your Rwanda experience',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -44),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _TripSummaryCard(
                    activitiesCount: trip?.activitiesCount ?? 0,
                    onViewPlan: () => widget.onNavigateToTab(1),
                    onDiscover: () => widget.onNavigateToTab(2),
                    onBuild: () => _buildOrOpenPlan(trip),
                    onQrCode: () => Navigator.of(context).pushNamed('/qr'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: const Text(
                  'Featured Spots',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (state.status == HomeStatus.ready)
                SizedBox(
                  height: 210,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: state.featuredSpots.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, index) => SpotCard(
                      attraction: state.featuredSpots[index],
                      onTap: () => Navigator.of(context).pushNamed(
                        '/spot',
                        arguments: state.featuredSpots[index],
                      ),
                    ),
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _TripSummaryCard extends StatelessWidget {
  final int activitiesCount;
  final VoidCallback onViewPlan;
  final VoidCallback onDiscover;
  final VoidCallback onBuild;
  final VoidCallback onQrCode;

  const _TripSummaryCard({
    required this.activitiesCount,
    required this.onViewPlan,
    required this.onDiscover,
    required this.onBuild,
    required this.onQrCode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.map_outlined, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Trip Summary',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$activitiesCount activities planned',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _QuickAction(
                  icon: Icons.visibility_outlined,
                  label: 'View Plan',
                  onTap: onViewPlan,
                ),
              ),
              Expanded(
                child: _QuickAction(
                  icon: Icons.explore_outlined,
                  label: 'Discover',
                  onTap: onDiscover,
                ),
              ),
              Expanded(
                child: _QuickAction(
                  icon: Icons.add_circle_outline,
                  label: 'Build',
                  onTap: onBuild,
                ),
              ),
              Expanded(
                child: _QuickAction(
                  icon: Icons.qr_code_2,
                  label: 'QR Code',
                  onTap: onQrCode,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
