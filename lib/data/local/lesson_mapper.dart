import '../../domain/entities/lesson.dart';

/// Converts the bundled lesson JSON into domain entities. Invalid files are
/// skipped instead of throwing, so one bad asset cannot blank the whole app.
class LessonMapper {
  const LessonMapper();

  Lesson? fromJson(Map<String, dynamic> json) {
    final type = _string(json['type']);
    final id = _string(json['id']);
    final title = _string(json['title_my'], fallback: _string(json['title']));
    if (id.isEmpty || title.isEmpty) return null;

    final subtitle =
        _string(json['title_en'], fallback: _string(json['subtitle']));
    final imageAsset =
        _string(json['cover_image'], fallback: _string(json['imageAsset']));
    final world = _int(json['world'], fallback: 1);
    final episode = _int(json['episode'], fallback: 1);
    final stickerReward = _nullableString(json['sticker_reward']);
    final starsReward = _int(json['stars_reward'], fallback: 3);

    switch (type) {
      case 'story_stream':
        final steps = _storySteps(json['story_stream']);
        final simpleQuiz = _simpleQuiz(json['simple_quiz']);
        if (steps.isEmpty) return null;

        // Backward compatibility synthesizers
        final pages = steps
            .map(
              (step) => StoryPage(
                text: step.textMy,
                imageAsset: step.image.isNotEmpty ? step.image : imageAsset,
                audioAsset: step.audio,
              ),
            )
            .toList(growable: false);

        final QuizQuestion moralQuestion;
        if (simpleQuiz.isNotEmpty && simpleQuiz.first.options.isNotEmpty) {
          final q = simpleQuiz.first;
          final correctIdx = q.options.indexWhere((o) => o.isCorrect);
          moralQuestion = QuizQuestion(
            id: '${id}_q',
            prompt: q.promptMy,
            options: q.options.map((o) => o.textMy).toList(growable: false),
            correctIndex: correctIdx >= 0 ? correctIdx : 0,
            explanation: q.encouragementMy,
            imageAsset: imageAsset,
          );
        } else {
          moralQuestion = QuizQuestion(
            id: '${id}_q',
            prompt: title,
            options: const ['မှန်ပါသည်', 'မဟုတ်ပါ'],
            correctIndex: 0,
            imageAsset: imageAsset,
          );
        }

        return StoryLesson(
          id: id,
          title: title,
          subtitle: subtitle,
          imageAsset: imageAsset,
          world: world,
          episode: episode,
          stickerReward: stickerReward,
          starsReward: starsReward,
          pages: pages,
          moralQuestion: moralQuestion,
          steps: steps,
          simpleQuiz: simpleQuiz,
        );

      case 'kg_discover':
        final discoverCards = _discoverCards(json['discover_cards']);
        final miniGame = _miniGame(json['mini_game']);
        if (discoverCards.isEmpty) return null;

        // Backward compatibility synthesizers
        final questions = <QuizQuestion>[];
        for (var i = 0; i < miniGame.length; i++) {
          final mq = miniGame[i];
          final correctIdx = mq.options.indexWhere((o) => o.isCorrect);
          questions.add(
            QuizQuestion(
              id: '${id}_mq_$i',
              prompt: mq.promptMy,
              options: mq.options
                  .map((o) => '${o.letter} - ${o.wordMy}')
                  .toList(growable: false),
              correctIndex: correctIdx >= 0 ? correctIdx : 0,
              explanation: mq.encouragementMy,
              imageAsset: mq.options.isNotEmpty ? mq.options.first.image : null,
            ),
          );
        }

        return QuizLesson(
          id: id,
          title: title,
          subtitle: subtitle,
          imageAsset: imageAsset,
          world: world,
          episode: episode,
          stickerReward: stickerReward,
          starsReward: starsReward,
          questions: questions.isNotEmpty
              ? questions
              : [
                  QuizQuestion(
                    id: '${id}_q0',
                    prompt: title,
                    options: discoverCards.map((c) => c.letter).toList(),
                    correctIndex: 0,
                  )
                ],
          discoverCards: discoverCards,
          miniGame: miniGame,
        );

      // Legacy fallback
      case 'story':
        final audioAsset = _nullableString(json['audioAsset']);
        final pages = _pages(json['pages'], imageAsset, audioAsset);
        final moralQuestion = _question(json['moralQuestion']);
        if (pages.isEmpty || moralQuestion == null) return null;
        return StoryLesson(
          id: id,
          title: title,
          subtitle: subtitle,
          imageAsset: imageAsset,
          audioAsset: audioAsset,
          pages: pages,
          moralQuestion: moralQuestion,
        );

      case 'quiz':
        final questions = _questions(json['questions']);
        if (questions.isEmpty) return null;
        return QuizLesson(
          id: id,
          title: title,
          subtitle: subtitle,
          imageAsset: imageAsset,
          questions: questions,
        );

      default:
        return null;
    }
  }

