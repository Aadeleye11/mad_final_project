import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/datasources/attraction_local_datasource.dart';
import 'data/datasources/attraction_remote_datasource.dart';
import 'data/repositories/attraction_repository_impl.dart';
import 'domain/repositories/attraction_repository.dart';
import 'domain/usecases/get_attractions.dart';
import 'domain/usecases/search_attractions.dart';
import 'presentation/bloc/discover_bloc.dart';

/// Every Discover dependency lives here, so the shared DI file never changes.
void initDiscover(GetIt sl) {
  sl.registerFactory(() => DiscoverBloc(getAttractions: sl()));

  sl.registerLazySingleton(() => GetAttractions(sl()));
  sl.registerLazySingleton(() => SearchAttractions(sl()));

  sl.registerLazySingleton<AttractionRepository>(
    () => AttractionRepositoryImpl(remote: sl(), local: sl()),
  );

  sl.registerLazySingleton<AttractionRemoteDataSource>(
    AttractionRemoteDataSourceImpl.new,
  );
  sl.registerLazySingleton<AttractionLocalDataSource>(
    () => AttractionLocalDataSourceImpl(sl<SharedPreferences>()),
  );
}
