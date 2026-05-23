import '../data/mock_team_stats.dart';
import '../models/team_stats.dart';

class TeamStatsService {
  List<TeamStats> getAllTeams() {
    return mockTeamStats;
  }

  TeamStats? getTeamByName(String teamName) {
    try {
      return mockTeamStats.firstWhere((team) => team.teamName == teamName);
    } catch (_) {
      return null;
    }
  }
}
