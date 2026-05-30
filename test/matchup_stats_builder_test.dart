import 'package:flutter_test/flutter_test.dart';

import 'package:euroliga_predictor/models/matchup_stat_comparison.dart';
import 'package:euroliga_predictor/models/team_stats.dart';

TeamStats _stats({required String clubCode, required int wins}) {
  return TeamStats(
    teamName: clubCode,
    apiTeamName: clubCode,
    clubCode: clubCode,
    logo: 'assets/logos/real_madrid.png',
    position: 1,
    wins: wins,
    losses: 10,
    gamesPlayed: wins + 10,
    pointsFor: 1200,
    pointsAgainst: 1100,
    last5Form: const ['W'],
    ppg: 85.2,
    pointsAllowed: 80.1,
    pointDifferential: 5.1,
    winPercentage: 60,
    rebounds: 35.4,
    offensiveRebounds: 10.2,
    defensiveRebounds: 25.2,
    assists: 18.3,
    steals: 7.1,
    blocks: 3.2,
    blocksAgainst: 2.1,
    turnovers: 12.4,
    assistToTurnover: 1.5,
    fieldGoalPercentage: 48.2,
    twoPointPercentage: 54.1,
    threePointPercentage: 36.5,
    freeThrowPercentage: 77.2,
    twoPointersMade: 20,
    twoPointersAttempted: 35,
    threePointersMade: 8,
    threePointersAttempted: 22,
    freeThrowsMade: 12,
    freeThrowsAttempted: 15,
    effectiveFieldGoalPercentage: 52.3,
    trueShootingPercentage: 57.8,
    pace: 74.2,
    offensiveRating: 115.4,
    defensiveRating: 108.2,
    netRating: 7.2,
    pir: 88.5,
    foulsCommitted: 18.2,
    foulsDrawn: 16.4,
    plusMinus: 4.2,
  );
}

void main() {
  test('includes all Teams stat sections in order', () {
    final home = _stats(clubCode: 'MAD', wins: 20);
    final away = _stats(clubCode: 'PAM', wins: 12);

    final sections = MatchupStatsBuilder.buildSections(home: home, away: away);

    expect(sections.map((section) => section.name), [
      'Overview',
      'Performance',
      'Advanced',
    ]);
    expect(sections[0].stats.map((stat) => stat.label), [
      'PTS',
      'AST',
      'REB',
      'FG%',
      '3P%',
      'FT%',
    ]);
    expect(sections[1].stats.map((stat) => stat.label), [
      'OREB',
      'DREB',
      'STL',
      'BLK',
      'TOV',
      'AST/TO',
      'PIR',
    ]);
    expect(sections[2].stats.length, home.advancedStats.length);
    expect(
      MatchupStatsBuilder.buildFlat(home: home, away: away).length,
      home.overviewStats.length +
          home.performanceStats.length +
          home.advancedStats.length,
    );
  });
}
