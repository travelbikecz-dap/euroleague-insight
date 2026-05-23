import 'package:flutter/material.dart';

import '../models/team_stats.dart';
import '../services/team_stats_service.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  late List<TeamStats> teams;

  @override
  void initState() {
    super.initState();

    teams = TeamStatsService().getAllTeams();
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.all(16),

      itemCount: teams.length,

      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }

          final item = teams.removeAt(oldIndex);

          teams.insert(newIndex, item);
        });
      },

      itemBuilder: (context, index) {
        final TeamStats team = teams[index];

        return Container(
          key: ValueKey(team.teamName),

          margin: const EdgeInsets.only(bottom: 16),

          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(20),
          ),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              Center(
                child: ReorderableDragStartListener(
                  index: index,
                  child: const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(
                      Icons.drag_handle,
                      color: Colors.white54,
                      size: 28,
                    ),
                  ),
                ),
              ),
              // LEFT SIDE
              SizedBox(
                width: 110,

                child: Column(
                  children: [
                    Image.asset(team.logo, width: 50, height: 50),

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
            style: const TextStyle(color: Colors.white, fontSize: 12),
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
