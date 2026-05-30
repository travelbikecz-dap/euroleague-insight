class GameTimeFormatter {
  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static String formatScheduled(DateTime utcDate) {
    final local = utcDate.toLocal();
    return '${_weekdays[local.weekday - 1]} ${formatClock(utcDate)}';
  }

  static String formatClock(DateTime utcDate) {
    final local = utcDate.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static String formatRoundDay(DateTime utcDate) {
    final local = utcDate.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '${_weekdays[local.weekday - 1]} $day/$month';
  }

  static String formatRoundRange(List<DateTime> utcDates) {
    if (utcDates.isEmpty) return '';

    final sorted = utcDates.toList()..sort();
    final first = sorted.first;
    final last = sorted.last;
    final firstLocal = first.toLocal();
    final lastLocal = last.toLocal();

    if (firstLocal.year == lastLocal.year &&
        firstLocal.month == lastLocal.month &&
        firstLocal.day == lastLocal.day) {
      return formatRoundDay(first);
    }

    return '${formatRoundDay(first)} – ${formatRoundDay(last)}';
  }

  static String formatFull(DateTime utcDate) {
    final local = utcDate.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '${_weekdays[local.weekday - 1]} $day/$month · ${formatClock(utcDate)}';
  }
}
