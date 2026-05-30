enum GamePhase {
  regularSeason,
  playIn,
  playoffs,
  finalFour,
}

GamePhase gamePhaseFromApiCode(String? code) {
  switch (code?.toUpperCase()) {
    case 'RS':
      return GamePhase.regularSeason;
    case 'PI':
      return GamePhase.playIn;
    case 'PO':
      return GamePhase.playoffs;
    case 'FF':
      return GamePhase.finalFour;
    default:
      return GamePhase.regularSeason;
  }
}
