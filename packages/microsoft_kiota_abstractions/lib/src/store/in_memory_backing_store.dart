part of '../../microsoft_kiota_abstractions.dart';

class InMemoryBackingStore implements BackingStore {
  final Map<String, (bool, Object?)> _store = {};
  final Map<String, BackingStoreSubscriptionCallback> _subscriptions = {};

  bool _initializationCompleted = true;

  @override
  bool get initializationCompleted => _initializationCompleted;

  @override
  set initializationCompleted(bool value) {
    _initializationCompleted = value;

    for (final key in _store.keys) {
      final tuple = _store[key]!;
      final obj = tuple.$2;

      if (obj is BackedModel) {
        obj.backingStore?.initializationCompleted = value;
      }

      _ensureCollectionPropertyIsConsistent(key, obj);

      _store[key] = (!value, obj);
    }
  }

  void _ensureCollectionPropertyIsConsistent(String key, Object? value) {
    // check if we put in a collection annotated with the size
    if (value is (Iterable<Object?>, int)) {
      value.$1.whereType<BackedModel>().forEach((model) {
        model.backingStore?.iterate().forEach((item) {
          // Call get() on nested properties so that this method may be called
          // recursively to ensure collections are consistent
          model.backingStore?.get<Object?>(item.key);
        });
      });

      // (and the size has changed since we last updated)
      if (value.$1.length != value.$2) {
        // ensure the store is notified the collection property has changed
        set(key, value.$1);
      }
    } else if (value is BackedModel) {
      value.backingStore?.iterate().forEach((item) {
        // Call get() on nested properties so that this method may be called
        // recursively to ensure collections are consistent
        value.backingStore?.get<Object?>(item.key);
      });
    }
  }

  @override
  bool returnOnlyChangedValues = false;

  @override
  void clear() => _store.clear();

  @override
  T? get<T>(String key) {
    if (key.isEmpty) {
      throw ArgumentError('The key cannot be empty.');
    }

    if (!_store.containsKey(key)) {
      return null;
    }

    final tuple = _store[key]!;
    final changed = tuple.$1;
    var obj = tuple.$2;

    _ensureCollectionPropertyIsConsistent(key, obj);

    if (obj is (Iterable<Object?>, int)) {
      obj = obj.$1;
    }

    return changed || !returnOnlyChangedValues ? obj as T? : null;
  }

  @override
  Iterable<MapEntry<String, Object?>> iterate() sync* {
    for (final key in _store.keys) {
      final tuple = _store[key]!;
      final changed = tuple.$1;
      final obj = tuple.$2;

      if (returnOnlyChangedValues) {
        _ensureCollectionPropertyIsConsistent(key, obj);
      }

      if (changed || !returnOnlyChangedValues) {
        yield MapEntry(key, obj);
      }
    }
  }

  @override
  Iterable<String> iterateKeysForValuesChangedToNull() sync* {
    for (final key in _store.keys) {
      final tuple = _store[key]!;
      final changed = tuple.$1;
      final obj = tuple.$2;

      if (changed && obj == null) {
        yield key;
      }
    }
  }

  @override
  void set<T>(String key, T value) {
    if (key.isEmpty) {
      throw ArgumentError('The key cannot be empty.');
    }

    (bool, Object?) valueToAdd = (initializationCompleted, value);
    if (value is Iterable<Object?>) {
      valueToAdd = (initializationCompleted, (value, value.length));
    }

    (bool, Object?)? oldValue;
    if (_store.containsKey(key)) {
      oldValue = _store[key];
    } else if (value is BackedModel) {
      value.backingStore?.subscribe((dataKey, previousValue, newValue) {
        // all its properties are dirty as the model has been touched
        value.backingStore!.initializationCompleted = false;

        set(key, value);
      }, key);
    }

    _store[key] = valueToAdd;

    if (value is Iterable<Object?>) {
      value.whereType<BackedModel>().forEach((model) {
        model.backingStore?.initializationCompleted = false;
        model.backingStore?.subscribe((dataKey, previousValue, newValue) {
          set(key, value);
        }, key);
      });
    }

    for (final subscription in _subscriptions.values) {
      subscription(key, oldValue?.$2, value);
    }
  }

  @override
  String subscribe(
    BackingStoreSubscriptionCallback callback, [
    String? subscriptionId,
  ]) {
    subscriptionId ??= const Uuid().v4();

    _subscriptions[subscriptionId] = callback;

    return subscriptionId;
  }

  @override
  void unsubscribe(String subscriptionId) {
    _subscriptions.remove(subscriptionId);
  }
}
