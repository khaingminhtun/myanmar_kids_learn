import '../../domain/entities/lesson.dart';
import '../../domain/repositories/content_repository.dart';
import '../local/asset_content_source.dart';

class ContentRepositoryImpl implements ContentRepository {
  ContentRepositoryImpl(this._source);

  final AssetContentSource _source;

  List<Lesson>? _cache;

  @override
  Future<List<Lesson>> loadLessons() async {
    return _cache ??= await _source.loadAll();
  }

  @override
  Future<Lesson?> lessonById(String id) async {
    final lessons = await loadLessons();
    for (final lesson in lessons) {
      if (lesson.id == id) return lesson;
    }
    return null;
  }
}
