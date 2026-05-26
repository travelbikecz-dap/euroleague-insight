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
      standings.add(
        Standing(
          team: Team(
            name: team['club']['name'],
            logo: team['club']['images']['crest'],
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
}
