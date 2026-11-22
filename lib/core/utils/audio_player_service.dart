import 'dart:async';

import 'package:just_audio/just_audio.dart';

import 'asset_loader.dart';

/// Thin, testable seam around just_audio. Every failure is swallowed and
/// reported as `false`/no-op so a missing or unplayable offline clip can never
/// crash the story reader.
abstract interface class AudioPlayerService {
  Future<bool> prepare(String assetPath);

  Future<void> play();

  Future<void> pause();

  Future<void> dispose();

  Stream<bool> get playingStream;
}

class JustAudioPlayerService implements AudioPlayerService {
  JustAudioPlayerService({AudioPlayer? player, AssetLoader? assetLoader})
      : _player = player ?? AudioPlayer(),
        _assetLoader = assetLoader ?? AssetLoader();

  final AudioPlayer _player;
  final AssetLoader _assetLoader;

  @override
  Stream<bool> get playingStream => _player.playingStream;

  @override
  Future<bool> prepare(String assetPath) async {
    try {
      if (!await _assetLoader.exists(assetPath)) return false;
      await _player.setAsset(assetPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> play() async {
    try {
      await _player.play();
    } catch (_) {
      // A missing/unplayable clip must stay silent, never throw.
    }
  }

  @override
  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (_) {
      // Ignore platform audio failures.
    }
  }

  @override
  Future<void> dispose() async {
    try {
      await _player.dispose();
    } catch (_) {
      // Ignore platform audio failures.
    }
  }
}
