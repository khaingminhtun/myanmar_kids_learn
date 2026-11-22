import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/burmese_numbers.dart';
import '../../core/widgets/avatar_badge.dart';
import '../../core/widgets/safe_svg.dart';
import '../../core/widgets/star_pill.dart';
import '../../core/widgets/warm_background.dart';
import '../../domain/entities/child_profile.dart';
import '../../domain/entities/lesson.dart';
import '../session/session_cubit.dart';
import 'home_cubit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openLesson(BuildContext context, Lesson lesson) {
    if (lesson is StoryLesson) {
      context.push('/story/${lesson.id}');
    } else if (lesson is QuizLesson) {
      context.push('/quiz/${lesson.id}');
    }
  }

  Future<void> _shareOffline(BuildContext context) async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          title: 'မြန်မာ ကလေးများ',
          subject: 'အော့ဖ်လိုင်း သင်ယူရေး APK',
          text: 'မြန်မာ ကလေးများ — အော့ဖ်လိုင်း သင်ယူရေး နှင့် အမူအကျင့် အက်ပ်\n'
              'အင်တာနက် မလိုဘဲ အသုံးပြုနိုင်ပါတယ်။ APK ဖိုင်ကို ဒီစက်မှ တိုက်ရိုက် မျှဝေနိုင်ပါတယ်။',
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('မျှဝေမှု မရနိုင်ပါ။ ထပ်ကြိုးစားပါ။')),
      );
    }
  }

  void _switchProfile(BuildContext context) {
    context.read<SessionCubit>().clear();
    context.go('/profiles');
  }

  void _openStickerAlbum(BuildContext context, HomeState state) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _StickerAlbumSheet(state: state),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WarmBackground(
        child: SafeArea(
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              final hasLessons =
                  state.mannersLessons.isNotEmpty || state.educationLessons.isNotEmpty;

              if (state.loading && !hasLessons) {
                return const _HomeLoading();
              }
              if (state.error != null && !hasLessons) {
                return _HomeError(
                  message: state.error!,
                  onRetry: () => context.read<HomeCubit>().retry(),
                );
              }

              return RefreshIndicator(
                onRefresh: () => context.read<HomeCubit>().retry(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  children: [
                    _HomeHeader(
                      profile: state.profile,
                      totalStars: state.totalStars,
                      unlockedStickersCount: state.unlockedStickers.length,
                      onSwitchProfile: () => _switchProfile(context),
                      onOpenStickerAlbum: () => _openStickerAlbum(context, state),
                    ),
                    if (state.error != null) ...[
                      const SizedBox(height: 14),
                      _InlineError(message: state.error!),
                    ],
                    const SizedBox(height: 16),

                    // Good Manners Phase
                    _PhaseHeader(
                      number: '၁',
                      title: 'ကောင်းမွန်သော အမူအကျင့်များ',
                      subtitle:
                          'ပုံပြင် ${BurmeseNumbers.of(state.mannersLessons.length)} ခု — '
                          'မနက်ခင်း နှုတ်ဆက်ခြင်းမှ အိပ်ရာဝင်ချိန်ထိ',
                      color: AppColors.teal,
                      icon: Icons.auto_stories_rounded,
                    ),
                    const SizedBox(height: 10),
                    if (state.mannersLessons.isEmpty)
                      const _EmptyLessons(message: 'ပုံပြင်များ မရှိသေးပါ။')
                    else
                      for (final lesson in state.mannersLessons) ...[
                        _LessonCard(
                          lesson: lesson,
                          stars: state.starsFor(lesson.id),
                          completed: state.isCompleted(lesson.id),
                          hasSticker: state.isStickerUnlocked(lesson.stickerReward),
                          onTap: () => _openLesson(context, lesson),
                        ),
                        const SizedBox(height: 10),
                      ],
                    const SizedBox(height: 12),

                    // KG Education Phase
                    _PhaseHeader(
                      number: '၂',
                      title: 'ပညာရေး ဂိမ်းများ',
                      subtitle:
                          'ဂိမ်း ${BurmeseNumbers.of(state.educationLessons.length)} ခု — '
                          'KG မြန်မာ အက္ခရာ က မှ ည အထိ',
                      color: AppColors.purple,
                      icon: Icons.calculate_rounded,
                    ),
                    const SizedBox(height: 12),
                    if (state.educationLessons.isEmpty)
                      const _EmptyLessons(message: 'ဂိမ်းများ မရှိသေးပါ။')
                    else
                      for (final lesson in state.educationLessons) ...[
                        _LessonCard(
                          lesson: lesson,
                          stars: state.starsFor(lesson.id),
                          completed: state.isCompleted(lesson.id),
                          hasSticker: state.isStickerUnlocked(lesson.stickerReward),
                          onTap: () => _openLesson(context, lesson),
                        ),
                        const SizedBox(height: 12),
                      ],
                    const SizedBox(height: 20),
                    _ShareCard(onShare: () => _shareOffline(context)),
                    const SizedBox(height: 18),
                    Center(
                      child: Text(
                        'ကြယ်များနှင့် စတစ်ကာများ စုဆောင်းပြီး နေ့တိုင်း သင်ယူရအောင်!',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.profile,
    required this.totalStars,
    required this.unlockedStickersCount,
    required this.onSwitchProfile,
    required this.onOpenStickerAlbum,
  });

  final ChildProfile? profile;
  final int totalStars;
  final int unlockedStickersCount;
  final VoidCallback onSwitchProfile;
  final VoidCallback onOpenStickerAlbum;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF4A261), Color(0xFFE76F51)],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.orangeDeep.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarBadge(
                avatarId: profile?.avatarId ?? 'elephant',
                size: 56,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'မင်္ဂလာပါ',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                    ),
                    Text(
                      profile?.name ?? 'ကလေး',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onSwitchProfile,
                tooltip: 'ပရိုဖိုင် ပြောင်းမယ်',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(48, 48),
                ),
                icon: const Icon(Icons.switch_account_rounded, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              StarPill(stars: totalStars, label: 'စုစုပေါင်း ကြယ်'),
              _StickerCountPill(
                count: unlockedStickersCount,
                onTap: onOpenStickerAlbum,
              ),
              const OfflineBadge(dark: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _StickerCountPill extends StatelessWidget {
  const _StickerCountPill({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 18, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                'စတစ်ကာ ${BurmeseNumbers.of(count)} ခု',
                style: const TextStyle(
                  fontFamily: 'NotoSansMyanmar',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhaseHeader extends StatelessWidget {
  const _PhaseHeader({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  final String number;
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 27),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'အဆင့် $number',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({
    required this.lesson,
    required this.stars,
    required this.completed,
    this.hasSticker = false,
    required this.onTap,
  });

  final Lesson lesson;
  final int stars;
  final bool completed;
  final bool hasSticker;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${lesson.title} သင်ခန်းစာ ဖွင့်မယ်',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: completed
                    ? AppColors.green.withValues(alpha: 0.65)
                    : Colors.white,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: 0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: SizedBox(
                    width: 90,
                    height: 90,
                    child: ColoredBox(
                      color: AppColors.cream,
                      child: SafeSvg(
                        lesson.imageAsset,
                        fit: BoxFit.contain,
                        semanticsLabel: '${lesson.title} ပုံ',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              lesson.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          if (completed)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.green.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Icon(
                                Icons.check_circle_rounded,
                                size: 20,
                                color: AppColors.green,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lesson.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          StarPill(stars: stars, compact: true),
                          if (hasSticker) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.auto_awesome_rounded,
                              size: 16,
                              color: AppColors.sun,
                            ),
                          ],
                          const Spacer(),
                          Text(
                            completed ? 'ပြီးဆုံး' : 'စတင်မယ်',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: completed
                                      ? AppColors.green
                                      : AppColors.orangeDeep,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 22,
                            color: completed
                                ? AppColors.green
                                : AppColors.orangeDeep,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShareCard extends StatelessWidget {
  const _ShareCard({required this.onShare});

  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.teal.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.offline_share_rounded,
                  color: AppColors.teal,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'အော့ဖ်လိုင်း မျှဝေခြင်း',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'အင်တာနက် မလိုဘဲ အခြားစက်များသို့ မျှဝေနိုင်သည်',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onShare,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.teal,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.share_rounded, size: 20),
              label: const Text(
                'အော့ဖ်လိုင်း APK မျှဝေမယ်',
                style: TextStyle(
                  fontFamily: 'NotoSansMyanmar',
                  fontSize: 15,
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

class _StickerAlbumSheet extends StatelessWidget {
  const _StickerAlbumSheet({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final allLessons = [...state.mannersLessons, ...state.educationLessons];

    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      maxChildSize: 0.94,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.inkSoft.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'စတစ်ကာ အယ်လ်ဘမ်',
                          style: TextStyle(
                            fontFamily: 'NotoSansMyanmar',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink,
                          ),
                        ),
                        Text(
                          'ရရှိထားသော စတစ်ကာ: ${BurmeseNumbers.of(state.unlockedStickers.length)} ခု',
                          style: const TextStyle(
                            fontFamily: 'NotoSansMyanmar',
                            fontSize: 14,
                            color: AppColors.inkSoft,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, size: 26),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(18),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.88,
                  ),
                  itemCount: allLessons.length,
                  itemBuilder: (context, index) {
                    final lesson = allLessons[index];
                    final isUnlocked =
                        state.isStickerUnlocked(lesson.stickerReward);

                    return _StickerItemCard(
                      lesson: lesson,
                      isUnlocked: isUnlocked,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StickerItemCard extends StatelessWidget {
  const _StickerItemCard({
    required this.lesson,
    required this.isUnlocked,
  });

  final Lesson lesson;
  final bool isUnlocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isUnlocked ? Colors.white : AppColors.card.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUnlocked
              ? AppColors.sun
              : AppColors.inkSoft.withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: AppColors.sun.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: isUnlocked
                ? SafeSvg(lesson.imageAsset, fit: BoxFit.contain)
                : Opacity(
                    opacity: 0.35,
                    child: SafeSvg(lesson.imageAsset, fit: BoxFit.contain),
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            lesson.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'NotoSansMyanmar',
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: isUnlocked ? AppColors.ink : AppColors.inkSoft,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isUnlocked ? Icons.verified_rounded : Icons.lock_outline_rounded,
                size: 14,
                color: isUnlocked ? AppColors.teal : AppColors.inkSoft,
              ),
              const SizedBox(width: 4),
              Text(
                isUnlocked ? 'ရရှိပြီး' : 'သော့ခတ်ထားဆဲ',
                style: TextStyle(
                  fontFamily: 'NotoSansMyanmar',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isUnlocked ? AppColors.teal : AppColors.inkSoft,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeLoading extends StatelessWidget {
  const _HomeLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _HomeError extends StatelessWidget {
  const _HomeError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 56, color: AppColors.orangeDeep),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('ပြန်လည် ကြိုးစားမည်'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.pink.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppColors.orangeDeep, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: 'NotoSansMyanmar',
                fontSize: 13,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyLessons extends StatelessWidget {
  const _EmptyLessons({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(
            fontFamily: 'NotoSansMyanmar',
            color: AppColors.inkSoft,
          ),
        ),
      ),
    );
  }
}
