part of 'interests_bloc.dart';

abstract class InterestsEvent extends Equatable {
  const InterestsEvent();

  @override
  List<Object> get props => [];
}

/// Load any previously saved interests for the given user.
class InterestsStarted extends InterestsEvent {
  final String email;

  const InterestsStarted({required this.email});

  @override
  List<Object> get props => [email];
}

class InterestToggled extends InterestsEvent {
  final String interest;

  const InterestToggled(this.interest);

  @override
  List<Object> get props => [interest];
}

class InterestsSubmitted extends InterestsEvent {
  const InterestsSubmitted();
}
