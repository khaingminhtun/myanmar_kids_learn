import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myanmar_kids_learn/core/theme/app_theme.dart';
import 'package:myanmar_kids_learn/domain/entities/lesson.dart';
import 'package:myanmar_kids_learn/presentation/education_quiz/quiz_cubit.dart';
import 'package:myanmar_kids_learn/presentation/education_quiz/quiz_screen.dart';
import 'package:myanmar_kids_learn/presentation/manners_story/audio_cubit.dart';
import 'package:myanmar_kids_learn/presentation/widgets/guided_teacher_bar.dart';

import '../support/fakes.dart';

void main() {
  late QuizLesson kgLesson;
  late FakeContentRepository content;
  late FakeProgressRepository progress;
  late FakeAudioPlayerService audioPlayer;
  late QuizCubit quizCubit;
  late AudioCubit audioCubit;

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
    audioPlayer = FakeAudioPlayerService();
    quizCubit = QuizCubit(
      profile: testProfile,
      lessonId: kgLesson.id,
      contentRepository: content,
      progressRepository: progress,
    );
    audioCubit = AudioCubit(audioPlayer);
  });

  tearDown(() async {
    await quizCubit.close();
    await audioCubit.close();
    await progress.dispose();
  });

  Widget buildScreen() {
    return MaterialApp(
      theme: AppTheme.light,
      home: MultiBlocProvider(
        providers: [
          BlocProvider<QuizCubit>.value(value: quizCubit),
          BlocProvider<AudioCubit>.value(value: audioCubit),
        ],
        child: const QuizScreen(),
      ),
    );
  }

  testWidgets('renders discover cards, requires tapping before mini-game, handles celebration',
      (tester) async {
    await quizCubit.load();
    await tester.pumpWidget(buildScreen());
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(GuidedTeacherBar), findsOneWidget);
    expect(find.text('ကလေး'), findsOneWidget);
    expect(find.text('ခွေး'), findsOneWidget);

    // Mini-game button is disabled initially
    final miniGameBtn = find.widgetWithText(FilledButton, 'ဂိမ်းကစားမယ်');
    expect(miniGameBtn, findsOneWidget);
    final buttonWidget = tester.widget<FilledButton>(miniGameBtn);
    expect(buttonWidget.onPressed, isNull);

    // Tap card 1
    await tester.tap(find.text('ကလေး'));
    await tester.pump(const Duration(milliseconds: 200));

    // Tap card 2
    await tester.tap(find.text('ခွေး'));
    await tester.pump(const Duration(milliseconds: 200));

    // Mini-game button should now be enabled
    final updatedButtonWidget = tester.widget<FilledButton>(miniGameBtn);
    expect(updatedButtonWidget.onPressed, isNotNull);

    // Start mini game
    await tester.tap(miniGameBtn);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('က ကြီး ကလေး ကို ရွေးပါ'), findsOneWidget);

    // Choose correct answer
    await tester.tap(find.text('ကလေး'));
    await tester.pump(const Duration(milliseconds: 500));

    // Celebration
    expect(find.text('အရမ်းတော်တယ် သားသား/မီးမီး!'), findsOneWidget);
    expect(find.text('စတစ်ကာ အသစ်တစ်ခု ရရှိပြီးပါပြီ! 🌟'), findsOneWidget);
    expect(progress.saved, isNotEmpty);
    expect(progress.saved.last.stars, 3);
    expect(progress.unlockedStickers, contains('sticker_kg_w1_ep01'));
  });
}
