/// Local/UTC helpers for Supabase `timestamptz` queries.
class DateRangeUtils {
  DateRangeUtils._();

  /// Start of the calendar day in local time.
  static DateTime startOfLocalDay(DateTime moment) {
    return DateTime(moment.year, moment.month, moment.day);
  }

  /// ISO-8601 UTC string for Supabase range filters.
  static String toUtcQueryString(DateTime local) {
    return local.toUtc().toIso8601String();
  }

  /// Local midnight today → now (for queries).
  static (DateTime fromLocal, DateTime toLocal) localDayRange(DateTime now) {
    return (startOfLocalDay(now), now);
  }

  /// Previous local calendar day [start, end).
  static (DateTime fromLocal, DateTime toLocal) previousLocalDayRange(
    DateTime now,
  ) {
    final todayStart = startOfLocalDay(now);
    final yesterdayStart = todayStart.subtract(const Duration(days: 1));
    return (yesterdayStart, todayStart);
  }
}
