import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myanmar_kids_learn/core/utils/asset_loader.dart';
import 'package:myanmar_kids_learn/data/local/asset_content_source.dart';

class _FakeAssetBundle extends CachingAssetBundle {
  _FakeAssetBundle(this.files);

  final Map<String, String> files;

  @override
  Future<ByteData> load(String key) async {
    final contents = files[key];
    if (contents == null) {
      throw FlutterError('Missing fake asset: $key');
    }
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(contents)));
  }
}

String _storyJson(String id) => jsonEncode(<String, dynamic>{
      'id': id,
      'type': 'story',
      'phase': 'manners',
      'title': 'ပုံပြင် $id',
      'subtitle': 'စာတန်းထိုး',
      'imageAsset': 'image.svg',
      'pages': [
        {'text': 'စာမျက်နှာ', 'imageAsset': 'image.svg'},
      ],
      'moralQuestion': {
        'prompt': 'မေးခွန်း',
        'options': ['က', 'ခ'],
        'correctIndex': 0,
      },
    });

void main() {
  test('loads valid JSON lessons and skips missing or invalid files', () async {
    final bundle = _FakeAssetBundle({
      'lessons/one.json': _storyJson('one'),
      'lessons/broken.json': '{not json',
    });
    final source = AssetContentSource(
      loader: AssetLoader(bundle),
      lessonPaths: [
        'lessons/one.json',
        'lessons/missing.json',
        'lessons/broken.json',
      ],
    );

    final lessons = await source.loadAll();

    expect(lessons, hasLength(1));
    expect(lessons.single.id, 'one');
  });

  test('caches the parsed lesson list', () async {
    final bundle = _FakeAssetBundle({
      'one.json': _storyJson('one'),
    });
    final source = AssetContentSource(
      loader: AssetLoader(bundle),
      lessonPaths: ['one.json'],
    );

    final first = await source.loadAll();
    final second = await source.loadAll();

    expect(identical(first, second), isTrue);
  });
}
