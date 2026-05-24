import '../data/mock_standings.dart';
import '../models/standing.dart';
import 'standings_api_service.dart';

class StandingsService {
  final StandingsApiService _api = StandingsApiService();

  Future<List<Standing>> getStandings() {
    return _api.fetchStandings();
  }

  Standing? getStandingByTeamName(String teamName) {
    try {
      return mockStandings.firstWhere(
        (standing) => standing.team.name == teamName,
      );
    } catch (_) {
      return null;
    }
  }
}
