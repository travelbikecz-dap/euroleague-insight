import 'game_display_status.dart';
import 'game_phase.dart';

class EuroleagueGame {
  final int gameCode;
  final String seasonCode;
  final GamePhase phase;
  final int round;
  final String roundLabel;
  final DateTime utcDate;

  final String homeClubCode;
  final String awayClubCode;
  final String homeApiName;
  final String awayApiName;
  final String homeDisplayName;
  final String awayDisplayName;
  final String homeLogo;
  final String awayLogo;

  final bool played;
  final String apiGameStatus;
  final GameDisplayStatus status;

  final int? homeScore;
  final int? awayScore;
  final String? liveClockLabel;

  const EuroleagueGame({
    required this.gameCode,
    required this.seasonCode,
    required this.phase,
    required this.round,
    required this.roundLabel,
    required this.utcDate,
    required this.homeClubCode,
    required this.awayClubCode,
    required this.homeApiName,
    required this.awayApiName,
    required this.homeDisplayName,
    required this.awayDisplayName,
    required this.homeLogo,
    required this.awayLogo,
    required this.played,
    required this.apiGameStatus,
    required this.status,
    required this.homeScore,
    required this.awayScore,
    this.liveClockLabel,
  });

  EuroleagueGame copyWith({
    bool? played,
    String? apiGameStatus,
    GameDisplayStatus? status,
    int? homeScore,
    int? awayScore,
    String? liveClockLabel,
    bool clearLiveClockLabel = false,
  }) {
    return EuroleagueGame(
      gameCode: gameCode,
      seasonCode: seasonCode,
      phase: phase,
      round: round,
      roundLabel: roundLabel,
      utcDate: utcDate,
      homeClubCode: homeClubCode,
      awayClubCode: awayClubCode,
      homeApiName: homeApiName,
      awayApiName: awayApiName,
      homeDisplayName: homeDisplayName,
      awayDisplayName: awayDisplayName,
      homeLogo: homeLogo,
      awayLogo: awayLogo,
      played: played ?? this.played,
      apiGameStatus: apiGameStatus ?? this.apiGameStatus,
      status: status ?? this.status,
      homeScore: homeScore ?? this.homeScore,
      awayScore: awayScore ?? this.awayScore,
      liveClockLabel: clearLiveClockLabel
          ? null
          : (liveClockLabel ?? this.liveClockLabel),
    );
  }

  bool get hasScoreboard {
    return homeScore != null && awayScore != null;
  }

  bool get isActionable {
    return status != GameDisplayStatus.postponed &&
        status != GameDisplayStatus.suspended &&
        status != GameDisplayStatus.cancelled;
  }
}
