import '../entities/lesson.dart';

abstract interface class ContentRepository {
  Future<List<Lesson>> loadLessons();

  Future<Lesson?> lessonById(String id);
}
