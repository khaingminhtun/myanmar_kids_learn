/// Central list of every bundled offline asset used by the app.
abstract final class AppAssets {
  static const String avatarDirectory = 'assets/avatars';
  static const String characterDirectory = 'assets/characters';
  static const String imageDirectory = 'assets/content/images';
  static const String audioDirectory = 'assets/content/audio';
  static const String lessonDirectory = 'assets/content/lessons';

  // Teacher & Assistant characters
  static const String mimiTeacher = '$characterDirectory/mimi_teacher.svg';
  static const String mimiCelebrate = '$characterDirectory/mimi_celebrate.svg';
  static const String jijiCurious = '$characterDirectory/jiji_curious.svg';
  static const String jijiOops = '$characterDirectory/jiji_oops.svg';

  // Common Scene SVGs
  static const String nonoBow = '$imageDirectory/nono_bow.svg';
  static const String nonoHappy = '$imageDirectory/nono_happy.svg';

  // Legacy demo image assets (backward compatibility)
  static const String mannersGreetingImage =
      '$imageDirectory/nono_bow.svg';
  static const String mannersSharingImage =
      '$imageDirectory/share_toy.svg';
  static const String mathMarketImage = '$imageDirectory/kg_zhya_market.svg';
  static const String englishAnimalsImage =
      '$imageDirectory/kg_kha_dog.svg';

  // 20 bundled offline lessons (10 Good Manners stories + 10 KG Alphabet discover)
  static const List<String> lessonPaths = [
    '$lessonDirectory/manners_w1_ep01.json',
    '$lessonDirectory/manners_w1_ep02.json',
    '$lessonDirectory/manners_w1_ep03.json',
    '$lessonDirectory/manners_w1_ep04.json',
    '$lessonDirectory/manners_w1_ep05.json',
    '$lessonDirectory/manners_w1_ep06.json',
    '$lessonDirectory/manners_w1_ep07.json',
    '$lessonDirectory/manners_w1_ep08.json',
    '$lessonDirectory/manners_w1_ep09.json',
    '$lessonDirectory/manners_w1_ep10.json',
    '$lessonDirectory/edu_w1_ep01.json',
    '$lessonDirectory/edu_w1_ep02.json',
    '$lessonDirectory/edu_w1_ep03.json',
    '$lessonDirectory/edu_w1_ep04.json',
    '$lessonDirectory/edu_w1_ep05.json',
    '$lessonDirectory/edu_w1_ep06.json',
    '$lessonDirectory/edu_w1_ep07.json',
    '$lessonDirectory/edu_w1_ep08.json',
    '$lessonDirectory/edu_w1_ep09.json',
    '$lessonDirectory/edu_w1_ep10.json',
  ];
}
