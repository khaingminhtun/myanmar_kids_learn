import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/child_profile.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileState extends Equatable {
  const ProfileState({
    this.loading = true,
    this.profiles = const [],
    this.creating = false,
    this.error,
  });

  final bool loading;
  final List<ChildProfile> profiles;
  final bool creating;
  final String? error;

  ProfileState copyWith({
    bool? loading,
    List<ChildProfile>? profiles,
    bool? creating,
    String? error,
  }) {
    return ProfileState(
      loading: loading ?? this.loading,
      profiles: profiles ?? this.profiles,
      creating: creating ?? this.creating,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [loading, profiles, creating, error];
}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repository) : super(const ProfileState());

  final ProfileRepository _repository;
  StreamSubscription<List<ChildProfile>>? _subscription;

  Future<void> start() async {
    emit(state.copyWith(loading: true, error: null));
    await _subscription?.cancel();
    _subscription = _repository.watchProfiles().listen(
      (profiles) {
        if (isClosed) return;
        emit(
          state.copyWith(
            loading: false,
            profiles: profiles,
            error: null,
          ),
        );
      },
      onError: (Object error) {
        if (isClosed) return;
        emit(
          state.copyWith(
            loading: false,
            error: 'ပရိုဖိုင်များကို ဖတ်၍ မရပါ။ ထပ်ကြိုးစားပါ။',
          ),
        );
      },
    );
  }

  Future<ChildProfile?> createProfile({
    required String name,
    required String avatarId,
  }) async {
    if (state.creating) return null;
    emit(state.copyWith(creating: true, error: null));
    try {
      final profile = await _repository.createProfile(
        name: name,
        avatarId: avatarId,
      );
      if (!isClosed) emit(state.copyWith(creating: false, error: null));
      return profile;
    } catch (_) {
      if (!isClosed) {
        emit(
          state.copyWith(
            creating: false,
            error: 'ပရိုဖိုင် ဖန်တီး၍ မရပါ။ ထပ်ကြိုးစားပါ။',
          ),
        );
      }
      return null;
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
