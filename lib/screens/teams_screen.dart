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
  static const _sectionNames = ['Overview', 'Performance', 'Advanced'];
  static const _statCellWidth = 48.0;
  static const _sectionDividerWidth = 25.0;
  static const _logoSize = 40.0;
  static const _identityWidth = 154.0;

  late Future<List<TeamStats>> teamsFuture;
  List<TeamStats>? teams;
  List<double> _sectionSnapOffsets = const [0];
  int _activeSectionIndex = 0;
  final List<ScrollController> _scrollControllers = [];
  bool _isSyncingScroll = false;

  @override
  void initState() {
    super.initState();
    teamsFuture = TeamStatsService().getAllTeams();
  }

  @override
  void dispose() {
    for (final controller in _scrollControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _ensureScrollControllers(int count) {
    while (_scrollControllers.length < count) {
      _scrollControllers.add(ScrollController());
    }
    while (_scrollControllers.length > count) {
      _scrollControllers.removeLast().dispose();
    }
  }

  void _computeSectionSnapOffsets(TeamStats sample) {
    final offsets = <double>[0];
    var x = 0.0;

    for (var i = 0; i < sample.statSections.length; i++) {
      x += sample.statSections[i].length * _statCellWidth;
      if (i < sample.statSections.length - 1) {
        x += _sectionDividerWidth;
        offsets.add(x);
      }
    }

    _sectionSnapOffsets = offsets;
  }

  int _sectionIndexForOffset(double offset) {
    var index = 0;
    for (var i = 0; i < _sectionSnapOffsets.length; i++) {
      if (offset + (_statCellWidth / 2) >= _sectionSnapOffsets[i]) {
        index = i;
      }
    }
    return index;
  }

  double _nearestSectionOffset(double offset) {
    return _sectionSnapOffsets.reduce(
      (best, candidate) =>
          (candidate - offset).abs() < (best - offset).abs() ? candidate : best,
    );
  }

  void _syncScroll(int sourceIndex, double offset) {
    if (_isSyncingScroll) return;

    _isSyncingScroll = true;
    for (var i = 0; i < _scrollControllers.length; i++) {
      if (i == sourceIndex) continue;

      final controller = _scrollControllers[i];
      if (!controller.hasClients) continue;

      final target = offset.clamp(0.0, controller.position.maxScrollExtent);
      if ((controller.offset - target).abs() > 0.5) {
        controller.jumpTo(target);
      }
    }
    _isSyncingScroll = false;

    final sectionIndex = _sectionIndexForOffset(offset);
    if (sectionIndex != _activeSectionIndex) {
      setState(() => _activeSectionIndex = sectionIndex);
    }
  }

  void _snapToNearestSection(double offset) {
    final target = _nearestSectionOffset(offset);
    final sectionIndex = _sectionIndexForOffset(target);

    _isSyncingScroll = true;
    final animations = <Future<void>>[];
    for (final controller in _scrollControllers) {
      if (!controller.hasClients) continue;

      animations.add(
        controller.animateTo(
          target.clamp(0.0, controller.position.maxScrollExtent),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        ),
      );
    }

    if (animations.isEmpty) {
      _isSyncingScroll = false;
    } else {
      Future.wait(animations).whenComplete(() {
        _isSyncingScroll = false;
      });
    }

    if (sectionIndex != _activeSectionIndex) {
      setState(() => _activeSectionIndex = sectionIndex);
    }
  }

  void _jumpToSection(int sectionIndex) {
    if (sectionIndex < 0 || sectionIndex >= _sectionSnapOffsets.length) {
      return;
    }

    final target = _sectionSnapOffsets[sectionIndex];
    _isSyncingScroll = true;
    final animations = <Future<void>>[];
    for (final controller in _scrollControllers) {
      if (!controller.hasClients) continue;

      animations.add(
        controller.animateTo(
          target.clamp(0.0, controller.position.maxScrollExtent),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        ),
      );
    }

    if (animations.isEmpty) {
      _isSyncingScroll = false;
    } else {
      Future.wait(animations).whenComplete(() {
        _isSyncingScroll = false;
      });
    }

    setState(() => _activeSectionIndex = sectionIndex);
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
        _ensureScrollControllers(teams!.length);
        if (_sectionSnapOffsets.length <= 1 && teams!.isNotEmpty) {
          _computeSectionSnapOffsets(teams!.first);
        }

        return Column(
          children: [
            _buildSectionHeader(),
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

                    final controller = _scrollControllers.removeAt(oldIndex);
                    _scrollControllers.insert(newIndex, controller);
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
                          child: NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              if (_isSyncingScroll) return false;

                              if (notification is ScrollUpdateNotification &&
                                  notification.depth == 0) {
                                _syncScroll(
                                  index,
                                  notification.metrics.pixels,
                                );
                              }

                              if (notification is ScrollEndNotification &&
                                  notification.depth == 0) {
                                _snapToNearestSection(
                                  notification.metrics.pixels,
                                );
                              }

                              return false;
                            },
                            child: SingleChildScrollView(
                              controller: _scrollControllers[index],
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: _buildScrollStats(team),
                              ),
                            ),
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

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_sectionNames.length, (index) {
          final selected = index == _activeSectionIndex;
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 6,
              right: index == _sectionNames.length - 1 ? 0 : 6,
            ),
            child: GestureDetector(
              onTap: () => _jumpToSection(index),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: selected ? Colors.orange : Colors.white,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  letterSpacing: 0.4,
                ),
                child: Text(_sectionNames[index]),
              ),
            ),
          );
        }),
      ),
    );
  }

  List<Widget> _buildScrollStats(TeamStats team) {
    final widgets = <Widget>[];

    for (var i = 0; i < team.statSections.length; i++) {
      if (i > 0) {
        widgets.add(_buildSectionDivider());
      }

      for (final stat in team.statSections[i]) {
        widgets.add(_buildStat(stat.label, stat.value));
      }
    }

    return widgets;
  }

  Widget _buildSectionDivider() {
    return Container(
      width: 1,
      height: 34,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: Colors.grey[700],
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
