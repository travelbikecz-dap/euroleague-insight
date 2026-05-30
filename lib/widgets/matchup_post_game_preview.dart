import 'package:flutter/material.dart';

import '../data/mock_post_game_analysis.dart';
import '../theme/app_theme.dart';

class MatchupPostGamePreview extends StatelessWidget {
  final MockPostGamePreview preview;

  const MatchupPostGamePreview({
    super.key,
    required this.preview,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _previewBanner(cs),
        const SizedBox(height: 12),
        _sectionTitle(context, 'Prediction vs Result'),
        const SizedBox(height: 10),
        _comparisonCard(context),
        const SizedBox(height: 20),
        _sectionTitle(context, 'Post Game Analysis'),
        const SizedBox(height: 10),
        _analysisCard(context),
      ],
    );
  }

  Widget _previewBanner(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.primary.withValues(alpha: 0.35)),
      ),
      child: Text(
        'Preview · mock post-game copy — layout only',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: cs.primary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
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

  Widget _comparisonCard(BuildContext context) {
    final cs = context.cs;
    final hit = preview.predictionHit;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: context.cardDecoration(radius: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  preview.title,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _hitMissBadge(hit),
            ],
          ),
          const SizedBox(height: 16),
          _comparisonRow(
            context,
            label: 'Predicted',
            value:
                '${preview.predictedWinner} · ${preview.predictedHomePct}% – ${preview.predictedAwayPct}%',
          ),
          const SizedBox(height: 10),
          _comparisonRow(
            context,
            label: 'Final',
            value: preview.resultLine,
          ),
          const SizedBox(height: 14),
          Text(
            preview.comparisonSummary,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _hitMissBadge(bool hit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: hit
            ? Colors.green.withValues(alpha: 0.18)
            : Colors.redAccent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        hit ? 'HIT' : 'MISS',
        style: TextStyle(
          color: hit ? Colors.green.shade700 : Colors.red.shade700,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _comparisonRow(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final cs = context.cs;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _analysisCard(BuildContext context) {
    final cs = context.cs;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: context.cardDecoration(radius: 12),
      child: Text(
        preview.analysis,
        textAlign: TextAlign.left,
        style: TextStyle(
          color: cs.onSurface,
          fontSize: 14,
          height: 1.55,
        ),
      ),
    );
  }
}
