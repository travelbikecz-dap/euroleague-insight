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
}
