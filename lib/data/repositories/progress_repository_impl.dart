import 'package:drift/drift.dart';

import '../../domain/entities/lesson_progress.dart';
import '../../domain/repositories/progress_repository.dart';
import '../local/app_database.dart' hide LessonProgress;

class ProgressRepositoryImpl implements ProgressRepository {
  ProgressRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<List<LessonProgress>> watchProgress(int profileId) {
    final query = _db.select(_db.lessonProgress)
      ..where((table) => table.profileId.equals(profileId))
      ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)]);
    return query.watch().map(
          (rows) => rows.map(_mapRow).toList(growable: false),
        );
  }

  @override
  Future<List<LessonProgress>> getProgress(int profileId) async {
    final query = _db.select(_db.lessonProgress)
      ..where((table) => table.profileId.equals(profileId))
      ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)]);
    final rows = await query.get();
    return rows.map(_mapRow).toList(growable: false);
  }

  @override
  Future<void> saveResult({
    required int profileId,
    required String lessonId,
    required int stars,
    required bool completed,
  }) async {
    final safeStars = stars < 0 ? 0 : stars;
    await _db.transaction(() async {
      final query = _db.select(_db.lessonProgress)
        ..where(
          (table) =>
              table.profileId.equals(profileId) &
              table.lessonId.equals(lessonId),
        );
      final existing = await query.getSingleOrNull();
      final now = DateTime.now();

      if (existing == null) {
        await _db.into(_db.lessonProgress).insert(
              LessonProgressCompanion.insert(
                profileId: profileId,
                lessonId: lessonId,
                completed: Value(completed),
                stars: Value(safeStars),
                updatedAt: Value(now),
              ),
            );
        return;
      }

      final bestStars = existing.stars > safeStars ? existing.stars : safeStars;
      await (_db.update(_db.lessonProgress)
            ..where((table) => table.id.equals(existing.id)))
          .write(
        LessonProgressCompanion(
          completed: Value(existing.completed || completed),
          stars: Value(bestStars),
          updatedAt: Value(now),
        ),
      );
    });
  }

  @override
  Future<void> unlockSticker({
    required int profileId,
    required String stickerId,
  }) async {
    await _db.transaction(() async {
      final query = _db.select(_db.unlockedStickers)
        ..where(
          (table) =>
              table.profileId.equals(profileId) &
              table.stickerId.equals(stickerId),
        );
      final existing = await query.getSingleOrNull();
      if (existing != null) return;

      await _db.into(_db.unlockedStickers).insert(
            UnlockedStickersCompanion.insert(
              profileId: profileId,
              stickerId: stickerId,
              unlockedAt: Value(DateTime.now()),
            ),
          );
    });
  }

  @override
  Stream<List<String>> watchUnlockedStickers(int profileId) {
    final query = _db.select(_db.unlockedStickers)
      ..where((table) => table.profileId.equals(profileId))
      ..orderBy([
        (table) => OrderingTerm.asc(table.unlockedAt),
        (table) => OrderingTerm.asc(table.id),
      ]);
    return query.watch().map(
          (rows) => rows.map((row) => row.stickerId).toList(growable: false),
        );
  }

  @override
  Future<List<String>> getUnlockedStickers(int profileId) async {
    final query = _db.select(_db.unlockedStickers)
      ..where((table) => table.profileId.equals(profileId))
      ..orderBy([
        (table) => OrderingTerm.asc(table.unlockedAt),
        (table) => OrderingTerm.asc(table.id),
      ]);
    final rows = await query.get();
    return rows.map((row) => row.stickerId).toList(growable: false);
  }

  LessonProgress _mapRow(LessonProgressRow row) => LessonProgress(
        profileId: row.profileId,
        lessonId: row.lessonId,
        completed: row.completed,
        stars: row.stars,
        updatedAt: row.updatedAt,
      );
}
