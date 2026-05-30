import 'package:flutter_test/flutter_test.dart';

import 'package:euroliga_predictor/models/euroleague_game.dart';
import 'package:euroliga_predictor/models/game_display_status.dart';
import 'package:euroliga_predictor/models/game_phase.dart';
import 'package:euroliga_predictor/models/game_round.dart';
import 'package:euroliga_predictor/services/primary_round_selector.dart';

EuroleagueGame _game({
  required int gameCode,
  required int round,
  required GameDisplayStatus status,
  required DateTime utcDate,
  bool played = false,
}) {
  return EuroleagueGame(
    gameCode: gameCode,
    seasonCode: 'E2025',
    phase: GamePhase.regularSeason,
    round: round,
    roundLabel: 'Round $round',
    utcDate: utcDate,
    homeClubCode: 'MAD',
    awayClubCode: 'IST',
    homeApiName: 'Real Madrid',
    awayApiName: 'Fenerbahce Beko Istanbul',
    homeDisplayName: 'Real Madrid',
    awayDisplayName: 'Fenerbahce',
    homeLogo: 'assets/logos/real_madrid.png',
    awayLogo: 'assets/logos/fenerbahce.png',
    played: played,
    apiGameStatus: status == GameDisplayStatus.postponed ? 'Postponed' : 'Confirmed',
    status: status,
    homeScore: played ? 80 : null,
    awayScore: played ? 75 : null,
  );
}

GameRound _round(int number, List<EuroleagueGame> games) {
  return GameRound(
    phase: GamePhase.regularSeason,
    roundNumber: number,
    label: 'Round $number',
    games: games,
    lifecycle: RoundLifecycle.complete,
  );
}

void main() {
  test('selects active round with live games', () {
    final now = DateTime.utc(2026, 1, 10, 20);

    final rounds = [
      _round(15, [
        _game(
          gameCode: 1,
          round: 15,
          status: GameDisplayStatus.final_,
          utcDate: DateTime.utc(2026, 1, 9),
          played: true,
        ),
        _game(
          gameCode: 2,
          round: 15,
          status: GameDisplayStatus.live,
          utcDate: DateTime.utc(2026, 1, 10, 19),
        ),
      ]),
      _round(16, [
        _game(
          gameCode: 3,
          round: 16,
          status: GameDisplayStatus.scheduled,
          utcDate: DateTime.utc(2026, 1, 16),
        ),
      ]),
    ];

    final selected = PrimaryRoundSelector.select(rounds, now: now);
    expect(selected.roundNumber, 15);
  });

  test('skips stale round with isolated postponed game', () {
    final now = DateTime.utc(2026, 1, 12, 12);

    final rounds = [
      _round(15, [
        _game(
          gameCode: 1,
          round: 15,
          status: GameDisplayStatus.final_,
          utcDate: DateTime.utc(2026, 1, 3),
          played: true,
        ),
        _game(
          gameCode: 2,
          round: 15,
          status: GameDisplayStatus.postponed,
          utcDate: DateTime.utc(2026, 2, 5),
        ),
      ]),
      _round(16, [
        _game(
          gameCode: 3,
          round: 16,
          status: GameDisplayStatus.scheduled,
          utcDate: DateTime.utc(2026, 1, 14),
        ),
      ]),
    ];

    final selected = PrimaryRoundSelector.select(rounds, now: now);
    expect(selected.roundNumber, 16);
  });

  test('opens after the last completed round mid-season', () {
    final now = DateTime.utc(2026, 3, 15, 12);

    final rounds = [
      for (var roundNumber = 1; roundNumber <= 30; roundNumber++)
        _round(roundNumber, [
          _game(
            gameCode: roundNumber,
            round: roundNumber,
            status: GameDisplayStatus.final_,
            utcDate: DateTime.utc(2026, 1, roundNumber.clamp(1, 28)),
            played: true,
          ),
        ]),
      _round(31, [
        _game(
          gameCode: 31,
          round: 31,
          status: GameDisplayStatus.scheduled,
          utcDate: DateTime.utc(2026, 3, 20),
        ),
      ]),
    ];

    final selected = PrimaryRoundSelector.select(rounds, now: now);
    expect(selected.roundNumber, 31);
  });
}
