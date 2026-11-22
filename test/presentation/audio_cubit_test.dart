import 'package:flutter_test/flutter_test.dart';
import 'package:myanmar_kids_learn/presentation/manners_story/audio_cubit.dart';

import '../support/fakes.dart';

void main() {
  test('a missing audio file becomes a friendly unavailable state', () async {
    final service = FakeAudioPlayerService(ready: false);
    final cubit = AudioCubit(service);
    addTearDown(cubit.close);

    await cubit.load('assets/content/audio/missing.ogg');

    expect(cubit.state.status, AudioStatus.unavailable);
    expect(cubit.state.message, isNotNull);
    expect(service.playCount, 0);

    await cubit.toggle();
    expect(cubit.state.status, AudioStatus.unavailable);
  });

  test('a failing audio plugin is caught without throwing', () async {
    final service = FakeAudioPlayerService(prepareThrows: true);
    final cubit = AudioCubit(service);
    addTearDown(cubit.close);

    await cubit.load('assets/content/audio/broken.ogg');

    expect(cubit.state.status, AudioStatus.unavailable);
  });

  test('available audio can be played and paused', () async {
    final service = FakeAudioPlayerService();
    final cubit = AudioCubit(service);
    addTearDown(cubit.close);

    await cubit.load('assets/content/audio/manners_01.ogg');
    expect(cubit.state.status, AudioStatus.paused);
    expect(cubit.state.isAvailable, isTrue);

    await cubit.toggle();
    expect(cubit.state.isPlaying, isTrue);
    expect(service.playCount, 1);

    await cubit.toggle();
    expect(cubit.state.status, AudioStatus.paused);
    expect(service.pauseCount, 1);
  });

  test('null audio is unavailable without preparing the player', () async {
    final service = FakeAudioPlayerService();
    final cubit = AudioCubit(service);
    addTearDown(cubit.close);

    await cubit.load(null);

    expect(cubit.state.status, AudioStatus.unavailable);
    expect(service.playCount, 0);
  });

  test('closing disposes the player service', () async {
    final service = FakeAudioPlayerService();
    final cubit = AudioCubit(service);

    await cubit.close();

    expect(service.disposed, isTrue);
  });
}
