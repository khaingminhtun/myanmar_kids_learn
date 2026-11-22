import 'dart:async';
import 'dart:math' as math;

import 'package:myanmar_kids_learn/core/utils/app_assets.dart';
import 'package:myanmar_kids_learn/core/utils/audio_player_service.dart';
import 'package:myanmar_kids_learn/domain/entities/child_profile.dart';
import 'package:myanmar_kids_learn/domain/entities/lesson.dart';
import 'package:myanmar_kids_learn/domain/entities/lesson_progress.dart';
import 'package:myanmar_kids_learn/domain/repositories/content_repository.dart';
import 'package:myanmar_kids_learn/domain/repositories/profile_repository.dart';
import 'package:myanmar_kids_learn/domain/repositories/progress_repository.dart';

final ChildProfile testProfile = ChildProfile(
  id: 1,
  name: 'မောင်မောင်',
  avatarId: 'tiger',
  createdAt: DateTime(2026, 1, 1),
);

final StoryLesson testStory = StoryLesson(
  id: 'manners_01_greeting',
  title: 'မင်္ဂလာပါ ပြောကြရအောင်',
  subtitle: 'ကြီးသူကို ရိုသေလေးစားခြင်း',
  imageAsset: AppAssets.mannersGreetingImage,
  audioAsset: 'assets/content/audio/manners_01.ogg',
  pages: const [
    StoryPage(
      text: 'မနက်ခင်း ကျောင်းတံခါးဝမှာ ဆရာမကြီးနဲ့ တွေ့ကြတယ်။',
      imageAsset: AppAssets.mannersGreetingImage,
      audioAsset: 'assets/content/audio/manners_01.ogg',
    ),
    StoryPage(
      text: 'သူတို့က ပြုံးပြီး “မင်္ဂလာပါ” လို့ နှုတ်ဆက်ကြတယ်။',
      imageAsset: AppAssets.mannersGreetingImage,
      audioAsset: 'assets/content/audio/manners_01.ogg',
    ),
    StoryPage(
      text: 'အဖိုးကို “မင်္ဂလာပါ အဖိုးရှင့်” လို့ နှုတ်ဆက်တယ်။',
      imageAsset: AppAssets.mannersGreetingImage,
      audioAsset: 'assets/content/audio/manners_01.ogg',
    ),
  ],
  moralQuestion: const QuizQuestion(
    id: 'manners_01_q1',
    prompt: 'အဖိုးအိမ်ထဲ ဝင်လာတဲ့အခါ သင်ဘာပြောမလဲ?',
    options: [
      'မင်္ဂလာပါ အဖိုးရှင့်',
      'ဘာလဲ အဖိုး',
      'မပြောဘဲ ဆက်ကစားမယ်',
    ],
    correctIndex: 0,
    explanation: 'ကြီးသူကို ယဉ်ကျေးစွာ နှုတ်ဆက်ပါ။',
    imageAsset: AppAssets.mannersGreetingImage,
  ),
);

final QuizLesson testQuiz = QuizLesson(
  id: 'education_01_kyat_math',
  title: 'ဈေးတန်း ကျပ်ငွေ သင်ခန်းစာ',
  subtitle: 'မြန်မာကျပ်ငွေ ရေတွက်ခြင်း',
  imageAsset: AppAssets.mathMarketImage,
  questions: const [
    QuizQuestion(
      id: 'kyat_q1',
      prompt: 'ငှက်ပျောသီးတစ်ဖီး ၅၀၀ ကျပ်။ နှစ်ဖီးဝယ်ရင် ဘယ်လောက်လဲ?',
      options: ['၅၀၀ ကျပ်', '၁,၀၀၀ ကျပ်', '၁,၅၀၀ ကျပ်'],
      correctIndex: 1,
      explanation: '၅၀၀ + ၅၀၀ = ၁,၀၀၀ ကျပ်။',
      imageAsset: AppAssets.mathMarketImage,
    ),
    QuizQuestion(
      id: 'kyat_q2',
      prompt: '၂,၀၀၀ ကျပ်ပေးပြီး ၁,၂၀၀ ကျပ်တန် မုန့်ဝယ်တယ်။ ပြန်အမ်းငွေ?',
      options: ['၆၀၀ ကျပ်', '၇၀၀ ကျပ်', '၈၀၀ ကျပ်'],
      correctIndex: 2,
      explanation: '၂,၀၀၀ − ၁,၂၀၀ = ၈၀၀ ကျပ်။',
      imageAsset: AppAssets.mathMarketImage,
    ),
  ],
);

class SavedResult {
  const SavedResult({
    required this.profileId,
    required this.lessonId,
    required this.stars,
    required this.completed,
  });

  final int profileId;
  final String lessonId;
  final int stars;
  final bool completed;
}

class FakeContentRepository implements ContentRepository {
  FakeContentRepository(this.lessons);

  final List<Lesson> lessons;
  int loadCount = 0;

  @override
  Future<List<Lesson>> loadLessons() async {
    loadCount++;
    return List.unmodifiable(lessons);
  }

  @override
  Future<Lesson?> lessonById(String id) async {
    for (final lesson in lessons) {
      if (lesson.id == id) return lesson;
    }
    return null;
  }
}

class FakeProgressRepository implements ProgressRepository {
  FakeProgressRepository({List<LessonProgress> initial = const []})
      : _current = List.of(initial);

  final List<SavedResult> saved = [];
  final Set<StreamController<List<LessonProgress>>> _controllers = {};
  List<LessonProgress> _current;

