import '../entities/child_profile.dart';

abstract interface class ProfileRepository {
  Stream<List<ChildProfile>> watchProfiles();

  Future<List<ChildProfile>> getProfiles();

  Future<ChildProfile?> getProfile(int id);

  Future<ChildProfile> createProfile({
    required String name,
    required String avatarId,
  });
}
