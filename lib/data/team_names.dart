class TeamNames {
  static String shortName(String apiName) {
    switch (apiName) {
      case 'Olympiacos Piraeus':
        return 'Olympiacos';

      case 'Fenerbahce Beko Istanbul':
        return 'Fenerbahce';

      case 'Panathinaikos AKTOR Athens':
        return 'Panathinaikos';

      case 'FC Barcelona':
        return 'Barcelona';

      case 'AS Monaco':
        return 'Monaco';

      case 'Zalgiris Kaunas':
        return 'Zalgiris';

      case 'Valencia Basket':
        return 'Valencia';

      case 'EA7 Emporio Armani Milan':
        return 'Milano';

      case 'FC Bayern Munich':
        return 'Bayern';

      case 'Paris Basketball':
        return 'Paris';

      case 'Dubai Basketball':
        return 'Dubai';

      case 'Hapoel IBI Tel Aviv':
        return 'Hapoel';

      case 'Maccabi Rapyd Tel Aviv':
        return 'Maccabi';

      case 'Virtus Bologna':
        return 'Virtus';

      case 'Anadolu Efes Istanbul':
        return 'Anadolu Efes';

      case 'Kosner Baskonia Vitoria-Gasteiz':
        return 'Baskonia';

      case 'Crvena Zvezda Meridianbet Belgrade':
        return 'Crvena Zvezda';

      case 'LDLC ASVEL Villeurbanne':
        return 'ASVEL';

      case 'Partizan Mozzart Bet Belgrade':
        return 'Partizan';

      case 'Real Madrid':
        return 'Real Madrid';

      default:
        return apiName;
    }
  }

  /// Display name for the compact Teams list (one line).
  static String listName(String apiName) => shortName(apiName);
}
