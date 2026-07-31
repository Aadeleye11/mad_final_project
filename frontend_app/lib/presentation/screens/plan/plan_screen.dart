import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/itinerary.dart';
import '../../../logic/blocs/plan/plan_bloc.dart';

/// My Plan tab from the design: day chips, a timeline of activity
/// cards with colored category tags, and a floating QR button.
class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PlanBloc>().add(const PlanStarted());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'My Plan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        onPressed: () => Navigator.of(context).pushNamed('/qr'),
        child: const Icon(Icons.qr_code_2, color: Colors.white),
      ),
      body: BlocBuilder<PlanBloc, PlanState>(
        builder: (context, state) {
          if (state.status != PlanStatus.ready) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final day = state.selectedDay;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: state.days.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final selected = index == state.selectedDayIndex;
                    return ChoiceChip(
                      label: Text('Day ${state.days[index].day}'),
                      selected: selected,
                      showCheckmark: false,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: StadiumBorder(
                        side: BorderSide(
                          color: selected
                              ? AppColors.primary
                              : const Color(0xFFDDE3E1),
                        ),
                      ),
                      onSelected: (_) =>
                          context.read<PlanBloc>().add(PlanDaySelected(index)),
                    );
                  },
                ),
              ),
              if (day != null) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                  child: Text(
                    day.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
                    itemCount: day.activities.length,
                    itemBuilder: (context, index) => _TimelineItem(
                      activity: day.activities[index],
                      isLast: index == day.activities.length - 1,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final ItineraryActivity activity;
  final bool isLast;

  const _TimelineItem({required this.activity, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.access_time, size: 16, color: Colors.white),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 3,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 18),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule,
                        size: 15,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        activity.time,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      _CategoryTag(category: activity.category),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.place_outlined,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          activity.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTag extends StatelessWidget {
  final String category;

  const _CategoryTag({required this.category});

  static const Map<String, Color> _colors = {
    'History': Color(0xFF8E44AD),
    'Culture': Color(0xFF2E86C1),
    'Food': Color(0xFFE74C3C),
    'Wildlife': Color(0xFF1E8449),
    'Nature': Color(0xFF148F77),
    'Adventure': Color(0xFFCA6F1E),
    'Travel': Color(0xFF616A6B),
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[category] ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
