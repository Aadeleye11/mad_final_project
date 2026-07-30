import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/preferences_repository.dart';

part 'interests_event.dart';
part 'interests_state.dart';

class InterestsBloc extends Bloc<InterestsEvent, InterestsState> {
  final PreferencesRepository _preferencesRepository;

  InterestsBloc(this._preferencesRepository) : super(const InterestsState()) {
    on<InterestsStarted>(_onStarted);
    on<InterestToggled>(_onToggled);
    on<InterestsSubmitted>(_onSubmitted);
  }

  void _onStarted(InterestsStarted event, Emitter<InterestsState> emit) {
    final saved = _preferencesRepository.getInterests(event.email);
    emit(state.copyWith(
      status: InterestsStatus.ready,
      email: event.email,
      selected: saved.toSet(),
    ));
  }

  void _onToggled(InterestToggled event, Emitter<InterestsState> emit) {
    final selected = Set<String>.from(state.selected);
    if (!selected.remove(event.interest)) {
      selected.add(event.interest);
    }
    emit(state.copyWith(status: InterestsStatus.ready, selected: selected));
  }

  Future<void> _onSubmitted(
    InterestsSubmitted event,
    Emitter<InterestsState> emit,
  ) async {
    if (state.selected.isEmpty) return;
    emit(state.copyWith(status: InterestsStatus.saving));
    await _preferencesRepository.saveInterests(
      state.email,
      state.selected.toList(),
    );
    emit(state.copyWith(status: InterestsStatus.saved));
  }
}
