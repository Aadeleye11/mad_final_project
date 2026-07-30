part of 'counter_bloc.dart';

class CounterState extends Equatable {
  final int count;

  const CounterState({required this.count});

  const CounterState.initial() : count = 0;

  CounterState copyWith({int? count}) {
    return CounterState(count: count ?? this.count);
  }

  @override
  List<Object> get props => [count];
}
