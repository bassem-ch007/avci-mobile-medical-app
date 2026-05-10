class SqliteHelpers {
  static int boolToInt(bool value) {
    return value ? 1 : 0;
  }

  static bool intToBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    return false;
  }

  static String dateToString(DateTime value) {
    return value.toIso8601String();
  }

  static String? nullableDateToString(DateTime? value) {
    return value?.toIso8601String();
  }

  static DateTime? stringToDate(dynamic value) {
    if (value == null) return null;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
