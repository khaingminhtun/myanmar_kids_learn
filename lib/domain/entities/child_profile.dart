import 'package:equatable/equatable.dart';

/// A local child profile. There is deliberately no account, email, phone or
/// password anywhere in this model: a child simply taps an animal avatar.
class ChildProfile extends Equatable {
  const ChildProfile({
    required this.id,
    required this.name,
    required this.avatarId,
    required this.createdAt,
  });

  final int id;
  final String name;
  final String avatarId;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, name, avatarId, createdAt];
}
