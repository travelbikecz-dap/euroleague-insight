import 'package:flutter/material.dart';
import '../data/mock_standings.dart';
import 'team_detail_screen.dart';
import '../services/standings_service.dart';
import '../models/standing.dart';
import '../data/mock_team_stats.dart';
import '../data/team_names.dart';

class StandingsScreen extends StatefulWidget {
  const StandingsScreen({super.key});

  @override
  State<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends State<StandingsScreen> {
  late Future<List<Standing>> standings;

  @override
  void initState() {
    super.initState();

    standings = StandingsService().getStandings();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Standing>>(
      future: standings,

      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'ERROR: ${snapshot.error}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final standingsList = snapshot.data!;

        return ListView.builder(
          itemCount: standingsList.length,

          itemBuilder: (context, index) {
            final standing = standingsList[index];

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
                      final orderedTeamStats = mockStandings.map((standing) {
                        return mockTeamStats.firstWhere(
                          (stats) => stats.teamName == standing.team.name,
                        );
                      }).toList();

                      final selectedIndex = orderedTeamStats.indexWhere(
                        (team) =>
                            team.teamName ==
                            TeamNames.shortName(standing.team.name),
                      );

                      return TeamDetailScreen(
                        teams: orderedTeamStats,
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

                      Image.network(
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
                    TeamNames.shortName(standing.team.name),

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
      },
    );
  }
}
