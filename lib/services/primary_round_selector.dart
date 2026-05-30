import '../models/euroleague_game.dart';
import '../models/game_display_status.dart';
import '../models/game_round.dart';
import 'game_status_resolver.dart';

class PrimaryRoundSelector {
  static const actionableHorizon = Duration(days: 4);

  static GameRound select(List<GameRound> rounds, {DateTime? now}) {
    if (rounds.isEmpty) {
      throw StateError('Cannot select primary round from an empty list');
    }

    final current = (now ?? DateTime.now()).toUtc();
    final enriched = rounds
        .map((round) => _withLifecycle(round, current))
        .toList(growable: false);

    final activeRounds = enriched
        .where((round) => round.lifecycle == RoundLifecycle.active)
        .toList();
    if (activeRounds.isNotEmpty) {
      return activeRounds.reduce(
        (best, round) =>
            round.roundNumber < best.roundNumber ? round : best,
      );
    }

    for (var index = enriched.length - 1; index >= 0; index--) {
      final round = enriched[index];
      if (round.lifecycle == RoundLifecycle.complete ||
          round.lifecycle == RoundLifecycle.stale) {
        if (index + 1 < enriched.length) {
          return enriched[index + 1];
        }
        break;
      }
    }

    return enriched.last;
  }

  static GameRound _withLifecycle(GameRound round, DateTime now) {
    final windowEnd = GameStatusResolver.roundWindowEnd(round.games);
    final lifecycle = _lifecycleFor(round.games, windowEnd, now);

    return GameRound(
      phase: round.phase,
      roundNumber: round.roundNumber,
      label: round.label,
      games: round.games,
      lifecycle: lifecycle,
    );
  }

  static RoundLifecycle _lifecycleFor(
    List<EuroleagueGame> games,
    DateTime windowEnd,
    DateTime now,
  ) {
    if (games.isEmpty) return RoundLifecycle.complete;

    final hasLive = games.any(
      (game) => game.status == GameDisplayStatus.live,
    );
    if (hasLive) return RoundLifecycle.active;

    final horizonEnd = now.add(actionableHorizon);
    final hasUpcoming = games.any((game) {
      if (GameStatusResolver.isDetached(
        game: game,
        roundWindowEnd: windowEnd,
      )) {
        return false;
      }

      return !game.played &&
          game.status == GameDisplayStatus.scheduled &&
          !game.utcDate.isBefore(now) &&
          !game.utcDate.isAfter(horizonEnd);
    });
    if (hasUpcoming) return RoundLifecycle.active;

    final actionableGames = games.where((game) {
      return !GameStatusResolver.isDetached(
        game: game,
        roundWindowEnd: windowEnd,
      );
    });

    final allActionablePlayed = actionableGames.every((game) => game.played);
    if (allActionablePlayed) return RoundLifecycle.complete;

    return RoundLifecycle.stale;
  }
}
