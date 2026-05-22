import 'package:flutter/material.dart';
import '../data/mock_standings.dart';
import 'team_detail_screen.dart';
import '../data/mock_team_stats.dart';

class StandingsScreen extends StatelessWidget {
  const StandingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: mockStandings.length,

      itemBuilder: (context, index) {
        final standing = mockStandings[index];

        Color cardColor = const Color(0xFF1C1C1E);

        if (index <= 5) {
          cardColor = const Color(0xFF1E88E5).withOpacity(0.80);
        } else if (index <= 9) {
          cardColor = const Color(0xFFFB8C00).withOpacity(0.80);
        }

        return InkWell(
          onTap: () {
            Navigator.push(
              context,

              MaterialPageRoute(
                builder: (context) {
                  final selectedIndex = mockTeamStats.indexWhere(
                    (team) => team.teamName == standing.team.name,
                  );

                  return TeamDetailScreen(
                    teams: mockTeamStats,
                    initialIndex: selectedIndex,
                  );
                },
              ),
            );
          },

          child: Card(
            color: cardColor,

            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

            child: ListTile(
              leading: Row(
                mainAxisSize: MainAxisSize.min,

                children: [
                  Text(
                    '${index + 1}.',

                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Image.asset(
                    standing.team.logo,

                    width: 40,
                    height: 40,

                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.sports_basketball,
                        color: Colors.orange,
                      );
                    },
                  ),
                ],
              ),

              title: Text(
                standing.team.name,

                style: const TextStyle(color: Colors.white),
              ),

              subtitle: Text(
                'W: ${standing.wins} | L: ${standing.losses}',

                style: const TextStyle(color: Colors.white),
              ),

              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Text(
                    'PF: ${standing.pointsFor}',

                    style: const TextStyle(color: Colors.white),
                  ),

                  Text(
                    'PA: ${standing.pointsAgainst}',

                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
