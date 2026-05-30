import 'package:flutter/material.dart';

import '../data/mock_game_mvp.dart';
import '../theme/app_theme.dart';
import 'player_avatar.dart';
import 'team_logo.dart';

class MatchupMvpPreview extends StatelessWidget {
  final MockGameMvp? mvp;
  final bool isPending;

  const MatchupMvpPreview({
    super.key,
    required MockGameMvp this.mvp,
  }) : isPending = false;

  const MatchupMvpPreview.pending({super.key})
    : mvp = null,
      isPending = true;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle(context, 'Game MVP'),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outline.withValues(alpha: 0.35)),
          ),
          child: isPending
              ? _pendingContent(context)
              : _mvpContent(context, mvp!),
        ),
      ],
    );
  }

  Widget _pendingContent(BuildContext context) {
    final cs = context.cs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PlayerAvatar(
              photoUrl: null,
              style: PlayerPhotoStyle.hero,
              fallbackText: '?',
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: cs.onSurface.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'PENDING',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Available after final buzzer',
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Game still in progress or not started',
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _pendingPrimaryStatsRow(context),
        const SizedBox(height: 8),
        _pendingSecondaryStatsRow(context),
        const SizedBox(height: 12),
        Text(
          '—',
          style: TextStyle(color: context.faint, fontSize: 13),
        ),
      ],
    );
  }

  Widget _mvpContent(BuildContext context, MockGameMvp mvp) {
    final cs = context.cs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PlayerAvatar(
              photoUrl: mvp.photoUrl,
              style: PlayerPhotoStyle.hero,
              fallbackText: mvp.displayName.isNotEmpty
                  ? mvp.displayName[0]
                  : '?',
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'TOP PIR',
                      style: TextStyle(
                        color: cs.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mvp.displayName,
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      TeamLogo(
                        assetPath: mvp.teamLogo,
                        width: 18,
                        height: 18,
                        borderRadius: 4,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${mvp.teamName} · #${mvp.dorsal}',
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _primaryStatsRow(
          context,
          pir: _formatStat(mvp.pir),
          points: _formatStat(mvp.points),
          rebounds: _formatStat(mvp.rebounds),
          assists: _formatStat(mvp.assists),
          minutes: mvp.minutes,
          highlight: true,
        ),
        const SizedBox(height: 8),
        _secondaryStatsRow(
          context,
          steals: _formatStat(mvp.steals),
          blocks: _formatStat(mvp.blocks),
          turnovers: _formatStat(mvp.turnovers),
          plusMinus: _formatPlusMinus(mvp.plusMinus),
        ),
        const SizedBox(height: 12),
        Text(
          mvp.shootingLine,
          style: TextStyle(
            color: cs.onSurfaceVariant,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: context.cs.onSurface,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _pendingPrimaryStatsRow(BuildContext context) {
    return _primaryStatsRow(
      context,
      pir: '—',
      points: '—',
      rebounds: '—',
      assists: '—',
      minutes: '—',
      highlight: false,
      muted: true,
    );
  }

  Widget _pendingSecondaryStatsRow(BuildContext context) {
    return _secondaryStatsRow(
      context,
      steals: '—',
      blocks: '—',
      turnovers: '—',
      plusMinus: '—',
      muted: true,
    );
  }

  Widget _primaryStatsRow(
    BuildContext context, {
    required String pir,
    required String points,
    required String rebounds,
    required String assists,
    required String minutes,
    required bool highlight,
    bool muted = false,
  }) {
    return Row(
      children: [
        _statChip(context, 'PIR', pir, highlight: highlight, muted: muted),
        _statChip(context, 'PTS', points, muted: muted),
        _statChip(context, 'REB', rebounds, muted: muted),
        _statChip(context, 'AST', assists, muted: muted),
        _statChip(context, 'MIN', minutes, compact: true, muted: muted),
      ],
    );
  }

  Widget _secondaryStatsRow(
    BuildContext context, {
    required String steals,
    required String blocks,
    required String turnovers,
    required String plusMinus,
    bool muted = false,
  }) {
    return Row(
      children: [
        _statChip(context, 'STL', steals, muted: muted),
        _statChip(context, 'BLK', blocks, muted: muted),
        _statChip(context, 'TOV', turnovers, muted: muted),
        _statChip(context, '+/-', plusMinus, muted: muted),
      ],
    );
  }

  String _formatPlusMinus(int value) {
    if (value > 0) return '+$value';
    return value.toString();
  }

  Widget _statChip(
    BuildContext context,
    String label,
    String value, {
    bool highlight = false,
    bool compact = false,
    bool muted = false,
  }) {
    final cs = context.cs;
    final valueColor = muted
        ? context.faint
        : (highlight ? cs.primary : cs.onSurface);
    final labelColor = muted
        ? context.faint
        : (highlight ? cs.primary : cs.onSurfaceVariant);

    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: EdgeInsets.symmetric(
          vertical: compact ? 8 : 10,
          horizontal: compact ? 4 : 6,
        ),
        decoration: BoxDecoration(
          color: context.elevatedCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outline.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: labelColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: valueColor,
                fontSize: compact ? 13 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatStat(double value) {
    if (value == value.roundToDouble()) {
      return value.round().toString();
    }
    return value.toStringAsFixed(1);
  }
}
