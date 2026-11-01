/// Conversion between the Gregorian and the tabular (arithmetic) Hijri
/// calendar.
///
/// The tabular calendar is a good approximation for display purposes, but it
/// can differ from the locally observed (moon-sighting) date by a day. Once the
/// app gains a location-aware calculation engine this should be replaced with
/// an Umm al-Qura or moon-sighting based conversion.
class HijriDate {
  const HijriDate({required this.year, required this.month, required this.day});

  final int year;
  final int month;
  final int day;

  static const List<String> monthNames = <String>[
    'Muharram',
    'Safar',
    "Rabi' al-Awwal",
    "Rabi' al-Thani",
    'Jumada al-Awwal',
    'Jumada al-Thani',
    'Rajab',
    "Sha'ban",
    'Ramadan',
    'Shawwal',
    "Dhu al-Qi'dah",
    'Dhu al-Hijjah',
  ];

  static const List<String> monthNamesArabic = <String>[
    'محرم',
    'صفر',
    'ربيع الأول',
    'ربيع الثاني',
    'جمادى الأولى',
    'جمادى الآخرة',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدة',
    'ذو الحجة',
  ];

  factory HijriDate.fromDateTime(DateTime date) {
    final int julianDay = _gregorianToJulianDay(
      date.year,
      date.month,
      date.day,
    );
    return _fromJulianDay(julianDay);
  }

  String get monthName => monthNames[month - 1];

  String get monthNameArabic => monthNamesArabic[month - 1];

  /// e.g. `21 Jumada al-Awwal 1448 AH`.
  String get formatted => '$day $monthName $year AH';

  static int _gregorianToJulianDay(int year, int month, int day) {
    final int a = ((14 - month) / 12).floor();
    final int y = year + 4800 - a;
    final int m = month + 12 * a - 3;
    return day +
        ((153 * m + 2) / 5).floor() +
        365 * y +
        (y / 4).floor() -
        (y / 100).floor() +
        (y / 400).floor() -
        32045;
  }

  static HijriDate _fromJulianDay(int julianDay) {
    int l = julianDay - 1948440 + 10632;
    final int n = ((l - 1) / 10631).floor();
    l = l - 10631 * n + 354;
    final int j =
        (((10985 - l) / 5316).floor()) * (((50 * l) / 17719).floor()) +
        ((l / 5670).floor()) * (((43 * l) / 15238).floor());
    l =
        l -
        (((30 - j) / 15).floor()) * (((17719 * j) / 50).floor()) -
        ((j / 16).floor()) * (((15238 * j) / 43).floor()) +
        29;
    final int month = ((24 * l) / 709).floor();
    final int day = l - ((709 * month) / 24).floor();
    final int year = 30 * n + j - 30;
    return HijriDate(year: year, month: month, day: day);
  }
}