  List<StoryStep> _storySteps(Object? raw) {
    if (raw is! List) return const [];
    final steps = <StoryStep>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final step = _int(item['step'], fallback: steps.length + 1);
      final kind = _string(item['kind'], fallback: 'narration');
      final image = _string(item['image']);
      final audio = _nullableString(item['audio']);
      final textMy = _string(item['text_my'], fallback: _string(item['text']));
      final actionLabelMy = _nullableString(item['action_label_my']);
      if (textMy.isEmpty) continue;
      steps.add(
        StoryStep(
          step: step,
          kind: kind,
          image: image,
          audio: audio,
          textMy: textMy,
          actionLabelMy: actionLabelMy,
        ),
      );
    }
    return steps;
  }

  List<SimpleQuizQuestion> _simpleQuiz(Object? raw) {
    if (raw is! List) return const [];
    final quiz = <SimpleQuizQuestion>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final promptMy = _string(item['prompt_my'], fallback: _string(item['prompt']));
      if (promptMy.isEmpty) continue;
      final encouragementMy =
          _string(item['encouragement_my'], fallback: _string(item['explanation']));
      final rawOptions = item['options'];
      if (rawOptions is! List) continue;

      final options = <SimpleQuizOption>[];
      for (final opt in rawOptions) {
        if (opt is! Map) continue;
        final image = _string(opt['image']);
        final textMy = _string(opt['text_my'], fallback: _string(opt['text']));
        final isCorrect = opt['is_correct'] == true;
        if (textMy.isEmpty && image.isEmpty) continue;
        options.add(
          SimpleQuizOption(
            image: image,
            textMy: textMy,
            isCorrect: isCorrect,
          ),
        );
      }
      if (options.length >= 2) {
        quiz.add(
          SimpleQuizQuestion(
            promptMy: promptMy,
            options: options,
            encouragementMy: encouragementMy,
          ),
        );
      }
    }
    return quiz;
  }

  List<KgCard> _discoverCards(Object? raw) {
    if (raw is! List) return const [];
    final cards = <KgCard>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final letter = _string(item['letter']);
      final wordMy = _string(item['word_my']);
      final image = _string(item['image']);
      final audio = _nullableString(item['audio']);
      final promptMy = _string(item['prompt_my']);
      if (letter.isEmpty && wordMy.isEmpty) continue;
      cards.add(
        KgCard(
          letter: letter,
          wordMy: wordMy,
          image: image,
          audio: audio,
          promptMy: promptMy,
        ),
      );
    }
    return cards;
  }

  List<KgMiniGameQuestion> _miniGame(Object? raw) {
    if (raw is! List) return const [];
    final questions = <KgMiniGameQuestion>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final promptMy = _string(item['prompt_my']);
      final encouragementMy = _string(item['encouragement_my']);
      final rawOptions = item['options'];
      if (rawOptions is! List) continue;

      final options = <KgMiniGameOption>[];
      for (final opt in rawOptions) {
        if (opt is! Map) continue;
        final letter = _string(opt['letter']);
        final wordMy = _string(opt['word_my']);
        final image = _string(opt['image']);
        final isCorrect = opt['is_correct'] == true;
        options.add(
          KgMiniGameOption(
            letter: letter,
            wordMy: wordMy,
            image: image,
            isCorrect: isCorrect,
          ),
        );
      }
      if (options.length >= 2) {
        questions.add(
          KgMiniGameQuestion(
            promptMy: promptMy,
            options: options,
            encouragementMy: encouragementMy,
          ),
        );
      }
    }
    return questions;
  }

  List<StoryPage> _pages(
    Object? rawPages,
    String lessonImage,
    String? lessonAudio,
  ) {
    if (rawPages is! List) return const [];
    final pages = <StoryPage>[];
    for (final raw in rawPages) {
      if (raw is! Map) continue;
      final text = _string(raw['text']);
      if (text.isEmpty) continue;
      final image = _string(raw['imageAsset'], fallback: lessonImage);
      final audio = _nullableString(raw['audioAsset']) ?? lessonAudio;
      pages.add(StoryPage(text: text, imageAsset: image, audioAsset: audio));
    }
    return pages;
  }

  List<QuizQuestion> _questions(Object? rawQuestions) {
    if (rawQuestions is! List) return const [];
    final questions = <QuizQuestion>[];
    for (var i = 0; i < rawQuestions.length; i++) {
      final raw = rawQuestions[i];
      if (raw is! Map) continue;
      final question = _question(raw, fallbackId: 'question_$i');
      if (question != null) questions.add(question);
    }
    return questions;
  }

  QuizQuestion? _question(Object? raw, {String fallbackId = 'question'}) {
    if (raw is! Map) return null;
    final prompt = _string(raw['prompt']);
    if (prompt.isEmpty) return null;

    final rawOptions = raw['options'];
    if (rawOptions is! List) return null;
    final options = rawOptions
        .map((option) => option is String ? option.trim() : '')
        .toList(growable: false);
    if (options.length < 2 || options.any((option) => option.isEmpty)) {
      return null;
    }

    final correctIndex = raw['correctIndex'];
    if (correctIndex is! int ||
        correctIndex < 0 ||
        correctIndex >= options.length) {
      return null;
    }

    return QuizQuestion(
      id: _string(raw['id'], fallback: fallbackId),
      prompt: prompt,
      options: options,
      correctIndex: correctIndex,
      explanation: _string(raw['explanation']),
      imageAsset: _nullableString(raw['imageAsset']),
    );
  }

  String _string(Object? value, {String fallback = ''}) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return fallback;
  }

  String? _nullableString(Object? value) {
    final parsed = _string(value);
    return parsed.isEmpty ? null : parsed;
  }

  int _int(Object? value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }
}
