import 'package:flutter/foundation.dart';
import 'package:xml/xml.dart';

class RecentFormGame {
  final String clubCode;
  final String teamName;
  final int gameday;
  final DateTime date;
  final String dateLabel;
  final String gameCode;
  final int gameNumber;
  final String result;
  final String homeTeam;
  final String awayTeam;
  final int homeScore;
  final int awayScore;

  const RecentFormGame({
    required this.clubCode,
    required this.teamName,
    required this.gameday,
    required this.date,
    required this.dateLabel,
    required this.gameCode,
    required this.gameNumber,
    required this.result,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeScore,
    required this.awayScore,
  });

  String get matchLabel =>
      '$homeTeam $homeScore-$awayScore $awayTeam (${result == 'W' ? 'WIN' : 'LOSS'})';
}

class RecentFormResult {
  final Map<String, List<String>> formByClubCode;
  final Map<String, List<RecentFormGame>> gamesByClubCode;

  const RecentFormResult({
    required this.formByClubCode,
    required this.gamesByClubCode,
  });
}

class RecentFormService {
  /// Temporary debug flag. Set to false once Last 5 is validated.
  static const enableDebugLogs = true;

  static RecentFormResult computeFromResultsXml(String xmlBody) {
    final document = XmlDocument.parse(xmlBody);
    final games = document.findAllElements('game');
    final gamesByClub = <String, List<RecentFormGame>>{};

    for (final game in games) {
      final round = _text(game, 'round');
      final played = _text(game, 'played') == 'true';
      if (!played || round != 'RS') continue;

      final gameday = int.tryParse(_text(game, 'gameday')) ?? 0;
      final dateLabel = _text(game, 'date');
      final date = _parseGameDate(dateLabel);
      final gameCode = _text(game, 'gamecode');
      final gameNumber = int.tryParse(_text(game, 'gamenumber')) ?? 0;

      final homeTeam = _text(game, 'hometeam');
      final awayTeam = _text(game, 'awayteam');
      final homeCode = _text(game, 'homecode');
      final awayCode = _text(game, 'awaycode');
      final homeScore = int.tryParse(_text(game, 'homescore')) ?? 0;
      final awayScore = int.tryParse(_text(game, 'awayscore')) ?? 0;

      _addTeamGame(
        gamesByClub,
        clubCode: homeCode,
        teamName: homeTeam,
        gameday: gameday,
        date: date,
        dateLabel: dateLabel,
        gameCode: gameCode,
        gameNumber: gameNumber,
        isWin: homeScore > awayScore,
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        homeScore: homeScore,
        awayScore: awayScore,
      );

      _addTeamGame(
        gamesByClub,
        clubCode: awayCode,
        teamName: awayTeam,
        gameday: gameday,
        date: date,
        dateLabel: dateLabel,
        gameCode: gameCode,
        gameNumber: gameNumber,
        isWin: awayScore > homeScore,
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        homeScore: homeScore,
        awayScore: awayScore,
      );
    }

    final formByClubCode = <String, List<String>>{};
    final selectedGamesByClub = <String, List<RecentFormGame>>{};

    for (final entry in gamesByClub.entries) {
      final sorted = List<RecentFormGame>.from(entry.value)
        ..sort((a, b) {
          final gamedayCompare = a.gameday.compareTo(b.gameday);
          if (gamedayCompare != 0) return gamedayCompare;

          final dateCompare = a.date.compareTo(b.date);
          if (dateCompare != 0) return dateCompare;

          return a.gameNumber.compareTo(b.gameNumber);
        });

      final lastFive = sorted.length > 5
          ? sorted.sublist(sorted.length - 5)
          : sorted;

      selectedGamesByClub[entry.key] = lastFive;
      formByClubCode[entry.key] = lastFive.map((game) => game.result).toList();
    }

    return RecentFormResult(
      formByClubCode: formByClubCode,
      gamesByClubCode: selectedGamesByClub,
    );
  }

