abstract final class BurmeseNumbers {
  static const List<String> _digits = [
    '၀',
    '၁',
    '၂',
    '၃',
    '၄',
    '၅',
    '၆',
    '၇',
    '၈',
    '၉',
  ];

  static String of(int value) {
    final buffer = StringBuffer();
    for (final rune in value.toString().runes) {
      final character = String.fromCharCode(rune);
      final digit = int.tryParse(character);
      buffer.write(digit == null ? character : _digits[digit]);
    }
    return buffer.toString();
  }
}
