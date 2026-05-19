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

    final Standing homeStanding = mockStandings.firstWhere(
      (standing) => standing.team.name == game.homeTeam.name,
    );

    final Standing awayStanding = mockStandings.firstWhere(
      (standing) => standing.team.name == game.awayTeam.name,
    );

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
                      child: Text(
                        '${game.homeTeam.name} 64% • ${game.awayTeam.name} 36%',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      height: 190,

                      child: ListView(
                        scrollDirection: Axis.horizontal,

                        children: [

                          _buildStatCard(
                            'WINS',
                            homeStanding.wins,
                            awayStanding.wins,
                          ),

                          _buildStatCard(
                            'LOSSES',
                            homeStanding.losses,
                            awayStanding.losses,
                          ),

                          _buildStatCard(
                          'OFF RTG',
                          118,
                          111,
                        ),

                        _buildStatCard(
                          'DEF RTG',
                          102,
                          108,
                        ),

                        _buildStatCard(
                          'PACE',
                          74,
                          71,
                        ),

                          _buildStatCard(
                            'POINTS FOR',
                            homeStanding.pointsFor,
                            awayStanding.pointsFor,
                          ),

                          _buildStatCard(
                            'POINTS AGAINST',
                            homeStanding.pointsAgainst,
                            awayStanding.pointsAgainst,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    Text(
                      '${game.homeTeam.name} arrives with better offensive efficiency and stronger recent form.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
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
  ) {

    Color homeColor = Colors.white;
    Color awayColor = Colors.white;

    if (homeValue > awayValue) {
      homeColor = Colors.green;
      awayColor = Colors.red;
    } else if (awayValue > homeValue) {
      homeColor = Colors.red;
      awayColor = Colors.green;
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
              color: Colors.white70,
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