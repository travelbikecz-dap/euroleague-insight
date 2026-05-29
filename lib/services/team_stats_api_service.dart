import '../config/season_config.dart';
import '../data/team_names.dart';
import '../models/standing.dart';
import '../models/team_stats.dart';
import '../utils/stats_calculator.dart';
import 'api_cache.dart';
import 'euroleague_api_client.dart';
import 'standings_api_service.dart';

class TeamStatsApiService {
  TeamStatsApiService({
    EuroleagueApiClient? client,
    StandingsApiService? standingsApi,
  }) : _client = client ?? EuroleagueApiClient(),
       _standingsApi = standingsApi ?? StandingsApiService();

  final EuroleagueApiClient _client;
  final StandingsApiService _standingsApi;

  Future<List<TeamStats>> fetchAllTeamStats({bool forceRefresh = false}) async {
    const cacheVersion = 'v2';
    final cacheKey = 'team_stats_${cacheVersion}_${getCurrentSeasonCode()}';
    if (!forceRefresh) {
      final cached = ApiCache.instance.get<List<TeamStats>>(cacheKey);
      if (cached != null) return cached;
    }

    final standings = await _standingsApi.fetchStandings(
      forceRefresh: forceRefresh,
    );

    final stats = await Future.wait(
      standings.map((standing) => _buildTeamStats(standing, forceRefresh)),
    );

    ApiCache.instance.set(cacheKey, stats, CacheDurations.clubStats);
    return stats;
  }

  Future<TeamStats> fetchTeamStats(
    Standing standing, {
    bool forceRefresh = false,
  }) {
    return _buildTeamStats(standing, forceRefresh);
  }

