import 'package:flutter/material.dart';

import '../data/mock_game_mvp.dart';
import 'player_avatar.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle('Game MVP'),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(16),
          ),
          child: isPending ? _pendingContent() : _mvpContent(mvp!),
        ),
      ],
    );
  }

  Widget _pendingContent() {
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
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'PENDING',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Available after final buzzer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Game still in progress or not started',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _pendingPrimaryStatsRow(),
        const SizedBox(height: 8),
        _pendingSecondaryStatsRow(),
        const SizedBox(height: 12),
        const Text(
          '—',
          style: TextStyle(
            color: Colors.white38,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _mvpContent(MockGameMvp mvp) {
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
                      color: Colors.orange.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'TOP PIR',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mvp.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Image.asset(mvp.teamLogo, width: 18, height: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${mvp.teamName} · #${mvp.dorsal}',
                          style: const TextStyle(
                            color: Colors.white70,
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
          pir: _formatStat(mvp.pir),
          points: _formatStat(mvp.points),
          rebounds: _formatStat(mvp.rebounds),
          assists: _formatStat(mvp.assists),
          minutes: mvp.minutes,
          highlight: true,
        ),
        const SizedBox(height: 8),
        _secondaryStatsRow(
          steals: _formatStat(mvp.steals),
          blocks: _formatStat(mvp.blocks),
          turnovers: _formatStat(mvp.turnovers),
          plusMinus: _formatPlusMinus(mvp.plusMinus),
        ),
        const SizedBox(height: 12),
        Text(
          mvp.shootingLine,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _pendingPrimaryStatsRow() {
    return _primaryStatsRow(
      pir: '—',
      points: '—',
      rebounds: '—',
      assists: '—',
      minutes: '—',
      highlight: false,
      muted: true,
    );
  }

  Widget _pendingSecondaryStatsRow() {
    return _secondaryStatsRow(
      steals: '—',
      blocks: '—',
      turnovers: '—',
      plusMinus: '—',
      muted: true,
    );
  }

  Widget _primaryStatsRow({
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
        _statChip('PIR', pir, highlight: highlight, muted: muted),
        _statChip('PTS', points, muted: muted),
        _statChip('REB', rebounds, muted: muted),
        _statChip('AST', assists, muted: muted),
        _statChip('MIN', minutes, compact: true, muted: muted),
      ],
    );
  }

  Widget _secondaryStatsRow({
    required String steals,
    required String blocks,
    required String turnovers,
    required String plusMinus,
    bool muted = false,
  }) {
    return Row(
      children: [
        _statChip('STL', steals, muted: muted),
        _statChip('BLK', blocks, muted: muted),
        _statChip('TOV', turnovers, muted: muted),
        _statChip('+/-', plusMinus, muted: muted),
      ],
    );
  }

  String _formatPlusMinus(int value) {
    if (value > 0) return '+$value';
    return value.toString();
  }

  Widget _statChip(
    String label,
    String value, {
    bool highlight = false,
    bool compact = false,
    bool muted = false,
  }) {
    final valueColor = muted
        ? Colors.white38
        : (highlight ? Colors.orange : Colors.white);
    final labelColor = muted
        ? Colors.white38
        : (highlight ? Colors.orange : Colors.white70);

    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: EdgeInsets.symmetric(
          vertical: compact ? 8 : 10,
          horizontal: compact ? 4 : 6,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(12),
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
