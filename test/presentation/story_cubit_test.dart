import 'package:flutter_test/flutter_test.dart';
import 'package:myanmar_kids_learn/presentation/manners_story/story_cubit.dart';

import '../support/fakes.dart';

void main() {
  late FakeContentRepository content;
  late FakeProgressRepository progress;
  late StoryCubit cubit;

  setUp(() {
    content = FakeContentRepository([testStory]);
    progress = FakeProgressRepository();
    cubit = StoryCubit(
      profile: testProfile,
      lessonId: testStory.id,
      contentRepository: content,
      progressRepository: progress,
    );
  });

  tearDown(() async {
    await cubit.close();
    await progress.dispose();
  });

  test('loads the story and reaches the moral question', () async {
    await cubit.load();

    expect(cubit.state.loading, isFalse);
    expect(cubit.state.lesson?.id, testStory.id);
    expect(cubit.state.pageIndex, 0);
    expect(cubit.state.isQuestion, isFalse);

    cubit.nextPage();
    cubit.nextPage();
    cubit.nextPage();

    expect(cubit.state.pageIndex, 3);
    expect(cubit.state.isQuestion, isTrue);
    expect(cubit.state.currentPage, isNull);
  });

  test('a wrong moral answer gives feedback without saving stars', () async {
    await cubit.load();
    cubit.nextPage();
    cubit.nextPage();
    cubit.nextPage();

    await cubit.answerMoral(1);

    expect(cubit.state.answered, isTrue);
    expect(cubit.state.isCorrect, isFalse);
    expect(cubit.state.starsAwarded, 0);
    expect(progress.saved, isEmpty);

    cubit.retryMoral();
    expect(cubit.state.answered, isFalse);
    expect(cubit.state.selectedIndex, isNull);
  });

  test('the correct moral answer saves 3 stars and completion', () async {
    await cubit.load();
    cubit.nextPage();
    cubit.nextPage();
    cubit.nextPage();

    await cubit.answerMoral(0);

    expect(cubit.state.isCorrect, isTrue);
    expect(cubit.state.starsAwarded, 3);
    expect(cubit.state.saving, isFalse);
    expect(progress.saved, hasLength(1));
    expect(progress.saved.single.profileId, testProfile.id);
    expect(progress.saved.single.lessonId, testStory.id);
    expect(progress.saved.single.stars, 3);
    expect(progress.saved.single.completed, isTrue);
  });

  test('a missing story produces a friendly error', () async {
    final missingCubit = StoryCubit(
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
