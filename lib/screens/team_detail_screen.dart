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
  static const double _statCardWidth = 78;
  static const double _statCardHeight = 72;
  static const double _gridSpacing = 8;
  static const int _gridColumns = 4;
  static const double _gridWidth =
      _statCardWidth * _gridColumns + _gridSpacing * (_gridColumns - 1);

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
        final previousTeam = index > 0 ? widget.teams[index - 1] : null;
        final nextTeam = index < widget.teams.length - 1
            ? widget.teams[index + 1]
            : null;

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(backgroundColor: Colors.black),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          previousTeam != null
                              ? '‹ ${previousTeam.teamName}'
                              : '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          nextTeam != null ? '${nextTeam.teamName} ›' : '',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Center(
                        child: Image.asset(team.logo, width: 120, height: 120),
                      ),
                      Positioned(
                        left: 20,
                        top: 35,
                        child: Text(
                          '${team.position}.',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  team.teamName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'LAST 5',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: team.last5Form.map((result) {
                    return Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      child: Text(
                        result == 'W' ? '✅' : '❌',
                        style: const TextStyle(fontSize: 20),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 30),
                _buildStatsSection('TEAM OVERVIEW', team.overviewStats),
                _buildSectionDivider(),
                _buildStatsSection('TEAM PERFORMANCE', team.performanceStats),
                _buildSectionDivider(),
                _buildStatsSection('ADVANCED ANALYTICS', team.advancedStats),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsSection(String title, List<TeamStatItem> stats) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: SizedBox(
            width: _gridWidth,
            child: Wrap(
              spacing: _gridSpacing,
              runSpacing: _gridSpacing,
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              children: stats
                  .map(
                    (stat) => SizedBox(
                      width: _statCardWidth,
                      height: _statCardHeight,
                      child: _buildStatCard(stat.label, stat.value),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: SizedBox(
          width: _gridWidth,
          child: Divider(color: Colors.grey[800], height: 1),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      width: _statCardWidth,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
