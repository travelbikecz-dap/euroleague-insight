class LiveGameClockFormatter {
  static String? format({
    required bool isLive,
    String? quarter,
    String? remainingTime,
  }) {
    if (!isLive) return null;

    final normalizedQuarter = _normalizeQuarter(quarter);
    final clock = _normalizeClock(remainingTime);

    if (normalizedQuarter != null && clock != null) {
      return 'LIVE · Q$normalizedQuarter $clock';
    }
    if (clock != null) {
      return 'LIVE · $clock';
    }
    if (normalizedQuarter != null) {
      return 'LIVE · Q$normalizedQuarter';
    }
    return 'LIVE';
  }

  static String? _normalizeQuarter(String? quarter) {
    final value = quarter?.trim();
    if (value == null || value.isEmpty) return null;

    final upper = value.toUpperCase();
    if (upper.startsWith('Q')) {
      return value.substring(1).trim().isEmpty ? null : value.substring(1).trim();
    }
    return value;
  }

  static String? _normalizeClock(String? remainingTime) {
    final value = remainingTime?.trim();
    if (value == null || value.isEmpty || value == '00:00' || value == '00:00:00') {
      return null;
    }
    return value;
  }
}
