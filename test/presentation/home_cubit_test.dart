import 'package:flutter_test/flutter_test.dart';
import 'package:myanmar_kids_learn/domain/entities/lesson_progress.dart';
import 'package:myanmar_kids_learn/presentation/home/home_cubit.dart';

import '../support/fakes.dart';

void main() {
  late FakeProgressRepository progress;
  late HomeCubit cubit;

  setUp(() {
    progress = FakeProgressRepository(
      initial: [
        LessonProgress(
          profileId: testProfile.id,
          lessonId: testStory.id,
          completed: true,
          stars: 3,
          updatedAt: DateTime(2026, 1, 1),
        ),
      ],
    );
    cubit = HomeCubit(
      profile: testProfile,
      contentRepository: FakeContentRepository([testStory, testQuiz]),
      progressRepository: progress,
    );
  });

  tearDown(() async {
    await cubit.close();
    await progress.dispose();
  });

  test('groups lessons by phase and streams stars', () async {
    await cubit.start();
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.loading, isFalse);
    expect(cubit.state.mannersLessons, hasLength(1));
    expect(cubit.state.educationLessons, hasLength(1));
    expect(cubit.state.totalStars, 3);
    expect(cubit.state.isCompleted(testStory.id), isTrue);
    expect(cubit.state.isCompleted(testQuiz.id), isFalse);
    expect(cubit.state.starsFor(testStory.id), 3);
  });

  test('updates the star total when progress changes', () async {
    await cubit.start();
    await Future<void>.delayed(Duration.zero);

    await progress.saveResult(
      profileId: testProfile.id,
      lessonId: testQuiz.id,
      stars: 2,
      completed: false,
    );
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.totalStars, 5);
    expect(cubit.state.starsFor(testQuiz.id), 2);
  });
}
