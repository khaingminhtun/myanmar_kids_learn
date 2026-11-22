import 'package:flutter_test/flutter_test.dart';
import 'package:myanmar_kids_learn/presentation/education_quiz/quiz_cubit.dart';

import '../support/fakes.dart';

void main() {
  late FakeContentRepository content;
  late FakeProgressRepository progress;
  late QuizCubit cubit;

  setUp(() {
    content = FakeContentRepository([testQuiz]);
    progress = FakeProgressRepository();
    cubit = QuizCubit(
      profile: testProfile,
      lessonId: testQuiz.id,
      contentRepository: content,
      progressRepository: progress,
    );
  });

  tearDown(() async {
    await cubit.close();
    await progress.dispose();
  });

  test('loads the quiz and starts at the first question', () async {
    await cubit.load();

    expect(cubit.state.loading, isFalse);
    expect(cubit.state.lesson?.id, testQuiz.id);
    expect(cubit.state.currentIndex, 0);
    expect(cubit.state.totalQuestions, 2);
    expect(cubit.state.earnedStars, 0);
  });

  test('correct answers earn stars and finishing marks completion', () async {
    await cubit.load();

    await cubit.answer(1);
    expect(cubit.state.isCorrect, isTrue);
    expect(cubit.state.earnedStars, 1);
    expect(progress.saved.last.stars, 1);
    expect(progress.saved.last.completed, isFalse);

    await cubit.nextQuestion();
    expect(cubit.state.currentIndex, 1);
    expect(cubit.state.answered, isFalse);

    await cubit.answer(0);
    expect(cubit.state.isCorrect, isFalse);
    expect(cubit.state.earnedStars, 1);

    await cubit.nextQuestion();
    expect(cubit.state.finished, isTrue);
    expect(progress.saved.last.stars, 1);
    expect(progress.saved.last.completed, isTrue);
  });

  test('a perfect run earns one star per question', () async {
    await cubit.load();

    await cubit.answer(1);
    await cubit.nextQuestion();
    await cubit.answer(2);
    await cubit.nextQuestion();

    expect(cubit.state.finished, isTrue);
    expect(cubit.state.earnedStars, 2);
    expect(progress.saved.last.stars, 2);
    expect(progress.saved.last.completed, isTrue);
  });

  test('restart clears the round without losing the lesson', () async {
    await cubit.load();
    await cubit.answer(1);
    await cubit.nextQuestion();
    await cubit.answer(2);
    await cubit.nextQuestion();

    cubit.restart();

    expect(cubit.state.finished, isFalse);
    expect(cubit.state.currentIndex, 0);
    expect(cubit.state.earnedStars, 0);
    expect(cubit.state.lesson?.id, testQuiz.id);
  });

  test('a missing quiz produces a friendly error', () async {
    final missingCubit = QuizCubit(
      profile: testProfile,
      lessonId: 'missing',
      contentRepository: content,
      progressRepository: progress,
    );
    addTearDown(missingCubit.close);

    await missingCubit.load();

    expect(missingCubit.state.loading, isFalse);
    expect(missingCubit.state.error, isNotNull);
    expect(missingCubit.state.lesson, isNull);
  });
}
