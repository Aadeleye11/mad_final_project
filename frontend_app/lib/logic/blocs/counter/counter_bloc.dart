import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'counter_event.dart';
part 'counter_state.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterState.initial()) {
    on<CounterIncremented>(_onIncremented);
    on<CounterDecremented>(_onDecremented);
    on<CounterReset>(_onReset);
  }

  void _onIncremented(CounterIncremented event, Emitter<CounterState> emit) {
    emit(state.copyWith(count: state.count + 1));
  }

  void _onDecremented(CounterDecremented event, Emitter<CounterState> emit) {
    emit(state.copyWith(count: state.count - 1));
  }

  void _onReset(CounterReset event, Emitter<CounterState> emit) {
    emit(const CounterState.initial());
  }
}
