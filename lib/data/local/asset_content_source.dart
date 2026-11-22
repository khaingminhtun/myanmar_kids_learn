import 'dart:convert';

import '../../core/utils/app_assets.dart';
import '../../core/utils/asset_loader.dart';
import '../../domain/entities/lesson.dart';
import 'lesson_mapper.dart';

/// Reads the seeded curriculum JSON from the app bundle. Everything is bundled
/// at build time, so this works in airplane mode.
class AssetContentSource {
  AssetContentSource({
    AssetLoader? loader,
    LessonMapper? mapper,
    List<String>? lessonPaths,
  })  : _loader = loader ?? AssetLoader(),
        _mapper = mapper ?? const LessonMapper(),
        _lessonPaths = lessonPaths ?? AppAssets.lessonPaths;

  final AssetLoader _loader;
  final LessonMapper _mapper;
  final List<String> _lessonPaths;

  List<Lesson>? _cache;

  Future<List<Lesson>> loadAll() async {
    final cached = _cache;
    if (cached != null) return cached;

    final lessons = <Lesson>[];
    for (final path in _lessonPaths) {
      final raw = await _loader.loadString(path);
      if (raw == null) continue;
      try {
        final decoded = jsonDecode(raw);
        if (decoded is! Map<String, dynamic>) continue;
        final lesson = _mapper.fromJson(decoded);
        if (lesson != null) lessons.add(lesson);
      } on FormatException {
        continue;
      }
    }

    _cache = List.unmodifiable(lessons);
    return _cache!;
  }
}
