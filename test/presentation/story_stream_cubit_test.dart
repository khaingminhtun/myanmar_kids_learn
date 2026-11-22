import 'package:flutter_test/flutter_test.dart';
import 'package:myanmar_kids_learn/domain/entities/lesson.dart';
import 'package:myanmar_kids_learn/presentation/manners_story/story_cubit.dart';

import '../support/fakes.dart';

void main() {
  late FakeContentRepository content;
  late FakeProgressRepository progress;
  late StoryLesson streamStory;
  late StoryCubit cubit;

  setUp(() {
    streamStory = const StoryLesson(
      id: 'manners_w1_ep01',
      title: 'အပိုင်း (၁) - မနက်ခင်း မင်္ဂလာပါ',
      subtitle: 'Ep 1: Morning Greeting',
      imageAsset: 'assets/content/images/nono_bow.svg',
      stickerReward: 'sticker_w1_ep01_greeting',
      starsReward: 3,
      pages: [],
      moralQuestion: QuizQuestion(
        id: 'q1',
        prompt: 'မနက်ခင်း ဘာပြောမလဲ?',
        options: ['မင်္ဂလာပါ', 'ပုန်းနေမည်'],
        correctIndex: 0,
      ),
      steps: [
        StoryStep(
          step: 1,
          kind: 'narration',
          image: 'assets/content/images/nono_happy.svg',
          textMy: 'မနက်မိုးလင်းတော့ နေရောင်ခြည်လေး ဝင်လာပါပြီ။',
        ),
        StoryStep(
          step: 2,
          kind: 'narration',
          image: 'assets/content/images/grandma_happy.svg',
          textMy: 'အဘွား ပန်းရေလောင်းနေသည်။',
        ),
        StoryStep(
          step: 3,
          kind: 'interactive_tap',
          image: 'assets/content/images/nono_bow.svg',
          textMy: 'နိုနိုကို နှိပ်ပေးပါဦး!',
          actionLabelMy: 'မင်္ဂလာပါ အဘွား',
        ),
        StoryStep(
          step: 4,
          kind: 'outcome',
          image: 'assets/content/images/grandma_happy.svg',
          textMy: 'အဘွား ပြုံးပြလိုက်သည်။',
        ),
        StoryStep(
          step: 5,
          kind: 'narration',
          image: 'assets/content/images/nono_happy.svg',
          textMy: 'မနက်တိုင်း မင်္ဂလာပါလို့ နှုတ်ဆက်ကြမယ်။',
        ),
      ],
      simpleQuiz: [
        SimpleQuizQuestion(
          promptMy: 'မနက်ခင်းမှာ အဘွားကို ဘာပြောမလဲ?',
          options: [
            SimpleQuizOption(
              image: 'assets/content/images/nono_bow.svg',
              textMy: 'မင်္ဂလာပါ အဘွား',
              isCorrect: true,
            ),
            SimpleQuizOption(
              image: 'assets/content/images/nono_sad.svg',
              textMy: 'ဘာမှမပြောဘဲ ပုန်းမည်',
              isCorrect: false,
            ),
          ],
          encouragementMy: 'တော်လိုက်တာ!',
        ),
      ],
    );

    content = FakeContentRepository([streamStory]);
    progress = FakeProgressRepository();
    cubit = StoryCubit(
      profile: testProfile,
      lessonId: streamStory.id,
      contentRepository: content,
      progressRepository: progress,
    );
  });

  tearDown(() async {
    await cubit.close();
    await progress.dispose();
  });

  test('advances through 5 steps requiring interactive tap on step 3', () async {
    await cubit.load();
    expect(cubit.state.pageIndex, 0);

    cubit.nextPage(); // step 2
    expect(cubit.state.pageIndex, 1);

    cubit.nextPage(); // step 3 (interactive)
    expect(cubit.state.pageIndex, 2);
    expect(cubit.state.currentStep?.isInteractiveTap, isTrue);

    // Cannot advance past step 3 without tap
    cubit.nextPage();
    expect(cubit.state.pageIndex, 2);

    // Tap interactive button
    cubit.tapInteractive();
    expect(cubit.state.hasTappedInteractive, isTrue);

    cubit.nextPage(); // step 4
    expect(cubit.state.pageIndex, 3);

    cubit.nextPage(); // step 5
    expect(cubit.state.pageIndex, 4);

    cubit.nextPage(); // unlocks simple quiz
    expect(cubit.state.isQuestion, isTrue);
  });

  test('wrong answer triggers gentle retry wiggle without saving stars', () async {
    await cubit.load();
    for (var i = 0; i < 5; i++) {
      if (cubit.state.currentStep?.isInteractiveTap ?? false) {
        cubit.tapInteractive();
      }
      cubit.nextPage();
    }
    expect(cubit.state.isQuestion, isTrue);

    await cubit.answerMoral(1); // wrong choice
    expect(cubit.state.isCorrect, isFalse);
    expect(cubit.state.isWiggling, isTrue);
    expect(cubit.state.starsAwarded, 0);
    expect(progress.saved, isEmpty);
  });

  test('correct answer awards 3 stars and unlocks sticker in drift', () async {
    await cubit.load();
    for (var i = 0; i < 5; i++) {
      if (cubit.state.currentStep?.isInteractiveTap ?? false) {
        cubit.tapInteractive();
      }
      cubit.nextPage();
    }
    expect(cubit.state.isQuestion, isTrue);

    await cubit.answerMoral(0); // correct choice
    expect(cubit.state.isCorrect, isTrue);
    expect(cubit.state.starsAwarded, 3);
    expect(cubit.state.stickerUnlocked, isTrue);
    expect(progress.saved.last.stars, 3);
    expect(progress.saved.last.completed, isTrue);
    expect(progress.unlockedStickers, contains('sticker_w1_ep01_greeting'));
  });
}
