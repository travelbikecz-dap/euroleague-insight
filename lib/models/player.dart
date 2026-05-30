import '../utils/player_name_formatter.dart';

class Player {
  final String code;
  final String apiName;
  final String displayName;
  final String? photoUrl;
  final String dorsal;
  final String position;
  final String country;
  final String birthCountry;
  final String lastTeam;
  final int height;
  final int weight;
  final DateTime? birthDate;

  Player({
    required this.code,
    required this.apiName,
    required this.displayName,
    required this.photoUrl,
    required this.dorsal,
    required this.position,
    required this.country,
    required this.birthCountry,
    required this.lastTeam,
    required this.height,
    required this.weight,
    required this.birthDate,
  });

  factory Player.fromRosterJson(Map<String, dynamic> json) {
    final person = Map<String, dynamic>.from(json['person'] as Map);
    final country = person['country'] as Map<String, dynamic>?;
    final birthCountry = person['birthCountry'] as Map<String, dynamic>?;
    final apiName = person['name'] as String? ?? '';

    return Player(
      code: person['code'] as String? ?? '',
      apiName: apiName,
      displayName: PlayerNameFormatter.displayName(apiName),
      photoUrl: _extractPhotoUrl(json['images']) ??
          _extractPhotoUrl(person['images']),
      dorsal: json['dorsal'] as String? ?? '',
      position: json['positionName'] as String? ?? '',
      country: country?['name'] as String? ?? '',
      birthCountry: birthCountry?['name'] as String? ?? '',
      lastTeam: json['lastTeam'] as String? ?? '',
      height: person['height'] as int? ?? 0,
      weight: person['weight'] as int? ?? 0,
      birthDate: _parseBirthDate(person['birthDate'] as String?),
    );
  }

  static DateTime? _parseBirthDate(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  static String? _extractPhotoUrl(Object? imagesRaw) {
    if (imagesRaw is! Map) return null;

    final images = Map<String, dynamic>.from(imagesRaw);
    if (images.isEmpty) return null;

    for (final key in ['headshot', 'action', 'photo', 'portrait']) {
      final url = _asUrl(images[key]);
      if (url != null) return url;
    }

    return null;
  }

  static String? _asUrl(Object? value) {
    if (value is String && value.startsWith('http')) return value;
    if (value is Map) {
      final nested = value['url'] ?? value['src'];
      if (nested is String && nested.startsWith('http')) return nested;
    }
    return null;
  }
}

class PlayerStatItem {
  final String label;
  final String value;

  const PlayerStatItem({required this.label, required this.value});
}

class PlayerSeasonStats {
  final String playerCode;
  final String teamCode;
  final int gamesPlayed;
  final double minutesPerGame;
  final double ppg;
  final double rebounds;
  final double assists;
  final double steals;
  final double blocks;
  final double turnovers;
  final double offensiveRebounds;
  final double defensiveRebounds;
  final double pir;
  final double plusMinus;
  final String fieldGoalPercentage;
  final String threePointPercentage;
  final String freeThrowPercentage;

  PlayerSeasonStats({
    required this.playerCode,
    required this.teamCode,
    required this.gamesPlayed,
    required this.minutesPerGame,
    required this.ppg,
    required this.rebounds,
    required this.assists,
    required this.steals,
    required this.blocks,
    required this.turnovers,
    required this.offensiveRebounds,
    required this.defensiveRebounds,
    required this.pir,
    required this.plusMinus,
    required this.fieldGoalPercentage,
    required this.threePointPercentage,
    required this.freeThrowPercentage,
  });

  List<PlayerStatItem> get seasonStats => [
    PlayerStatItem(label: 'GP', value: gamesPlayed.toString()),
    PlayerStatItem(label: 'MIN', value: _n(minutesPerGame)),
    PlayerStatItem(label: 'PTS', value: _n(ppg)),
    PlayerStatItem(label: 'PIR', value: _n(pir)),
    PlayerStatItem(label: 'REB', value: _n(rebounds)),
    PlayerStatItem(label: 'OREB', value: _n(offensiveRebounds)),
    PlayerStatItem(label: 'DREB', value: _n(defensiveRebounds)),
    PlayerStatItem(label: 'AST', value: _n(assists)),
    PlayerStatItem(label: 'STL', value: _n(steals)),
    PlayerStatItem(label: 'BLK', value: _n(blocks)),
    PlayerStatItem(label: 'TOV', value: _n(turnovers)),
    PlayerStatItem(label: 'FG%', value: fieldGoalPercentage),
    PlayerStatItem(label: '3P%', value: threePointPercentage),
    PlayerStatItem(label: 'FT%', value: freeThrowPercentage),
  ];

  String _n(double value) => value.toStringAsFixed(1);
}
