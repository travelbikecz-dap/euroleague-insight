import 'team.dart';

class Standing {
  final Team team;
  final int wins;
  final int losses;
  final int pointsFor;
  final int pointsAgainst;

  Standing({
    required this.team,
    required this.wins,
    required this.losses,
    required this.pointsFor,
    required this.pointsAgainst,
  });
}