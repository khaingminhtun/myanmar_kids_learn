import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myanmar_kids_learn/core/theme/app_theme.dart';
import 'package:myanmar_kids_learn/presentation/profiles/profile_cubit.dart';
import 'package:myanmar_kids_learn/presentation/profiles/profiles_screen.dart';
import 'package:myanmar_kids_learn/presentation/session/session_cubit.dart';

import '../support/fakes.dart';

void main() {
  testWidgets('shows the who-is-learning prompt and profile cards',
      (tester) async {
    final repository = FakeProfileRepository(initial: [testProfile]);
    final cubit = ProfileCubit(repository);
    addTearDown(() async {
      await cubit.close();
      await repository.dispose();
    });

    await cubit.start();
    await tester.pump();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: MultiBlocProvider(
          providers: [
            BlocProvider<ProfileCubit>.value(value: cubit),
            BlocProvider<SessionCubit>(create: (_) => SessionCubit()),
          ],
          child: const ProfilesScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.textContaining('ယနေ့ ဘယ်သူ'), findsOneWidget);
    expect(find.text(testProfile.name), findsOneWidget);
    expect(find.text('အသစ် ထည့်မယ်'), findsOneWidget);
    expect(find.text('သင်ယူမယ်'), findsOneWidget);
  });
}
