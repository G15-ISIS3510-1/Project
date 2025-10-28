// lib/app/utils/lru_cache.dart
import 'dart:collection';

/// Tiny, generic LRU cache using LinkedHashMap's insertion order.
/// - Most recently used entries are moved to the end.
/// - When [capacity] is exceeded, the least-recently-used (the first key) is evicted.
class LruCache<K, V> {
  final int capacity;
  final _map = LinkedHashMap<K, V>();

  LruCache(this.capacity) : assert(capacity > 0, 'capacity must be > 0');

  int get length => _map.length;
  Iterable<K> get keys => _map.keys;

  V? get(K key) {
    final value = _map.remove(key);
    if (value != null) _map[key] = value; // reinsert to mark as MRU
    return value;
  }

  void put(K key, V value) {
    // remove first to update order if key existed
    _map.remove(key);
    _map[key] = value;
    // evict LRU
    if (_map.length > capacity) {
      final lruKey = _map.keys.first;
      _map.remove(lruKey);
    }
  }

  bool containsKey(K key) => _map.containsKey(key);
  V? remove(K key) => _map.remove(key);
  void clear() => _map.clear();
}
