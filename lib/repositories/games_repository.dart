import '../models/euroleague_game.dart';
import '../models/game_display_status.dart';
import '../models/game_phase.dart';
import '../models/game_round.dart';
import '../services/games_api_service.dart';
import '../services/primary_round_selector.dart';

class GamesRepository {
  GamesRepository({GamesApiService? apiService})
    : _apiService = apiService ?? GamesApiService();

  final GamesApiService _apiService;

  Future<List<GameRound>> getRegularSeasonRounds({
    bool forceRefresh = false,
  }) async {
    final games = await _apiService.fetchRegularSeasonGames(
      forceRefresh: forceRefresh,
    );
    return _buildRounds(games);
  }

  GameRound selectPrimaryRound(List<GameRound> rounds) {
    return PrimaryRoundSelector.select(rounds);
  }

  List<GameRound> _buildRounds(List<EuroleagueGame> games) {
    final gamesByRound = <int, List<EuroleagueGame>>{};

    for (final game in games) {
      gamesByRound.putIfAbsent(game.round, () => []).add(game);
    }

    final roundNumbers = gamesByRound.keys.toList()..sort();

    return roundNumbers.map((roundNumber) {
      final roundGames = List<EuroleagueGame>.from(gamesByRound[roundNumber]!);
      roundGames.sort(_compareGames);

      return GameRound(
        phase: GamePhase.regularSeason,
        roundNumber: roundNumber,
        label: roundGames.first.roundLabel,
        games: roundGames,
        lifecycle: RoundLifecycle.complete,
      );
    }).toList();
  }

  int _compareGames(EuroleagueGame a, EuroleagueGame b) {
    final statusOrder = a.status.sortOrder.compareTo(b.status.sortOrder);
    if (statusOrder != 0) return statusOrder;
    return a.utcDate.compareTo(b.utcDate);
  }
}
