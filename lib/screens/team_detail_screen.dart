import 'package:flutter/material.dart';

import '../models/team_stats.dart';
import '../widgets/team_roster_section.dart';

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
        final previousTeam = index > 0 ? widget.teams[index - 1] : null;
        final nextTeam = index < widget.teams.length - 1
            ? widget.teams[index + 1]
            : null;

        return _TeamDetailPage(
          team: team,
          previousTeamName: previousTeam?.teamName,
          nextTeamName: nextTeam?.teamName,
        );
      },
    );
  }
}

class _TeamDetailPage extends StatefulWidget {
  final TeamStats team;
  final String? previousTeamName;
  final String? nextTeamName;

  const _TeamDetailPage({
    required this.team,
    this.previousTeamName,
    this.nextTeamName,
  });

  @override
  State<_TeamDetailPage> createState() => _TeamDetailPageState();
}

class _TeamDetailPageState extends State<_TeamDetailPage> {
  static const double _statCardWidth = 78;
  static const double _statCardHeight = 72;
  static const double _gridSpacing = 8;
  static const int _gridColumns = 4;
  static const double _gridWidth =
      _statCardWidth * _gridColumns + _gridSpacing * (_gridColumns - 1);

  final _scrollController = ScrollController();
  final _rosterKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _scrollToRoster() async {
    final context = _rosterKey.currentContext;
    if (context == null) return;

    await Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
      alignment: 0.0,
      alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
    );
  }

  @override
  Widget build(BuildContext context) {
    final team = widget.team;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
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
                        widget.previousTeamName != null
                            ? '‹ ${widget.previousTeamName}'
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
                        widget.nextTeamName != null
                            ? '${widget.nextTeamName} ›'
                            : '',
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
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildRosterCta(),
              const SizedBox(height: 24),
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
              KeyedSubtree(
                key: _rosterKey,
                child: _buildSectionDivider(),
              ),
              TeamRosterSection(
                clubCode: team.clubCode,
                teamName: team.teamName,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRosterCta() {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _scrollToRoster,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.groups_outlined, color: Colors.grey[300], size: 20),
                const SizedBox(width: 8),
                const Text(
                  'View Team Roster',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
