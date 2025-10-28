// lib/app/utils/lru_cache.dart
import 'dart:collection';

/// Tiny, generic LRU cache using LinkedHashMap's insertion order.
/// - Most recently used entries are moved to the end.
/// - When [capacity] is exceeded, the least-recently-used (the first key) is evicted.
///
/// Typical usage in our app:
///   - Cache availability for the most recently viewed vehicles
///   - Cache a few "pages" of bookings/vehicles
class LruCache<K, V> {
  final int capacity;
  final _map = LinkedHashMap<K, V>();

  LruCache(this.capacity) : assert(capacity > 0, 'capacity must be > 0');

  int get length => _map.length;
  Iterable<K> get keys => _map.keys;

  /// Returns the value (and promotes it to MRU position), or null if not present.
  V? get(K key) {
    final value = _map.remove(key);
    if (value != null) {
      // reinsert at the end = most recently used
      _map[key] = value;
    }
    return value;
  }

  /// Insert/update.
  /// If inserting will overflow capacity, evict the least-recently-used entry.
  void put(K key, V value) {
    // If key already exists, remove first so we can reinsert at the end.
    _map.remove(key);
    _map[key] = value;

    // Evict if over capacity
    if (_map.length > capacity) {
      final lruKey = _map.keys.first;
      _map.remove(lruKey);

      // Debug log only in debug/profile (assert block does not run in release)
      assert(() {
        print('[LruCache] Evicted key=$lruKey (capacity=$capacity)');
        return true;
      }());
    }
  }

  bool containsKey(K key) => _map.containsKey(key);

  /// Remove one key manually.
  V? remove(K key) => _map.remove(key);

  /// Clear everything (e.g. on logout or manual forceRefresh).
  void clear() => _map.clear();
}
