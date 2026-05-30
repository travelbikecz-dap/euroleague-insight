import '../config/season_config.dart';
import '../data/team_names.dart';
import '../models/euroleague_game.dart';
import '../models/game_phase.dart';
import 'api_cache.dart';
import 'euroleague_api_client.dart';
import 'game_status_resolver.dart';
import 'standings_api_service.dart';

class GamesApiService {
  GamesApiService({
    EuroleagueApiClient? client,
    StandingsApiService? standingsService,
  }) : _client = client ?? EuroleagueApiClient(),
       _standingsService = standingsService ?? StandingsApiService();

  final EuroleagueApiClient _client;
  final StandingsApiService _standingsService;

  Future<List<EuroleagueGame>> fetchRegularSeasonGames({
    bool forceRefresh = false,
  }) async {
    const cacheVersion = 'v1';
    final seasonCode = getCurrentSeasonCode();
    final cacheKey = 'games_rs_${cacheVersion}_$seasonCode';

    if (!forceRefresh) {
      final cached = ApiCache.instance.get<List<EuroleagueGame>>(cacheKey);
      if (cached != null) return cached;
    }

    final games = <EuroleagueGame>[];
    const pageSize = 100;
    var offset = 0;
    int? total;

    while (true) {
      final page = await _client.getJson(
        'https://api-live.euroleague.net/v2/competitions/E/seasons/$seasonCode/games'
        '?limit=$pageSize&offset=$offset',
        cacheKey: '${cacheKey}_page_$offset',
        cacheTtl: CacheDurations.schedule,
        forceRefresh: forceRefresh,
      );

      final data = page['data'] as List<dynamic>? ?? const [];
      total ??= page['total'] as int?;

      for (final entry in data) {
        if (entry is! Map) continue;
        final game = _parseGame(
          Map<String, dynamic>.from(entry),
          seasonCode: seasonCode,
        );
        if (game != null && game.phase == GamePhase.regularSeason) {
          games.add(game);
        }
      }

      offset += data.length;
      if (data.isEmpty || (total != null && offset >= total)) {
        break;
      }
    }

    games.sort((a, b) {
      final roundCompare = a.round.compareTo(b.round);
      if (roundCompare != 0) return roundCompare;
      return a.utcDate.compareTo(b.utcDate);
    });

    ApiCache.instance.set(cacheKey, games, CacheDurations.schedule);
    return games;
  }

  EuroleagueGame? _parseGame(
    Map<String, dynamic> json, {
    required String seasonCode,
  }) {
    final phaseType = json['phaseType'] as Map<String, dynamic>?;
    final phase = gamePhaseFromApiCode(phaseType?['code'] as String?);

    final local = json['local'] as Map<String, dynamic>?;
    final road = json['road'] as Map<String, dynamic>?;
    if (local == null || road == null) return null;

    final homeClub = Map<String, dynamic>.from(local['club'] as Map? ?? {});
    final awayClub = Map<String, dynamic>.from(road['club'] as Map? ?? {});

    final homeApiName = homeClub['name'] as String? ?? '';
    final awayApiName = awayClub['name'] as String? ?? '';
    if (homeApiName.isEmpty || awayApiName.isEmpty) return null;

    final played = json['played'] as bool? ?? false;
    final apiGameStatus = json['gameStatus'] as String? ?? '';
    final utcDate = DateTime.tryParse(json['utcDate'] as String? ?? '');
    if (utcDate == null) return null;

    final status = GameStatusResolver.resolve(
      played: played,
      apiGameStatus: apiGameStatus,
      utcDate: utcDate,
    );

    return EuroleagueGame(
      gameCode: json['gameCode'] as int? ?? 0,
      seasonCode: seasonCode,
      phase: phase,
      round: json['round'] as int? ?? 0,
      roundLabel: json['roundName'] as String? ??
          json['roundAlias'] as String? ??
          'Round ${json['round']}',
      utcDate: utcDate,
      homeClubCode: homeClub['code'] as String? ?? '',
      awayClubCode: awayClub['code'] as String? ?? '',
      homeApiName: homeApiName,
      awayApiName: awayApiName,
      homeDisplayName: TeamNames.shortName(homeApiName),
      awayDisplayName: TeamNames.shortName(awayApiName),
      homeLogo: _standingsService.getLocalLogo(homeApiName),
      awayLogo: _standingsService.getLocalLogo(awayApiName),
      played: played,
      apiGameStatus: apiGameStatus,
      status: status,
      homeScore: _score(local, played),
      awayScore: _score(road, played),
    );
  }

  int? _score(Map<String, dynamic> side, bool played) {
    if (!played) return null;
    return side['score'] as int?;
  }
}
