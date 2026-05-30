import 'package:flutter/material.dart';

import '../models/team_stats.dart';
import '../services/team_stats_service.dart';
import '../data/team_names.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  static const _statCellWidth = 48.0;
  static const _logoSize = 40.0;
  static const _identityWidth = 154.0;

  /// List padding, card padding, drag handle and team identity column.
  static const _statsAreaHorizontalInset = 250.0;

  late Future<List<TeamStats>> teamsFuture;
  List<TeamStats>? teams;
  int _statOffset = 0;

  @override
  void initState() {
    super.initState();
    teamsFuture = TeamStatsService().getAllTeams();
  }

  int _visibleStatCount(double statsAreaWidth) {
    return (statsAreaWidth / _statCellWidth).floor().clamp(1, 999);
  }

  int _maxStatOffset(int totalStats, int visibleCount) {
    return (totalStats - visibleCount).clamp(0, totalStats);
  }

  int _clampedStatOffset(int totalStats, int visibleCount) {
    return _statOffset.clamp(0, _maxStatOffset(totalStats, visibleCount));
  }

  void _shiftPage(int direction, int totalStats, int visibleCount) {
    final maxOffset = _maxStatOffset(totalStats, visibleCount);
    final step = visibleCount;
    final next = (_statOffset + direction * step).clamp(0, maxOffset);
    if (next == _statOffset) return;
    setState(() => _statOffset = next);
  }

  double _statsAreaWidth(BuildContext context) {
    return MediaQuery.sizeOf(context).width - _statsAreaHorizontalInset;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TeamStats>>(
      future: teamsFuture,
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

        teams ??= List<TeamStats>.from(snapshot.data!);

        final statsAreaWidth = _statsAreaWidth(context);
        final visibleCount = _visibleStatCount(statsAreaWidth);
        final totalStats = teams!.first.detailStats.length;
        final start = _clampedStatOffset(totalStats, visibleCount);
        final end = (start + visibleCount).clamp(0, totalStats);
        final maxOffset = _maxStatOffset(totalStats, visibleCount);
        final needsPager = totalStats > visibleCount;

        return Column(
          children: [
            _buildStatsHeader(
              start: start,
              end: end,
              total: totalStats,
              needsPager: needsPager,
              canGoBack: start > 0,
              canGoForward: start < maxOffset,
              onBack: () => _shiftPage(-1, totalStats, visibleCount),
              onForward: () => _shiftPage(1, totalStats, visibleCount),
            ),
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: teams!.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final item = teams!.removeAt(oldIndex);
                    teams!.insert(newIndex, item);
                  });
                },
                itemBuilder: (context, index) {
                  final team = teams![index];

                  return Container(
                    key: ValueKey(team.clubCode),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ReorderableDragStartListener(
                          index: index,
                          child: const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Icon(
                              Icons.drag_handle,
                              color: Colors.white54,
                              size: 24,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: _identityWidth,
                          child: Row(
                            children: [
                              Image.asset(
                                team.logo,
                                width: _logoSize,
                                height: _logoSize,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  TeamNames.listName(team.apiTeamName),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildVisibleStats(
                            team,
                            start: start,
                            end: end,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVisibleStats(
    TeamStats team, {
    required int start,
    required int end,
  }) {
    final stats = team.detailStats.sublist(start, end);

    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (final stat in stats)
            _buildStat(stat.label, stat.value),
        ],
      ),
    );
  }

  Widget _buildStatsHeader({
    required int start,
    required int end,
    required int total,
    required bool needsPager,
    required bool canGoBack,
    required bool canGoForward,
    required VoidCallback onBack,
    required VoidCallback onForward,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
      child: Row(
        children: [
          const Text(
            'Stats',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.4,
            ),
          ),
          const Spacer(),
          if (needsPager) ...[
            IconButton(
              tooltip: 'Previous stats',
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              onPressed: canGoBack ? onBack : null,
              icon: Icon(
                Icons.chevron_left,
                color: canGoBack ? Colors.white : Colors.white24,
                size: 28,
              ),
            ),
            Text(
              '${start + 1}–$end / $total',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            IconButton(
              tooltip: 'Next stats',
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              onPressed: canGoForward ? onForward : null,
              icon: Icon(
                Icons.chevron_right,
                color: canGoForward ? Colors.white : Colors.white24,
                size: 28,
              ),
            ),
          ] else
            Text(
              '$total stats',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return SizedBox(
      width: _statCellWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
