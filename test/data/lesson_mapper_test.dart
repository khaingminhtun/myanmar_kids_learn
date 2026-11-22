import 'package:flutter_test/flutter_test.dart';
import 'package:myanmar_kids_learn/data/local/lesson_mapper.dart';
import 'package:myanmar_kids_learn/domain/entities/lesson.dart';

void main() {
  const mapper = LessonMapper();

  test('maps a story JSON with pages, audio and a moral question', () {
    final lesson = mapper.fromJson(<String, dynamic>{
      'id': 'story_1',
      'type': 'story',
      'phase': 'manners',
      'title': 'ပုံပြင်',
      'subtitle': 'စာတန်းထိုး',
      'imageAsset': 'assets/images/story.svg',
      'audioAsset': 'assets/audio/story.ogg',
      'pages': [
        {
          'text': 'ပထမ စာမျက်နှာ',
          'imageAsset': 'assets/images/page.svg',
          'audioAsset': 'assets/audio/page.ogg',
        },
        {'text': 'ဒုတိယ စာမျက်နှာ'},
      ],
      'moralQuestion': {
        'id': 'q1',
        'prompt': 'ဘာလုပ်မလဲ?',
        'options': ['ကောင်းတာ', 'မကောင်းတာ'],
        'correctIndex': 0,
        'explanation': 'ကောင်းတာကို ရွေးပါ။',
      },
    });

    expect(lesson, isA<StoryLesson>());
    final story = lesson! as StoryLesson;
    expect(story.phase, LessonPhase.manners);
    expect(story.pages, hasLength(2));
    expect(story.pages.first.audioAsset, 'assets/audio/page.ogg');
    expect(story.pages.last.imageAsset, 'assets/images/story.svg');
    expect(story.pages.last.audioAsset, 'assets/audio/story.ogg');
    expect(story.moralQuestion.correctIndex, 0);
    expect(story.moralQuestion.options, hasLength(2));
  });

  test('maps a quiz JSON into an education lesson', () {
    final lesson = mapper.fromJson(<String, dynamic>{
      'id': 'quiz_1',
      'type': 'quiz',
      'phase': 'education',
      'title': 'ကျပ်ငွေ',
      'subtitle': 'ဈေးတန်း',
      'imageAsset': 'assets/images/market.svg',
      'questions': [
        {
          'id': 'q1',
          'prompt': 'ငှက်ပျောသီး ဘယ်လောက်လဲ?',
          'options': ['၅၀၀', '၁,၀၀၀'],
          'correctIndex': 1,
          'explanation': 'အဖြေမှာ ၁,၀၀၀ ဖြစ်တယ်။',
        },
      ],
    });

    expect(lesson, isA<QuizLesson>());
    final quiz = lesson! as QuizLesson;
    expect(quiz.phase, LessonPhase.education);
    expect(quiz.questions.single.isCorrect(1), isTrue);
  });

  test('maps a story_stream JSON into a StoryLesson with steps and simpleQuiz', () {
    final lesson = mapper.fromJson(<String, dynamic>{
      'id': 'manners_w1_ep01',
      'type': 'story_stream',
      'phase': 'good_manners',
      'world': 1,
      'episode': 1,
      'title_my': 'အပိုင်း (၁) - မနက်ခင်း မင်္ဂလာပါ',
      'title_en': 'Ep 1: Morning Greeting',
      'cover_image': 'assets/content/images/nono_bow.svg',
      'sticker_reward': 'sticker_w1_ep01_greeting',
      'stars_reward': 3,
      'story_stream': [
        {
          'step': 1,
          'kind': 'narration',
          'image': 'assets/content/images/nono_happy.svg',
          'audio': 'assets/content/audio/w1_ep01_s1.mp3',
          'text_my': 'မနက်မိုးလင်းတော့ နေရောင်ခြည်လေး ဝင်လာပါပြီ။',
        },
        {
          'step': 3,
          'kind': 'interactive_tap',
          'image': 'assets/content/images/nono_bow.svg',
          'audio': 'assets/content/audio/w1_ep01_s3.mp3',
          'text_my': 'ဆင်လေးနိုနိုကို နှိပ်ပေးပါဦး!',
          'action_label_my': 'မင်္ဂလာပါ အဘွား',
        },
      ],
      'simple_quiz': [
        {
          'prompt_my': 'မနက်ခင်းမှာ ဘာပြောပြီး နှုတ်ဆက်သလဲ?',
          'options': [
            {'image': 'assets/content/images/nono_bow.svg', 'text_my': 'မင်္ဂလာပါ', 'is_correct': true},
            {'image': 'assets/content/images/nono_sad.svg', 'text_my': 'ပုန်းနေမည်', 'is_correct': false},
          ],
          'encouragement_my': 'တော်လိုက်တာ!',
        },
      ],
    });

    expect(lesson, isA<StoryLesson>());
    final story = lesson! as StoryLesson;
    expect(story.id, 'manners_w1_ep01');
    expect(story.title, 'အပိုင်း (၁) - မနက်ခင်း မင်္ဂလာပါ');
    expect(story.stickerReward, 'sticker_w1_ep01_greeting');
    expect(story.steps, hasLength(2));
    expect(story.steps[1].isInteractiveTap, isTrue);
    expect(story.steps[1].actionLabelMy, 'မင်္ဂလာပါ အဘွား');
    expect(story.simpleQuiz.single.options.first.isCorrect, isTrue);
  });

  test('maps a kg_discover JSON into a QuizLesson with discoverCards and miniGame', () {
    final lesson = mapper.fromJson(<String, dynamic>{
      'id': 'edu_w1_ep01',
      'type': 'kg_discover',
      'phase': 'education',
      'world': 1,
      'episode': 1,
      'title_my': 'သင်ခန်းစာ (၁) - က နှင့် ခ',
      'title_en': 'Lesson 1: Letters က & ခ',
      'cover_image': 'assets/content/images/kg_ka_child.svg',
      'sticker_reward': 'sticker_kg_w1_ep01',
      'stars_reward': 3,
      'discover_cards': [
        {
          'letter': 'က',
          'word_my': 'ကလေး',
          'image': 'assets/content/images/kg_ka_child.svg',
          'audio': 'assets/content/audio/edu_w1_ep01_c1.mp3',
          'prompt_my': 'က — က — ကလေး။',
        },
        {
          'letter': 'ခ',
          'word_my': 'ခွေး',
          'image': 'assets/content/images/kg_kha_dog.svg',
          'audio': 'assets/content/audio/edu_w1_ep01_c2.mp3',
          'prompt_my': 'ခ — ခ — ခွေးလေး။',
        },
      ],
      'mini_game': [
        {
          'prompt_my': 'က ကြီး — ကလေး ပုံလေးကို ရွေးပေးပါဦး!',
          'options': [
            {'letter': 'က', 'word_my': 'ကလေး', 'image': 'assets/content/images/kg_ka_child.svg', 'is_correct': true},
            {'letter': 'ခ', 'word_my': 'ခွေး', 'image': 'assets/content/images/kg_kha_dog.svg', 'is_correct': false},
          ],
          'encouragement_my': 'တော်လိုက်တာ!',
        },
      ],
    });

    expect(lesson, isA<QuizLesson>());
    final quiz = lesson! as QuizLesson;
    expect(quiz.id, 'edu_w1_ep01');
    expect(quiz.isKgDiscover, isTrue);
    expect(quiz.discoverCards, hasLength(2));
    expect(quiz.discoverCards.first.letter, 'က');
    expect(quiz.miniGame.single.options.first.isCorrect, isTrue);
  });

  test('rejects malformed lessons instead of throwing', () {
    expect(mapper.fromJson(<String, dynamic>{}), isNull);
    expect(
      mapper.fromJson(<String, dynamic>{
        'id': 'bad',
        'type': 'story',
        'title': 'ခေါင်းစဉ်',
        'pages': [],
      }),
      isNull,
    );
    expect(
      mapper.fromJson(<String, dynamic>{
        'id': 'bad_quiz',
        'type': 'quiz',
        'title': 'ခေါင်းစဉ်',
        'questions': [
          {
            'prompt': 'မှားသော အဖြေညွှန်း',
            'options': ['က', 'ခ'],
            'correctIndex': 9,
          },
        ],
      }),
      isNull,
    );
  });
}
