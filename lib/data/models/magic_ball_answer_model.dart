/// Одна фраза-ответ Магического Шара, привязанная к одному из 9 «рядов»
/// из ТЗ. Алгоритм (Этап 5) берёт случайный элемент из [MagicBallAnswerModel.all].
///
/// ВАЖНО: переводы заполнены только для ru/en. Полная локализация (es/fr/pt)
/// запланирована на Этап 11 — см. FLUTTER_ARCHITECTURE_PLAN.md §5.
class MagicBallAnswerModel {
  const MagicBallAnswerModel({required this.row, required this.translations});

  /// Номер ряда 1-9, как в оригинальном ТЗ (для аналитики/группировки).
  final int row;

  /// languageCode -> текст ответа.
  final Map<String, String> translations;

  String text(String languageCode) =>
      translations[languageCode] ?? translations['en'] ?? '';

  /// Полная база ответов — 9 рядов, дословно перенесены из ТЗ (RU) + перевод EN.
  static const List<MagicBallAnswerModel> all = [
    // РЯД 1
    MagicBallAnswerModel(row: 1, translations: {'ru': 'АБСОЛЮТНО ТОЧНО', 'en': 'ABSOLUTELY'}),
    MagicBallAnswerModel(row: 1, translations: {'ru': 'СПРОСИТЕ ПОЗЖЕ', 'en': 'ASK LATER'}),
    MagicBallAnswerModel(row: 1, translations: {'ru': 'ПОХОЖЕ, ЧТО ДА', 'en': 'IT SEEMS SO'}),
    MagicBallAnswerModel(row: 1, translations: {'ru': 'МНЕ КАЖЕТСЯ, ДА', 'en': 'I THINK SO'}),
    MagicBallAnswerModel(row: 1, translations: {'ru': 'ОЧЕНЬ ВЕРОЯТНО', 'en': 'VERY LIKELY'}),

    // РЯД 2
    MagicBallAnswerModel(row: 2, translations: {'ru': '??', 'en': '??'}),
    MagicBallAnswerModel(row: 2, translations: {'ru': 'НЕ НАДЕЙТЕСЬ', 'en': "DON'T COUNT ON IT"}),
    MagicBallAnswerModel(row: 2, translations: {'ru': 'НЕТ', 'en': 'NO'}),
    MagicBallAnswerModel(row: 2, translations: {'ru': 'ДОЛЖНО БЫТЬ ТАК', 'en': 'IT SHOULD BE SO'}),
    MagicBallAnswerModel(row: 2, translations: {'ru': 'ДА', 'en': 'YES'}),

    // РЯД 3
    MagicBallAnswerModel(row: 3, translations: {'ru': 'НЕ МОГУ СКАЗАТЬ', 'en': "CAN'T SAY"}),
    MagicBallAnswerModel(row: 3, translations: {'ru': 'СПРОСИТЕ СНОВА', 'en': 'ASK AGAIN'}),
    MagicBallAnswerModel(row: 3, translations: {'ru': 'БЕЗ СОМНЕНИЙ', 'en': 'WITHOUT A DOUBT'}),
    MagicBallAnswerModel(row: 3, translations: {'ru': 'ЗВЕЗДЫ ГОВОРЯТ НЕТ', 'en': 'THE STARS SAY NO'}),
    MagicBallAnswerModel(row: 3, translations: {'ru': 'НЕ ПОХОЖЕ', 'en': "DOESN'T SEEM SO"}),

    // РЯД 4
    MagicBallAnswerModel(row: 4, translations: {'ru': 'МАЛО ШАНСОВ', 'en': 'LOW CHANCE'}),
    MagicBallAnswerModel(row: 4, translations: {'ru': 'ДУХИ ГОВОРЯТ ДА', 'en': 'THE SPIRITS SAY YES'}),
    MagicBallAnswerModel(row: 4, translations: {'ru': 'БЕЗУСЛОВНО', 'en': 'UNDOUBTEDLY'}),
    MagicBallAnswerModel(row: 4, translations: {'ru': 'ВРЯД ЛИ', 'en': 'UNLIKELY'}),
    MagicBallAnswerModel(row: 4, translations: {'ru': 'ОТВЕТ НЕТ', 'en': 'THE ANSWER IS NO'}),

    // РЯД 5
    MagicBallAnswerModel(row: 5, translations: {'ru': 'ДА', 'en': 'YES'}),
    MagicBallAnswerModel(row: 5, translations: {'ru': 'БЕЗ СОМНЕНИЙ', 'en': 'WITHOUT A DOUBT'}),
    MagicBallAnswerModel(row: 5, translations: {'ru': 'БЕССПОРНО', 'en': 'INDISPUTABLY'}),
    MagicBallAnswerModel(row: 5, translations: {'ru': 'ЗВЕЗДЫ ГОВОРЯТ НЕТ', 'en': 'THE STARS SAY NO'}),

    // РЯД 6
    MagicBallAnswerModel(row: 6, translations: {'ru': 'СБУДЕТСЯ', 'en': 'IT WILL COME TRUE'}),
    MagicBallAnswerModel(row: 6, translations: {'ru': 'ТАК И БУДЕТ', 'en': 'SO IT WILL BE'}),
    MagicBallAnswerModel(row: 6, translations: {'ru': 'ОПРЕДЕЛЕННО ДА', 'en': 'DEFINITELY YES'}),
    MagicBallAnswerModel(row: 6, translations: {'ru': 'МНОГО СОМНЕНИЙ', 'en': 'TOO MANY DOUBTS'}),

    // РЯД 7
    MagicBallAnswerModel(row: 7, translations: {'ru': 'СПРОСИТЕ ПОЗЖЕ', 'en': 'ASK LATER'}),
    MagicBallAnswerModel(row: 7, translations: {'ru': 'ПЛОХАЯ ПЕРСПЕКТИВА', 'en': 'POOR OUTLOOK'}),
    MagicBallAnswerModel(row: 7, translations: {'ru': 'ДОЛЖНО БЫТЬ ТАК', 'en': 'IT SHOULD BE SO'}),
    MagicBallAnswerModel(row: 7, translations: {'ru': 'ШАНСОВ МАЛО', 'en': 'LOW CHANCE'}),

    // РЯД 8
    MagicBallAnswerModel(row: 8, translations: {'ru': 'ПОВТОРИТЕ ВОПРОС', 'en': 'REPEAT THE QUESTION'}),
    MagicBallAnswerModel(row: 8, translations: {'ru': 'НЕ МОГУ СКАЗАТЬ', 'en': "CAN'T SAY"}),
    MagicBallAnswerModel(row: 8, translations: {'ru': 'ШАНСЫ ХОРОШИЕ', 'en': 'GOOD CHANCES'}),
    MagicBallAnswerModel(row: 8, translations: {'ru': 'НЕТ', 'en': 'NO'}),

    // РЯД 9
    MagicBallAnswerModel(row: 9, translations: {'ru': 'ВОЗМОЖНО', 'en': 'MAYBE'}),
    MagicBallAnswerModel(row: 9, translations: {'ru': 'НЕ МОГУ ОТВЕТИТЬ СЕЙЧАС', 'en': "CAN'T ANSWER RIGHT NOW"}),
    MagicBallAnswerModel(row: 9, translations: {'ru': 'ЗАДАЙТЕ ВОПРОС ТОЧНЕЕ', 'en': 'ASK A MORE PRECISE QUESTION'}),
    MagicBallAnswerModel(row: 9, translations: {'ru': 'СЕЙЧАС НЕИЗВЕСТНО', 'en': 'UNKNOWN FOR NOW'}),
  ];
}
