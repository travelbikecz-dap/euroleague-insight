import '../models/game.dart';
import '../models/team.dart';

final List<Team> gameTeams = [
  Team(
    name: 'Real Madrid',
    logo: 'assets/logos/real_madrid.png',
  ),
  Team(
    name: 'Fenerbahce',
    logo: 'assets/logos/fenerbahce.png',
  ),
  Team(
    name: 'Olympiacos',
    logo: 'assets/logos/olympiacos.png',
  ),
  Team(
    name: 'Barcelona',
    logo: 'assets/logos/barcelona.png',
  ),
  Team(
    name: 'Monaco',
    logo: 'assets/logos/monaco.png',
  ),
  Team(
    name: 'Partizan',
    logo: 'assets/logos/partizan.png',
  ),
];

final List<Game> mockGames = [
  Game(
    homeTeam: gameTeams[0],
    awayTeam: gameTeams[1],
    homeScore: 82,
    awayScore: 79,
    status: 'LIVE • Q4 03:22',
  ),
  Game(
    homeTeam: gameTeams[2],
    awayTeam: gameTeams[3],
    homeScore: 67,
    awayScore: 71,
    status: 'Q3 • 08:11',
  ),
  Game(
    homeTeam: gameTeams[4],
    awayTeam: gameTeams[5],
    homeScore: 0,
    awayScore: 0,
    status: '20:30',
  ),
];