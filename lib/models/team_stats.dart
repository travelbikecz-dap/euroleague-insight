import '../utils/stats_calculator.dart';

class TeamStats {
  final String teamName;
  final String apiTeamName;
  final String clubCode;
  final String logo;
  final int position;
  final int wins;
  final int losses;
  final int gamesPlayed;
  final int pointsFor;
  final int pointsAgainst;
  final List<String> last5Form;

  final double ppg;
  final double pointsAllowed;
  final double pointDifferential;
  final double winPercentage;
  final double rebounds;
  final double offensiveRebounds;
  final double defensiveRebounds;
  final double assists;
  final double steals;
  final double blocks;
  final double blocksAgainst;
  final double turnovers;
  final double assistToTurnover;
  final double fieldGoalPercentage;
  final double twoPointPercentage;
  final double threePointPercentage;
  final double freeThrowPercentage;
  final double twoPointersMade;
  final double twoPointersAttempted;
  final double threePointersMade;
  final double threePointersAttempted;
  final double freeThrowsMade;
  final double freeThrowsAttempted;
  final double effectiveFieldGoalPercentage;
  final double trueShootingPercentage;
  final double pace;
  final double offensiveRating;
  final double defensiveRating;
  final double netRating;
  final double pir;
  final double foulsCommitted;
  final double foulsDrawn;
  final double plusMinus;

  TeamStats({
    required this.teamName,
    required this.apiTeamName,
    required this.clubCode,
    required this.logo,
    required this.position,
    required this.wins,
    required this.losses,
    required this.gamesPlayed,
    required this.pointsFor,
    required this.pointsAgainst,
    required this.last5Form,
    required this.ppg,
    required this.pointsAllowed,
    required this.pointDifferential,
    required this.winPercentage,
    required this.rebounds,
    required this.offensiveRebounds,
    required this.defensiveRebounds,
    required this.assists,
    required this.steals,
    required this.blocks,
    required this.blocksAgainst,
    required this.turnovers,
    required this.assistToTurnover,
    required this.fieldGoalPercentage,
    required this.twoPointPercentage,
    required this.threePointPercentage,
    required this.freeThrowPercentage,
    required this.twoPointersMade,
    required this.twoPointersAttempted,
    required this.threePointersMade,
    required this.threePointersAttempted,
    required this.freeThrowsMade,
    required this.freeThrowsAttempted,
    required this.effectiveFieldGoalPercentage,
    required this.trueShootingPercentage,
    required this.pace,
    required this.offensiveRating,
    required this.defensiveRating,
    required this.netRating,
    required this.pir,
    required this.foulsCommitted,
    required this.foulsDrawn,
    required this.plusMinus,
  });

  double get threePoint => threePointPercentage;

  double get possessionsPerGame => StatsCalculator.possessions(
    fieldGoalsAttempted: twoPointersAttempted + threePointersAttempted,
    freeThrowsAttempted: freeThrowsAttempted,
    offensiveRebounds: offensiveRebounds,
    turnovers: turnovers,
  );
}

class TeamStatItem {
  final String label;
  final String value;

  const TeamStatItem({required this.label, required this.value});
}

extension TeamStatsDisplay on TeamStats {
  List<TeamStatItem> get comparisonStats => [
    TeamStatItem(label: 'PPG', value: _n(ppg)),
    TeamStatItem(label: 'REB', value: _n(rebounds)),
    TeamStatItem(label: 'AST', value: _n(assists)),
    TeamStatItem(label: '3PT%', value: _p(threePointPercentage)),
    TeamStatItem(label: 'PACE', value: _n(pace)),
    TeamStatItem(label: 'OFF RTG', value: _n(offensiveRating)),
    TeamStatItem(label: 'DEF RTG', value: _n(defensiveRating)),
    TeamStatItem(label: 'TOV', value: _n(turnovers)),
    TeamStatItem(label: 'NET RTG', value: _n(netRating)),
  ];

  List<TeamStatItem> get overviewStats => [
    TeamStatItem(label: 'PTS', value: _n(ppg)),
    TeamStatItem(label: 'AST', value: _n(assists)),
    TeamStatItem(label: 'REB', value: _n(rebounds)),
    TeamStatItem(label: 'FG%', value: _p(fieldGoalPercentage)),
    TeamStatItem(label: '3P%', value: _p(threePointPercentage)),
    TeamStatItem(label: 'FT%', value: _p(freeThrowPercentage)),
  ];

  List<TeamStatItem> get performanceStats => [
    TeamStatItem(label: 'OREB', value: _n(offensiveRebounds)),
    TeamStatItem(label: 'DREB', value: _n(defensiveRebounds)),
    TeamStatItem(label: 'STL', value: _n(steals)),
    TeamStatItem(label: 'BLK', value: _n(blocks)),
    TeamStatItem(label: 'TOV', value: _n(turnovers)),
    TeamStatItem(label: 'AST/TO', value: _n(assistToTurnover)),
    TeamStatItem(label: 'PIR', value: _n(pir)),
  ];

  List<TeamStatItem> get advancedStats => [
    TeamStatItem(label: 'OFF RTG', value: _n(offensiveRating)),
    TeamStatItem(label: 'DEF RTG', value: _n(defensiveRating)),
    TeamStatItem(label: 'NET RTG', value: _n(netRating)),
    TeamStatItem(label: 'eFG%', value: _p(effectiveFieldGoalPercentage)),
    TeamStatItem(label: 'TS%', value: _p(trueShootingPercentage)),
    TeamStatItem(label: 'PACE', value: _n(pace)),
    TeamStatItem(label: 'POSS', value: _n(possessionsPerGame)),
    TeamStatItem(label: 'RECORD', value: '$wins-$losses'),
    TeamStatItem(label: 'WIN %', value: _p(winPercentage)),
    TeamStatItem(label: 'OPP PPG', value: _n(pointsAllowed)),
    TeamStatItem(label: 'DIFF', value: _signed(pointDifferential)),
    TeamStatItem(label: '2P%', value: _p(twoPointPercentage)),
    TeamStatItem(label: 'PF', value: _n(foulsCommitted)),
    TeamStatItem(label: 'FD', value: _n(foulsDrawn)),
    TeamStatItem(label: 'BLK AG', value: _n(blocksAgainst)),
    TeamStatItem(label: '+/-', value: _signed(plusMinus)),
    TeamStatItem(label: 'PTS FOR', value: pointsFor.toString()),
    TeamStatItem(label: 'PTS AG', value: pointsAgainst.toString()),
  ];

  List<TeamStatItem> get detailStats => [
    ...overviewStats,
    ...performanceStats,
    ...advancedStats,
  ];

  List<List<TeamStatItem>> get statSections => [
    overviewStats,
    performanceStats,
    advancedStats,
  ];

  String _n(num? value) => (value ?? 0).toStringAsFixed(1);

  String _p(num? value) => '${(value ?? 0).toStringAsFixed(1)}%';

  String _signed(num? value) {
    final safeValue = value ?? 0;
    final prefix = safeValue > 0 ? '+' : '';
    return '$prefix${safeValue.toStringAsFixed(1)}';
  }
}
