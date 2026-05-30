import '../models/euroleague_game.dart';
import '../models/game_round.dart';
import '../models/game_display_status.dart';
import '../models/live_game_snapshot.dart';

class LiveGameMerger {
  static EuroleagueGame apply(
    EuroleagueGame game,
    LiveGameSnapshot? snapshot,
  ) {
    if (snapshot == null) return game;

    final homeScore = snapshot.homeScore ?? game.homeScore;
    final awayScore = snapshot.awayScore ?? game.awayScore;

    if (snapshot.isLive) {
      return game.copyWith(
        status: GameDisplayStatus.live,
        homeScore: homeScore,
        awayScore: awayScore,
        liveClockLabel: snapshot.clockLabel,
      );
    }

    if (snapshot.isFinal) {
      return game.copyWith(
        status: GameDisplayStatus.final_,
        homeScore: homeScore,
        awayScore: awayScore,
        clearLiveClockLabel: true,
      );
    }

    if (homeScore != null || awayScore != null) {
      return game.copyWith(
        homeScore: homeScore,
        awayScore: awayScore,
      );
    }

    return game;
  }

  static List<GameRound> applyToRounds(
    List<GameRound> rounds,
    Map<int, LiveGameSnapshot> snapshots,
  ) {
    if (snapshots.isEmpty) return rounds;

    return rounds
        .map(
          (round) => round.copyWith(
            games: round.games
                .map((game) => apply(game, snapshots[game.gameCode]))
                .toList(),
          ),
        )
        .toList();
  }
}
