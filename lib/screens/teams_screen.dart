import 'package:flutter/material.dart';

import '../data/mock_team_stats.dart';
import '../models/team_stats.dart';

class TeamsScreen extends StatelessWidget {
  const TeamsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return ListView.builder(

      padding: const EdgeInsets.all(16),

      itemCount: mockTeamStats.length,

      itemBuilder: (context, index) {

        final TeamStats team = mockTeamStats[index];

        return Container(

          margin: const EdgeInsets.only(bottom: 16),

          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(20),
          ),

          child: Row(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              // LEFT SIDE
              SizedBox(

                width: 110,

                child: Column(

                  children: [

                    Image.asset(
                      team.logo,
                      width: 50,
                      height: 50,
                    ),

                    const SizedBox(height: 10),

                    Text(

                      team.teamName,

                      textAlign: TextAlign.center,

                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 20),

              // RIGHT SIDE
              Expanded(

                child: SingleChildScrollView(

                  scrollDirection: Axis.horizontal,

                  child: Row(

                    children: [

                      _buildStat('PPG', team.ppg.toString()),
                      _buildStat('REB', team.rebounds.toString()),
                      _buildStat('AST', team.assists.toString()),
                      _buildStat('3PT%', team.threePoint.toString()),
                      _buildStat('PACE', team.pace.toString()),
                      _buildStat('OFF RTG', team.offensiveRating.toString()),
                      _buildStat('DEF RTG', team.defensiveRating.toString()),
                      _buildStat('TOV', team.turnovers.toString()),
                      _buildStat('NET RTG', team.netRating.toString()),

                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStat(String label, String value) {

    return Padding(

      padding: const EdgeInsets.only(right: 24),

      child: Column(

        children: [

          Text(
            label,

            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 6),

          Text(

            value,

            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}