  static void logDebug({
    required RecentFormResult computed,
    required Map<String, String> clubNames,
    Map<String, List<String>>? apiFormByClubCode,
  }) {
    if (!kDebugMode || !enableDebugLogs) return;

    final lastResults = computed.formByClubCode.entries
        .where((entry) => entry.value.isNotEmpty)
        .map((entry) => MapEntry(entry.key, entry.value.last))
        .toList();

    final wins = lastResults.where((entry) => entry.value == 'W').length;
    final losses = lastResults.length - wins;

    debugPrint('[Last5] === Computed recent form ===');
    debugPrint(
      '[Last5] Validation (most recent icon): $wins W / $losses L '
      'across ${lastResults.length} teams',
    );

    final sortedClubs = computed.formByClubCode.keys.toList()..sort();
    for (final clubCode in sortedClubs) {
      final form = computed.formByClubCode[clubCode] ?? const [];
      final teamName = clubNames[clubCode] ?? clubCode;
      final apiForm = apiFormByClubCode?[clubCode];
      final apiLast = apiForm != null && apiForm.isNotEmpty ? apiForm.last : '-';
      final computedLast = form.isNotEmpty ? form.last : '-';
      final mismatch = apiLast != computedLast ? ' MISMATCH(api=$apiLast)' : '';

      debugPrint(
        '[Last5] $clubCode $teamName: ${form.join(' ')} '
        '(last=$computedLast$mismatch)',
      );

      for (final game in computed.gamesByClubCode[clubCode] ?? const []) {
        debugPrint(
          '[Last5]   gd=${game.gameday} ${game.dateLabel} '
          '${game.result} ${game.matchLabel} [${game.gameCode}]',
        );
      }
    }

    if (apiFormByClubCode != null) {
      var mismatchCount = 0;
      for (final clubCode in sortedClubs) {
        final apiForm = apiFormByClubCode[clubCode];
        final computedForm = computed.formByClubCode[clubCode];
        if (apiForm == null || computedForm == null) continue;
        if (apiForm.join() != computedForm.join()) {
          mismatchCount++;
        }
      }
      debugPrint('[Last5] API basicstandings mismatches: $mismatchCount teams');
    }
  }

  static String? findClubCodeForTeamName(
    RecentFormResult result,
    String apiTeamName,
  ) {
    final normalized = apiTeamName.toLowerCase();
    for (final entry in result.gamesByClubCode.entries) {
      for (final game in entry.value) {
        if (game.teamName.toLowerCase() == normalized) {
          return entry.key;
        }
      }
    }
    return null;
  }

  static void _addTeamGame(
    Map<String, List<RecentFormGame>> gamesByClub, {
    required String clubCode,
    required String teamName,
    required int gameday,
    required DateTime date,
    required String dateLabel,
    required String gameCode,
    required int gameNumber,
    required bool isWin,
    required String homeTeam,
    required String awayTeam,
    required int homeScore,
    required int awayScore,
  }) {
    if (clubCode.isEmpty) return;

    gamesByClub.putIfAbsent(clubCode, () => []);
    gamesByClub[clubCode]!.add(
      RecentFormGame(
        clubCode: clubCode,
        teamName: teamName,
        gameday: gameday,
        date: date,
        dateLabel: dateLabel,
        gameCode: gameCode,
        gameNumber: gameNumber,
        result: isWin ? 'W' : 'L',
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        homeScore: homeScore,
        awayScore: awayScore,
      ),
    );
  }

  static String _text(XmlElement game, String tag) {
    return game.findElements(tag).firstOrNull?.innerText.trim() ?? '';
  }

  static DateTime _parseGameDate(String value) {
    const months = {
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12,
    };

    final cleaned = value.replaceAll(',', '').trim().split(RegExp(r'\s+'));
    if (cleaned.length != 3) return DateTime.fromMillisecondsSinceEpoch(0);

    final month = months[cleaned[0]];
    final day = int.tryParse(cleaned[1]);
    final year = int.tryParse(cleaned[2]);
    if (month == null || day == null || year == null) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    return DateTime(year, month, day);
  }
}
