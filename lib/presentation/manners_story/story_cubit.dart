import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/child_profile.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/repositories/content_repository.dart';
import '../../domain/repositories/progress_repository.dart';

class StoryState extends Equatable {
  const StoryState({
    this.loading = true,
    this.lesson,
    this.pageIndex = 0,
    this.hasTappedInteractive = false,
    this.answered = false,
    this.selectedIndex,
    this.isCorrect = false,
    this.isWiggling = false,
    this.starsAwarded = 0,
    this.saving = false,
    this.stickerUnlocked = false,
    this.error,
  });

  static const Object _unset = Object();

  final bool loading;
  final StoryLesson? lesson;
  final int pageIndex;
  final bool hasTappedInteractive;
  final bool answered;
  final int? selectedIndex;
  final bool isCorrect;
  final bool isWiggling;
  final int starsAwarded;
  final bool saving;
  final bool stickerUnlocked;
  final String? error;

  int get streamStepsLength => lesson?.steps.length ?? 0;

  int get legacyPagesLength => lesson?.pages.length ?? 0;

  int get storyLength =>
      (lesson?.isStream ?? false) ? streamStepsLength : legacyPagesLength;

  bool get isQuestion => lesson != null && pageIndex >= storyLength;

  StoryStep? get currentStep {
    final story = lesson;
    if (story == null || !story.isStream || pageIndex >= story.steps.length) {
      return null;
    }
    return story.steps[pageIndex];
  }

  StoryPage? get currentPage {
    final story = lesson;
    if (story == null || pageIndex >= story.pages.length) return null;
    return story.pages[pageIndex];
  }

  QuizQuestion? get moralQuestion => lesson?.moralQuestion;

  SimpleQuizQuestion? get currentSimpleQuiz {
    final story = lesson;
    if (story == null || story.simpleQuiz.isEmpty) return null;
    return story.simpleQuiz.first;
  }

  String? get currentAudioAsset {
    if (currentStep != null) return currentStep!.audio;
    return currentPage?.audioAsset;
  }

  String get currentPrompt {
    if (isQuestion) {
      if (answered) {
        return isCorrect
            ? (currentSimpleQuiz?.encouragementMy.isNotEmpty ?? false)
                ? currentSimpleQuiz!.encouragementMy
                : 'အရမ်းတော်တယ်! ကြယ် ၃ ပွင့် ရရှိသွားပါပြီ။'
            : 'နောက်တစ်ခေါက် ထပ်ကြိုးစားကြည့်ရအောင်နော်!';
      }
      return currentSimpleQuiz?.promptMy ?? moralQuestion?.prompt ?? 'မှန်ကန်သောအဖြေကို ရွေးချယ်ပါ';
    }

    if (currentStep != null) {
      if (currentStep!.isInteractiveTap && !hasTappedInteractive) {
        return currentStep!.textMy;
      }
      return currentStep!.textMy;
    }

    return currentPage?.text ?? '';
  }

  int get pageCount => storyLength;

  int get stepCount => lesson == null ? 0 : storyLength + 1;

  bool get isLastStoryPage =>
      lesson != null && pageIndex == storyLength - 1;

  StoryState copyWith({
    bool? loading,
    StoryLesson? lesson,
    int? pageIndex,
    bool? hasTappedInteractive,
    bool? answered,
    Object? selectedIndex = _unset,
    bool? isCorrect,
    bool? isWiggling,
    int? starsAwarded,
    bool? saving,
    bool? stickerUnlocked,
    Object? error = _unset,
  }) {
    return StoryState(
      loading: loading ?? this.loading,
      lesson: lesson ?? this.lesson,
      pageIndex: pageIndex ?? this.pageIndex,
      hasTappedInteractive: hasTappedInteractive ?? this.hasTappedInteractive,
      answered: answered ?? this.answered,
      selectedIndex: identical(selectedIndex, _unset)
          ? this.selectedIndex
          : selectedIndex as int?,
      isCorrect: isCorrect ?? this.isCorrect,
      isWiggling: isWiggling ?? this.isWiggling,
      starsAwarded: starsAwarded ?? this.starsAwarded,
      saving: saving ?? this.saving,
      stickerUnlocked: stickerUnlocked ?? this.stickerUnlocked,
      error: identical(error, _unset) ? this.error : error as String?,
    );
  }

