import '../models/euroleague_game.dart';
import '../models/game_display_status.dart';

class GameStatusResolver {
  static const liveWindow = Duration(hours: 3);
  static const preGamePollLead = Duration(minutes: 15);

  static bool isLivePollCandidate(EuroleagueGame game, {DateTime? now}) {
    if (game.played || !game.isActionable) return false;

    final current = (now ?? DateTime.now()).toUtc();
    final pollStart = game.utcDate.subtract(preGamePollLead);
    final pollEnd = game.utcDate.add(liveWindow);

    return !current.isBefore(pollStart) && current.isBefore(pollEnd);
  }

  static List<EuroleagueGame> livePollCandidates(
    Iterable<EuroleagueGame> games, {
    DateTime? now,
  }) {
    return games
        .where((game) => isLivePollCandidate(game, now: now))
        .toList();
  }

  static GameDisplayStatus resolve({
    required bool played,
    required String apiGameStatus,
    required DateTime utcDate,
    DateTime? now,
  }) {
    final current = (now ?? DateTime.now()).toUtc();
    final status = apiGameStatus.trim();

    if (played) {
      return GameDisplayStatus.final_;
    }

    switch (status.toLowerCase()) {
      case 'postponed':
        return GameDisplayStatus.postponed;
      case 'suspended':
        return GameDisplayStatus.suspended;
      case 'cancelled':
        return GameDisplayStatus.cancelled;
      case 'walkover':
        return GameDisplayStatus.walkover;
    }

    if (utcDate.isAfter(current)) {
      return GameDisplayStatus.scheduled;
    }

    if (current.isBefore(utcDate.add(liveWindow))) {
      return GameDisplayStatus.live;
    }

    return GameDisplayStatus.scheduled;
  }

  static bool isDetached({
    required EuroleagueGame game,
    required DateTime roundWindowEnd,
    Duration grace = const Duration(days: 7),
  }) {
    if (!game.isActionable) return true;

    if (!game.played && game.utcDate.isAfter(roundWindowEnd.add(grace))) {
      return true;
    }

    return false;
  }

  static DateTime roundWindowEnd(List<EuroleagueGame> games) {
    final actionableDates = games
        .where((game) => game.isActionable)
        .map((game) => game.utcDate)
        .toList();

    if (actionableDates.isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    }

    return actionableDates.reduce(
      (latest, date) => date.isAfter(latest) ? date : latest,
    );
  }
}
