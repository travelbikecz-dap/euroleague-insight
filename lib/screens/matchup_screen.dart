import 'package:flutter/material.dart';
import '../models/game.dart';
import '../models/standing.dart';
import '../data/mock_standings.dart';

class MatchUpScreen extends StatelessWidget {
  final Game game;

  const MatchUpScreen({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {

    final homeStanding = mockStandings.firstWhere(
    (standing) => standing.team.name == game.homeTeam.name,
    orElse: () => mockStandings.first,
    );

    final awayStanding = mockStandings.firstWhere(
      (standing) => standing.team.name == game.awayTeam.name,
      orElse: () => mockStandings.first,
    );
    
    final double homeWinProbability = 64;
    final double awayWinProbability = 36;

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text('MatchUp'),
        backgroundColor: Colors.black,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [

              Text(
                game.status,
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Column(
                    children: [

                      Image.asset(
                        game.homeTeam.logo,
                        width: 70,
                      ),

                      const SizedBox(height: 10),

                      Text(
                        game.homeTeam.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),

                  Text(
                    '${game.homeScore} - ${game.awayScore}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Column(
                    children: [

                      Image.asset(
                        game.awayTeam.logo,
                        width: 70,
                      ),

                      const SizedBox(height: 10),

                      Text(
                        game.awayTeam.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 40),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Center(
                      child: Text(
                        'Win Probability',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                                children: [

                                  Column(
                                    children: [

                                      const Text(
                                        'HOME',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      Text(
                                        '${homeWinProbability.round()}%',
                                        style: const TextStyle(
                                          color: Colors.orange,
                                          fontSize: 52,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),

                                  Container(
                                    width: 1,
                                    height: 70,
                                    color: Colors.white12,
                                  ),

                                  Column(
                                    children: [

                                      const Text(
                                        'AWAY',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      Text(
                                        '${awayWinProbability.round()}%',
                                        style: const TextStyle(
                                          color: Colors.orange,
                                          fontSize: 52,
                                          fontWeight: FontWeight.bold,
                         ),
                      ),
                   ],
                 ),
             ],
      ),
 ),

                    const SizedBox(height: 30),

                    SizedBox(
                      height: 135,

                      child: ListView(
                        scrollDirection: Axis.horizontal,

                        children: [

                          _buildStatCard(
                            'WINS',
                            homeStanding.wins,
                            awayStanding.wins,
                            false,
                          ),

                          _buildStatCard(
                            'LOSSES',
                            homeStanding.losses,
                            awayStanding.losses,
                            true,
                          ),

                          _buildStatCard(
                          'OFF RTG',
                          118,
                          111,
                          false,
                        ),

                        _buildStatCard(
                          'DEF RTG',
                          102,
                          108,
                          true,
                        ),

                        _buildStatCard(
                          'PACE',
                          74,
                          71,
                          false,
                        ),

                          _buildStatCard(
                            'POINTS FOR',
                            homeStanding.pointsFor,
                            awayStanding.pointsFor,
                            false,
                          ),

                          _buildStatCard(
                            'POINTS AGAINST',
                            homeStanding.pointsAgainst,
                            awayStanding.pointsAgainst,
                            true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    Text(
                      _getInsight(homeStanding, awayStanding),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    int homeValue,
    int awayValue,
    bool lowerIsBetter,
  ) {

    Color homeColor = Colors.white;
    Color awayColor = Colors.white;

    if (!lowerIsBetter) {

      if (homeValue > awayValue) {
        homeColor = Colors.green;
        awayColor = Colors.red;
      } else if (awayValue > homeValue) {
        homeColor = Colors.red;
        awayColor = Colors.green;
      }

    } else {

      if (homeValue < awayValue) {
        homeColor = Colors.green;
        awayColor = Colors.red;
      } else if (awayValue < homeValue) {
        homeColor = Colors.red;
        awayColor = Colors.green;
      }
    }

    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 12),

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 25),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [

              Text(
                '$homeValue',
                style: TextStyle(
                  color: homeColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Text(
                '-',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 24,
                ),
              ),

              Text(
                '$awayValue',
                style: TextStyle(
                  color: awayColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
String _getInsight(
  Standing home,
  Standing away,
) {

  if (home.wins > away.wins) {
    return '${home.team.name} comes into this matchup with stronger overall form and better season consistency.';
  }

  if (away.wins > home.wins) {
    return '${away.team.name} has shown stronger results recently and appears more competitive statistically.';
  }

  return 'Both teams arrive with very similar performance levels, making this matchup highly balanced.';
}