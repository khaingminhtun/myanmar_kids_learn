import 'package:flutter_test/flutter_test.dart';
import 'package:myanmar_kids_learn/domain/entities/lesson.dart';
import 'package:myanmar_kids_learn/presentation/education_quiz/quiz_cubit.dart';

import '../support/fakes.dart';

void main() {
  late FakeContentRepository content;
  late FakeProgressRepository progress;
  late QuizLesson kgLesson;
  late QuizCubit cubit;

  setUp(() {
    kgLesson = const QuizLesson(
      id: 'edu_w1_ep01',
      title: 'သင်ခန်းစာ (၁) - က နှင့် ခ',
      subtitle: 'Lesson 1: Letters က & ခ',
      imageAsset: 'assets/content/images/kg_ka_child.svg',
      stickerReward: 'sticker_kg_w1_ep01',
      starsReward: 3,
      questions: [],
      discoverCards: [
        KgCard(
          letter: 'က',
          wordMy: 'ကလေး',
          image: 'assets/content/images/kg_ka_child.svg',
          audio: 'assets/content/audio/edu_w1_ep01_c1.mp3',
          promptMy: 'က — က — ကလေး။',
        ),
        KgCard(
          letter: 'ခ',
          wordMy: 'ခွေး',
          image: 'assets/content/images/kg_kha_dog.svg',
          audio: 'assets/content/audio/edu_w1_ep01_c2.mp3',
          promptMy: 'ခ — ခ — ခွေးလေး။',
        ),
      ],
      miniGame: [
        KgMiniGameQuestion(
          promptMy: 'က ကြီး ကလေး ကို ရွေးပါ',
          options: [
            KgMiniGameOption(
              letter: 'က',
              wordMy: 'ကလေး',
              image: 'assets/content/images/kg_ka_child.svg',
              isCorrect: true,
            ),
            KgMiniGameOption(
              letter: 'ခ',
              wordMy: 'ခွေး',
              image: 'assets/content/images/kg_kha_dog.svg',
              isCorrect: false,
            ),
          ],
        ),
      ],
    );

    content = FakeContentRepository([kgLesson]);
    progress = FakeProgressRepository();
    cubit = QuizCubit(
      profile: testProfile,
      lessonId: kgLesson.id,
      contentRepository: content,
      progressRepository: progress,
    );
  });

  tearDown(() async {
    await cubit.close();
    await progress.dispose();
  });

  test('requires listening to all discover cards before mini game unlocks', () async {
    await cubit.load();
    expect(cubit.state.isDiscoverMode, isTrue);
    expect(cubit.state.allCardsTapped, isFalse);

    // Try starting without tapping
    cubit.startMiniGame();
    expect(cubit.state.inMiniGame, isFalse);

    // Tap first card
    cubit.tapDiscoverCard(0);
    expect(cubit.state.allCardsTapped, isFalse);

    // Tap second card
    cubit.tapDiscoverCard(1);
    expect(cubit.state.allCardsTapped, isTrue);

    // Now start mini game
    cubit.startMiniGame();
    expect(cubit.state.inMiniGame, isTrue);
  });

  test('mini game wrong choice triggers gentle retry without saving', () async {
    await cubit.load();
    cubit.tapDiscoverCard(0);
    cubit.tapDiscoverCard(1);
    cubit.startMiniGame();

    await cubit.answer(1); // wrong choice
    expect(cubit.state.isCorrect, isFalse);
    expect(cubit.state.isWiggling, isTrue);
    expect(cubit.state.finished, isFalse);
    expect(progress.saved, isEmpty);
  });

  test('mini game correct choice awards 3 stars and unlocks sticker', () async {
    await cubit.load();
    cubit.tapDiscoverCard(0);
    cubit.tapDiscoverCard(1);
    cubit.startMiniGame();

    await cubit.answer(0); // correct choice
    expect(cubit.state.isCorrect, isTrue);
    expect(cubit.state.finished, isTrue);
    expect(cubit.state.stickerUnlocked, isTrue);
    expect(progress.saved.last.stars, 3);
    expect(progress.saved.last.completed, isTrue);
    expect(progress.unlockedStickers, contains('sticker_kg_w1_ep01'));
  });
}
