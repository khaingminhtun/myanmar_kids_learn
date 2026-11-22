import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/child_profile.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/lesson_progress.dart';
import '../../domain/repositories/content_repository.dart';
import '../../domain/repositories/progress_repository.dart';

class HomeState extends Equatable {
  const HomeState({
    this.loading = true,
    this.profile,
    this.mannersLessons = const [],
    this.educationLessons = const [],
    this.progressByLesson = const {},
    this.unlockedStickers = const [],
    this.error,
  });

  static const Object _unset = Object();

  final bool loading;
  final ChildProfile? profile;
  final List<Lesson> mannersLessons;
  final List<Lesson> educationLessons;
  final Map<String, LessonProgress> progressByLesson;
  final List<String> unlockedStickers;
  final String? error;

  int get totalStars => progressByLesson.values.fold(
        0,
        (sum, progress) => sum + progress.stars,
      );

  bool isCompleted(String lessonId) =>
      progressByLesson[lessonId]?.completed ?? false;

  int starsFor(String lessonId) => progressByLesson[lessonId]?.stars ?? 0;

  bool isStickerUnlocked(String? stickerId) {
    if (stickerId == null || stickerId.isEmpty) return false;
    return unlockedStickers.contains(stickerId);
  }

  HomeState copyWith({
    bool? loading,
    ChildProfile? profile,
    List<Lesson>? mannersLessons,
    List<Lesson>? educationLessons,
    Map<String, LessonProgress>? progressByLesson,
    List<String>? unlockedStickers,
    Object? error = _unset,
  }) {
    return HomeState(
      loading: loading ?? this.loading,
      profile: profile ?? this.profile,
      mannersLessons: mannersLessons ?? this.mannersLessons,
      educationLessons: educationLessons ?? this.educationLessons,
      progressByLesson: progressByLesson ?? this.progressByLesson,
      unlockedStickers: unlockedStickers ?? this.unlockedStickers,
      error: identical(error, _unset) ? this.error : error as String?,
    );
  }

  @override
  List<Object?> get props => [
        loading,
        profile,
        mannersLessons,
        educationLessons,
        progressByLesson,
        unlockedStickers,
        error,
      ];
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required ChildProfile profile,
    required this.contentRepository,
    required this.progressRepository,
  }) : super(HomeState(profile: profile));

  final ContentRepository contentRepository;
  final ProgressRepository progressRepository;
  StreamSubscription<List<LessonProgress>>? _progressSubscription;
  StreamSubscription<List<String>>? _stickersSubscription;

  Future<void> start() async {
    final profile = state.profile;
    if (profile == null) {
      emit(state.copyWith(loading: false, error: 'ပရိုဖိုင် မတွေ့ပါ။'));
      return;
    }

    emit(state.copyWith(loading: true, error: null));
    try {
      final lessons = await contentRepository.loadLessons();
      if (isClosed) return;

      final manners = lessons
          .where((lesson) => lesson.phase == LessonPhase.manners)
          .toList()
        ..sort((a, b) => a.episode.compareTo(b.episode));

      final education = lessons
          .where((lesson) => lesson.phase == LessonPhase.education)
          .toList()
        ..sort((a, b) => a.episode.compareTo(b.episode));

      emit(
        state.copyWith(
          loading: false,
          mannersLessons: manners,
          educationLessons: education,
          error: null,
        ),
      );

      await _progressSubscription?.cancel();
      _progressSubscription =
          progressRepository.watchProgress(profile.id).listen(
        (rows) {
          if (isClosed) return;
          emit(
            state.copyWith(
              progressByLesson: {
                for (final row in rows) row.lessonId: row,
              },
              error: null,
            ),
          );
        },
        onError: (Object error) {
          if (isClosed) return;
          emit(
            state.copyWith(
              error: 'တိုးတက်မှုကို ဖတ်၍ မရပါ။ ထပ်ကြိုးစားပါ။',
            ),
          );
        },
      );

      await _stickersSubscription?.cancel();
      _stickersSubscription =
          progressRepository.watchUnlockedStickers(profile.id).listen(
        (stickers) {
          if (isClosed) return;
          emit(state.copyWith(unlockedStickers: stickers));
        },
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          loading: false,
          error: 'သင်ခန်းစာများ ဖွင့်၍ မရပါ။ ထပ်ကြိုးစားပါ။',
        ),
      );
    }
  }

  Future<void> retry() => start();

  @override
  Future<void> close() async {
    await _progressSubscription?.cancel();
    await _stickersSubscription?.cancel();
    return super.close();
  }
}