  @override
  List<Object?> get props => [
        loading,
        lesson,
        pageIndex,
        hasTappedInteractive,
        answered,
        selectedIndex,
        isCorrect,
        isWiggling,
        starsAwarded,
        saving,
        stickerUnlocked,
        error,
      ];
}

class StoryCubit extends Cubit<StoryState> {
  StoryCubit({
    required this.profile,
    required this.lessonId,
    required this.contentRepository,
    required this.progressRepository,
  }) : super(const StoryState());

  final ChildProfile profile;
  final String lessonId;
  final ContentRepository contentRepository;
  final ProgressRepository progressRepository;

  Future<void> load() async {
    emit(const StoryState(loading: true));
    try {
      final lesson = await contentRepository.lessonById(lessonId);
      if (isClosed) return;
      if (lesson is! StoryLesson) {
        emit(
          const StoryState(
            loading: false,
            error: 'ဒီပုံပြင်ကို ရှာမတွေ့ပါ။',
          ),
        );
        return;
      }
      emit(StoryState(loading: false, lesson: lesson));
    } catch (_) {
      if (isClosed) return;
      emit(
        const StoryState(
          loading: false,
          error: 'ပုံပြင်ကို ဖွင့်၍ မရပါ။ ထပ်ကြိုးစားပါ။',
        ),
      );
    }
  }

  void tapInteractive() {
    if (state.hasTappedInteractive) return;
    emit(state.copyWith(hasTappedInteractive: true));
  }

  void nextPage() {
    final story = state.lesson;
    if (story == null || state.isQuestion) return;

    // If on interactive step and not tapped yet, require tap first
    final step = state.currentStep;
    if (step != null && step.isInteractiveTap && !state.hasTappedInteractive) {
      return;
    }

    emit(
      state.copyWith(
        pageIndex: state.pageIndex + 1,
        hasTappedInteractive: false,
        isWiggling: false,
      ),
    );
  }

  void previousPage() {
    if (state.pageIndex <= 0) return;
    emit(
      state.copyWith(
        pageIndex: state.pageIndex - 1,
        isWiggling: false,
      ),
    );
  }

  Future<void> answerMoral(int index) async {
    final story = state.lesson;
    if (story == null || state.answered || !state.isQuestion) return;

    final bool correct;
    if (story.isStream && story.simpleQuiz.isNotEmpty) {
      final q = story.simpleQuiz.first;
      correct = index >= 0 && index < q.options.length && q.options[index].isCorrect;
    } else {
      correct = story.moralQuestion.isCorrect(index);
    }

    if (!correct) {
      emit(
        state.copyWith(
          answered: true,
          selectedIndex: index,
          isCorrect: false,
          isWiggling: true,
          starsAwarded: 0,
          error: null,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        answered: true,
        selectedIndex: index,
        isCorrect: true,
        isWiggling: false,
        starsAwarded: story.starsReward > 0 ? story.starsReward : 3,
        saving: true,
        error: null,
      ),
    );

    try {
      await progressRepository.saveResult(
        profileId: profile.id,
        lessonId: story.id,
        stars: story.starsReward > 0 ? story.starsReward : 3,
        completed: true,
      );

      if (story.stickerReward != null && story.stickerReward!.isNotEmpty) {
        await progressRepository.unlockSticker(
          profileId: profile.id,
          stickerId: story.stickerReward!,
        );
      }

      if (!isClosed) {
        emit(state.copyWith(saving: false, stickerUnlocked: true));
      }
    } catch (_) {
      if (!isClosed) {
        emit(
          state.copyWith(
            saving: false,
            error: 'ကြယ်များ သိမ်း၍ မရပါ။ သင်ယူမှုကို ဆက်လုပ်နိုင်ပါတယ်။',
          ),
        );
      }
    }
  }

  void retryMoral() {
    if (!state.isCorrect) {
      emit(
        state.copyWith(
          answered: false,
          selectedIndex: null,
          isCorrect: false,
          isWiggling: false,
          starsAwarded: 0,
          error: null,
        ),
      );
    }
  }

  void resetWiggle() {
    if (state.isWiggling) {
      emit(state.copyWith(isWiggling: false));
    }
  }

  Future<void> retry() => load();
}
