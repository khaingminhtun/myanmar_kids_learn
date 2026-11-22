import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/child_profile.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/repositories/content_repository.dart';
import '../../domain/repositories/progress_repository.dart';

class QuizState extends Equatable {
  const QuizState({
    this.loading = true,
    this.lesson,
    this.currentIndex = 0,
    this.selectedIndex,
    this.answered = false,
    this.isCorrect = false,
    this.correctCount = 0,
    this.finished = false,
    this.saving = false,
    this.tappedLetters = const {},
    this.inMiniGame = false,
    this.isWiggling = false,
    this.stickerUnlocked = false,
    this.selectedCardIndex = 0,
    this.error,
  });

  static const Object _unset = Object();

  final bool loading;
  final QuizLesson? lesson;
  final int currentIndex;
  final int? selectedIndex;
  final bool answered;
  final bool isCorrect;
  final int correctCount;
  final bool finished;
  final bool saving;
  final Set<String> tappedLetters;
  final bool inMiniGame;
  final bool isWiggling;
  final bool stickerUnlocked;
  final int selectedCardIndex;
  final String? error;

  bool get isKgDiscover => lesson?.isKgDiscover ?? false;

  bool get isDiscoverMode => isKgDiscover && !inMiniGame;

  bool get allCardsTapped =>
      lesson != null &&
      lesson!.discoverCards.isNotEmpty &&
      tappedLetters.length >= lesson!.discoverCards.length;

  KgCard? get currentCard {
    final quiz = lesson;
    if (quiz == null ||
        !quiz.isKgDiscover ||
        selectedCardIndex >= quiz.discoverCards.length) {
      return null;
    }
    return quiz.discoverCards[selectedCardIndex];
  }

  KgMiniGameQuestion? get currentMiniGame {
    final quiz = lesson;
    if (quiz == null ||
        !quiz.isKgDiscover ||
        currentIndex >= quiz.miniGame.length) {
      return null;
    }
    return quiz.miniGame[currentIndex];
  }

  QuizQuestion? get currentQuestion {
    final quiz = lesson;
    if (quiz == null || currentIndex >= quiz.questions.length) return null;
    return quiz.questions[currentIndex];
  }

  int get totalQuestions => isKgDiscover
      ? (lesson?.miniGame.length ?? 0)
      : (lesson?.questions.length ?? 0);

  bool get isLastQuestion =>
      lesson != null && currentIndex == totalQuestions - 1;

  int get earnedStars =>
      isKgDiscover ? (finished ? 3 : 0) : correctCount;

  String? get currentAudioAsset {
    if (isDiscoverMode) {
      return currentCard?.audio;
    }
    return null;
  }

  String get currentPrompt {
    if (isDiscoverMode) {
      final card = currentCard;
      if (card != null && card.promptMy.isNotEmpty) {
        return card.promptMy;
      }
      return 'အက္ခရာကတ်လေးများကို နှိပ်၍ အသံနားထောင်ပါ';
    }

    if (inMiniGame) {
      if (answered) {
        return isCorrect
            ? (currentMiniGame?.encouragementMy.isNotEmpty ?? false)
                ? currentMiniGame!.encouragementMy
                : 'အရမ်းတော်တယ်! မှန်ကန်ပါတယ်။'
            : 'နောက်တစ်ခေါက် ထပ်ရှာကြည့်ရအောင်နော်!';
      }
      return currentMiniGame?.promptMy ?? 'မှန်ကန်သောပုံကို ရွေးချယ်ပါ';
    }

    final q = currentQuestion;
    return q?.prompt ?? 'မေးခွန်းကို ဖြေဆိုပါ';
  }

  QuizState copyWith({
    bool? loading,
    QuizLesson? lesson,
    int? currentIndex,
    Object? selectedIndex = _unset,
    bool? answered,
    bool? isCorrect,
    int? correctCount,
    bool? finished,
    bool? saving,
    Set<String>? tappedLetters,
    bool? inMiniGame,
    bool? isWiggling,
    bool? stickerUnlocked,
    int? selectedCardIndex,
    Object? error = _unset,
  }) {
    return QuizState(
      loading: loading ?? this.loading,
      lesson: lesson ?? this.lesson,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedIndex: identical(selectedIndex, _unset)
          ? this.selectedIndex
          : selectedIndex as int?,
      answered: answered ?? this.answered,
      isCorrect: isCorrect ?? this.isCorrect,
      correctCount: correctCount ?? this.correctCount,
      finished: finished ?? this.finished,
      saving: saving ?? this.saving,
      tappedLetters: tappedLetters ?? this.tappedLetters,
      inMiniGame: inMiniGame ?? this.inMiniGame,
      isWiggling: isWiggling ?? this.isWiggling,
      stickerUnlocked: stickerUnlocked ?? this.stickerUnlocked,
      selectedCardIndex: selectedCardIndex ?? this.selectedCardIndex,
      error: identical(error, _unset) ? this.error : error as String?,
    );
  }

  @override
  List<Object?> get props => [
        loading,
        lesson,
        currentIndex,
        selectedIndex,
        answered,
        isCorrect,
        correctCount,
        finished,
        saving,
        tappedLetters,
        inMiniGame,
        isWiggling,
        stickerUnlocked,
        selectedCardIndex,
        error,
      ];
}

class QuizCubit extends Cubit<QuizState> {
  QuizCubit({
    required this.profile,
    required this.lessonId,
    required this.contentRepository,
    required this.progressRepository,
  }) : super(const QuizState());

