import 'package:flutter_test/flutter_test.dart';
import 'package:myanmar_kids_learn/presentation/profiles/profile_cubit.dart';

import '../support/fakes.dart';

void main() {
  late FakeProfileRepository repository;
  late ProfileCubit cubit;

  setUp(() {
    repository = FakeProfileRepository(initial: [testProfile]);
    cubit = ProfileCubit(repository);
  });

  tearDown(() async {
    await cubit.close();
    await repository.dispose();
  });

  test('streams local profiles on start', () async {
    await cubit.start();
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.loading, isFalse);
    expect(cubit.state.profiles, hasLength(1));
    expect(cubit.state.profiles.single.name, testProfile.name);
  });

  test('creates a profile with a safe default name', () async {
    await cubit.start();
    await Future<void>.delayed(Duration.zero);

    final created = await cubit.createProfile(name: '   ', avatarId: 'owl');
    await Future<void>.delayed(Duration.zero);

    expect(created, isNotNull);
    expect(created?.name, 'ကလေး');
    expect(created?.avatarId, 'owl');
    expect(cubit.state.profiles, hasLength(2));
    expect(cubit.state.creating, isFalse);
  });
}
