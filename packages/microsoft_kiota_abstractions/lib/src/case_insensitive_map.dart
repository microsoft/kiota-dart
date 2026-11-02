part of '../microsoft_kiota_abstractions.dart';

/// Stores key-value pairs with case-insensitive keys.
///
/// Internally uses two maps to store the data. The first map stores the
/// normalized keys and the values. The second map stores normalized keys and
/// the original keys.
class CaseInsensitiveMap<K extends String, V> implements Map<K, V> {
  /// Creates a new instance of [CaseInsensitiveMap].
  CaseInsensitiveMap();

  /// Normalizes the given [key] to be used as a key in the internal maps.
  static String normalizeKey<T extends String>(T key) => key.toUpperCase();

  final Map<String, V> _contents = {};
  final Map<String, K> _originalKeys = {};

  @override
  V? operator [](Object? key) {
    if (key is K) {
      return _contents[normalizeKey(key)];
    }

    return null;
  }

  @override
  void operator []=(K key, V value) {
    final lowerCaseKey = normalizeKey(key);

    _originalKeys[lowerCaseKey] = key;
    _contents[lowerCaseKey] = value;
  }

  @override
  void addAll(Map<K, V> other) {
    other.forEach((key, value) {
      this[key] = value;
    });
  }

  @override
  void addEntries(Iterable<MapEntry<K, V>> newEntries) {
    newEntries.forEach((entry) {
      this[entry.key] = entry.value;
    });
  }

  @override
  Map<RK, RV> cast<RK, RV>() => _contents.cast<RK, RV>();

  @override
  void clear() {
    _contents.clear();
    _originalKeys.clear();
  }

  @override
  bool containsKey(Object? key) {
    if (key is K) {
      return _contents.containsKey(normalizeKey(key));
    }

    return false;
  }

  @override
  bool containsValue(Object? value) => _contents.containsValue(value);

  @override
  Iterable<MapEntry<K, V>> get entries {
    return _contents.entries.map((entry) {
      return MapEntry(_originalKeys[entry.key]!, entry.value);
    });
  }

  @override
  void forEach(void Function(K key, V value) action) {
    _contents.forEach((key, value) {
      action(_originalKeys[key]!, value);
    });
  }

  @override
  bool get isEmpty => _contents.isEmpty;

  @override
  bool get isNotEmpty => _contents.isNotEmpty;

  @override
  Iterable<K> get keys => _contents.keys.map((key) => _originalKeys[key]!);

  @override
  int get length => _contents.length;

  @override
  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> Function(K key, V value) convert) {
    final result = <K2, V2>{};

    _contents.forEach((key, value) {
      final entry = convert(_originalKeys[key]!, value);
      result[entry.key] = entry.value;
    });

    return result;
  }

  @override
  V putIfAbsent(K key, V Function() ifAbsent) {
    final normalizedKey = normalizeKey(key);

    return _contents.putIfAbsent(normalizedKey, () {
      _originalKeys[normalizedKey] = key;

      return ifAbsent();
    });
  }

  @override
  V? remove(Object? key) {
    if (key is K) {
      _originalKeys.remove(normalizeKey(key));
      return _contents.remove(normalizeKey(key));
    }

    return null;
  }

  @override
  void removeWhere(bool Function(K key, V value) test) {
    final keys = _contents.keys.toList();

    for (final key in keys) {
      if (test(_originalKeys[key]!, _contents[key] as V)) {
        _originalKeys.remove(key);
        _contents.remove(key);
      }
    }
  }

  @override
  V update(K key, V Function(V value) update, {V Function()? ifAbsent}) {
    final normalizedKey = normalizeKey(key);

    return _contents.update(
      normalizedKey,
      update,
      ifAbsent: ifAbsent == null
          ? null
          : () {
              _originalKeys[normalizedKey] = key;

              return ifAbsent();
            },
    );
  }

  @override
  void updateAll(V Function(K key, V value) update) {
    final keys = _contents.keys.toList();

    for (final key in keys) {
      _contents[key] = update(_originalKeys[key]!, _contents[key] as V);
    }
  }

  @override
  Iterable<V> get values => _contents.values;
}
