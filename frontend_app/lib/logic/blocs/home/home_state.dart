part of 'home_bloc.dart';

enum HomeStatus { initial, loading, ready, failure }

class HomeState extends Equatable {
  final HomeStatus status;
  final Trip? trip;
  final List<Attraction> featuredSpots;

  const HomeState({
    this.status = HomeStatus.initial,
    this.trip,
    this.featuredSpots = const [],
  });

  HomeState copyWith({
    HomeStatus? status,
    Trip? trip,
    List<Attraction>? featuredSpots,
  }) {
    return HomeState(
      status: status ?? this.status,
      trip: trip ?? this.trip,
      featuredSpots: featuredSpots ?? this.featuredSpots,
    );
  }

  @override
  List<Object?> get props => [status, trip, featuredSpots];
}
