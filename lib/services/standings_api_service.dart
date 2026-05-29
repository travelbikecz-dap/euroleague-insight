import '../config/season_config.dart';
import '../models/standing.dart';
import '../models/team.dart';
import 'api_cache.dart';
import 'euroleague_api_client.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class StandingsApiService {
  StandingsApiService({EuroleagueApiClient? client, http.Client? httpClient})
    : _client = client ?? EuroleagueApiClient(),
      _httpClient = httpClient ?? http.Client();

  final EuroleagueApiClient _client;
  final http.Client _httpClient;

  Future<List<Standing>> fetchStandings({bool forceRefresh = false}) async {
    final seasonCode = getCurrentSeasonCode();
    final standingRound = await getLatestValidStandingsRound(
      forceRefresh: forceRefresh,
    );

    final cacheKey = 'standings_${seasonCode}_$standingRound';
    if (!forceRefresh) {
      final cached = ApiCache.instance.get<List<Standing>>(cacheKey);
      if (cached != null) return cached;
    }

    final data = await _client.getJson(
      'https://api-live.euroleague.net/v3/competitions/E/seasons/$seasonCode/rounds/$standingRound/basicstandings',
      cacheKey: cacheKey,
      cacheTtl: CacheDurations.liveData,
      forceRefresh: forceRefresh,
    );

    final List<Standing> standings = [];

    for (final team in data['teams'] as List<dynamic>) {
      final club = team['club'] as Map<String, dynamic>;
      final last5Form = (team['last5Form'] as List<dynamic>? ?? [])
          .map((result) => result.toString())
          .toList();

      standings.add(
        Standing(
          position: team['position'] as int? ?? standings.length + 1,
          clubCode: club['code'] as String? ?? '',
          team: Team(
            name: club['name'] as String? ?? '',
            logo: getLocalLogo(club['name'] as String? ?? ''),
          ),
          wins: team['gamesWon'] as int? ?? 0,
          losses: team['gamesLost'] as int? ?? 0,
          gamesPlayed: team['gamesPlayed'] as int? ?? 0,
          pointsFor: team['pointsFor'] as int? ?? 0,
          pointsAgainst: team['pointsAgainst'] as int? ?? 0,
          last5Form: last5Form,
        ),
      );
    }

    ApiCache.instance.set(cacheKey, standings, CacheDurations.liveData);
    return standings;
  }

  Future<int> getLatestValidStandingsRound({bool forceRefresh = false}) async {
    final seasonCode = getCurrentSeasonCode();
    final cacheKey = 'latest_standings_round_$seasonCode';

    if (!forceRefresh) {
      final cached = ApiCache.instance.get<int>(cacheKey);
      if (cached != null) return cached;
    }

    final resultsUrl =
        'https://api-live.euroleague.net/v1/results/?seasonCode=$seasonCode';
    final resultsResponse = await _getCachedXml(
      resultsUrl,
      cacheKey: 'results_xml_$seasonCode',
      forceRefresh: forceRefresh,
    );

    final document = XmlDocument.parse(resultsResponse);
    final gamedays = document.findAllElements('gameday');

    int maxRound = 0;
    for (final gameday in gamedays) {
      final round = int.tryParse(gameday.innerText) ?? 0;
      if (round > maxRound) maxRound = round;
    }

    for (int round = maxRound; round >= 1; round--) {
      final standingsUrl =
          'https://api-live.euroleague.net/v3/competitions/E/seasons/$seasonCode/rounds/$round/basicstandings';

      try {
        final data = await _client.getJson(
          standingsUrl,
          cacheKey: 'standings_probe_${seasonCode}_$round',
          cacheTtl: CacheDurations.liveData,
          forceRefresh: forceRefresh,
        );

        if (data['teams'] != null) {
          ApiCache.instance.set(cacheKey, round, CacheDurations.liveData);
          return round;
        }
      } catch (_) {}
    }

    ApiCache.instance.set(cacheKey, 38, CacheDurations.liveData);
    return 38;
  }

  Future<String> _getCachedXml(
    String url, {
    required String cacheKey,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = ApiCache.instance.get<String>(cacheKey);
      if (cached != null) return cached;
    }

    final response = await _httpClient.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('API error ${response.statusCode} for $url');
    }

    ApiCache.instance.set(cacheKey, response.body, CacheDurations.liveData);
    return response.body;
  }

  Future<List<String>> getRecentForm(
    String teamName, {
    bool forceRefresh = false,
  }) async {
    final apiTeamName = getApiTeamName(teamName).toLowerCase();
    final seasonCode = getCurrentSeasonCode();
    final cacheKey = 'recent_form_${seasonCode}_$apiTeamName';

    if (!forceRefresh) {
      final cached = ApiCache.instance.get<List<String>>(cacheKey);
      if (cached != null) return cached;
    }

    final url =
        'https://api-live.euroleague.net/v1/results/?seasonCode=$seasonCode';
    final responseBody = await _getCachedXml(
      url,
      cacheKey: 'results_xml_$seasonCode',
      forceRefresh: forceRefresh,
    );

    final document = XmlDocument.parse(responseBody);
    final games = document.findAllElements('game');
    final List<Map<String, dynamic>> gamesData = [];

    for (final game in games) {
      final homeTeam = game
          .findElements('hometeam')
          .first
          .innerText
          .toLowerCase();
      final awayTeam = game
          .findElements('awayteam')
          .first
          .innerText
          .toLowerCase();
      final homeScore =
          int.tryParse(game.findElements('homescore').first.innerText) ?? 0;
      final awayScore =
          int.tryParse(game.findElements('awayscore').first.innerText) ?? 0;
      final played = game.findElements('played').first.innerText == 'true';
      final round = game.findElements('round').first.innerText;

      if (!played || round != 'RS') continue;

      final isTeamPlaying =
          homeTeam == apiTeamName || awayTeam == apiTeamName;
      if (!isTeamPlaying) continue;

      final isWin = homeTeam == apiTeamName
          ? homeScore > awayScore
          : awayScore > homeScore;
      final gameday =
          int.tryParse(game.findElements('gameday').first.innerText) ?? 0;

      gamesData.add({'gameday': gameday, 'result': isWin ? 'W' : 'L'});
    }

    gamesData.sort((a, b) => a['gameday'].compareTo(b['gameday']));

    var form = gamesData.map((game) => game['result'] as String).toList();
    if (form.length > 5) {
      form = form.sublist(form.length - 5);
    }

    ApiCache.instance.set(cacheKey, form, CacheDurations.liveData);
    return form;
  }

  String getLocalLogo(String teamName) {
    switch (teamName.toLowerCase()) {
      case 'real madrid':
        return 'assets/logos/real_madrid.png';
      case 'olympiacos piraeus':
        return 'assets/logos/olympiacos.png';
      case 'fenerbahce beko istanbul':
        return 'assets/logos/fenerbahce.png';
      case 'fc barcelona':
        return 'assets/logos/barcelona.png';
      case 'kosner baskonia vitoria-gasteiz':
        return 'assets/logos/baskonia.png';
      case 'virtus bologna':
        return 'assets/logos/virtus.png';
      case 'partizan mozzart bet belgrade':
        return 'assets/logos/partizan.png';
      case 'crvena zvezda meridianbet belgrade':
        return 'assets/logos/crvena.png';
      case 'maccabi rapyd tel aviv':
        return 'assets/logos/maccabi.png';
      case 'anadolu efes istanbul':
        return 'assets/logos/anadolu.png';
      case 'panathinaikos aktor athens':
        return 'assets/logos/panathinaikos.png';
      case 'zalgiris kaunas':
        return 'assets/logos/zalgiris.png';
      case 'as monaco':
        return 'assets/logos/monaco.png';
      case 'ea7 emporio armani milan':
        return 'assets/logos/milano.png';
      case 'paris basketball':
        return 'assets/logos/paris.png';
      case 'fc bayern munich':
        return 'assets/logos/munich.png';
      case 'valencia basket':
        return 'assets/logos/valencia.png';
      case 'ldlc asvel villeurbanne':
        return 'assets/logos/lyon.png';
      case 'hapoel ibi tel aviv':
        return 'assets/logos/hapoel.png';
      case 'dubai basketball':
        return 'assets/logos/dubai.png';
      default:
        return 'assets/logos/euroleague.png';
    }
  }

  String getApiTeamName(String teamName) {
    switch (teamName.toLowerCase()) {
      case 'olympiacos':
        return 'Olympiacos Piraeus';
      case 'real madrid':
        return 'Real Madrid';
      case 'fenerbahce':
        return 'Fenerbahce Beko Istanbul';
      case 'barcelona':
        return 'FC Barcelona';
      case 'baskonia':
        return 'Kosner Baskonia Vitoria-Gasteiz';
      case 'virtus':
        return 'Virtus Bologna';
      case 'partizan':
        return 'Partizan Mozzart Bet Belgrade';
      case 'crvena zvezda':
        return 'Crvena Zvezda Meridianbet Belgrade';
      case 'maccabi':
        return 'Maccabi Rapyd Tel Aviv';
      case 'anadolu efes':
        return 'Anadolu Efes Istanbul';
      case 'panathinaikos':
        return 'Panathinaikos AKTOR Athens';
      case 'zalgiris':
        return 'Zalgiris Kaunas';
      case 'monaco':
        return 'AS Monaco';
      case 'milano':
        return 'EA7 Emporio Armani Milan';
      case 'paris':
        return 'Paris Basketball';
      case 'bayern':
        return 'FC Bayern Munich';
      case 'valencia':
        return 'Valencia Basket';
      case 'asvel':
        return 'LDLC ASVEL Villeurbanne';
      case 'hapoel':
        return 'Hapoel IBI Tel Aviv';
      case 'dubai':
        return 'Dubai Basketball';
      default:
        return teamName;
    }
  }
}
