import 'euroleague_game.dart';
import 'game_phase.dart';
import '../utils/game_time_formatter.dart';
enum RoundLifecycle {
  active,
  complete,
  stale,
}

class GameRound {
  final GamePhase phase;
  final int roundNumber;
  final String label;
  final List<EuroleagueGame> games;
  final RoundLifecycle lifecycle;

  const GameRound({
    required this.phase,
    required this.roundNumber,
    required this.label,
    required this.games,
    required this.lifecycle,
  });

  GameRound copyWith({
    List<EuroleagueGame>? games,
    RoundLifecycle? lifecycle,
  }) {
    return GameRound(
      phase: phase,
      roundNumber: roundNumber,
      label: label,
      games: games ?? this.games,
      lifecycle: lifecycle ?? this.lifecycle,
    );
  }

  int get roundIndex => roundNumber - 1;

  String get dateLabel {
    if (games.isEmpty) return '';
    return GameTimeFormatter.formatRoundRange(
      games.map((game) => game.utcDate).toList(),
    );
  }
}
