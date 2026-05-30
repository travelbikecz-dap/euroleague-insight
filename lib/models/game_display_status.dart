enum GameDisplayStatus {
  scheduled,
  live,
  final_,
  postponed,
  suspended,
  cancelled,
  walkover,
}

extension GameDisplayStatusLabel on GameDisplayStatus {
  String get label {
    return switch (this) {
      GameDisplayStatus.scheduled => 'SCHEDULED',
      GameDisplayStatus.live => 'LIVE',
      GameDisplayStatus.final_ => 'FINAL',
      GameDisplayStatus.postponed => 'POSTPONED',
      GameDisplayStatus.suspended => 'SUSPENDED',
      GameDisplayStatus.cancelled => 'CANCELLED',
      GameDisplayStatus.walkover => 'WALKOVER',
    };
  }

  int get sortOrder {
    return switch (this) {
      GameDisplayStatus.live => 0,
      GameDisplayStatus.scheduled => 1,
      GameDisplayStatus.final_ => 2,
      GameDisplayStatus.walkover => 3,
      GameDisplayStatus.postponed => 4,
      GameDisplayStatus.suspended => 5,
      GameDisplayStatus.cancelled => 6,
    };
  }
}
