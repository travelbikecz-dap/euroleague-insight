import 'team.dart';

class Game {
  final Team homeTeam;
  final Team awayTeam;
  final int homeScore;
  final int awayScore;
  final String status;

  Game({
    required this.homeTeam,
    required this.awayTeam,
    required this.homeScore,
    required this.awayScore,
    required this.status,
  });
}