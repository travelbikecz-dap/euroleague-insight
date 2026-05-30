class MockGameMvp {
  final String playerName;
  final String displayName;
  final String teamName;
  final String teamLogo;
  final String? photoUrl;
  final String dorsal;
  final double pir;
  final double points;
  final double rebounds;
  final double assists;
  final double steals;
  final double blocks;
  final double turnovers;
  final int plusMinus;
  final String minutes;
  final String shootingLine;

  const MockGameMvp({
    required this.playerName,
    required this.displayName,
    required this.teamName,
    required this.teamLogo,
    this.photoUrl,
    required this.dorsal,
    required this.pir,
    required this.points,
    required this.rebounds,
    required this.assists,
    required this.steals,
    required this.blocks,
    required this.turnovers,
    required this.plusMinus,
    required this.minutes,
    required this.shootingLine,
  });
}

class MockGameMvpData {
  MockGameMvpData._();

  static const previews = [
    MockGameMvp(
      playerName: 'HEZONJA, MARIO',
      displayName: 'Mario Hezonja',
      teamName: 'Real Madrid',
      teamLogo: 'assets/logos/real_madrid.png',
      photoUrl:
          'https://media-cdn.cortextech.io/c415b3ab-6a2d-4ff4-8504-5119fca3c9f6.png',
      dorsal: '11',
      pir: 19,
      points: 16,
      rebounds: 4,
      assists: 2,
      steals: 1,
      blocks: 0,
      turnovers: 1,
      plusMinus: 12,
      minutes: '21:43',
      shootingLine: '6/9 FG · 4/7 3P · 0/0 FT',
    ),
    MockGameMvp(
      playerName: 'VEZENKOV, SASHA',
      displayName: 'Sasha Vezenkov',
      teamName: 'Olympiacos',
      teamLogo: 'assets/logos/olympiacos.png',
      dorsal: '14',
      pir: 24,
      points: 22,
      rebounds: 9,
      assists: 1,
      steals: 0,
      blocks: 1,
      turnovers: 2,
      plusMinus: 8,
      minutes: '32:10',
      shootingLine: '8/14 FG · 3/6 3P · 3/3 FT',
    ),
    MockGameMvp(
      playerName: 'SHORTS, TJ',
      displayName: 'T.J. Shorts',
      teamName: 'Paris Basketball',
      teamLogo: 'assets/logos/paris.png',
      dorsal: '0',
      pir: 21,
      points: 18,
      rebounds: 3,
      assists: 11,
      steals: 3,
      blocks: 0,
      turnovers: 4,
      plusMinus: 15,
      minutes: '34:02',
      shootingLine: '7/15 FG · 2/5 3P · 2/2 FT',
    ),
  ];

  static MockGameMvp forGame(int gameCode) {
    return previews[gameCode.abs() % previews.length];
  }
}
