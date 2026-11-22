import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myanmar_kids_learn/core/theme/app_theme.dart';
import 'package:myanmar_kids_learn/presentation/widgets/animated_scene_stage.dart';
import 'package:myanmar_kids_learn/presentation/widgets/guided_teacher_bar.dart';

void main() {
  testWidgets('GuidedTeacherBar displays prompt, character and triggers audio replay',
      (tester) async {
    var audioToggled = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: GuidedTeacherBar(
            message: 'မင်္ဂလာပါ သားသားမီးမီးတို့ရေ!',
            mood: TeacherMood.idle,
            character: TeacherCharacter.mimi,
            onReplayAudio: () {
              audioToggled = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('မင်္ဂလာပါ သားသားမီးမီးတို့ရေ!'), findsOneWidget);
    expect(find.byType(GuidedTeacherBar), findsOneWidget);

    final replayBtn = find.byType(InkWell);
    expect(replayBtn, findsWidgets);

    await tester.tap(replayBtn.first);
    expect(audioToggled, isTrue);
  });

  testWidgets('AnimatedSceneStage renders child and handles tap bounce',
      (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AnimatedSceneStage(
            onTap: () {
              tapped = true;
            },
            child: const Text('စမ်းသပ်ကတ်'),
          ),
        ),
      ),
    );

    expect(find.text('စမ်းသပ်ကတ်'), findsOneWidget);
    await tester.tap(find.text('စမ်းသပ်ကတ်'));
    expect(tapped, isTrue);
  });
}