  Future<TeamStats> _buildTeamStats(
    Standing standing,
    bool forceRefresh,
  ) async {
    final seasonCode = getCurrentSeasonCode();
    final clubCode = standing.clubCode;
    final cacheKey = 'club_stats_${seasonCode}_${clubCode}_RS';

    final data = await _client.getJsonList(
      'https://api-live.euroleague.net/v3/competitions/E/seasons/$seasonCode/clubs/$clubCode/stats?phaseTypeCode=RS',
      cacheKey: cacheKey,
      cacheTtl: CacheDurations.clubStats,
      forceRefresh: forceRefresh,
    );

    final average = data.first['averagePerGame'] as Map<String, dynamic>;

    final ppg = _d(average, 'points');
    final twoPointersMade = _d(average, 'fieldGoalsMade2');
    final twoPointersAttempted = _d(average, 'fieldGoalsAttempted2');
    final threePointersMade = _d(average, 'fieldGoalsMade3');
    final threePointersAttempted = _d(average, 'fieldGoalsAttempted3');
    final freeThrowsMade = _d(average, 'freeThrowsMade');
    final freeThrowsAttempted = _d(average, 'freeThrowsAttempted');
    final fieldGoalsMade = _d(average, 'fieldGoalsMadeTotal');
    final fieldGoalsAttempted = _d(average, 'fieldGoalsAttemptedTotal');
    final offensiveRebounds = _d(average, 'offensiveRebounds');
    final defensiveRebounds = _d(average, 'defensiveRebounds');
    final rebounds = _d(average, 'totalRebounds');
    final assists = _d(average, 'assistances');
    final steals = _d(average, 'steals');
    final turnovers = _d(average, 'turnovers');
    final blocks = _d(average, 'blocksFavour');
    final blocksAgainst = _d(average, 'blocksAgainst');
    final foulsCommitted = _d(average, 'foulsCommited');
    final foulsDrawn = _d(average, 'foulsReceived');
    final pir = _d(average, 'valuation');
    final plusMinus = _d(average, 'plusMinus');

    final pointsAllowed = standing.gamesPlayed > 0
        ? standing.pointsAgainst / standing.gamesPlayed
        : 0.0;
    final pointDifferential = ppg - pointsAllowed;
    final winPercentage = standing.gamesPlayed > 0
        ? (standing.wins / standing.gamesPlayed) * 100
        : 0.0;

    final fieldGoalPercentage = StatsCalculator.percentage(
      fieldGoalsMade,
      fieldGoalsAttempted,
    );
    final twoPointPercentage = StatsCalculator.percentage(
      twoPointersMade,
      twoPointersAttempted,
    );
    final threePointPercentage = StatsCalculator.percentage(
      threePointersMade,
      threePointersAttempted,
    );
    final freeThrowPercentage = StatsCalculator.percentage(
      freeThrowsMade,
      freeThrowsAttempted,
    );
    final effectiveFieldGoalPercentage =
        StatsCalculator.effectiveFieldGoalPercentage(
          fieldGoalsMade: fieldGoalsMade,
          threePointersMade: threePointersMade,
          fieldGoalsAttempted: fieldGoalsAttempted,
        );
    final trueShootingPercentage = StatsCalculator.trueShootingPercentage(
      points: ppg,
      fieldGoalsAttempted: fieldGoalsAttempted,
      freeThrowsAttempted: freeThrowsAttempted,
    );
    final possessionsPerGame = StatsCalculator.possessions(
      fieldGoalsAttempted: fieldGoalsAttempted,
      freeThrowsAttempted: freeThrowsAttempted,
      offensiveRebounds: offensiveRebounds,
      turnovers: turnovers,
    );
    final pace = StatsCalculator.pace(
      fieldGoalsAttempted: fieldGoalsAttempted,
      freeThrowsAttempted: freeThrowsAttempted,
      offensiveRebounds: offensiveRebounds,
      turnovers: turnovers,
      minutesPlayed: _d(average, 'timePlayed'),
    );
    final offensiveRating = StatsCalculator.offensiveRating(
      points: ppg,
      possessions: possessionsPerGame,
    );
    final defensiveRating = StatsCalculator.defensiveRating(
      pointsAllowed: pointsAllowed,
      possessions: possessionsPerGame,
    );
    final netRating = offensiveRating - defensiveRating;
    final assistToTurnover = StatsCalculator.assistToTurnoverRatio(
      assists: assists,
      turnovers: turnovers,
    );

    return TeamStats(
      teamName: TeamNames.shortName(standing.team.name),
      apiTeamName: standing.team.name,
      clubCode: clubCode,
      logo: standing.team.logo,
      position: standing.position,
      wins: standing.wins,
      losses: standing.losses,
      gamesPlayed: standing.gamesPlayed,
      pointsFor: standing.pointsFor,
      pointsAgainst: standing.pointsAgainst,
      last5Form: standing.last5Form,
      ppg: ppg,
      pointsAllowed: pointsAllowed,
      pointDifferential: pointDifferential,
      winPercentage: winPercentage,
      rebounds: rebounds,
      offensiveRebounds: offensiveRebounds,
      defensiveRebounds: defensiveRebounds,
      assists: assists,
      steals: steals,
      blocks: blocks,
      blocksAgainst: blocksAgainst,
      turnovers: turnovers,
      assistToTurnover: assistToTurnover,
      fieldGoalPercentage: fieldGoalPercentage,
      twoPointPercentage: twoPointPercentage,
      threePointPercentage: threePointPercentage,
      freeThrowPercentage: freeThrowPercentage,
      twoPointersMade: twoPointersMade,
      twoPointersAttempted: twoPointersAttempted,
      threePointersMade: threePointersMade,
      threePointersAttempted: threePointersAttempted,
      freeThrowsMade: freeThrowsMade,
      freeThrowsAttempted: freeThrowsAttempted,
      effectiveFieldGoalPercentage: effectiveFieldGoalPercentage,
      trueShootingPercentage: trueShootingPercentage,
      pace: pace,
      offensiveRating: offensiveRating,
      defensiveRating: defensiveRating,
      netRating: netRating,
      pir: pir,
      foulsCommitted: foulsCommitted,
      foulsDrawn: foulsDrawn,
      plusMinus: plusMinus,
    );
  }

  double _d(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is num) return value.toDouble();
    return 0;
  }
}
