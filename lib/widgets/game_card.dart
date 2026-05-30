import 'package:flutter/material.dart';

import '../models/euroleague_game.dart';
import '../models/game_display_status.dart';
import '../theme/app_theme.dart';
import '../utils/game_time_formatter.dart';
import 'team_logo.dart';

class GameCard extends StatelessWidget {
  final EuroleagueGame game;
  final VoidCallback? onTap;

  const GameCard({
    super.key,
    required this.game,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final showScores = _showScores(game);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _statusLabel(game),
                style: TextStyle(
                  color: _statusColor(game.status),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              _teamRow(
                context,
                logo: game.homeLogo,
                name: game.homeDisplayName,
                trailing: showScores ? '${game.homeScore}' : _timeLabel(game),
              ),
              const SizedBox(height: 12),
              _teamRow(
                context,
                logo: game.awayLogo,
                name: game.awayDisplayName,
                trailing: showScores ? '${game.awayScore}' : '',
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _showScores(EuroleagueGame game) {
    return game.hasScoreboard &&
        (game.status == GameDisplayStatus.final_ ||
            game.status == GameDisplayStatus.live ||
            game.status == GameDisplayStatus.walkover);
  }

  String _statusLabel(EuroleagueGame game) {
    if (game.status == GameDisplayStatus.live) {
      return game.liveClockLabel ?? game.status.label;
    }
    if (game.status == GameDisplayStatus.scheduled) {
      return GameTimeFormatter.formatScheduled(game.utcDate);
    }
    return game.status.label;
  }

  String _timeLabel(EuroleagueGame game) {
    return GameTimeFormatter.formatClock(game.utcDate);
  }

  Color _statusColor(GameDisplayStatus status) {
    return switch (status) {
      GameDisplayStatus.live => Colors.redAccent,
      GameDisplayStatus.postponed ||
      GameDisplayStatus.suspended ||
      GameDisplayStatus.cancelled => Colors.grey,
      _ => AppTheme.brandOrange,
    };
  }

  Widget _teamRow(
    BuildContext context, {
    required String logo,
    required String name,
    required String trailing,
  }) {
    final onSurface = context.cs.onSurface;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              TeamLogo(assetPath: logo, width: 28, height: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: onSurface, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
        if (trailing.isNotEmpty)
          Text(
            trailing,
            style: TextStyle(
              color: onSurface,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}
