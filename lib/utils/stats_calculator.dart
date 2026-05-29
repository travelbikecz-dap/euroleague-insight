class StatsCalculator {
  static double percentage(double made, double attempted) {
    if (attempted <= 0) return 0;
    return (made / attempted) * 100;
  }

  static double effectiveFieldGoalPercentage({
    required double fieldGoalsMade,
    required double threePointersMade,
    required double fieldGoalsAttempted,
  }) {
    if (fieldGoalsAttempted <= 0) return 0;
    return ((fieldGoalsMade + 0.5 * threePointersMade) / fieldGoalsAttempted) *
        100;
  }

  static double trueShootingPercentage({
    required double points,
    required double fieldGoalsAttempted,
    required double freeThrowsAttempted,
  }) {
    final denominator =
        2 * (fieldGoalsAttempted + 0.44 * freeThrowsAttempted);
    if (denominator <= 0) return 0;
    return (points / denominator) * 100;
  }

  static double possessions({
    required double fieldGoalsAttempted,
    required double freeThrowsAttempted,
    required double offensiveRebounds,
    required double turnovers,
  }) {
    return fieldGoalsAttempted +
        0.44 * freeThrowsAttempted -
        offensiveRebounds +
        turnovers;
  }

  /// Team pace estimate for a 40-minute EuroLeague game.
  /// Uses team possessions and API-reported team minutes when available.
  static double pace({
    required double fieldGoalsAttempted,
    required double freeThrowsAttempted,
    required double offensiveRebounds,
    required double turnovers,
    required double minutesPlayed,
  }) {
    final teamPossessions = possessions(
      fieldGoalsAttempted: fieldGoalsAttempted,
      freeThrowsAttempted: freeThrowsAttempted,
      offensiveRebounds: offensiveRebounds,
      turnovers: turnovers,
    );

    if (minutesPlayed <= 0) return teamPossessions;

    // API timePlayed is team seconds per game; scale possessions to a 40-min game.
    const gameLengthSeconds = 40 * 60;
    return teamPossessions * (gameLengthSeconds / minutesPlayed);
  }

  static double offensiveRating({
    required double points,
    required double possessions,
  }) {
    if (possessions <= 0) return 0;
    return (points / possessions) * 100;
  }

  static double defensiveRating({
    required double pointsAllowed,
    required double possessions,
  }) {
    if (possessions <= 0) return 0;
    return (pointsAllowed / possessions) * 100;
  }

  static double assistToTurnoverRatio({
    required double assists,
    required double turnovers,
  }) {
    if (turnovers <= 0) return assists;
    return assists / turnovers;
  }

  static String formatNumber(double value, {int decimals = 1}) {
    if (value == value.roundToDouble()) {
      return value.round().toString();
    }
    return value.toStringAsFixed(decimals);
  }

  static String formatPercentage(double value) {
    return '${formatNumber(value, decimals: 1)}%';
  }
}
