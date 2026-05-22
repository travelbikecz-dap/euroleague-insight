import 'package:flutter/material.dart';
import '../models/team_stats.dart';

class TeamDetailScreen extends StatefulWidget {
  final List<TeamStats> teams;
  final int initialIndex;

  const TeamDetailScreen({
    super.key,
    required this.teams,
    required this.initialIndex,
  });

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.teams.length,
      itemBuilder: (context, index) {
        final team = widget.teams[index];

        return Scaffold(
          backgroundColor: Colors.black,

          appBar: AppBar(
            backgroundColor: Colors.black,
            title: Text(team.teamName),
          ),

          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [
                Image.asset(team.logo, width: 120, height: 120),

                const SizedBox(height: 20),

                Text(
                  team.teamName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                Center(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,

                    children: [
                      _buildStatCard('PPG', team.ppg.toString()),
                      _buildStatCard('REB', team.rebounds.toString()),
                      _buildStatCard('AST', team.assists.toString()),
                      _buildStatCard('3PT%', team.threePoint.toString()),
                      _buildStatCard('PACE', team.pace.toString()),
                      _buildStatCard(
                        'OFF RTG',
                        team.offensiveRating.toString(),
                      ),
                      _buildStatCard(
                        'DEF RTG',
                        team.defensiveRating.toString(),
                      ),
                      _buildStatCard('TOV', team.turnovers.toString()),
                      _buildStatCard('NET RTG', team.netRating.toString()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      width: 78,

      padding: const EdgeInsets.all(8),

      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
