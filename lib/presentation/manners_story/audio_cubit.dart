import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/audio_player_service.dart';

enum AudioStatus { idle, loading, playing, paused, unavailable }

class AudioState extends Equatable {
  const AudioState({
    this.status = AudioStatus.idle,
    this.assetPath,
    this.message,
  });

  static const Object _unset = Object();

  final AudioStatus status;
  final String? assetPath;
  final String? message;

  bool get isPlaying => status == AudioStatus.playing;
  bool get isLoading => status == AudioStatus.loading;
  bool get isUnavailable => status == AudioStatus.unavailable;
  bool get isAvailable =>
      status == AudioStatus.playing || status == AudioStatus.paused;

  AudioState copyWith({
    AudioStatus? status,
    String? assetPath,
    Object? message = _unset,
  }) {
    return AudioState(
      status: status ?? this.status,
      assetPath: assetPath ?? this.assetPath,
      message: identical(message, _unset) ? this.message : message as String?,
    );
  }

  @override
  List<Object?> get props => [status, assetPath, message];
}

/// Audio that degrades gracefully: missing .ogg files, plugin errors and
/// low-end devices simply show a friendly "no sound" state.
class AudioCubit extends Cubit<AudioState> {
  AudioCubit(this._service) : super(const AudioState());

  final AudioPlayerService _service;
  StreamSubscription<bool>? _playingSubscription;
  String? _currentPath;

  Future<void> load(String? assetPath) async {
    if (_currentPath == assetPath &&
        (state.isAvailable || state.isLoading)) {
      return;
    }
    _currentPath = assetPath;
    await _playingSubscription?.cancel();
    _playingSubscription = null;

    if (assetPath == null || assetPath.isEmpty) {
      emit(
        const AudioState(
          status: AudioStatus.unavailable,
          message: 'ဒီစာမျက်နှာမှာ အသံဖိုင် မပါပါ။',
        ),
      );
      return;
    }

    emit(AudioState(status: AudioStatus.loading, assetPath: assetPath));

    try {
      final ready = await _service.prepare(assetPath);
      if (isClosed) return;
      if (!ready) {
        emit(
          AudioState(
            status: AudioStatus.unavailable,
            assetPath: assetPath,
            message: 'အသံဖိုင် မရနိုင်ပါ။ စာဖတ်ပြီး ဆက်သင်ယူနိုင်ပါတယ်။',
          ),
        );
        return;
      }

      _playingSubscription = _service.playingStream.listen(
        (playing) {
          if (isClosed) return;
          emit(
            state.copyWith(
              status: playing ? AudioStatus.playing : AudioStatus.paused,
            ),
          );
        },
        onError: (Object error) {
          if (isClosed) return;
          emit(
            state.copyWith(
              status: AudioStatus.unavailable,
              message: 'အသံဖိုင် မရနိုင်ပါ။ စာဖတ်ပြီး ဆက်သင်ယူနိုင်ပါတယ်။',
            ),
          );
        },
      );

      emit(
        AudioState(
          status: AudioStatus.paused,
          assetPath: assetPath,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        AudioState(
          status: AudioStatus.unavailable,
          assetPath: assetPath,
          message: 'အသံဖိုင် မရနိုင်ပါ။ စာဖတ်ပြီး ဆက်သင်ယူနိုင်ပါတယ်။',
        ),
      );
    }
  }

  Future<void> toggle() async {
    if (state.status == AudioStatus.loading ||
        state.status == AudioStatus.unavailable ||
        state.status == AudioStatus.idle) {
      return;
    }

    try {
      if (state.isPlaying) {
        await _service.pause();
        if (!isClosed) emit(state.copyWith(status: AudioStatus.paused));
      } else {
        unawaited(
          _service.play().catchError((Object error) {
            if (!isClosed) {
              emit(
                state.copyWith(
                  status: AudioStatus.unavailable,
                  message:
                      'အသံဖိုင် မရနိုင်ပါ။ စာဖတ်ပြီး ဆက်သင်ယူနိုင်ပါတယ်။',
                ),
              );
            }
          }),
        );
        if (!isClosed) emit(state.copyWith(status: AudioStatus.playing));
      }
    } catch (_) {
      if (!isClosed) {
        emit(
          state.copyWith(
            status: AudioStatus.unavailable,
            message: 'အသံဖိုင် မရနိုင်ပါ။ စာဖတ်ပြီး ဆက်သင်ယူနိုင်ပါတယ်။',
          ),
        );
      }
    }
  }

  Future<void> stop() async {
    if (!state.isPlaying) return;
    try {
      await _service.pause();
      if (!isClosed) emit(state.copyWith(status: AudioStatus.paused));
    } catch (_) {
      // Stay silent.
    }
  }

  @override
  Future<void> close() async {
    await _playingSubscription?.cancel();
    await _service.dispose();
    return super.close();
  }
}
