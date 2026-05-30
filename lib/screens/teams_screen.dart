import 'package:flutter/material.dart';

import '../models/team_stats.dart';
import '../services/team_stats_service.dart';
import '../data/team_names.dart';
import '../theme/app_theme.dart';
import '../widgets/team_logo.dart';

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
              style: TextStyle(color: context.cs.onSurface),
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
              context,
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
                  final cs = context.cs;

                  return Container(
                    key: ValueKey(team.clubCode),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: context.cardDecoration(radius: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ReorderableDragStartListener(
                          index: index,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(
                              Icons.drag_handle,
                              color: context.subtle,
                              size: 24,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: _identityWidth,
                          child: Row(
                            children: [
                              TeamLogo(
                                assetPath: team.logo,
                                width: _logoSize,
                                height: _logoSize,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  TeamNames.listName(team.apiTeamName),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: cs.onSurface,
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
                            context,
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
    BuildContext context,
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
            _buildStat(context, stat.label, stat.value),
        ],
      ),
    );
  }

  Widget _buildStatsHeader(
    BuildContext context, {
    required int start,
    required int end,
    required int total,
    required bool needsPager,
    required bool canGoBack,
    required bool canGoForward,
    required VoidCallback onBack,
    required VoidCallback onForward,
  }) {
    final cs = context.cs;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
      child: Row(
        children: [
          Text(
            'Stats',
            style: TextStyle(
              color: cs.primary,
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
                color: canGoBack ? cs.onSurface : context.faint,
                size: 28,
              ),
            ),
            Text(
              '${start + 1}–$end / $total',
              style: TextStyle(
                color: context.muted,
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
                color: canGoForward ? cs.onSurface : context.faint,
                size: 28,
              ),
            ),
          ] else
            Text(
              '$total stats',
              style: TextStyle(color: context.subtle, fontSize: 12),
            ),
        ],
      ),
    );
  }

  Widget _buildStat(BuildContext context, String label, String value) {
    final onSurface = context.cs.onSurface;

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
            style: TextStyle(
              color: onSurface,
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
            style: TextStyle(
              color: onSurface,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
