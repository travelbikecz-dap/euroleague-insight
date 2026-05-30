import 'package:flutter/material.dart';

import '../models/player.dart';
import '../screens/player_detail_screen.dart';
import '../services/roster_api_service.dart';
import '../theme/app_theme.dart';
import 'player_avatar.dart';

class TeamRosterSection extends StatefulWidget {
  final String clubCode;
  final String teamName;

  const TeamRosterSection({
    super.key,
    required this.clubCode,
    required this.teamName,
  });

  @override
  State<TeamRosterSection> createState() => _TeamRosterSectionState();
}

class _TeamRosterSectionState extends State<TeamRosterSection> {
  final _rosterService = RosterApiService();
  late Future<List<Player>> _rosterFuture;

  @override
  void initState() {
    super.initState();
    _rosterFuture = _rosterService.fetchRoster(widget.clubCode);
  }

  @override
  void didUpdateWidget(covariant TeamRosterSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.clubCode != widget.clubCode) {
      _rosterFuture = _rosterService.fetchRoster(widget.clubCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;

    return Column(
      children: [
        Text(
          'ROSTER',
          style: TextStyle(
            color: cs.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<Player>>(
          future: _rosterFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(color: cs.primary),
              );
            }

            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Could not load roster',
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              );
            }

            final players = snapshot.data ?? [];
            if (players.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No players found',
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              );
            }

            return Column(
              children: players.asMap().entries.map((entry) {
                return _buildPlayerRow(
                  context,
                  players: players,
                  index: entry.key,
                  player: entry.value,
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPlayerRow(
    BuildContext context, {
    required List<Player> players,
    required int index,
    required Player player,
  }) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PlayerDetailScreen(
              players: players,
              initialIndex: index,
              teamName: widget.teamName,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.cs.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            PlayerAvatar(
              photoUrl: player.photoUrl,
              style: PlayerPhotoStyle.compact,
              fallbackText: player.dorsal.isNotEmpty ? '#${player.dorsal}' : '?',
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 28,
              child: Text(
                player.dorsal.isNotEmpty ? '#${player.dorsal}' : '',
                style: TextStyle(
                  color: context.cs.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(
              child: Text(
                player.displayName,
                style: TextStyle(
                  color: context.cs.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (player.position.isNotEmpty)
              Text(
                player.position,
                style: TextStyle(
                  color: context.cs.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              color: context.cs.outline,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
