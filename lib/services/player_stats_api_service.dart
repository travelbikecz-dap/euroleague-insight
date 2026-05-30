import '../config/season_config.dart';
import '../models/player.dart';
import '../utils/stats_calculator.dart';
import 'api_cache.dart';
import 'euroleague_api_client.dart';

class PlayerStatsApiService {
  PlayerStatsApiService({EuroleagueApiClient? client})
    : _client = client ?? EuroleagueApiClient();

  final EuroleagueApiClient _client;

  Future<PlayerSeasonStats?> fetchSeasonStats(
    Player player, {
    bool forceRefresh = false,
  }) async {
    final seasonCode = getCurrentSeasonCode();
    const cacheVersion = 'v2';
    final cacheKey = 'player_stats_${cacheVersion}_${seasonCode}_${player.code}';

    if (!forceRefresh) {
      final cached = ApiCache.instance.get<PlayerSeasonStats>(cacheKey);
      if (cached != null) return cached;
    }

    final data = await _client.getJsonList(
      'https://api-live.euroleague.net/v2/people/${player.code}/stats',
      cacheKey: '${cacheKey}_raw',
      cacheTtl: CacheDurations.clubStats,
      forceRefresh: forceRefresh,
    );

    if (data.isEmpty) return null;

    Map<String, dynamic>? competition;
    for (final entry in data.whereType<Map>()) {
      final item = Map<String, dynamic>.from(entry);
      if (item['competitionCode'] == 'E') {
        competition = item;
        break;
      }
    }
    competition ??= Map<String, dynamic>.from(data.first as Map);

    final seasons = competition['seasons'] as List<dynamic>? ?? [];

    Map<String, dynamic>? seasonEntry;
    for (final season in seasons) {
      final entry = season as Map<String, dynamic>;
      if (entry['seasonCode'] == seasonCode) {
        seasonEntry = entry;
        break;
      }
    }

    if (seasonEntry == null) return null;

    final stats = seasonEntry['stats'] as Map<String, dynamic>;
    final gamesPlayed = _i(stats, 'gamesPlayed');
    if (gamesPlayed <= 0) return null;

    final fieldGoalsMade = _d(stats, 'fieldGoalsMadeTotal');
    final fieldGoalsAttempted = _d(stats, 'fieldGoalsAttemptedTotal');
    final threePointersMade = _d(stats, 'fieldGoalsMade3');
    final threePointersAttempted = _d(stats, 'fieldGoalsAttempted3');
    final freeThrowsMade = _d(stats, 'freeThrowsMade');
    final freeThrowsAttempted = _d(stats, 'freeThrowsAttempted');

    final result = PlayerSeasonStats(
      playerCode: player.code,
      teamCode: seasonEntry['teamCode'] as String? ?? '',
      gamesPlayed: gamesPlayed,
      minutesPerGame: _d(stats, 'timePlayed') / gamesPlayed / 60,
      ppg: _d(stats, 'points') / gamesPlayed,
      rebounds: _d(stats, 'totalRebounds') / gamesPlayed,
      assists: _d(stats, 'assistances') / gamesPlayed,
      steals: _d(stats, 'steals') / gamesPlayed,
      blocks: _d(stats, 'blocksFavour') / gamesPlayed,
      turnovers: _d(stats, 'turnovers') / gamesPlayed,
      offensiveRebounds: _d(stats, 'offensiveRebounds') / gamesPlayed,
      defensiveRebounds: _d(stats, 'defensiveRebounds') / gamesPlayed,
      pir: _d(stats, 'valuation') / gamesPlayed,
      plusMinus: _d(stats, 'plusMinus') / gamesPlayed,
      fieldGoalPercentage: StatsCalculator.formatPercentage(
        StatsCalculator.percentage(fieldGoalsMade, fieldGoalsAttempted),
      ),
      threePointPercentage: StatsCalculator.formatPercentage(
        StatsCalculator.percentage(threePointersMade, threePointersAttempted),
      ),
      freeThrowPercentage: StatsCalculator.formatPercentage(
        StatsCalculator.percentage(freeThrowsMade, freeThrowsAttempted),
      ),
    );

    ApiCache.instance.set(cacheKey, result, CacheDurations.clubStats);
    return result;
  }

  double _d(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is num) return value.toDouble();
    return 0;
  }

  int _i(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is num) return value.toInt();
    return 0;
  }
}
