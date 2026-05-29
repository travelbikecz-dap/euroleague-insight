import 'package:flutter/material.dart';
import '../models/team_stats.dart';
import '../services/team_stats_service.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  late Future<List<TeamStats>> teamsFuture;
  List<TeamStats>? teams;

  @override
  void initState() {
    super.initState();
    teamsFuture = TeamStatsService().getAllTeams();
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

        return ReorderableListView.builder(
          padding: const EdgeInsets.all(16),
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildScrollStats(team),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: Colors.grey[700],
    );
  }

  Widget _buildStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
