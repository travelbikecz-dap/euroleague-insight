import '../utils/live_game_clock_formatter.dart';

class LiveGameSnapshot {
  final int gameCode;
  final bool isLive;
  final int? homeScore;
  final int? awayScore;
  final String? quarter;
  final String? remainingTime;

  const LiveGameSnapshot({
    required this.gameCode,
    required this.isLive,
    this.homeScore,
    this.awayScore,
    this.quarter,
    this.remainingTime,
  });

  bool get isFinal {
    if (isLive || homeScore == null || awayScore == null) return false;
    return remainingTime == '00:00' || remainingTime == '00:00:00';
  }

  String? get clockLabel {
    return LiveGameClockFormatter.format(
      isLive: isLive,
      quarter: quarter,
      remainingTime: remainingTime,
    );
  }
}
