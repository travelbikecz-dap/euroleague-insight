class PlayerNameFormatter {
  static String displayName(String apiName) {
    final parts = apiName.split(',');
    if (parts.length == 2) {
      final lastName = _titleCase(parts[0].trim());
      final firstName = _titleCase(parts[1].trim());
      return '$firstName $lastName';
    }
    return _titleCase(apiName);
  }

  static String _titleCase(String value) {
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
}
