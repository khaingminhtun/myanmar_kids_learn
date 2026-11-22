import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/app_assets.dart';
import '../../core/utils/burmese_numbers.dart';
import '../../core/widgets/safe_svg.dart';
import '../../core/widgets/star_pill.dart';
import '../../core/widgets/warm_background.dart';
import '../../domain/entities/lesson.dart';
import '../manners_story/audio_cubit.dart';
import '../widgets/animated_scene_stage.dart';
import '../widgets/guided_teacher_bar.dart';
import 'quiz_cubit.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<QuizCubit, QuizState>(
      listenWhen: (previous, current) =>
          current.isDiscoverMode &&
          current.currentCard != null &&
          (previous.currentCard != current.currentCard ||
              previous.selectedCardIndex != current.selectedCardIndex),
      listener: (context, state) {
        if (state.currentAudioAsset != null) {
          context.read<AudioCubit>().load(state.currentAudioAsset);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<QuizCubit, QuizState>(
            builder: (context, state) => Text(
              state.lesson?.title ?? 'သင်ခန်းစာ',
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
            child: BlocBuilder<QuizCubit, QuizState>(
              builder: (context, state) {
                if (state.loading) {
                  return const Center(child: CircularProgressIndicator());
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
                                context.read<QuizCubit>().retry(),
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

                final mood = state.finished
                    ? TeacherMood.celebrate
                    : state.isWiggling
                        ? TeacherMood.retry
                        : TeacherMood.idle;

                return Column(
                  children: [
                    // Guided Teacher Bar
                    BlocBuilder<AudioCubit, AudioState>(
                      builder: (context, audioState) {
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
                              if (state.currentAudioAsset != null) {
                                audioCubit.load(state.currentAudioAsset).then(
                                  (_) => audioCubit.toggle(),
                                );
                              } else {
                                audioCubit.toggle();
                              }
                            }
                          },
                        );
                      },
                    ),

                    // Progress indicator
                    _QuizProgress(state: state),

                    // Main Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(18, 6, 18, 20),
                        child: state.finished
                            ? _QuizCelebration(state: state)
                            : state.isDiscoverMode
                                ? _DiscoverCardsView(state: state)
                                : _MiniGameView(state: state),
                      ),
                    ),

                    // Bottom navigation if in mini game or discover
                    if (!state.finished) _QuizBottomBar(state: state),
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

class _QuizProgress extends StatelessWidget {
  const _QuizProgress({required this.state});

  final QuizState state;

  @override
  Widget build(BuildContext context) {
    if (state.finished) return const SizedBox.shrink();

    final String label;
    final double value;

    if (state.isDiscoverMode) {
      final total = state.lesson?.discoverCards.length ?? 1;
      final tapped = state.tappedLetters.length;
      label =
          'လေ့လာပြီး: ${BurmeseNumbers.of(tapped)} / ${BurmeseNumbers.of(total)}';
      value = (tapped / total).clamp(0.0, 1.0);
    } else {
      final total = state.totalQuestions == 0 ? 1 : state.totalQuestions;
      label =
          'မေးခွန်း ${BurmeseNumbers.of(state.currentIndex + 1)} / ${BurmeseNumbers.of(total)}';
      value = ((state.currentIndex + 1) / total).clamp(0.0, 1.0);
    }

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
              if (state.isDiscoverMode && state.allCardsTapped)
                const Text(
                  'ဂိမ်းကစားနိုင်ပါပြီ 🎮',
                  style: TextStyle(
                    fontFamily: 'NotoSansMyanmar',
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.teal,
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
              backgroundColor: AppColors.teal.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation(AppColors.teal),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscoverCardsView extends StatelessWidget {
  const _DiscoverCardsView({required this.state});

  final QuizState state;

  @override
  Widget build(BuildContext context) {
    final cards = state.lesson?.discoverCards ?? const [];

    return Column(
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          _DiscoverCardItem(
            card: cards[i],
            isTapped: state.tappedLetters.contains(cards[i].letter),
            isSelected: state.selectedCardIndex == i,
            onTap: () {
              context.read<QuizCubit>().tapDiscoverCard(i);
              if (cards[i].audio != null) {
                final audio = context.read<AudioCubit>();
                audio.load(cards[i].audio).then((_) => audio.toggle());
              }
            },
          ),
          const SizedBox(height: 14),
        ],
        const SizedBox(height: 8),
        if (!state.allCardsTapped)
          const Text(
            'ဂိမ်းကစားရန် ကတ်အားလုံးကို အရင်နှိပ်၍ အသံနားထောင်ပါ 👆',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'NotoSansMyanmar',
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.orangeDeep,
            ),
          ),
      ],
    );
  }
}

class _DiscoverCardItem extends StatelessWidget {
  const _DiscoverCardItem({
    required this.card,
    required this.isTapped,
    required this.isSelected,
    required this.onTap,
  });

  final KgCard card;
  final bool isTapped;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedSceneStage(
      onTap: onTap,
      borderColor: isSelected ? AppColors.teal : null,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // Letter badge
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isTapped
                  ? AppColors.teal.withValues(alpha: 0.15)
                  : AppColors.sun.withValues(alpha: 0.3),
              border: Border.all(
                color: isTapped ? AppColors.teal : AppColors.sun,
                width: 2.5,
              ),
            ),
            child: Center(
              child: Text(
                card.letter,
                style: const TextStyle(
                  fontFamily: 'NotoSansMyanmar',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Illustration
          SizedBox(
            width: 70,
            height: 70,
            child: SafeSvg(card.image, fit: BoxFit.contain),
          ),
          const SizedBox(width: 14),

          // Word & Speaker
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.wordMy,
                  style: const TextStyle(
                    fontFamily: 'NotoSansMyanmar',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      isTapped
                          ? Icons.check_circle_rounded
                          : Icons.volume_up_rounded,
                      size: 18,
                      color: isTapped ? AppColors.teal : AppColors.orangeDeep,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isTapped ? 'နားထောင်ပြီး' : 'နှိပ်၍ နားထောင်ပါ',
                      style: TextStyle(
                        fontFamily: 'NotoSansMyanmar',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color:
                            isTapped ? AppColors.teal : AppColors.orangeDeep,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniGameView extends StatelessWidget {
  const _MiniGameView({required this.state});

  final QuizState state;

  @override
  Widget build(BuildContext context) {
    final mg = state.currentMiniGame;
    if (mg != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < mg.options.length; i++) ...[
            _MiniGameOptionCard(
              option: mg.options[i],
              isSelected: state.selectedIndex == i,
              isWiggling: state.isWiggling && state.selectedIndex == i,
              onTap: state.answered && state.isCorrect
                  ? null
                  : () => context.read<QuizCubit>().answer(i),
            ),
            const SizedBox(height: 14),
          ],
        ],
      );
    }

    // Fallback legacy questions
    final q = state.currentQuestion;
    if (q == null) return const SizedBox.shrink();

    return Column(
      children: [
        for (var i = 0; i < q.options.length; i++) ...[
          AnimatedSceneStage(
            onTap: state.answered && state.isCorrect
                ? null
                : () => context.read<QuizCubit>().answer(i),
            isWiggling: state.isWiggling && state.selectedIndex == i,
            child: ListTile(
              title: Text(
                q.options[i],
                style: const TextStyle(
                  fontFamily: 'NotoSansMyanmar',
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: Icon(
                state.selectedIndex == i
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: state.selectedIndex == i
                    ? AppColors.orangeDeep
                    : AppColors.inkSoft,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _MiniGameOptionCard extends StatelessWidget {
  const _MiniGameOptionCard({
    required this.option,
    required this.isSelected,
    required this.isWiggling,
    required this.onTap,
  });

  final KgMiniGameOption option;
  final bool isSelected;
  final bool isWiggling;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedSceneStage(
      onTap: onTap,
      isWiggling: isWiggling,
      padding: const EdgeInsets.all(14),
      borderColor: isSelected ? AppColors.teal : null,
      child: Row(
        children: [
          // Option Letter badge
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.cream,
              border: Border.all(color: AppColors.teal, width: 2),
            ),
            child: Center(
              child: Text(
                option.letter,
                style: const TextStyle(
                  fontFamily: 'NotoSansMyanmar',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Illustration
          SizedBox(
            width: 65,
            height: 65,
            child: SafeSvg(option.image, fit: BoxFit.contain),
          ),
          const SizedBox(width: 14),

          // Word text
          Expanded(
            child: Text(
              option.wordMy,
              style: const TextStyle(
                fontFamily: 'NotoSansMyanmar',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuizCelebration extends StatelessWidget {
  const _QuizCelebration({required this.state});

  final QuizState state;

  @override
  Widget build(BuildContext context) {
    final nextEpisode = (state.lesson?.episode ?? 1) + 1;
    final nextId = nextEpisode <= 10
        ? 'edu_w1_ep${nextEpisode.toString().padLeft(2, '0')}'
        : null;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 150,
            child: SafeSvg(AppAssets.mimiCelebrate, fit: BoxFit.contain),
          ),
          const SizedBox(height: 14),
          const StarPill(stars: 3),
          const SizedBox(height: 12),
          Text(
            'အရမ်းတော်တယ် သားသား/မီးမီး!',
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
                : 'သင်ခန်းစာ အောင်မြင်ပါပြီ!',
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
                onPressed: () => context.go('/quiz/$nextId'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                icon: const Icon(Icons.skip_next_rounded),
                label: const Text(
                  'နောက်သင်ခန်းစာ ဆက်သင်မယ်',
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

class _QuizBottomBar extends StatelessWidget {
  const _QuizBottomBar({required this.state});

  final QuizState state;

  @override
  Widget build(BuildContext context) {
    if (state.isDiscoverMode) {
      return Container(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
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
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: state.allCardsTapped
                ? () => context.read<QuizCubit>().startMiniGame()
                : null,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.teal,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            icon: const Icon(Icons.videogame_asset_rounded, size: 26),
            label: const Text(
              'ဂိမ်းကစားမယ်',
              style: TextStyle(
                fontFamily: 'NotoSansMyanmar',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    if (state.answered) {
      if (!state.isCorrect) {
        return Container(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
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
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => context.read<QuizCubit>().retryMiniGame(),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.orangeDeep,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(
                'ထပ်ကြိုးစားမယ်',
                style: TextStyle(
                  fontFamily: 'NotoSansMyanmar',
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }

      if (!state.isLastQuestion) {
        return Container(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
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
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => context.read<QuizCubit>().nextQuestion(),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.teal,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text(
                'နောက်မေးခွန်းသို့',
                style: TextStyle(
                  fontFamily: 'NotoSansMyanmar',
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }
    }

    return const SizedBox.shrink();
  }
}
