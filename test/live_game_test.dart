import 'package:flutter_test/flutter_test.dart';

import 'package:euroliga_predictor/models/euroleague_game.dart';
import 'package:euroliga_predictor/models/game_display_status.dart';
import 'package:euroliga_predictor/models/game_phase.dart';
import 'package:euroliga_predictor/models/live_game_snapshot.dart';
import 'package:euroliga_predictor/services/game_status_resolver.dart';
import 'package:euroliga_predictor/services/live_game_merger.dart';
import 'package:euroliga_predictor/utils/live_game_clock_formatter.dart';

EuroleagueGame _game({required DateTime utcDate, bool played = false}) {
  return EuroleagueGame(
    gameCode: 100,
    seasonCode: 'E2025',
    phase: GamePhase.regularSeason,
    round: 10,
    roundLabel: 'Round 10',
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
    apiGameStatus: 'Confirmed',
    status: GameDisplayStatus.scheduled,
    homeScore: null,
    awayScore: null,
  );
}

void main() {
  test('formats live clock with quarter and remaining time', () {
    expect(
      LiveGameClockFormatter.format(
        isLive: true,
        quarter: '3',
        remainingTime: '04:21',
      ),
      'LIVE · Q3 04:21',
    );
  });

  test('marks poll candidate shortly before tipoff', () {
    final now = DateTime.utc(2026, 3, 12, 19, 50);
    final game = _game(utcDate: DateTime.utc(2026, 3, 12, 20, 0));

    expect(
      GameStatusResolver.isLivePollCandidate(game, now: now),
      isTrue,
    );
  });

  test('merges live snapshot into game', () {
    final game = _game(utcDate: DateTime.utc(2026, 3, 12, 19, 0));
    const snapshot = LiveGameSnapshot(
      gameCode: 100,
      isLive: true,
      homeScore: 52,
      awayScore: 48,
      quarter: '3',
      remainingTime: '08:12',
    );

    final merged = LiveGameMerger.apply(game, snapshot);

    expect(merged.status, GameDisplayStatus.live);
    expect(merged.homeScore, 52);
    expect(merged.awayScore, 48);
    expect(merged.liveClockLabel, 'LIVE · Q3 08:12');
  });
}
