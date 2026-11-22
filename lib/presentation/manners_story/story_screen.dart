import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/app_assets.dart';
import '../../core/utils/burmese_numbers.dart';
import '../../core/widgets/safe_svg.dart';
import '../../core/widgets/star_pill.dart';
import '../../core/widgets/warm_background.dart';
import '../widgets/animated_scene_stage.dart';
import '../widgets/guided_teacher_bar.dart';
import 'audio_cubit.dart';
import 'story_cubit.dart';

class StoryScreen extends StatelessWidget {
  const StoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<StoryCubit, StoryState>(
      listenWhen: (previous, current) =>
          current.lesson != null &&
          (previous.lesson == null ||
              previous.pageIndex != current.pageIndex ||
              previous.currentAudioAsset != current.currentAudioAsset),
      listener: (context, state) {
        context.read<AudioCubit>().load(state.currentAudioAsset);
      },
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<StoryCubit, StoryState>(
            builder: (context, state) => Text(
              state.lesson?.title ?? 'အမူအကျင့် ပုံပြင်',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 14),
              child: StarPill(stars: 3),
            ),
          ],
        ),
        body: WarmBackground(
          child: SafeArea(
            top: false,
            child: BlocBuilder<StoryCubit, StoryState>(
              builder: (context, state) {
                if (state.loading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (state.error != null && state.lesson == null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              size: 48, color: AppColors.orangeDeep),
                          const SizedBox(height: 12),
                          Text(state.error!,
                              style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () =>
                                context.read<StoryCubit>().retry(),
                            child: const Text('ပြန်လည် ကြိုးစားမည်'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final lesson = state.lesson;
                if (lesson == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Column(
                  children: [
                    // Teacher Bar
                    BlocBuilder<AudioCubit, AudioState>(
                      builder: (context, audioState) {
                        final mood = state.isCorrect
                            ? TeacherMood.celebrate
                            : state.isWiggling
                                ? TeacherMood.retry
                                : TeacherMood.idle;

                        return GuidedTeacherBar(
                          message: state.currentPrompt,
                          mood: mood,
                          character: state.isWiggling
                              ? TeacherCharacter.jiji
                              : TeacherCharacter.mimi,
                          isPlayingAudio: audioState.isPlaying,
                          onReplayAudio: () {
                            final audioCubit = context.read<AudioCubit>();
                            if (audioState.isPlaying) {
                              audioCubit.stop();
                            } else {
                              audioCubit.toggle();
                            }
                          },
                        );
                      },
                    ),

                    // Progress indicator
                    _StoryProgress(state: state),

                    // Main stage
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(18, 6, 18, 16),
                        child: state.isQuestion
                            ? _QuizView(state: state)
                            : _StreamStepView(state: state),
                      ),
                    ),

                    // Bottom navigation
                    _StoryNavigation(state: state),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _StoryProgress extends StatelessWidget {
  const _StoryProgress({required this.state});

  final StoryState state;

  @override
  Widget build(BuildContext context) {
    final total = state.stepCount == 0 ? 1 : state.stepCount;
    final value = ((state.pageIndex + 1) / total).clamp(0.0, 1.0);
    final label = state.isQuestion
        ? 'မေးခွန်း အဖြေရှာမည်'
        : 'အဆင့် ${BurmeseNumbers.of(state.pageIndex + 1)} / ${BurmeseNumbers.of(total)}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'NotoSansMyanmar',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.inkSoft,
                ),
              ),
              if (state.lesson?.stickerReward != null)
                Text(
                  'စတစ်ကာ ဆုလာဘ် ✨',
                  style: TextStyle(
                    fontFamily: 'NotoSansMyanmar',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.orangeDeep,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 7,
              backgroundColor: AppColors.orange.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation(AppColors.orange),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreamStepView extends StatelessWidget {
  const _StreamStepView({required this.state});

  final StoryState state;

  @override
  Widget build(BuildContext context) {
    final step = state.currentStep;
    final page = state.currentPage;

    final image = step?.image ?? page?.imageAsset ?? AppAssets.nonoBow;
    final isInteractive = step?.isInteractiveTap ?? false;
    final actionLabel = step?.actionLabelMy ?? 'နှိပ်ပေးပါ';

    return Column(
      children: [
        // Scene Stage
        AnimatedSceneStage(
          onTap: isInteractive
              ? () => context.read<StoryCubit>().tapInteractive()
              : null,
          child: SizedBox(
            height: 220,
            width: double.infinity,
            child: SafeSvg(
              image,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Interactive Button if Step 3
        if (isInteractive) ...[
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: FilledButton.icon(
              onPressed: () => context.read<StoryCubit>().tapInteractive(),
              style: FilledButton.styleFrom(
                backgroundColor: state.hasTappedInteractive
                    ? AppColors.teal
                    : AppColors.orangeDeep,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: Icon(
                state.hasTappedInteractive
                    ? Icons.check_circle_rounded
                    : Icons.touch_app_rounded,
                size: 28,
              ),
              label: Text(
                actionLabel,
                style: const TextStyle(
                  fontFamily: 'NotoSansMyanmar',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (!state.hasTappedInteractive)
            const Text(
              'ရှေ့ဆက်ရန် အပေါ်မှ ခလုတ်ကို နှိပ်ပါ 👆',
              style: TextStyle(
                fontFamily: 'NotoSansMyanmar',
                fontSize: 13.5,
                color: AppColors.orangeDeep,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ],
    );
  }
}

class _QuizView extends StatelessWidget {
  const _QuizView({required this.state});

  final StoryState state;

  @override
  Widget build(BuildContext context) {
    if (state.isCorrect) {
      return _CelebrationView(state: state);
    }

    final simpleQuiz = state.currentSimpleQuiz;
    final moral = state.moralQuestion;

    if (simpleQuiz != null && simpleQuiz.options.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < simpleQuiz.options.length; i++) ...[
            _QuizOptionCard(
              index: i,
              image: simpleQuiz.options[i].image,
              text: simpleQuiz.options[i].textMy,
              isSelected: state.selectedIndex == i,
              isWiggling: state.isWiggling && state.selectedIndex == i,
              onTap: state.answered && state.isCorrect
                  ? null
                  : () => context.read<StoryCubit>().answerMoral(i),
            ),
            const SizedBox(height: 12),
          ],
        ],
      );
    }

    // Fallback moral question
    final options = moral?.options ?? const ['မှန်ပါသည်', 'မဟုတ်ပါ'];
    return Column(
      children: [
        for (var i = 0; i < options.length; i++) ...[
          _QuizOptionCard(
            index: i,
            text: options[i],
            isSelected: state.selectedIndex == i,
            isWiggling: state.isWiggling && state.selectedIndex == i,
            onTap: state.answered && state.isCorrect
                ? null
                : () => context.read<StoryCubit>().answerMoral(i),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _QuizOptionCard extends StatelessWidget {
  const _QuizOptionCard({
    required this.index,
    this.image,
    required this.text,
    required this.isSelected,
    required this.isWiggling,
    required this.onTap,
  });

  final int index;
  final String? image;
  final String text;
  final bool isSelected;
  final bool isWiggling;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedSceneStage(
      onTap: onTap,
      isWiggling: isWiggling,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderColor: isSelected
          ? AppColors.orangeDeep
          : AppColors.orange.withValues(alpha: 0.3),
      child: Row(
        children: [
          if (image != null && image!.isNotEmpty) ...[
            SizedBox(
              width: 58,
              height: 58,
              child: SafeSvg(image!, fit: BoxFit.contain),
            ),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'NotoSansMyanmar',
                fontSize: 16,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            isSelected
                ? Icons.radio_button_checked_rounded
                : Icons.radio_button_off_rounded,
            color: isSelected ? AppColors.orangeDeep : AppColors.inkSoft,
          ),
        ],
      ),
    );
  }
}

class _CelebrationView extends StatelessWidget {
  const _CelebrationView({required this.state});

  final StoryState state;

  @override
  Widget build(BuildContext context) {
    final nextEpisode = (state.lesson?.episode ?? 1) + 1;
    final nextId = nextEpisode <= 10
        ? 'manners_w1_ep${nextEpisode.toString().padLeft(2, '0')}'
        : null;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 150,
            child: SafeSvg(
              AppAssets.mimiCelebrate,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 14),
          const StarPill(stars: 3),
          const SizedBox(height: 12),
          Text(
            'ဂုဏ်ယူပါတယ် သားသား/မီးမီး!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.teal,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            state.stickerUnlocked
                ? 'စတစ်ကာ အသစ်တစ်ခု ရရှိပြီးပါပြီ! 🌟'
                : 'သင်ခန်းစာ ပြီးဆုံးပါပြီ!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'NotoSansMyanmar',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.inkSoft,
            ),
          ),
          const SizedBox(height: 24),
          if (nextId != null) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => context.go('/story/$nextId'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                icon: const Icon(Icons.skip_next_rounded),
                label: const Text(
                  'နောက်တစ်ပုဒ် ဆက်သင်မယ်',
                  style: TextStyle(
                    fontFamily: 'NotoSansMyanmar',
                    fontSize: 16.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.go('/home'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: const Icon(Icons.home_rounded),
              label: const Text(
                'ပင်မစာမျက်နှာသို့ ပြန်မယ်',
                style: TextStyle(
                  fontFamily: 'NotoSansMyanmar',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryNavigation extends StatelessWidget {
  const _StoryNavigation({required this.state});

  final StoryState state;

  @override
  Widget build(BuildContext context) {
    if (state.isCorrect) {
      return const SizedBox.shrink();
    }

    final step = state.currentStep;
    final isInteractiveLocked =
        step != null && step.isInteractiveTap && !state.hasTappedInteractive;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          if (state.pageIndex > 0 && !state.isQuestion) ...[
            OutlinedButton.icon(
              onPressed: () => context.read<StoryCubit>().previousPage(),
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('နောက်သို့'),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: state.isQuestion
                ? (state.answered && !state.isCorrect)
                    ? FilledButton.icon(
                        onPressed: () =>
                            context.read<StoryCubit>().retryMoral(),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.orangeDeep,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('ထပ်ကြိုးစားမယ်'),
                      )
                    : const SizedBox.shrink()
                : FilledButton.icon(
                    onPressed: isInteractiveLocked
                        ? null
                        : () => context.read<StoryCubit>().nextPage(),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(
                      state.isLastStoryPage ? 'မေးခွန်းသို့' : 'ရှေ့သို့',
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
