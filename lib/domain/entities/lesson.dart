import 'package:equatable/equatable.dart';

enum LessonPhase { manners, education }

/// A single step in a 5-step manners story stream.
class StoryStep extends Equatable {
  const StoryStep({
    required this.step,
    required this.kind, // 'narration', 'interactive_tap', 'outcome'
    required this.image,
    this.audio,
    required this.textMy,
    this.actionLabelMy,
  });

  final int step;
  final String kind;
  final String image;
  final String? audio;
  final String textMy;
  final String? actionLabelMy;

  bool get isInteractiveTap => kind == 'interactive_tap';

  @override
  List<Object?> get props => [step, kind, image, audio, textMy, actionLabelMy];
}

/// An option in a simple quiz for manners stories.
class SimpleQuizOption extends Equatable {
  const SimpleQuizOption({
    required this.image,
    required this.textMy,
    required this.isCorrect,
  });

  final String image;
  final String textMy;
  final bool isCorrect;

  @override
  List<Object?> get props => [image, textMy, isCorrect];
}

/// A simple quiz question following a manners story stream.
class SimpleQuizQuestion extends Equatable {
  const SimpleQuizQuestion({
    required this.promptMy,
    required this.options,
    this.encouragementMy = '',
  });

  final String promptMy;
  final List<SimpleQuizOption> options;
  final String encouragementMy;

  @override
  List<Object?> get props => [promptMy, options, encouragementMy];
}

/// A discovery card in KG Education.
class KgCard extends Equatable {
  const KgCard({
    required this.letter,
    required this.wordMy,
    required this.image,
    this.audio,
    required this.promptMy,
  });

  final String letter;
  final String wordMy;
  final String image;
  final String? audio;
  final String promptMy;

  @override
  List<Object?> get props => [letter, wordMy, image, audio, promptMy];
}

/// An option in a KG mini-game question.
class KgMiniGameOption extends Equatable {
  const KgMiniGameOption({
    required this.letter,
    required this.wordMy,
    required this.image,
    required this.isCorrect,
  });

  final String letter;
  final String wordMy;
  final String image;
  final bool isCorrect;

  @override
  List<Object?> get props => [letter, wordMy, image, isCorrect];
}

/// A mini-game question in KG Education.
class KgMiniGameQuestion extends Equatable {
  const KgMiniGameQuestion({
    required this.promptMy,
    required this.options,
    this.encouragementMy = '',
  });

  final String promptMy;
  final List<KgMiniGameOption> options;
  final String encouragementMy;

  @override
  List<Object?> get props => [promptMy, options, encouragementMy];
}

/// A single illustrated page in a manners story (legacy support).
class StoryPage extends Equatable {
  const StoryPage({
    required this.text,
    required this.imageAsset,
    this.audioAsset,
  });

  final String text;
  final String imageAsset;
  final String? audioAsset;

  @override
  List<Object?> get props => [text, imageAsset, audioAsset];
}

/// A tap-to-answer question used by both stories and quizzes (legacy support).
class QuizQuestion extends Equatable {
  const QuizQuestion({
    required this.id,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    this.explanation = '',
    this.imageAsset,
  });

  final String id;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String? imageAsset;

  bool isCorrect(int index) => index == correctIndex;

  @override
  List<Object?> get props =>
      [id, prompt, options, correctIndex, explanation, imageAsset];
}

sealed class Lesson extends Equatable {
  const Lesson({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.phase,
    required this.imageAsset,
    this.world = 1,
    this.episode = 1,
    this.stickerReward,
    this.starsReward = 3,
  });

  final String id;
  final String title;
  final String subtitle;
  final LessonPhase phase;
  final String imageAsset;
  final int world;
  final int episode;
  final String? stickerReward;
  final int starsReward;

  bool get isStory => this is StoryLesson;
}

class StoryLesson extends Lesson {
  const StoryLesson({
    required super.id,
    required super.title,
    required super.subtitle,
    required super.imageAsset,
    super.world = 1,
    super.episode = 1,
    super.stickerReward,
    super.starsReward = 3,
    required this.pages,
    required this.moralQuestion,
    this.audioAsset,
    this.steps = const [],
    this.simpleQuiz = const [],
  }) : super(phase: LessonPhase.manners);

  final List<StoryPage> pages;
  final QuizQuestion moralQuestion;
  final String? audioAsset;
  final List<StoryStep> steps;
  final List<SimpleQuizQuestion> simpleQuiz;

  bool get isStream => steps.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        title,
        subtitle,
        phase,
        imageAsset,
        world,
        episode,
        stickerReward,
        starsReward,
        pages,
        moralQuestion,
        audioAsset,
        steps,
        simpleQuiz,
      ];
}

class QuizLesson extends Lesson {
  const QuizLesson({
    required super.id,
    required super.title,
    required super.subtitle,
    required super.imageAsset,
    super.world = 1,
    super.episode = 1,
    super.stickerReward,
    super.starsReward = 3,
    required this.questions,
    this.discoverCards = const [],
    this.miniGame = const [],
  }) : super(phase: LessonPhase.education);

  final List<QuizQuestion> questions;
  final List<KgCard> discoverCards;
  final List<KgMiniGameQuestion> miniGame;

  bool get isKgDiscover => discoverCards.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        title,
        subtitle,
        phase,
        imageAsset,
        world,
        episode,
        stickerReward,
        starsReward,
        questions,
        discoverCards,
        miniGame,
      ];
}
