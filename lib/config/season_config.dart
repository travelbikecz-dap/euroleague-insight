String getCurrentSeasonCode() {
  final now = DateTime.now();

  final seasonYear = now.month >= 9 ? now.year : now.year - 1;

  return 'E$seasonYear';
}
