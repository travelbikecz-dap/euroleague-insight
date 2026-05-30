import 'package:flutter/material.dart';

import '../data/mock_post_game_analysis.dart';

class MatchupPostGamePreview extends StatelessWidget {
  final MockPostGamePreview preview;

  const MatchupPostGamePreview({
    super.key,
    required this.preview,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _previewBanner(),
        const SizedBox(height: 12),
        _sectionTitle('Prediction vs Result'),
        const SizedBox(height: 10),
        _comparisonCard(),
        const SizedBox(height: 20),
        _sectionTitle('Post Game Analysis'),
        const SizedBox(height: 10),
        _analysisCard(),
      ],
    );
  }

  Widget _previewBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.35)),
      ),
      child: const Text(
        'Preview · mock post-game copy — layout only',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.orange,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
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

  Widget _comparisonCard() {
    final hit = preview.predictionHit;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  preview.title,
                  style: const TextStyle(
                    color: Colors.white,
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
            label: 'Predicted',
            value:
                '${preview.predictedWinner} · ${preview.predictedHomePct}% – ${preview.predictedAwayPct}%',
          ),
          const SizedBox(height: 10),
          _comparisonRow(
            label: 'Final',
            value: preview.resultLine,
          ),
          const SizedBox(height: 14),
          Text(
            preview.comparisonSummary,
            style: const TextStyle(
              color: Colors.white,
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
          color: hit ? Colors.greenAccent : Colors.redAccent,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _comparisonRow({required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _analysisCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        preview.analysis,
        textAlign: TextAlign.left,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          height: 1.55,
        ),
      ),
    );
  }
}