  @override
  Stream<List<LessonProgress>> watchProgress(int profileId) {
    final controller = StreamController<List<LessonProgress>>();
    controller.onListen =
        () => controller.add(List<LessonProgress>.unmodifiable(_current));
    controller.onCancel = () => _controllers.remove(controller);
    _controllers.add(controller);
    return controller.stream;
  }

  void _notify() {
    final snapshot = List<LessonProgress>.unmodifiable(_current);
    for (final controller in List.of(_controllers)) {
      if (!controller.isClosed) controller.add(snapshot);
    }
  }

  @override
  Future<List<LessonProgress>> getProgress(int profileId) async {
    return List.unmodifiable(_current);
  }

  @override
  Future<void> saveResult({
    required int profileId,
    required String lessonId,
    required int stars,
    required bool completed,
  }) async {
    saved.add(
      SavedResult(
        profileId: profileId,
        lessonId: lessonId,
        stars: stars,
        completed: completed,
      ),
    );

    final index = _current.indexWhere((row) => row.lessonId == lessonId);
    final existing = index == -1 ? null : _current[index];
    final merged = LessonProgress(
      profileId: profileId,
      lessonId: lessonId,
      completed: completed || (existing?.completed ?? false),
      stars: math.max(stars, existing?.stars ?? 0),
      updatedAt: DateTime(2026, 1, 2),
    );
    if (index == -1) {
      _current = [..._current, merged];
    } else {
      _current = [..._current]..[index] = merged;
    }
    _notify();
  }

  final List<String> unlockedStickers = [];
  final Set<StreamController<List<String>>> _stickerControllers = {};

  @override
  Future<void> unlockSticker({
    required int profileId,
    required String stickerId,
  }) async {
    if (!unlockedStickers.contains(stickerId)) {
      unlockedStickers.add(stickerId);
      final snapshot = List<String>.unmodifiable(unlockedStickers);
      for (final controller in List.of(_stickerControllers)) {
        if (!controller.isClosed) controller.add(snapshot);
      }
    }
  }

  @override
  Stream<List<String>> watchUnlockedStickers(int profileId) {
    final controller = StreamController<List<String>>();
    controller.onListen =
        () => controller.add(List<String>.unmodifiable(unlockedStickers));
    controller.onCancel = () => _stickerControllers.remove(controller);
    _stickerControllers.add(controller);
    return controller.stream;
  }

  @override
  Future<List<String>> getUnlockedStickers(int profileId) async {
    return List.unmodifiable(unlockedStickers);
  }

  Future<void> dispose() async {
    for (final controller in List.of(_controllers)) {
      unawaited(controller.close());
    }
    _controllers.clear();
    for (final controller in List.of(_stickerControllers)) {
      unawaited(controller.close());
    }
    _stickerControllers.clear();
  }
}

class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository({List<ChildProfile> initial = const []})
      : _current = List.of(initial) {
    _nextId = _current.fold<int>(
          0,
          (maxId, profile) => math.max(maxId, profile.id),
        ) +
        1;
  }

  final Set<StreamController<List<ChildProfile>>> _controllers = {};
  List<ChildProfile> _current;
  int _nextId = 1;

  @override
  Stream<List<ChildProfile>> watchProfiles() {
    final controller = StreamController<List<ChildProfile>>();
    controller.onListen =
        () => controller.add(List<ChildProfile>.unmodifiable(_current));
    controller.onCancel = () => _controllers.remove(controller);
    _controllers.add(controller);
    return controller.stream;
  }

  void _notify() {
    final snapshot = List<ChildProfile>.unmodifiable(_current);
    for (final controller in List.of(_controllers)) {
      if (!controller.isClosed) controller.add(snapshot);
    }
  }

  @override
  Future<List<ChildProfile>> getProfiles() async => List.unmodifiable(_current);

  @override
  Future<ChildProfile?> getProfile(int id) async {
    for (final profile in _current) {
      if (profile.id == id) return profile;
    }
    return null;
  }

  @override
  Future<ChildProfile> createProfile({
    required String name,
    required String avatarId,
  }) async {
    final trimmed = name.trim();
    final profile = ChildProfile(
      id: _nextId++,
      name: trimmed.isEmpty ? 'ကလေး' : trimmed,
      avatarId: avatarId,
      createdAt: DateTime(2026, 1, 1),
    );
    _current = [..._current, profile];
    _notify();
    return profile;
  }

  Future<void> dispose() async {
    for (final controller in List.of(_controllers)) {
      unawaited(controller.close());
    }
    _controllers.clear();
  }
}

class FakeAudioPlayerService implements AudioPlayerService {
  FakeAudioPlayerService({
    this.ready = true,
    this.prepareThrows = false,
    this.playThrows = false,
  });

  bool ready;
  bool prepareThrows;
  bool playThrows;

  final StreamController<bool> _playing =
      StreamController<bool>.broadcast();
  int playCount = 0;
  int pauseCount = 0;
  bool disposed = false;

  @override
  Stream<bool> get playingStream => _playing.stream;

  @override
  Future<bool> prepare(String assetPath) async {
    if (prepareThrows) throw StateError('prepare failed');
    return ready;
  }

  @override
  Future<void> play() async {
    playCount++;
    if (playThrows) throw StateError('play failed');
    _playing.add(true);
  }

  @override
  Future<void> pause() async {
    pauseCount++;
    _playing.add(false);
  }

  @override
  Future<void> dispose() async {
    disposed = true;
    await _playing.close();
  }
}
