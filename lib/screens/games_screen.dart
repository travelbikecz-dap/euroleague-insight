import 'package:flutter/material.dart';
import '../models/team.dart';
import '../models/game.dart';
import '../data/mock_games.dart';
import 'matchup_screen.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),

      children: [
        ...mockGames.map((game) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MatchUpScreen(
                    game: game,
                  ),
                ),
              );
            },

            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),

              child: GameCard(
                game: game,
                homeTeam: game.homeTeam,
                awayTeam: game.awayTeam,
                homeScore: game.homeScore.toString(),
                awayScore: game.awayScore.toString(),
                status: game.status,
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}

class GameCard extends StatelessWidget {
  final Game game;

  final Team homeTeam;
  final Team awayTeam;

  final String homeScore;
  final String awayScore;
  final String status;

  const GameCard({
    super.key,
    required this.game,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeScore,
    required this.awayScore,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Text(
            status,
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [

              Row(
                children: [

                  Image.asset(
                    homeTeam.logo,
                    width: 28,
                    height: 28,
                  ),

                  const SizedBox(width: 10),

                  Text(
                    homeTeam.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),

              Text(
                homeScore,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [

              Row(
                children: [

                  Image.asset(
                    awayTeam.logo,
                    width: 28,
                    height: 28,
                  ),

                  const SizedBox(width: 10),

                  Text(
                    awayTeam.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),

              Text(
                awayScore,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
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