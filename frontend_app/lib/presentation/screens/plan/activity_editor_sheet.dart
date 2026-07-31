import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/itinerary.dart';

/// Tags an activity can carry. Matches the colours the timeline draws.
const List<String> planCategories = [
  'Wildlife',
  'Culture',
  'Food',
  'History',
  'Nature',
  'Adventure',
  'Travel',
];

/// Opens the add/edit sheet for a single activity. Resolves to null when the
/// sheet is dismissed without saving.
Future<ItineraryActivity?> showActivityEditor(
  BuildContext context, {
  required ItineraryActivity activity,
  required String heading,
}) {
  return showModalBottomSheet<ItineraryActivity>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => Padding(
      // Lifts the sheet above the keyboard instead of overflowing behind it.
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
      ),
      child: _ActivityEditor(activity: activity, heading: heading),
    ),
  );
}

/// Reads back a time the sheet wrote earlier, e.g. "9:00 AM" or "14:30".
/// Falls back to a sensible morning slot rather than refusing to open.
TimeOfDay parseActivityTime(String value) {
  final match = RegExp(
    r'^(\d{1,2}):(\d{2})\s*([AaPp][Mm])?$',
  ).firstMatch(value.trim());
  if (match == null) return const TimeOfDay(hour: 9, minute: 0);

  var hour = int.parse(match.group(1)!);
  final minute = int.parse(match.group(2)!);
  final suffix = match.group(3)?.toUpperCase();
  if (suffix == 'PM' && hour != 12) hour += 12;
  if (suffix == 'AM' && hour == 12) hour = 0;

  return TimeOfDay(hour: hour % 24, minute: minute % 60);
}

class _ActivityEditor extends StatefulWidget {
  final ItineraryActivity activity;
  final String heading;

  const _ActivityEditor({required this.activity, required this.heading});

  @override
  State<_ActivityEditor> createState() => _ActivityEditorState();
}

class _ActivityEditorState extends State<_ActivityEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late TimeOfDay _time;
  late String _category;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.activity.title);
    _time = parseActivityTime(widget.activity.time);
    _category = planCategories.contains(widget.activity.category)
        ? widget.activity.category
        : planCategories.last;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null && mounted) setState(() => _time = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      widget.activity.copyWith(
        time: _time.format(context),
        title: _titleController.text.trim(),
        category: _category,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDE3E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                widget.heading,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'What are you doing?',
                  prefixIcon: Icon(Icons.place_outlined),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Give the activity a name'
                    : null,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: Color(0xFFDDE3E1)),
                  minimumSize: const Size.fromHeight(52),
                  alignment: Alignment.centerLeft,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _pickTime,
                icon: const Icon(Icons.schedule, color: AppColors.primary),
                label: Text('Starts at ${_time.format(context)}'),
              ),
              const SizedBox(height: 20),
              const Text(
                'Category',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final category in planCategories)
                    ChoiceChip(
                      label: Text(category),
                      selected: _category == category,
                      showCheckmark: false,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: _category == category
                            ? Colors.white
                            : AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      onSelected: (_) => setState(() => _category = category),
                    ),
                ],
              ),
              const SizedBox(height: 28),
              ElevatedButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}
