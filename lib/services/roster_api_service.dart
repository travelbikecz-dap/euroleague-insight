import '../config/season_config.dart';
import '../models/player.dart';
import 'api_cache.dart';
import 'euroleague_api_client.dart';

class RosterApiService {
  RosterApiService({EuroleagueApiClient? client})
    : _client = client ?? EuroleagueApiClient();

  final EuroleagueApiClient _client;

  Future<List<Player>> fetchRoster(
    String clubCode, {
    bool forceRefresh = false,
  }) async {
    final seasonCode = getCurrentSeasonCode();
    const cacheVersion = 'v2';
    final cacheKey = 'roster_${cacheVersion}_${seasonCode}_$clubCode';

    if (!forceRefresh) {
      final cached = ApiCache.instance.get<List<Player>>(cacheKey);
      if (cached != null) return cached;
    }

    final data = await _client.getJsonList(
      'https://api-live.euroleague.net/v2/competitions/E/seasons/$seasonCode/clubs/$clubCode/people',
      cacheKey: '${cacheKey}_raw',
      cacheTtl: CacheDurations.clubStats,
      forceRefresh: forceRefresh,
    );

    final players = data
        .whereType<Map>()
        .map((entry) => Map<String, dynamic>.from(entry))
        .where((entry) => entry['type'] == 'J' && entry['active'] == true)
        .map(Player.fromRosterJson)
        .toList();

    players.sort((a, b) {
      final dorsalA = int.tryParse(a.dorsal) ?? 999;
      final dorsalB = int.tryParse(b.dorsal) ?? 999;
      return dorsalA.compareTo(dorsalB);
    });

    ApiCache.instance.set(cacheKey, players, CacheDurations.clubStats);
    return players;
  }
}
