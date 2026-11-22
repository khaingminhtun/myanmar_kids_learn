import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myanmar_kids_learn/data/local/app_database.dart';
import 'package:myanmar_kids_learn/data/repositories/profile_repository_impl.dart';
import 'package:myanmar_kids_learn/data/repositories/progress_repository_impl.dart';

void main() {
  late AppDatabase db;
  late ProgressRepositoryImpl progressRepo;
  late ProfileRepositoryImpl profileRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    progressRepo = ProgressRepositoryImpl(db);
    profileRepo = ProfileRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('unlocks sticker idempotently and streams unlocked stickers', () async {
    final profile = await profileRepo.createProfile(name: 'စောစော', avatarId: 'cat');
    expect(profile, isNotNull);

    expect(await progressRepo.getUnlockedStickers(profile.id), isEmpty);

    await progressRepo.unlockSticker(
      profileId: profile.id,
      stickerId: 'sticker_w1_ep01_greeting',
    );

    final unlocked = await progressRepo.getUnlockedStickers(profile.id);
    expect(unlocked, equals(['sticker_w1_ep01_greeting']));

    // Idempotent unlock attempt
    await progressRepo.unlockSticker(
      profileId: profile.id,
      stickerId: 'sticker_w1_ep01_greeting',
    );
    expect(await progressRepo.getUnlockedStickers(profile.id), equals(['sticker_w1_ep01_greeting']));

    // Second sticker
    await progressRepo.unlockSticker(
      profileId: profile.id,
      stickerId: 'sticker_kg_w1_ep01',
    );
    expect(
      await progressRepo.getUnlockedStickers(profile.id),
      equals(['sticker_w1_ep01_greeting', 'sticker_kg_w1_ep01']),
    );
  });
}
