class GameTimeFormatter {
  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

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

  /// Compact range for narrow headers, e.g. `14–16 Mar` or `28 Mar – 2 Apr`.
  static String formatRoundRangeCompact(List<DateTime> utcDates) {
    if (utcDates.isEmpty) return '';

    final sorted = utcDates.toList()..sort();
    final first = sorted.first.toLocal();
    final last = sorted.last.toLocal();

    if (first.year == last.year &&
        first.month == last.month &&
        first.day == last.day) {
      return _formatRoundDayCompact(first);
    }

    if (first.year == last.year && first.month == last.month) {
      return '${first.day}–${last.day} ${_months[first.month - 1]}';
    }

    return '${_formatRoundDayCompact(first)} – ${_formatRoundDayCompact(last)}';
  }

  static String _formatRoundDayCompact(DateTime local) {
    return '${local.day} ${_months[local.month - 1]}';
  }

  static String formatFull(DateTime utcDate) {
    final local = utcDate.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '${_weekdays[local.weekday - 1]} $day/$month · ${formatClock(utcDate)}';
  }
}
