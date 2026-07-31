part of 'home_bloc.dart';

enum HomeStatus { initial, loading, ready, failure }

class HomeState extends Equatable {
  final HomeStatus status;
  final List<Attraction> featuredSpots;

  const HomeState({
    this.status = HomeStatus.initial,
    this.featuredSpots = const [],
  });

  HomeState copyWith({HomeStatus? status, List<Attraction>? featuredSpots}) {
    return HomeState(
      status: status ?? this.status,
      featuredSpots: featuredSpots ?? this.featuredSpots,
    );
  }

  @override
  List<Object?> get props => [status, featuredSpots];
}
