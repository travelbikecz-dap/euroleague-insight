import '../models/standing.dart';
import '../models/team_stats.dart';
import 'standings_api_service.dart';
import 'team_stats_api_service.dart';

class TeamStatsService {
  TeamStatsService({
    TeamStatsApiService? api,
    StandingsApiService? standingsApi,
  }) : _api = api ?? TeamStatsApiService(standingsApi: standingsApi);

  final TeamStatsApiService _api;

  Future<List<TeamStats>> getAllTeams({bool forceRefresh = false}) {
    return _api.fetchAllTeamStats(forceRefresh: forceRefresh);
  }

  Future<TeamStats?> getTeamByName(String teamName) async {
    final teams = await getAllTeams();
    try {
      return teams.firstWhere((team) => team.teamName == teamName);
    } catch (_) {
      return null;
    }
  }
}

class StandingsService {
  StandingsService({StandingsApiService? api}) : _api = api ?? StandingsApiService();

  final StandingsApiService _api;

  Future<List<Standing>> getStandings({bool forceRefresh = false}) {
    return _api.fetchStandings(forceRefresh: forceRefresh);
  }
}
