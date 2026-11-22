import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/education_quiz/quiz_cubit.dart';
import '../../presentation/education_quiz/quiz_screen.dart';
import '../../presentation/home/home_cubit.dart';
import '../../presentation/home/home_screen.dart';
import '../../presentation/manners_story/audio_cubit.dart';
import '../../presentation/manners_story/story_cubit.dart';
import '../../presentation/manners_story/story_screen.dart';
import '../../presentation/profiles/profile_cubit.dart';
import '../../presentation/profiles/profiles_screen.dart';
import '../../presentation/session/session_cubit.dart';
import '../di/injection.dart';
import '../theme/app_theme.dart';
import '../utils/audio_player_service.dart';
import '../widgets/warm_background.dart';

GoRouter createAppRouter({required SessionCubit session}) {
  return GoRouter(
    initialLocation: '/profiles',
    redirect: (context, state) {
      if (session.state == null &&
          state.matchedLocation != '/profiles') {
        return '/profiles';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/profiles',
        builder: (context, state) => BlocProvider<ProfileCubit>(
          create: (_) =>
              ProfileCubit(getIt())..start(),
          child: const ProfilesScreen(),
        ),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) {
          final profile = session.state;
          if (profile == null) return const SizedBox.shrink();
          return BlocProvider<HomeCubit>(
            create: (_) => HomeCubit(
              profile: profile,
              contentRepository: getIt(),
              progressRepository: getIt(),
            )..start(),
            child: const HomeScreen(),
          );
        },
      ),
      GoRoute(
        path: '/story/:id',
        builder: (context, state) {
          final profile = session.state;
          final lessonId = state.pathParameters['id'];
          if (profile == null || lessonId == null) {
            return const SizedBox.shrink();
          }
          return MultiBlocProvider(
            providers: [
              BlocProvider<StoryCubit>(
                create: (_) => StoryCubit(
                  profile: profile,
                  lessonId: lessonId,
                  contentRepository: getIt(),
                  progressRepository: getIt(),
                )..load(),
              ),
              BlocProvider<AudioCubit>(
                create: (_) => AudioCubit(JustAudioPlayerService()),
              ),
            ],
            child: const StoryScreen(),
          );
        },
      ),
      GoRoute(
        path: '/quiz/:id',
        builder: (context, state) {
          final profile = session.state;
          final lessonId = state.pathParameters['id'];
          if (profile == null || lessonId == null) {
            return const SizedBox.shrink();
          }
          return MultiBlocProvider(
            providers: [
              BlocProvider<QuizCubit>(
                create: (_) => QuizCubit(
                  profile: profile,
                  lessonId: lessonId,
                  contentRepository: getIt(),
                  progressRepository: getIt(),
                )..load(),
              ),
              BlocProvider<AudioCubit>(
                create: (_) => AudioCubit(JustAudioPlayerService()),
              ),
            ],
            child: const QuizScreen(),
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: WarmBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.explore_off_rounded,
                    size: 58,
                    color: AppColors.orangeDeep,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'ဒီစာမျက်နှာကို ရှာမတွေ့ပါ။',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: () => context.go('/profiles'),
                    icon: const Icon(Icons.home_rounded),
                    label: const Text('ပင်မသို့ ပြန်မယ်'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
