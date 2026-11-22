import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myanmar_kids_learn/core/theme/app_theme.dart';
import 'package:myanmar_kids_learn/domain/entities/lesson.dart';
import 'package:myanmar_kids_learn/presentation/manners_story/audio_cubit.dart';
import 'package:myanmar_kids_learn/presentation/manners_story/story_cubit.dart';
import 'package:myanmar_kids_learn/presentation/manners_story/story_screen.dart';
import 'package:myanmar_kids_learn/presentation/widgets/guided_teacher_bar.dart';

import '../support/fakes.dart';

void main() {
  late StoryLesson streamStory;
  late FakeContentRepository content;
  late FakeProgressRepository progress;
  late FakeAudioPlayerService audioPlayer;
  late StoryCubit storyCubit;
  late AudioCubit audioCubit;

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
    audioPlayer = FakeAudioPlayerService();
    storyCubit = StoryCubit(
      profile: testProfile,
      lessonId: streamStory.id,
      contentRepository: content,
      progressRepository: progress,
    );
    audioCubit = AudioCubit(audioPlayer);
  });

  tearDown(() async {
    await storyCubit.close();
    await audioCubit.close();
    await progress.dispose();
  });

  Widget buildScreen() {
    return MaterialApp(
      theme: AppTheme.light,
      home: MultiBlocProvider(
        providers: [
          BlocProvider<StoryCubit>.value(value: storyCubit),
          BlocProvider<AudioCubit>.value(value: audioCubit),
        ],
        child: const StoryScreen(),
      ),
    );
  }

  testWidgets('renders GuidedTeacherBar, steps, interactive button, quiz and celebration',
      (tester) async {
    await storyCubit.load();
    await tester.pumpWidget(buildScreen());
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(GuidedTeacherBar), findsOneWidget);
    expect(find.text('မနက်မိုးလင်းတော့ နေရောင်ခြည်လေး ဝင်လာပါပြီ။'), findsOneWidget);

    // Advance to step 2
    await tester.tap(find.text('ရှေ့သို့'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('အဘွား ပန်းရေလောင်းနေသည်။'), findsOneWidget);

    // Advance to step 3 (interactive tap)
    await tester.tap(find.text('ရှေ့သို့'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('မင်္ဂလာပါ အဘွား'), findsOneWidget);

    // Tap interactive button
    await tester.tap(find.text('မင်္ဂလာပါ အဘွား'));
    await tester.pump(const Duration(milliseconds: 300));

    // Advance to step 4
    await tester.tap(find.text('ရှေ့သို့'));
    await tester.pump(const Duration(milliseconds: 300));

    // Advance to step 5
    await tester.tap(find.text('ရှေ့သို့'));
    await tester.pump(const Duration(milliseconds: 300));

    // Advance to quiz
    await tester.tap(find.text('မေးခွန်းသို့'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('မနက်ခင်းမှာ အဘွားကို ဘာပြောမလဲ?'), findsOneWidget);
    expect(find.text('မင်္ဂလာပါ အဘွား'), findsOneWidget);
    expect(find.text('ဘာမှမပြောဘဲ ပုန်းမည်'), findsOneWidget);

    // Tap correct option
    await tester.tap(find.text('မင်္ဂလာပါ အဘွား'));
    await tester.pump(const Duration(milliseconds: 500));

    // Celebration stage
    expect(find.text('ဂုဏ်ယူပါတယ် သားသား/မီးမီး!'), findsOneWidget);
    expect(find.text('စတစ်ကာ အသစ်တစ်ခု ရရှိပြီးပါပြီ! 🌟'), findsOneWidget);
    expect(progress.saved, isNotEmpty);
    expect(progress.unlockedStickers, contains('sticker_w1_ep01_greeting'));
  });
}
