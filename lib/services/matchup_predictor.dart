import 'dart:math';

import '../models/team_stats.dart';

class MatchupPrediction {
  final double homeWinProbability;
  final double awayWinProbability;
  final String insight;

  const MatchupPrediction({
    required this.homeWinProbability,
    required this.awayWinProbability,
    required this.insight,
  });
}

class MatchupPredictor {
  static const _homeCourtNetRatingBoost = 3.5;
  static const _logisticScale = 0.11;

  static MatchupPrediction predict({
    required TeamStats home,
    required TeamStats away,
  }) {
    final ratingDiff =
        (home.netRating - away.netRating) + _homeCourtNetRatingBoost;
    final homeProb = 100.0 / (1.0 + exp(-_logisticScale * ratingDiff));
    final awayProb = 100.0 - homeProb;

    return MatchupPrediction(
      homeWinProbability: homeProb,
      awayWinProbability: awayProb,
      insight: _buildInsight(home, away),
    );
  }

  static String _buildInsight(TeamStats home, TeamStats away) {
    final homeName = home.teamName;
    final awayName = away.teamName;

    if (home.wins > away.wins + 2) {
      return '$homeName comes into this matchup with stronger overall form and better season consistency.';
    }

    if (away.wins > home.wins + 2) {
      return '$awayName has shown stronger results recently and appears more competitive statistically.';
    }

    if (home.netRating > away.netRating + 3) {
      return '$homeName holds a measurable edge in efficiency metrics, with home court adding another layer of advantage.';
    }

    if (away.netRating > home.netRating + 3) {
      return '$awayName profiles as the more efficient team on paper, even playing on the road.';
    }

    return 'Both teams arrive with very similar performance levels, making this matchup highly balanced.';
  }
}
