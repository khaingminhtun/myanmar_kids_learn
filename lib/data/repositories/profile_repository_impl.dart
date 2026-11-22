import 'package:drift/drift.dart';

import '../../domain/entities/child_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../local/app_database.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<List<ChildProfile>> watchProfiles() {
    final query = _db.select(_db.childProfiles)
      ..orderBy([(table) => OrderingTerm.asc(table.createdAt)]);
    return query.watch().map(
          (rows) => rows.map(_mapRow).toList(growable: false),
        );
  }

  @override
  Future<List<ChildProfile>> getProfiles() async {
    final query = _db.select(_db.childProfiles)
      ..orderBy([(table) => OrderingTerm.asc(table.createdAt)]);
    final rows = await query.get();
    return rows.map(_mapRow).toList(growable: false);
  }

  @override
  Future<ChildProfile?> getProfile(int id) async {
    final query = _db.select(_db.childProfiles)
      ..where((table) => table.id.equals(id));
    final row = await query.getSingleOrNull();
    return row == null ? null : _mapRow(row);
  }

  @override
  Future<ChildProfile> createProfile({
    required String name,
    required String avatarId,
  }) async {
    final trimmed = name.trim();
    final safeName = trimmed.isEmpty ? 'ကလေး' : trimmed;
    final id = await _db.into(_db.childProfiles).insert(
          ChildProfilesCompanion.insert(
            name: safeName,
            avatarId: avatarId,
          ),
        );
    final created = await getProfile(id);
    if (created != null) return created;
    return ChildProfile(
      id: id,
      name: safeName,
      avatarId: avatarId,
      createdAt: DateTime.now(),
    );
  }

  ChildProfile _mapRow(ChildProfileRow row) => ChildProfile(
        id: row.id,
        name: row.name,
        avatarId: row.avatarId,
        createdAt: row.createdAt,
      );
}
