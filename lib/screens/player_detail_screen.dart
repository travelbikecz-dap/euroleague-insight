import 'package:flutter/material.dart';

import '../models/player.dart';
import '../services/player_stats_api_service.dart';
import '../widgets/player_avatar.dart';

class PlayerDetailScreen extends StatefulWidget {
  final Player player;
  final String teamName;

  const PlayerDetailScreen({
    super.key,
    required this.player,
    required this.teamName,
  });

  @override
  State<PlayerDetailScreen> createState() => _PlayerDetailScreenState();
}

class _PlayerDetailScreenState extends State<PlayerDetailScreen> {
  static const double _statCardWidth = 78;
  static const double _statCardHeight = 72;
  static const double _gridSpacing = 8;
  static const int _gridColumns = 4;
  static const double _gridWidth =
      _statCardWidth * _gridColumns + _gridSpacing * (_gridColumns - 1);

  final _statsService = PlayerStatsApiService();
  late Future<PlayerSeasonStats?> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _statsService.fetchSeasonStats(widget.player);
  }

  @override
  Widget build(BuildContext context) {
    final player = widget.player;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              PlayerAvatar(
                photoUrl: player.photoUrl,
                size: 120,
                fallbackText: player.dorsal.isNotEmpty ? '#${player.dorsal}' : '?',
              ),
              const SizedBox(height: 16),
              if (player.dorsal.isNotEmpty)
                Text(
                  '#${player.dorsal}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                ),
              Text(
                player.displayName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _subtitle(player),
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              const SizedBox(height: 30),
              FutureBuilder<PlayerSeasonStats?>(
                future: _statsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }

                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'Could not load stats',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    );
                  }

                  final stats = snapshot.data;
                  if (stats == null) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'No season stats available',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      _buildStatsSection('SEASON OVERVIEW', stats.overviewStats),
                      _buildSectionDivider(),
                      _buildStatsSection('SEASON ADVANCED', stats.advancedStats),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _subtitle(Player player) {
    final parts = <String>[
      if (player.position.isNotEmpty) player.position,
      if (player.country.isNotEmpty) player.country,
      if (player.height > 0) '${player.height} cm',
      widget.teamName,
    ];
    return parts.join(' · ');
  }

  Widget _buildStatsSection(String title, List<PlayerStatItem> stats) {
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
