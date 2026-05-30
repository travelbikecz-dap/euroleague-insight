class PlayerBioFormatter {
  static String formatTeamName(String value) {
    if (value.isEmpty) return value;
    return value
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  static int? ageFromBirthDate(DateTime? birthDate) {
    if (birthDate == null) return null;

    final today = DateTime.now();
    var age = today.year - birthDate.year;
    final hadBirthdayThisYear = today.month > birthDate.month ||
        (today.month == birthDate.month && today.day >= birthDate.day);
    if (!hadBirthdayThisYear) age--;
    return age;
  }
}
