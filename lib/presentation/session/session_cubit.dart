import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/child_profile.dart';

/// Remembers which local profile was tapped. Nothing is sent anywhere.
class SessionCubit extends Cubit<ChildProfile?> {
  SessionCubit() : super(null);

  void selectProfile(ChildProfile profile) => emit(profile);

  void clear() => emit(null);
}
