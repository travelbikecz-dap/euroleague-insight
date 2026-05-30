import '../models/player_experience.dart';
import 'api_cache.dart';
import 'euroleague_api_client.dart';

class PlayerExperienceApiService {
  PlayerExperienceApiService({EuroleagueApiClient? client})
    : _client = client ?? EuroleagueApiClient();

  final EuroleagueApiClient _client;

  Future<PlayerEuroleagueExperience?> fetchExperience(
    String playerCode, {
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'player_experience_$playerCode';

    if (!forceRefresh) {
      final cached = ApiCache.instance.get<PlayerEuroleagueExperience>(cacheKey);
      if (cached != null) return cached;
    }

    final data = await _client.getJsonList(
      'https://api-live.euroleague.net/v2/people/$playerCode/summary',
      cacheKey: '${cacheKey}_raw',
      cacheTtl: CacheDurations.clubStats,
      forceRefresh: forceRefresh,
    );

    var seasons = 0;
    var games = 0;

    for (final entry in data.whereType<Map>()) {
      final season = Map<String, dynamic>.from(entry);
      if (season['competitionCode'] != 'E') continue;

      seasons++;
      games += _i(season, 'gamesCount');
    }

    if (seasons == 0) return null;

    final result = PlayerEuroleagueExperience(seasons: seasons, games: games);
    ApiCache.instance.set(cacheKey, result, CacheDurations.clubStats);
    return result;
  }

  int _i(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is num) return value.toInt();
    return 0;
  }
}
