import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myanmar_kids_learn/core/theme/app_theme.dart';
import 'package:myanmar_kids_learn/presentation/profiles/widgets/create_profile_sheet.dart';

void main() {
  testWidgets('creates a profile draft with the chosen avatar', (tester) async {
    ProfileDraft? draft;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () async {
                  draft = await showModalBottomSheet<ProfileDraft>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const CreateProfileSheet(),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('ကိုယ်ပိုင် ပရိုဖိုင် ဖန်တီးမယ်'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'သီတာ');
    await tester.tap(find.text('ဇီးကွက်'));
    await tester.pump();
    await tester.tap(find.text('ပရိုဖိုင် ဖန်တီးမယ်'));
    await tester.pumpAndSettle();

    expect(draft, isNotNull);
    expect(draft?.name, 'သီတာ');
    expect(draft?.avatarId, 'owl');
  });
}
