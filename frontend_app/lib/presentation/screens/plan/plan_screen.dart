import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/itinerary.dart';
import '../../../data/models/trip.dart';
import '../../../logic/blocs/plan/plan_bloc.dart';
import '../../../logic/services/itinerary_generator.dart';
import 'activity_editor_sheet.dart';
import 'add_activity_screen.dart';
import 'plan_form_screen.dart';

final _dateFormat = DateFormat('d MMM');
final _moneyFormat = NumberFormat('#,##0');

/// Plan tab: the trip at a glance, day chips, and an editable timeline.
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

  Future<void> _openForm({Trip? trip}) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => PlanFormScreen(trip: trip)),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this plan?'),
        content: const Text(
          'The itinerary and everything in it will be removed. You can '
          'generate a new plan afterwards.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep it'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<PlanBloc>().add(const PlanDeleted());
    }
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
        actions: [
          // No buildWhen here: the menu hands the current trip to the edit
          // form, so it has to see every change to it.
          BlocBuilder<PlanBloc, PlanState>(
            builder: (context, state) {
              if (!state.hasPlan) return const SizedBox.shrink();
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) => switch (value) {
                  'edit' => _openForm(trip: state.trip),
                  'new' => _openForm(),
                  _ => _confirmDelete(),
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit trip details')),
                  PopupMenuItem(value: 'new', child: Text('Start a new plan')),
                  PopupMenuItem(value: 'delete', child: Text('Delete plan')),
                ],
              );
            },
          ),
        ],
      ),
      floatingActionButton: BlocBuilder<PlanBloc, PlanState>(
        buildWhen: (previous, current) => previous.hasPlan != current.hasPlan,
        builder: (context, state) {
          if (!state.hasPlan) return const SizedBox.shrink();
          return FloatingActionButton(
            backgroundColor: AppColors.primary,
            shape: const CircleBorder(),
            tooltip: 'Offline QR code',
            onPressed: () => Navigator.of(context).pushNamed('/qr'),
            child: const Icon(Icons.qr_code_2, color: Colors.white),
          );
        },
      ),
      body: BlocConsumer<PlanBloc, PlanState>(
        listenWhen: (previous, current) =>
            current.errorMessage != null &&
            previous.errorMessage != current.errorMessage,
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
        },
        builder: (context, state) {
          if (state.status == PlanStatus.initial ||
              state.status == PlanStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (!state.hasPlan) {
            return _NoPlanView(onCreate: () => _openForm());
          }

          return _PlanView(state: state);
        },
      ),
    );
  }
}

class _NoPlanView extends StatelessWidget {
  final VoidCallback onCreate;

