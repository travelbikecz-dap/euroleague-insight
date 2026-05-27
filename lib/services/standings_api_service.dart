import 'dart:convert';
import '../models/team.dart';
import '../models/standing.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class StandingsApiService {
  Future<List<Standing>> fetchStandings() async {
    final standingRound = await getLatestValidStandingsRound();

    final url = Uri.parse(
      'https://api-live.euroleague.net/v3/competitions/E/seasons/E2025/rounds/$standingRound/basicstandings',
    );

    final response = await http.get(url);

    final data = jsonDecode(response.body);

    final List<Standing> standings = [];

    for (final team in data['teams']) {
      print('TEAM NAME: ${team['club']['name']}');
      standings.add(
        Standing(
          team: Team(
            name: team['club']['name'],
            logo: getLocalLogo(team['club']['name']),
          ),
          wins: team['gamesWon'],
          losses: team['gamesLost'],
          pointsFor: team['pointsFor'],
          pointsAgainst: team['pointsAgainst'],
        ),
      );
    }

    return standings;
  }

  Future<int> getLatestValidStandingsRound() async {
    final resultsUrl = Uri.parse(
      'https://api-live.euroleague.net/v1/results/?seasonCode=E2025',
    );

    final resultsResponse = await http.get(resultsUrl);

    final document = XmlDocument.parse(resultsResponse.body);

    final gamedays = document.findAllElements('gameday');

    int maxRound = 0;

    for (final gameday in gamedays) {
      final round = int.tryParse(gameday.innerText) ?? 0;

      if (round > maxRound) {
        maxRound = round;
      }
    }

    for (int round = maxRound; round >= 1; round--) {
      final standingsUrl = Uri.parse(
        'https://api-live.euroleague.net/v3/competitions/E/seasons/E2025/rounds/$round/basicstandings',
      );

      final standingsResponse = await http.get(standingsUrl);

      if (standingsResponse.statusCode == 200) {
        try {
          final data = jsonDecode(standingsResponse.body);

          if (data['teams'] != null) {
            return round;
          }
        } catch (_) {}
      }
    }

    return 38;
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

  Future<List<String>> getRecentForm(String teamName) async {
    final apiTeamName = getApiTeamName(teamName).toLowerCase();
    print('API TEAM NAME: $apiTeamName');

    final url = Uri.parse(
      'https://api-live.euroleague.net/v1/results/?seasonCode=E2025',
    );

    final response = await http.get(url);

    final document = XmlDocument.parse(response.body);

    print(response.body.substring(0, 1000));

    final games = document.findAllElements('game');

    List<String> form = [];

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

      if (!played) continue;

      bool isTeamPlaying = homeTeam == apiTeamName || awayTeam == apiTeamName;

      if (!isTeamPlaying) continue;

      bool isWin = false;

      if (homeTeam == apiTeamName) {
        isWin = homeScore > awayScore;
      } else {
        isWin = awayScore > homeScore;
      }

      form.add(isWin ? 'W' : 'L');
    }

    if (form.length > 5) {
      form = form.sublist(form.length - 5);
    }

    print('Form For $teamName: $form');

    return form;
  }
}
