import 'dart:convert';
import '../models/team.dart';
import '../models/standing.dart';
import 'package:http/http.dart' as http;

class StandingsApiService {
  Future<List<Standing>> fetchStandings() async {
    final url = Uri.parse(
      'https://api-live.euroleague.net/v3/competitions/E/seasons/E2025/rounds/38/basicstandings',
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
    print('ROUND TEST -> ${standings.first.team.name}');
    return standings;
  }
}
