import 'package:get_it/get_it.dart';

import '../../data/local/app_database.dart';
import '../../data/local/asset_content_source.dart';
import '../../data/repositories/content_repository_impl.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../data/repositories/progress_repository_impl.dart';
import '../../domain/repositories/content_repository.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../presentation/session/session_cubit.dart';

final GetIt getIt = GetIt.instance;

/// Wires the offline-only dependency graph. No network clients are registered.
Future<void> configureDependencies({AppDatabase? database}) async {
  if (getIt.isRegistered<AppDatabase>()) return;

  final db = database ?? AppDatabase();
  getIt.registerSingleton<AppDatabase>(db);
  getIt.registerLazySingleton<AssetContentSource>(AssetContentSource.new);
  getIt.registerLazySingleton<ContentRepository>(
    () => ContentRepositoryImpl(getIt<AssetContentSource>()),
  );
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<ProgressRepository>(
    () => ProgressRepositoryImpl(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<SessionCubit>(SessionCubit.new);
}

/// Useful for tests that need a clean locator.
Future<void> resetDependencies() async {
  await getIt.reset();
}
