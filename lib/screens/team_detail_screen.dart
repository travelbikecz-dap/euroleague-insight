import 'package:flutter/material.dart';

import '../models/team_stats.dart';
import '../widgets/team_roster_section.dart';

/// Scroll offset after which the hero name is off-screen (~logo + title block).
const _kCompactHeaderScrollThreshold = 200.0;

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
  final _scrollControllers = <String, ScrollController>{};
  double _syncedScrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  ScrollController _scrollFor(String clubCode) {
    return _scrollControllers.putIfAbsent(clubCode, () {
      final controller = ScrollController(
        initialScrollOffset: _syncedScrollOffset,
      );
      controller.addListener(() {
        if (!controller.hasClients) return;
        _syncedScrollOffset = controller.offset;
      });
      return controller;
    });
  }

  void _onPageChanged(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || index < 0 || index >= widget.teams.length) return;
      _applySyncedScroll(widget.teams[index].clubCode);
    });
  }

  void _applySyncedScroll(String clubCode) {
    final controller = _scrollControllers[clubCode];
    if (controller == null || !controller.hasClients) return;

    final maxExtent = controller.position.maxScrollExtent;
    final target = _syncedScrollOffset.clamp(0.0, maxExtent);
    if ((controller.offset - target).abs() > 0.5) {
      controller.jumpTo(target);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final controller in _scrollControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: _onPageChanged,
      itemCount: widget.teams.length,
      itemBuilder: (context, index) {
        final team = widget.teams[index];
        final previousTeam = index > 0 ? widget.teams[index - 1] : null;
        final nextTeam = index < widget.teams.length - 1
            ? widget.teams[index + 1]
            : null;

        return _TeamDetailPage(
          key: ValueKey(team.clubCode),
          team: team,
          scrollController: _scrollFor(team.clubCode),
          previousTeamName: previousTeam?.teamName,
          nextTeamName: nextTeam?.teamName,
        );
      },
    );
  }
}

class _TeamDetailPage extends StatefulWidget {
  final TeamStats team;
  final ScrollController scrollController;
  final String? previousTeamName;
  final String? nextTeamName;

  const _TeamDetailPage({
    super.key,
    required this.team,
    required this.scrollController,
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

  final _rosterKey = GlobalKey();
  bool _showCompactTitle = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!widget.scrollController.hasClients) return;

    final show =
        widget.scrollController.offset > _kCompactHeaderScrollThreshold;
    if (show != _showCompactTitle) {
      setState(() => _showCompactTitle = show);
    }
  }

  Widget _buildCompactAppBarTitle(TeamStats team) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          team.logo,
          width: 28,
          height: 28,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 10),
        Text(
          team.teamName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (team.position > 0) ...[
          const SizedBox(width: 8),
          Text(
            '${team.position}.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
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
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: null,
        automaticallyImplyLeading: true,
        flexibleSpace: _showCompactTitle
            ? SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    const SizedBox(width: 56),
                    Expanded(
                      child: Center(
                        child: _buildCompactAppBarTitle(team),
                      ),
                    ),
                    const SizedBox(width: 56),
                  ],
                ),
              )
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: widget.scrollController,
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
