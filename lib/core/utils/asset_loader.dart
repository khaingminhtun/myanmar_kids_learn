import 'package:flutter/services.dart';

/// Asset reads that never throw: a missing file simply returns null/false.
class AssetLoader {
  AssetLoader([AssetBundle? bundle]) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  Future<String?> loadString(String path) async {
    try {
      return await _bundle.loadString(path);
    } catch (_) {
      return null;
    }
  }

  Future<bool> exists(String path) async {
    try {
      await _bundle.load(path);
      return true;
    } catch (_) {
      return false;
    }
  }
}
