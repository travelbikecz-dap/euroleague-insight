import 'team.dart';

class Standing {
  final Team team;
  final String clubCode;
  final int position;
  final int wins;
  final int losses;
  final int gamesPlayed;
  final int pointsFor;
  final int pointsAgainst;
  final List<String> last5Form;

  Standing({
    required this.team,
    required this.wins,
    required this.losses,
    required this.pointsFor,
    required this.pointsAgainst,
    this.clubCode = '',
    this.position = 0,
    this.gamesPlayed = 0,
    this.last5Form = const [],
  });
}
