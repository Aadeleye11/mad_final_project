import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_interests.dart';
import '../../../data/models/trip.dart';
import '../../../data/repositories/preferences_repository.dart';
import '../../../logic/blocs/auth/auth_bloc.dart';
import '../../../logic/blocs/plan/plan_bloc.dart';
import '../../../logic/services/itinerary_generator.dart';

final _dateFormat = DateFormat('d MMM yyyy');

/// Creates a plan, or edits the trip details of the existing one.
///
/// Creating generates the itinerary from the chosen interests; editing leaves
/// the activities alone and only re-dates the trip, so nothing is lost.
class PlanFormScreen extends StatefulWidget {
  /// Null creates a new plan. Non-null edits that trip's details.
  final Trip? trip;

  const PlanFormScreen({super.key, this.trip});

  bool get isEditing => trip != null;

  @override
  State<PlanFormScreen> createState() => _PlanFormScreenState();
}

class _PlanFormScreenState extends State<PlanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _budgetController;
  late DateTimeRange _dates;
  late int _groupSize;
  late Set<String> _interests;

  @override
  void initState() {
    super.initState();
    final trip = widget.trip;
    final today = DateUtils.dateOnly(DateTime.now());

    _titleController = TextEditingController(
      text: trip?.title ?? 'My Rwanda trip',
    );
    _budgetController = TextEditingController(
      text: (trip?.budget ?? 300000).toStringAsFixed(0),
    );
    _dates = trip != null
        ? DateTimeRange(start: trip.startDate, end: trip.endDate)
        : DateTimeRange(start: today, end: today.add(const Duration(days: 3)));
    _groupSize = trip?.groupSize ?? 2;

    // A new plan starts from the interests picked during onboarding.
    final email = context.read<AuthBloc>().state.user?.email ?? '';
    _interests = trip != null
        ? {...trip.interests}
        : {...context.read<PreferencesRepository>().getInterests(email)};
  }

  @override
  void dispose() {
    _titleController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _pickDates() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _dates,
      // Deliberately wide: the picker asserts if an existing trip's dates fall
      // outside the range, and an old plan must still be editable.
      firstDate: DateTime(2020),
      lastDate: DateTime(DateTime.now().year + 5),
      helpText: 'Trip dates',
    );
    if (picked != null && mounted) setState(() => _dates = picked);
  }

  /// Days that would be dropped if the trip is saved with a shorter range.
  int get _daysLost {
    final trip = widget.trip;
    if (trip == null) return 0;
    final next = ItineraryGenerator.dayCountFor(_dates.start, _dates.end);
    return trip.days.length > next ? trip.days.length - next : 0;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final title = _titleController.text.trim();
    final budget = double.tryParse(_budgetController.text.trim()) ?? 0;
    final planBloc = context.read<PlanBloc>();

    if (widget.isEditing) {
      planBloc.add(
        PlanDetailsEdited(
          title: title,
          startDate: _dates.start,
          endDate: _dates.end,
          groupSize: _groupSize,
          budget: budget,
        ),
      );
    } else {
      planBloc.add(
        PlanCreated(
          title: title,
          startDate: _dates.start,
          endDate: _dates.end,
          groupSize: _groupSize,
          budget: budget,
          interests: _interests.toList(),
        ),
      );
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing ? 'Trip updated' : 'Your plan is ready',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final dayCount = ItineraryGenerator.dayCountFor(_dates.start, _dates.end);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit trip' : 'Create a plan'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            children: [
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Trip name',
                  prefixIcon: Icon(Icons.luggage_outlined),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Give your trip a name'
                    : null,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: Color(0xFFDDE3E1)),
                  minimumSize: const Size.fromHeight(56),
                  alignment: Alignment.centerLeft,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _pickDates,
                icon: const Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.primary,
                ),
                label: Text(
                  '${_dateFormat.format(_dates.start)} — '
                  '${_dateFormat.format(_dates.end)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                dayCount == ItineraryGenerator.maxDays
                    ? '$dayCount days — the longest plan we generate'
                    : '$dayCount ${dayCount == 1 ? 'day' : 'days'}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              if (_daysLost > 0) ...[
                const SizedBox(height: 8),
                Text(
                  'Shortening the trip removes the last $_daysLost '
                  '${_daysLost == 1 ? 'day' : 'days'} and everything planned '
                  'in them.',
                  style: const TextStyle(fontSize: 12, color: AppColors.error),
                ),
              ],
              const SizedBox(height: 24),
              const Text(
                'Travellers',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              _GroupSizeStepper(
                value: _groupSize,
                onChanged: (value) => setState(() => _groupSize = value),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Budget (RWF)',
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                ),
                validator: (value) {
                  final budget = double.tryParse(value?.trim() ?? '');
                  if (budget == null) return 'Enter a number';
                  if (budget < 0) return 'Budget cannot be negative';
                  return null;
                },
              ),
              if (!widget.isEditing) ...[
                const SizedBox(height: 24),
                const Text(
                  'Build the plan around',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Leave everything unselected to draw from all of Rwanda.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final interest in AppInterests.all)
                      FilterChip(
                        label: Text(interest),
                        selected: _interests.contains(interest),
                        showCheckmark: false,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: _interests.contains(interest)
                              ? Colors.white
                              : AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        onSelected: (selected) => setState(() {
                          if (selected) {
                            _interests.add(interest);
                          } else {
                            _interests.remove(interest);
                          }
                        }),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                child: Text(
                  widget.isEditing ? 'Save changes' : 'Generate my itinerary',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupSizeStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _GroupSizeStepper({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDDE3E1)),
      ),
      child: Row(
        children: [
          IconButton(
            constraints: const BoxConstraints.tightFor(width: 48, height: 48),
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_circle_outline),
            color: AppColors.primary,
          ),
          Expanded(
            child: Text(
              '$value ${value == 1 ? 'traveller' : 'travellers'}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            constraints: const BoxConstraints.tightFor(width: 48, height: 48),
            onPressed: value < 20 ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add_circle_outline),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
