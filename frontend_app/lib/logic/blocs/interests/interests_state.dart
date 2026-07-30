part of 'interests_bloc.dart';

enum InterestsStatus { initial, ready, saving, saved }

class InterestsState extends Equatable {
  final InterestsStatus status;
  final String email;
  final Set<String> selected;

  const InterestsState({
    this.status = InterestsStatus.initial,
    this.email = '',
    this.selected = const {},
  });

  InterestsState copyWith({
    InterestsStatus? status,
    String? email,
    Set<String>? selected,
  }) {
    return InterestsState(
      status: status ?? this.status,
      email: email ?? this.email,
      selected: selected ?? this.selected,
    );
  }

  @override
  List<Object> get props => [status, email, selected];
}
