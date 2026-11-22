import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/avatar_catalog.dart';
import '../../core/widgets/avatar_badge.dart';
import '../../core/widgets/warm_background.dart';
import '../../domain/entities/child_profile.dart';
import '../session/session_cubit.dart';
import 'profile_cubit.dart';
import 'widgets/create_profile_sheet.dart';

class ProfilesScreen extends StatelessWidget {
  const ProfilesScreen({super.key});

  Future<void> _createProfile(BuildContext context) async {
    final draft = await showModalBottomSheet<ProfileDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateProfileSheet(),
    );
    if (draft == null || !context.mounted) return;

    final cubit = context.read<ProfileCubit>();
    final profile = await cubit.createProfile(
      name: draft.name,
      avatarId: draft.avatarId,
    );
    if (!context.mounted) return;
    if (profile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            cubit.state.error ?? 'ပရိုဖိုင် ဖန်တီး၍ မရပါ။ ထပ်ကြိုးစားပါ။',
          ),
        ),
      );
      return;
    }

    context.read<SessionCubit>().selectProfile(profile);
    context.go('/home');
  }

  void _startProfile(BuildContext context, ChildProfile profile) {
    context.read<SessionCubit>().selectProfile(profile);
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WarmBackground(
        child: SafeArea(
          child: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              return RefreshIndicator(
                onRefresh: () => context.read<ProfileCubit>().start(),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
                  children: [
                    const _ProfilesHeader(),
                    const SizedBox(height: 22),
                    if (state.loading && state.profiles.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 18),
                        child: LinearProgressIndicator(
                          minHeight: 5,
                          borderRadius: BorderRadius.all(Radius.circular(99)),
                        ),
                      ),
                    if (state.error != null)
                      _ErrorBanner(
                        message: state.error!,
                        onRetry: () => context.read<ProfileCubit>().start(),
                      ),
                    if (state.creating)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: LinearProgressIndicator(
                          minHeight: 5,
                          borderRadius: BorderRadius.all(Radius.circular(99)),
                        ),
                      ),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = constraints.maxWidth >= 760
                            ? 4
                            : constraints.maxWidth >= 520
                                ? 3
                                : 2;
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.profiles.length + 1,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.84,
                          ),
                          itemBuilder: (context, index) {
                            if (index >= state.profiles.length) {
                              return _AddProfileCard(
                                onTap: () => _createProfile(context),
                              );
                            }
                            final profile = state.profiles[index];
                            return _ProfileCard(
                              profile: profile,
                              onTap: () => _startProfile(context, profile),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 22),
                    const _PrivacyNote(),
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

class _ProfilesHeader extends StatelessWidget {
  const _ProfilesHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.orange.withValues(alpha: 0.24),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.pets_rounded,
                color: AppColors.orangeDeep,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'မြန်မာ ကလေးများ',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    'သင်ယူရေး နှင့် အမူအကျင့်',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const OfflineBadge(),
          ],
        ),
        const SizedBox(height: 26),
        Text(
          'ယနေ့ ဘယ်သူ\nသင်ယူမလဲ?',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 8),
        Text(
          'ကိုယ့် တိရစ္ဆာန် ပုံလေးကို တစ်ချက်နှိပ်ပြီး ချက်ချင်း စတင်ပါ။ '
          'အကောင့်၊ အီးမေးလ် သို့မဟုတ် ဖုန်းနံပါတ် မလိုပါ။',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.inkSoft,
              ),
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile, required this.onTap});

  final ChildProfile profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final avatar = AvatarCatalog.byId(profile.avatarId);
    return Semantics(
      button: true,
      label: '${profile.name} ပရိုဖိုင် ဖွင့်မယ်',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(26),
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: avatar.color.withValues(alpha: 0.8),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: 0.07),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(14),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AvatarBadge(avatarId: profile.avatarId, size: 82),
                  const SizedBox(height: 8),
                  Text(
                    profile.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.play_circle_fill_rounded,
                        size: 20,
                        color: avatar.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'သင်ယူမယ်',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddProfileCard extends StatelessWidget {
  const _AddProfileCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'ပရိုဖိုင် အသစ် ဖန်တီးမယ်',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(26),
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.58),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: AppColors.orange.withValues(alpha: 0.65),
                width: 2,
              ),
            ),
            padding: const EdgeInsets.all(14),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.orange.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      size: 40,
                      color: AppColors.orangeDeep,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'အသစ် ထည့်မယ်',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'ပရိုဖိုင် ဖန်တီးရန်',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.error,
                  ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('ထပ်မယ်'),
          ),
        ],
      ),
    );
  }
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lock_rounded,
            color: AppColors.teal,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'ပရိုဖိုင်များနှင့် ကြယ်များကို ဒီစက် (SQLite) ထဲမှာသာ သိမ်းထားပါတယ်။ '
              'အင်တာနက် မလိုပါ။ မည်သည့်အချက်အလက်မှ ပြင်ပသို့ မပို့ပါ။',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