  final ChildProfile profile;
  final String lessonId;
  final ContentRepository contentRepository;
  final ProgressRepository progressRepository;

  Future<void> load() async {
    emit(const QuizState(loading: true));
    try {
      final lesson = await contentRepository.lessonById(lessonId);
      if (isClosed) return;
      if (lesson is! QuizLesson) {
        emit(
          const QuizState(
            loading: false,
            error: 'ဒီဂိမ်းကို ရှာမတွေ့ပါ။',
          ),
        );
        return;
      }
      emit(QuizState(loading: false, lesson: lesson));
    } catch (_) {
      if (isClosed) return;
      emit(
        const QuizState(
          loading: false,
          error: 'ဂိမ်းကို ဖွင့်၍ မရပါ။ ထပ်ကြိုးစားပါ။',
        ),
      );
    }
  }

  void tapDiscoverCard(int cardIndex) {
    final quiz = state.lesson;
    if (quiz == null || !quiz.isKgDiscover) return;
    if (cardIndex < 0 || cardIndex >= quiz.discoverCards.length) return;

    final card = quiz.discoverCards[cardIndex];
    final updated = Set<String>.from(state.tappedLetters)..add(card.letter);

    emit(
      state.copyWith(
        selectedCardIndex: cardIndex,
        tappedLetters: updated,
      ),
    );
  }

  void startMiniGame() {
    if (!state.allCardsTapped && state.isKgDiscover) return;
    emit(
      state.copyWith(
        inMiniGame: true,
        currentIndex: 0,
        selectedIndex: null,
        answered: false,
        isCorrect: false,
        isWiggling: false,
      ),
    );
  }

  Future<void> answer(int index) async {
    final quiz = state.lesson;
    if (quiz == null || state.answered || state.finished) return;

    if (quiz.isKgDiscover && state.inMiniGame) {
      await _answerKgMiniGame(index);
      return;
    }

    final question = state.currentQuestion;
    if (question == null) return;
    if (index < 0 || index >= question.options.length) return;

    final correct = question.isCorrect(index);
    final newCount = state.correctCount + (correct ? 1 : 0);

    emit(
      state.copyWith(
        answered: true,
        selectedIndex: index,
        isCorrect: correct,
        correctCount: newCount,
        error: null,
      ),
    );

    if (!correct) return;

    try {
      await progressRepository.saveResult(
        profileId: profile.id,
        lessonId: quiz.id,
        stars: newCount,
        completed: false,
      );
    } catch (_) {
      if (!isClosed) {
        emit(
          state.copyWith(
            error: 'ကြယ်များ သိမ်း၍ မရပါ။ ဆက်ကစားနိုင်ပါတယ်။',
          ),
        );
      }
    }
  }

  Future<void> _answerKgMiniGame(int index) async {
    final mg = state.currentMiniGame;
    if (mg == null || index < 0 || index >= mg.options.length) return;

    final option = mg.options[index];
    if (!option.isCorrect) {
      emit(
        state.copyWith(
          answered: true,
          selectedIndex: index,
          isCorrect: false,
          isWiggling: true,
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
      ),
    );

    // If last question in mini-game, finish!
    if (state.isLastQuestion) {
      await _finishKgDiscover();
    }
  }

  Future<void> nextQuestion() async {
    if (!state.answered || state.finished) return;
    if (state.isLastQuestion) {
      if (state.isKgDiscover) {
        await _finishKgDiscover();
      } else {
        await _finish();
      }
      return;
    }
    emit(
      state.copyWith(
        currentIndex: state.currentIndex + 1,
        selectedIndex: null,
        answered: false,
        isCorrect: false,
        isWiggling: false,
        error: null,
      ),
    );
  }

  Future<void> _finishKgDiscover() async {
    final quiz = state.lesson;
    if (quiz == null) return;

    emit(state.copyWith(finished: true, saving: true, error: null));
    try {
      await progressRepository.saveResult(
        profileId: profile.id,
        lessonId: quiz.id,
        stars: 3,
        completed: true,
      );

      if (quiz.stickerReward != null && quiz.stickerReward!.isNotEmpty) {
        await progressRepository.unlockSticker(
          profileId: profile.id,
          stickerId: quiz.stickerReward!,
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
            error: 'ကြယ်များ သိမ်း၍ မရပါ။ ရလဒ်ကို ဆက်ကြည့်နိုင်ပါတယ်။',
          ),
        );
      }
    }
  }

  Future<void> _finish() async {
    final quiz = state.lesson;
    if (quiz == null) return;

    emit(state.copyWith(finished: true, saving: true, error: null));
    try {
      await progressRepository.saveResult(
        profileId: profile.id,
        lessonId: quiz.id,
        stars: state.correctCount,
        completed: true,
      );
      if (!isClosed) emit(state.copyWith(saving: false));
    } catch (_) {
      if (!isClosed) {
        emit(
          state.copyWith(
            saving: false,
            error: 'ကြယ်များ သိမ်း၍ မရပါ။ ရလဒ်ကို ဆက်ကြည့်နိုင်ပါတယ်။',
          ),
        );
      }
    }
  }

  void retryMiniGame() {
    emit(
      state.copyWith(
        answered: false,
        selectedIndex: null,
        isCorrect: false,
        isWiggling: false,
      ),
    );
  }

  void restart() {
    if (state.lesson == null) return;
    emit(
      QuizState(
        loading: false,
        lesson: state.lesson,
      ),
    );
  }

  Future<void> retry() => load();
}
