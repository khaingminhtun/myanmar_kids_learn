# AGENTS.md - Myanmar Kids Offline Learning & Good Manners App

## 1. Environment & Platform Rules
- Host OS: Windows (PowerShell). Use only Windows/PowerShell-safe commands (flutter pub add, dart run, New-Item). Never use bash-only commands.
- Target Device: Android 6.0+ (minSdkVersion 23), low-RAM devices, APK size under 35 MB.
- 100% Offline &  Cost: NEVER add Firebase, Supabase, cloud APIs, analytics, ads, or login/registration screens.
- No Heavy Video Files: NEVER add .mp4 or .webm videos. Create cartoon motion using Flutter animations over lightweight .svg assets.

## 2. Approved Flutter Stack
- State Management & DI: flutter_bloc (Cubit pattern only), equatable, get_it, go_router
- Local SQLite Database: drift, drift_flutter, path_provider
- Dev Dependencies: drift_dev, build_runner, flutter_test, bloc_test, flutter_lints
- Media & Offline Sharing: flutter_svg, just_audio, share_plus

## 3. Pre-Placed Assets & Required Scene SVGs
Register all asset directories in pubspec.yaml (assets/fonts/, assets/avatars/, assets/characters/, assets/content/images/, assets/content/lessons/, assets/content/audio/):
1. Pre-Placed Assets (Do NOT overwrite or delete):
   - assets/fonts/: NotoSansMyanmar-Regular.ttf, NotoSansMyanmar-Bold.ttf
   - assets/characters/: mimi_teacher.svg, mimi_celebrate.svg, jiji_curious.svg, jiji_oops.svg
   - assets/content/lessons/: manners_w1_ep01.json to ep10.json (5-step stories) and edu_w1_ep01.json to ep10.json (KG Alphabet)
   - assets/content/audio/: w1_ep01_s1.mp3 to w1_ep10_s5.mp3 and edu_w1_ep01_c1.mp3 to edu_w1_ep10_c2.mp3
2. Generate These 20 Reusable Scene SVGs in assets/content/images/:
   - Good Manners (10 SVGs): nono_happy.svg, nono_bow.svg, nono_sad.svg, grandma_happy.svg, parents_happy.svg, wash_hands.svg, dining_table.svg, share_toy.svg, clean_spill.svg, goodnight_bed.svg
   - KG Alphabet (10 SVGs): kg_ka_child.svg, kg_kha_dog.svg, kg_ga_crab.svg, kg_gha_pot.svg, kg_nga_fish.svg, kg_sa_book.svg, kg_hsa_elephant.svg, kg_za_owl.svg, kg_zhya_market.svg, kg_nya_tree.svg

## 4. Core Learning & UX Rules (KG Level, Ages 5-7)
- Learn First -> Simple Quiz -> Reward: Children NEVER see quiz questions first.
  1. Good Manners (type: story_stream): Play all 5 story steps (narration -> narration -> interactive_tap -> outcome -> narration) first. On interactive_tap, pause until the child taps the character/action button (action_label_my) with a bounce animation. After Step 5, unlock simple_quiz.
  2. KG Education (type: kg_discover): Display all discover_cards first. Each tap bounces the card and plays its Burmese phonics MP3 (AudioCubit). Unlock mini_game only after every card has been tapped at least once.
  3. Gentle Retry Rule: Wrong quiz taps NEVER show a scary red X. Gently wiggle the card, show jiji_oops.svg on the teacher bar, and encourage trying again.
  4. Sticker & Star Reward: Completing any lesson awards stars, switches the teacher bar to mimi_celebrate.svg, saves an unlocked sticker into Drift (UnlockedStickers table), and offers a Next Episode / Lesson button.
- Guided Cartoon Teacher (GuidedTeacherBar): Display Mimi Cat & Jiji Mouse (assets/characters/*.svg) with gentle idle bobbing motion, Burmese speech bubble guidance, and a tap-to-replay speaker button across all learning and quiz screens.

## 5. Strict Layered Folder Architecture
- lib/core/: di (get_it), router (go_router), theme (NotoSansMyanmar, touch targets >= 56dp), utils
- lib/data/: local (Drift AppDatabase: ChildProfiles, LessonProgress, UnlockedStickers + AssetContentSource), repositories
- lib/domain/: entities & abstract repository interfaces
- lib/presentation/: widgets (GuidedTeacherBar, AnimatedSceneStage), profiles, home (World 1 map + Sticker Album), manners_story, education_quiz

## 6. Mandatory Verification Gate
Before finishing any task, run and ensure 0 errors:
1. dart run build_runner build --delete-conflicting-outputs
2. flutter analyze
3. flutter test
