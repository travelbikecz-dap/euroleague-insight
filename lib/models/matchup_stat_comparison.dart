import 'team_stats.dart';

class MatchupStatComparison {
  final String label;
  final double homeValue;
  final double awayValue;
  final String homeDisplay;
  final String awayDisplay;
  final bool lowerIsBetter;

  const MatchupStatComparison({
    required this.label,
    required this.homeValue,
    required this.awayValue,
    required this.homeDisplay,
    required this.awayDisplay,
    this.lowerIsBetter = false,
  });
}

class MatchupStatSection {
  final String name;
  final List<MatchupStatComparison> stats;

  const MatchupStatSection({
    required this.name,
    required this.stats,
  });
}

class MatchupStatsBuilder {
  static List<MatchupStatSection> buildSections({
    required TeamStats home,
    required TeamStats away,
  }) {
    return [
      MatchupStatSection(
        name: 'Overview',
        stats: _mapItems(home, away, home.overviewStats, away.overviewStats),
      ),
      MatchupStatSection(
        name: 'Performance',
        stats: _mapItems(
          home,
          away,
          home.performanceStats,
          away.performanceStats,
        ),
      ),
      MatchupStatSection(
        name: 'Advanced',
        stats: _mapAdvanced(home, away),
      ),
    ];
  }

  static List<MatchupStatComparison> buildFlat({
    required TeamStats home,
    required TeamStats away,
  }) {
    return buildSections(home: home, away: away)
        .expand((section) => section.stats)
        .toList();
  }

  static List<MatchupStatComparison> _mapItems(
    TeamStats home,
    TeamStats away,
    List<TeamStatItem> homeItems,
    List<TeamStatItem> awayItems,
  ) {
    final comparisons = <MatchupStatComparison>[];

    for (var i = 0; i < homeItems.length; i++) {
      final homeItem = homeItems[i];
      final awayItem = awayItems[i];
      comparisons.add(
        MatchupStatComparison(
          label: homeItem.label,
          homeValue: _parseValue(homeItem.value),
          awayValue: _parseValue(awayItem.value),
          homeDisplay: homeItem.value,
          awayDisplay: awayItem.value,
          lowerIsBetter: _lowerIsBetter(homeItem.label),
        ),
      );
    }

    return comparisons;
  }

  static List<MatchupStatComparison> _mapAdvanced(
    TeamStats home,
    TeamStats away,
  ) {
    return [
      _compare(
        label: 'OFF RTG',
        home: home,
        away: away,
        value: (stats) => stats.offensiveRating,
        display: (stats) => _num(stats.offensiveRating),
      ),
      _compare(
        label: 'DEF RTG',
        home: home,
        away: away,
        value: (stats) => stats.defensiveRating,
        display: (stats) => _num(stats.defensiveRating),
        lowerIsBetter: true,
      ),
      _compare(
        label: 'NET RTG',
        home: home,
        away: away,
        value: (stats) => stats.netRating,
        display: (stats) => _signed(stats.netRating),
      ),
      _compare(
        label: 'eFG%',
        home: home,
        away: away,
        value: (stats) => stats.effectiveFieldGoalPercentage,
        display: (stats) => _pct(stats.effectiveFieldGoalPercentage),
      ),
      _compare(
        label: 'TS%',
        home: home,
        away: away,
        value: (stats) => stats.trueShootingPercentage,
        display: (stats) => _pct(stats.trueShootingPercentage),
      ),
      _compare(
        label: 'PACE',
        home: home,
        away: away,
        value: (stats) => stats.pace,
        display: (stats) => _num(stats.pace),
      ),
      _compare(
        label: 'POSS',
        home: home,
        away: away,
        value: (stats) => stats.possessionsPerGame,
        display: (stats) => _num(stats.possessionsPerGame),
      ),
      _compare(
        label: 'RECORD',
        home: home,
        away: away,
        value: (stats) => stats.wins.toDouble(),
        display: (stats) => '${stats.wins}-${stats.losses}',
      ),
      _compare(
        label: 'WIN %',
        home: home,
        away: away,
        value: (stats) => stats.winPercentage,
        display: (stats) => _pct(stats.winPercentage),
      ),
      _compare(
        label: 'OPP PPG',
        home: home,
        away: away,
        value: (stats) => stats.pointsAllowed,
        display: (stats) => _num(stats.pointsAllowed),
        lowerIsBetter: true,
      ),
      _compare(
        label: 'DIFF',
        home: home,
        away: away,
        value: (stats) => stats.pointDifferential,
        display: (stats) => _signed(stats.pointDifferential),
      ),
      _compare(
        label: '2P%',
        home: home,
        away: away,
        value: (stats) => stats.twoPointPercentage,
        display: (stats) => _pct(stats.twoPointPercentage),
      ),
      _compare(
        label: 'PF',
        home: home,
        away: away,
        value: (stats) => stats.foulsCommitted,
        display: (stats) => _num(stats.foulsCommitted),
        lowerIsBetter: true,
      ),
      _compare(
        label: 'FD',
        home: home,
        away: away,
        value: (stats) => stats.foulsDrawn,
        display: (stats) => _num(stats.foulsDrawn),
      ),
      _compare(
        label: 'BLK AG',
        home: home,
        away: away,
        value: (stats) => stats.blocksAgainst,
        display: (stats) => _num(stats.blocksAgainst),
        lowerIsBetter: true,
      ),
      _compare(
        label: '+/-',
        home: home,
        away: away,
        value: (stats) => stats.plusMinus,
        display: (stats) => _signed(stats.plusMinus),
      ),
      _compare(
        label: 'PTS FOR',
        home: home,
        away: away,
        value: (stats) => stats.pointsFor.toDouble(),
        display: (stats) => stats.pointsFor.toString(),
      ),
      _compare(
        label: 'PTS AG',
        home: home,
        away: away,
        value: (stats) => stats.pointsAgainst.toDouble(),
        display: (stats) => stats.pointsAgainst.toString(),
        lowerIsBetter: true,
      ),
    ];
  }

  static MatchupStatComparison _compare({
    required String label,
    required TeamStats home,
    required TeamStats away,
    required double Function(TeamStats stats) value,
    required String Function(TeamStats stats) display,
    bool lowerIsBetter = false,
  }) {
    return MatchupStatComparison(
      label: label,
      homeValue: value(home),
      awayValue: value(away),
      homeDisplay: display(home),
      awayDisplay: display(away),
      lowerIsBetter: lowerIsBetter,
    );
  }

  static bool _lowerIsBetter(String label) {
    return switch (label) {
      'TOV' || 'DEF RTG' || 'OPP PPG' || 'PF' || 'BLK AG' || 'PTS AG' => true,
      _ => false,
    };
  }

  static double _parseValue(String value) {
    final normalized = value.replaceAll('%', '').replaceAll('+', '').trim();
    return double.tryParse(normalized) ?? 0;
  }

  static String _num(double value) => value.toStringAsFixed(1);

  static String _pct(double value) => '${value.toStringAsFixed(1)}%';

  static String _signed(double value) {
    final prefix = value > 0 ? '+' : '';
    return '$prefix${value.toStringAsFixed(1)}';
  }
}
