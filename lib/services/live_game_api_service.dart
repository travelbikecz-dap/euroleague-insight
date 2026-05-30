import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/live_game_snapshot.dart';

class LiveGameApiService {
  LiveGameApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<LiveGameSnapshot?> fetchHeader({
    required int gameCode,
    required String seasonCode,
  }) async {
    final uri = Uri.parse(
      'https://live.euroleague.net/api/Header'
      '?gamecode=$gameCode&seasoncode=$seasonCode',
    );

    final response = await _client.get(uri);
    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body);
    if (data is! Map<String, dynamic>) return null;

    return _parseHeader(gameCode, data);
  }

  Future<Map<int, LiveGameSnapshot>> fetchHeaders({
    required String seasonCode,
    required Iterable<int> gameCodes,
  }) async {
    final snapshots = <int, LiveGameSnapshot>{};

    await Future.wait(
      gameCodes.map((gameCode) async {
        final snapshot = await fetchHeader(
          gameCode: gameCode,
          seasonCode: seasonCode,
        );
        if (snapshot != null) {
          snapshots[gameCode] = snapshot;
        }
      }),
    );

    return snapshots;
  }

  LiveGameSnapshot? _parseHeader(int gameCode, Map<String, dynamic> json) {
    final homeScore = _parseScore(json['ScoreA']);
    final awayScore = _parseScore(json['ScoreB']);

    return LiveGameSnapshot(
      gameCode: gameCode,
      isLive: json['Live'] as bool? ?? false,
      homeScore: homeScore,
      awayScore: awayScore,
      quarter: json['Quarter'] as String?,
      remainingTime: json['RemainingPartialTime'] as String?,
    );
  }

  int? _parseScore(Object? value) {
    if (value == null) return null;
    return int.tryParse(value.toString().trim());
  }
}
