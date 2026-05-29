class ApiCache {
  ApiCache._();

  static final ApiCache instance = ApiCache._();

  final Map<String, _CacheEntry> _entries = {};

  T? get<T>(String key) {
    final entry = _entries[key];
    if (entry == null) return null;
    if (DateTime.now().isAfter(entry.expiresAt)) {
      _entries.remove(key);
      return null;
    }
    return entry.value as T;
  }

  void set(String key, Object value, Duration ttl) {
    _entries[key] = _CacheEntry(
      value: value,
      expiresAt: DateTime.now().add(ttl),
    );
  }

  void invalidate(String keyPrefix) {
    _entries.removeWhere((key, _) => key.startsWith(keyPrefix));
  }

  void clear() => _entries.clear();
}

class _CacheEntry {
  _CacheEntry({required this.value, required this.expiresAt});

  final Object value;
  final DateTime expiresAt;
}

class CacheDurations {
  static const seasonCode = Duration(hours: 24);
  static const liveData = Duration(minutes: 15);
  static const clubStats = Duration(minutes: 15);
}
