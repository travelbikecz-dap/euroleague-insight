import 'package:flutter_test/flutter_test.dart';

import 'package:euroliga_predictor/models/team_stats.dart';
import 'package:euroliga_predictor/services/matchup_predictor.dart';

TeamStats _stats({
  required String name,
  required String clubCode,
  required int wins,
  required int losses,
  required double netRating,
  required double offensiveRating,
  required double defensiveRating,
  required double pace,
}) {
  return TeamStats(
    teamName: name,
    apiTeamName: name,
    clubCode: clubCode,
    logo: 'assets/logos/real_madrid.png',
    position: 1,
    wins: wins,
    losses: losses,
    gamesPlayed: wins + losses,
    pointsFor: 1000,
    pointsAgainst: 900,
    last5Form: const ['W', 'W', 'L', 'W', 'W'],
    ppg: 85,
    pointsAllowed: 80,
    pointDifferential: 5,
    winPercentage: 70,
    rebounds: 35,
    offensiveRebounds: 10,
    defensiveRebounds: 25,
    assists: 18,
    steals: 7,
    blocks: 3,
    blocksAgainst: 2,
    turnovers: 12,
    assistToTurnover: 1.5,
    fieldGoalPercentage: 50,
    twoPointPercentage: 55,
    threePointPercentage: 35,
    freeThrowPercentage: 75,
    twoPointersMade: 20,
    twoPointersAttempted: 35,
    threePointersMade: 8,
    threePointersAttempted: 22,
    freeThrowsMade: 12,
    freeThrowsAttempted: 15,
    effectiveFieldGoalPercentage: 54,
    trueShootingPercentage: 58,
    pace: pace,
    offensiveRating: offensiveRating,
    defensiveRating: defensiveRating,
    netRating: netRating,
    pir: 90,
    foulsCommitted: 18,
    foulsDrawn: 16,
    plusMinus: 4,
  );
}

void main() {
  test('favors stronger home team with home court boost', () {
    final home = _stats(
      name: 'Real Madrid',
      clubCode: 'MAD',
      wins: 20,
      losses: 5,
      netRating: 8,
      offensiveRating: 118,
      defensiveRating: 110,
      pace: 74,
    );
    final away = _stats(
      name: 'Valencia',
      clubCode: 'PAM',
      wins: 12,
      losses: 13,
      netRating: -2,
      offensiveRating: 108,
      defensiveRating: 110,
      pace: 71,
    );

    final prediction = MatchupPredictor.predict(home: home, away: away);

    expect(prediction.homeWinProbability, greaterThan(50));
    expect(
      prediction.homeWinProbability + prediction.awayWinProbability,
      closeTo(100, 0.001),
    );
    expect(prediction.insight, contains('Real Madrid'));
  });
}