  const _NoPlanView({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.map_outlined,
              size: 56,
              color: AppColors.primaryLight,
            ),
            const SizedBox(height: 16),
            const Text(
              'No plan yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pick your dates and we will build a day-by-day itinerary from '
              'the places that match your interests. You can change anything '
              'afterwards.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Create a plan'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanView extends StatelessWidget {
  final PlanState state;

  const _PlanView({required this.state});

  /// Proposes the next generated slot, then hourly once the day is full.
  String _nextTime(BuildContext context, ItineraryDay day) {
    final count = day.activities.length;
    if (count < ItineraryGenerator.slots.length) {
      return ItineraryGenerator.slots[count];
    }
    final hour = 17 + count - ItineraryGenerator.slots.length;
    return TimeOfDay(hour: hour > 23 ? 23 : hour, minute: 0).format(context);
  }

  Future<void> _addActivity(BuildContext context, ItineraryDay day) async {
    final activity = await Navigator.of(context).push<ItineraryActivity>(
      MaterialPageRoute(
        builder: (_) =>
            AddActivityScreen(suggestedTime: _nextTime(context, day)),
      ),
    );
    if (activity == null || !context.mounted) return;
    context.read<PlanBloc>().add(
      PlanActivityAdded(dayIndex: state.selectedDayIndex, activity: activity),
    );
  }

  Future<void> _editActivity(
    BuildContext context,
    ItineraryActivity activity,
  ) async {
    final edited = await showActivityEditor(
      context,
      activity: activity,
      heading: 'Edit activity',
    );
    if (edited == null || !context.mounted) return;
    context.read<PlanBloc>().add(
      PlanActivityEdited(dayIndex: state.selectedDayIndex, activity: edited),
    );
  }

  void _removeActivity(BuildContext context, ItineraryActivity activity) {
    context.read<PlanBloc>().add(
      PlanActivityRemoved(
        dayIndex: state.selectedDayIndex,
        activityId: activity.id,
      ),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Removed ${activity.title}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final trip = state.trip!;
    final day = state.selectedDay;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: _TripHeaderCard(trip: trip),
        ),
        SizedBox(
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
            padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    day.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(minimumSize: const Size(0, 48)),
                  onPressed: () => _addActivity(context, day),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: day.activities.isEmpty
                ? _EmptyDay(onAdd: () => _addActivity(context, day))
                : ReorderableListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 96),
                    buildDefaultDragHandles: false,
                    itemCount: day.activities.length,
                    onReorder: (oldIndex, newIndex) =>
                        context.read<PlanBloc>().add(
                          PlanActivitiesReordered(
                            dayIndex: state.selectedDayIndex,
                            oldIndex: oldIndex,
                            newIndex: newIndex,
                          ),
                        ),
                    itemBuilder: (context, index) {
                      final activity = day.activities[index];
                      return _TimelineItem(
                        key: ValueKey(activity.id),
                        index: index,
                        activity: activity,
                        isLast: index == day.activities.length - 1,
                        onEdit: () => _editActivity(context, activity),
                        onRemove: () => _removeActivity(context, activity),
                      );
                    },
                  ),
          ),
        ],
      ],
    );
  }
}

class _TripHeaderCard extends StatelessWidget {
  final Trip trip;

  const _TripHeaderCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            trip.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          // Wrap rather than Row: these never overflow, however narrow it gets.
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _HeaderFact(
                icon: Icons.calendar_today_outlined,
                text:
                    '${_dateFormat.format(trip.startDate)} — '
                    '${_dateFormat.format(trip.endDate)}',
              ),
              _HeaderFact(
                icon: Icons.group_outlined,
                text: '${trip.groupSize}',
              ),
              _HeaderFact(
                icon: Icons.account_balance_wallet_outlined,
                text: 'RWF ${_moneyFormat.format(trip.budget)}',
              ),
              _HeaderFact(
                icon: Icons.checklist_outlined,
                text:
                    '${trip.activitiesCount} '
                    '${trip.activitiesCount == 1 ? 'activity' : 'activities'}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderFact extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HeaderFact({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.primary),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _EmptyDay extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyDay({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Nothing planned for this day.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                minimumSize: const Size(0, 48),
                shape: const StadiumBorder(),
              ),
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add an activity'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final int index;
  final ItineraryActivity activity;
  final bool isLast;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const _TimelineItem({
    super.key,
    required this.index,
    required this.activity,
    required this.isLast,
    required this.onEdit,
    required this.onRemove,
  });

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
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: onEdit,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 4, 14),
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
                            PopupMenuButton<String>(
                              tooltip: 'Activity options',
                              icon: const Icon(
                                Icons.more_vert,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                              onSelected: (value) =>
                                  value == 'edit' ? onEdit() : onRemove(),
                              itemBuilder: (_) => const [
                                PopupMenuItem(value: 'edit', child: Text('Edit')),
                                PopupMenuItem(
                                  value: 'remove',
                                  child: Text('Remove'),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
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
                            ReorderableDragStartListener(
                              index: index,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 12,
                                ),
                                child: Icon(
                                  Icons.drag_handle,
                                  size: 20,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
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
