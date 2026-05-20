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

  Team(
    name: 'Panathinaikos',
    logo: 'assets/logos/panathinaikos.png',
  ),

  Team(
    name: 'Anadolu Efes',
    logo: 'assets/logos/anadolu.png',
  ),

  Team(
    name: 'Virtus Bologna',
    logo: 'assets/logos/virtus.png',
  ),

  Team(
    name: 'Maccabi Tel Aviv',
    logo: 'assets/logos/maccabi.png',
  ),

  Team(
    name: 'Baskonia',
    logo: 'assets/logos/baskonia.png',
  ),

  Team(
    name: 'Zalgiris',
    logo: 'assets/logos/zalgiris.png',
  ),

  Team(
    name: 'Crvena Zvezda',
    logo: 'assets/logos/crvena.png',
  ),

  Team(
    name: 'Olimpia Milano',
    logo: 'assets/logos/milano.png',
  ),

  Team(
    name: 'Bayern Munich',
    logo: 'assets/logos/munich.png',
  ),

  Team(
    name: 'ASVEL',
    logo: 'assets/logos/lyon.png',
  ),

  Team(
    name: 'Paris Basketball',
    logo: 'assets/logos/paris.png',
  ),

  Team(
    name: 'Valencia Basket',
    logo: 'assets/logos/valencia.png',
  ),

  Team(
    name: 'Hapoel',
    logo: 'assets/logos/hapoel.png',
  ),

  Team(
    name: 'Dubai BC',
    logo: 'assets/logos/dubai.png',
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

  Game(
    homeTeam: gameTeams[6],
    awayTeam: gameTeams[7],
    homeScore: 91,
    awayScore: 87,
    status: 'FINAL',
  ),

  Game(
    homeTeam: gameTeams[8],
    awayTeam: gameTeams[9],
    homeScore: 76,
    awayScore: 81,
    status: 'LIVE • Q4 01:45',
  ),

  Game(
    homeTeam: gameTeams[10],
    awayTeam: gameTeams[11],
    homeScore: 84,
    awayScore: 78,
    status: 'FINAL',
  ),

  Game(
    homeTeam: gameTeams[12],
    awayTeam: gameTeams[13],
    homeScore: 73,
    awayScore: 75,
    status: 'Q2 • 06:52',
  ),

  Game(
    homeTeam: gameTeams[14],
    awayTeam: gameTeams[15],
    homeScore: 0,
    awayScore: 0,
    status: '21:00',
  ),

  Game(
    homeTeam: gameTeams[16],
    awayTeam: gameTeams[17],
    homeScore: 89,
    awayScore: 91,
    status: 'FINAL',
  ),

  Game(
    homeTeam: gameTeams[18],
    awayTeam: gameTeams[19],
    homeScore: 0,
    awayScore: 0,
    status: '22:15',
  ),
];