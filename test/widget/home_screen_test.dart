import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myanmar_kids_learn/core/theme/app_theme.dart';
import 'package:myanmar_kids_learn/domain/entities/lesson_progress.dart';
import 'package:myanmar_kids_learn/presentation/home/home_cubit.dart';
import 'package:myanmar_kids_learn/presentation/home/home_screen.dart';

import '../support/fakes.dart';

void main() {
  testWidgets('shows phases, lesson cards, stars and offline share button',
      (tester) async {
    final progress = FakeProgressRepository(
      initial: [
        LessonProgress(
          profileId: testProfile.id,
          lessonId: testStory.id,
          completed: true,
          stars: 3,
          updatedAt: DateTime(2026, 1, 1),
        ),
      ],
    );
    final cubit = HomeCubit(
      profile: testProfile,
      contentRepository: FakeContentRepository([testStory, testQuiz]),
      progressRepository: progress,
    );
    addTearDown(() async {
      await cubit.close();
      await progress.dispose();
    });

    await cubit.start();
    await tester.pump();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: BlocProvider<HomeCubit>.value(
          value: cubit,
          child: const HomeScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text(testProfile.name), findsOneWidget);
    expect(find.text('ကောင်းမွန်သော အမူအကျင့်များ'), findsOneWidget);
    expect(find.text('ပညာရေး ဂိမ်းများ'), findsOneWidget);
    expect(find.text(testStory.title), findsOneWidget);
    expect(find.text(testQuiz.title), findsOneWidget);
    expect(find.text('ပြီးဆုံး'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('အော့ဖ်လိုင်း APK မျှဝေမယ်'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('အော့ဖ်လိုင်း APK မျှဝေမယ်'), findsOneWidget);
  });
}
