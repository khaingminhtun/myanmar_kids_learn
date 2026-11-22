import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Local child profiles. No login, email or password columns exist by design.
@DataClassName('ChildProfileRow')
class ChildProfiles extends Table {
  @override
  String get tableName => 'child_profiles';

  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 40)();

  TextColumn get avatarId => text().withLength(min: 1, max: 24)();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// One row per child profile and lesson. Stars only ever increase.
@DataClassName('LessonProgressRow')
class LessonProgress extends Table {
  @override
  String get tableName => 'lesson_progress';

  IntColumn get id => integer().autoIncrement()();

  IntColumn get profileId =>
      integer().references(ChildProfiles, #id, onDelete: KeyAction.cascade)();

  TextColumn get lessonId => text().withLength(min: 1, max: 80)();

  BoolColumn get completed => boolean().withDefault(const Constant(false))();

  IntColumn get stars => integer().withDefault(const Constant(0))();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {profileId, lessonId},
      ];
}

/// One row per child profile and unlocked sticker reward.
@DataClassName('UnlockedStickerRow')
class UnlockedStickers extends Table {
  @override
  String get tableName => 'unlocked_stickers';

  IntColumn get id => integer().autoIncrement()();

  IntColumn get profileId =>
      integer().references(ChildProfiles, #id, onDelete: KeyAction.cascade)();

  TextColumn get stickerId => text().withLength(min: 1, max: 80)();

  DateTimeColumn get unlockedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {profileId, stickerId},
      ];
}

@DriftDatabase(tables: [ChildProfiles, LessonProgress, UnlockedStickers])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'myanmar_kids_learn'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) async {
          await migrator.createAll();
        },
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await migrator.createTable(unlockedStickers);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
