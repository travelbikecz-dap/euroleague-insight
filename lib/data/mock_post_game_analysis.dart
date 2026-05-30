class MockPostGamePreview {
  final String title;
  final bool predictionHit;
  final String predictedWinner;
  final int predictedHomePct;
  final int predictedAwayPct;
  final String resultLine;
  final String comparisonSummary;
  final String analysis;

  const MockPostGamePreview({
    required this.title,
    required this.predictionHit,
    required this.predictedWinner,
    required this.predictedHomePct,
    required this.predictedAwayPct,
    required this.resultLine,
    required this.comparisonSummary,
    required this.analysis,
  });
}

class MockPostGameAnalysis {
  MockPostGameAnalysis._();

  static const previews = [
    MockPostGamePreview(
      title: 'Prediction confirmed',
      predictionHit: true,
      predictedWinner: 'Real Madrid',
      predictedHomePct: 64,
      predictedAwayPct: 36,
      resultLine: 'Real Madrid 91 – 79 Valencia',
      comparisonSummary:
          'We favored Real Madrid at 64% and they won at home. The final margin (+12) was wider than a typical toss-up, but directionally the model read the matchup correctly.',
      analysis:
          'Real Madrid’s offensive rating edge showed up in the box score: higher eFG% and fewer turnovers than season average. Valencia stayed competitive through the first half, but could not sustain efficiency in the fourth quarter.\n\n'
          'The pre-game signal was form + home court. The result validated those factors rather than revealing a major statistical surprise.',
    ),
    MockPostGamePreview(
      title: 'Upset — model missed',
      predictionHit: false,
      predictedWinner: 'Olympiacos',
      predictedHomePct: 58,
      predictedAwayPct: 42,
      resultLine: 'Barcelona 88 – 84 Olympiacos',
      comparisonSummary:
          'We leaned Olympiacos at 58%, but Barcelona won a tight road game. The prediction missed on the winner, although the final score stayed within a single possession late.',
      analysis:
          'Barcelona won the shooting battle (7 more 3PM) despite our pre-game defensive profile favoring Olympiacos. Turnovers were even, so the swing came from hot perimeter shooting — a factor the season averages underweighted for this specific night.\n\n'
          'This is exactly the kind of game Post Game Analysis should flag: prediction miss driven by above-average 3PT variance, not by a collapse in rebounding or pace.',
    ),
    MockPostGamePreview(
      title: 'Correct side, closer game',
      predictionHit: true,
      predictedWinner: 'Panathinaikos',
      predictedHomePct: 61,
      predictedAwayPct: 39,
      resultLine: 'Panathinaikos 78 – 76 Fenerbahce',
      comparisonSummary:
          'Panathinaikos were the predicted winner at 61% and they won, but only by 2 points. Probability suggested an edge, not a blowout — the result fits that profile.',
      analysis:
          'Fenerbahce matched Panathinaikos in offensive rating for much of the game and kept pace below season norms. The model’s pre-game read (small home edge) held, but Fenerbahce’s defense limited easy looks in the paint.\n\n'
          'Calibration note: a 61% line should often translate into close games. This outcome supports the prediction without overstating confidence.',
    ),
    MockPostGamePreview(
      title: 'Home favorite upset',
      predictionHit: false,
      predictedWinner: 'Monaco',
      predictedHomePct: 67,
      predictedAwayPct: 33,
      resultLine: 'Partizan 83 – 77 Monaco',
      comparisonSummary:
          'Monaco were clear pre-game favorites at 67%, but Partizan won at home. The model correctly identified Monaco as the stronger season profile, but not the turnover and foul-trouble swing in-game.',
      analysis:
          'Partizan forced 18 turnovers (+4 vs Monaco season allowed) and won the free-throw volume battle. Monaco’s second unit stretch in Q3 was their weakest phase and matched our live concern about bench depth in high-pressure road games.\n\n'
          'Post-game takeaway: season efficiency favored Monaco, but game-state factors (TOV, fouls) flipped the result. Future analysis should surface those live-risk flags before tip-off.',
    ),
  ];

  static MockPostGamePreview forGame(int gameCode) {
    return previews[gameCode.abs() % previews.length];
  }
}
