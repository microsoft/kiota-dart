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

    for (final key in List<String>.of(_store.keys)) {
      final tuple = _store[key];
      if (tuple == null) {
        continue;
      }

      _ensureCollectionPropertyIsConsistent(key, tuple.$2);

      final updatedTuple = _store[key];
      if (updatedTuple == null) {
        continue;
      }

      final refreshedObj = updatedTuple.$2;
      if (refreshedObj is BackedModel) {
        refreshedObj.backingStore?.initializationCompleted = value;
      } else if (refreshedObj is (Iterable<Object?>, int)) {
        for (final model in refreshedObj.$1.whereType<BackedModel>()) {
          model.backingStore?.initializationCompleted = value;
        }
      } else if (refreshedObj is (Map<Object?, Object?>, int)) {
        for (final model in refreshedObj.$1.values.whereType<BackedModel>()) {
          model.backingStore?.initializationCompleted = value;
        }
      }

      _store[key] = (!value, refreshedObj);
    }
  }

  void _ensureCollectionPropertyIsConsistent(String key, Object? value) {
    // check if we put in a collection annotated with the size
    if (value is (Iterable<Object?>, int)) {
      for (final model in value.$1.whereType<BackedModel>()) {
        model.backingStore?.iterate().forEach((item) {
          // Call get() on nested properties so that this method may be called
          // recursively to ensure collections are consistent
          model.backingStore?.get<Object?>(item.key);
        });
      }

      // (and the size has changed since we last updated)
      if (value.$1.length != value.$2) {
        // ensure the store is notified the collection property has changed
        set(key, value.$1);
      }
    } else if (value is (Map<Object?, Object?>, int)) {
      for (final model in value.$1.values.whereType<BackedModel>()) {
        model.backingStore?.iterate().forEach((item) {
          model.backingStore?.get<Object?>(item.key);
        });
      }

      if (value.$1.length != value.$2) {
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

  bool _returnOnlyChangedValues = false;

  @override
  bool get returnOnlyChangedValues => _returnOnlyChangedValues;

  @override
  set returnOnlyChangedValues(bool value) {
    _returnOnlyChangedValues = value;

    for (final key in List<String>.of(_store.keys)) {
      final tuple = _store[key];
      if (tuple == null) {
        continue;
      }

      final obj = tuple.$2;
      if (obj is BackedModel) {
        final nestedStore = obj.backingStore;
        if (nestedStore != null &&
            nestedStore.returnOnlyChangedValues != value) {
          nestedStore.returnOnlyChangedValues = value;
        }
      } else if (obj is (Iterable<Object?>, int)) {
        for (final model in obj.$1.whereType<BackedModel>()) {
          final nestedStore = model.backingStore;
          if (nestedStore != null &&
              nestedStore.returnOnlyChangedValues != value) {
            nestedStore.returnOnlyChangedValues = value;
          }
        }
      } else if (obj is (Map<Object?, Object?>, int)) {
        for (final model in obj.$1.values.whereType<BackedModel>()) {
          final nestedStore = model.backingStore;
          if (nestedStore != null &&
              nestedStore.returnOnlyChangedValues != value) {
            nestedStore.returnOnlyChangedValues = value;
          }
        }
      }
    }
  }

  @override
  void clear() {
    for (final entry in List<MapEntry<String, (bool, Object?)>>.of(
      _store.entries,
    )) {
      _unsubscribeNestedModels(entry.key, entry.value.$2);
    }

    _store.clear();
  }

  void _unsubscribeNestedModels(String key, Object? value) {
    final unwrapped = _unwrapValue(value);
    if (unwrapped is BackedModel) {
      unwrapped.backingStore?.unsubscribe(key);
    } else if (unwrapped is Iterable<Object?>) {
      for (final model in unwrapped.whereType<BackedModel>()) {
        model.backingStore?.unsubscribe(key);
      }
    } else if (unwrapped is Map<Object?, Object?>) {
      for (final model in unwrapped.values.whereType<BackedModel>()) {
        model.backingStore?.unsubscribe(key);
      }
    }
  }

  Object? _unwrapValue(Object? value) {
    if (value is (Iterable<Object?>, int)) {
      return value.$1;
    }
    if (value is (Map<Object?, Object?>, int)) {
      return value.$1;
    }

    return value;
  }

  @override
  T? get<T>(String key) {
    if (key.isEmpty) {
      throw ArgumentError('The key cannot be empty.');
    }

    final tuple = _store[key];
    if (tuple == null) {
      return null;
    }

    _ensureCollectionPropertyIsConsistent(key, tuple.$2);

    final updatedTuple = _store[key];
    if (updatedTuple == null) {
      return null;
    }

    final changed = updatedTuple.$1;
    final unwrapped = _unwrapValue(updatedTuple.$2);

    return changed || !returnOnlyChangedValues ? unwrapped as T? : null;
  }

  @override
  Iterable<MapEntry<String, Object?>> iterate() sync* {
    for (final key in List<String>.of(_store.keys)) {
      final tuple = _store[key];
      if (tuple == null) {
        continue;
      }

      if (returnOnlyChangedValues) {
        _ensureCollectionPropertyIsConsistent(key, tuple.$2);
      }

      final updatedTuple = _store[key];
      if (updatedTuple == null) {
        continue;
      }

      if (updatedTuple.$1 || !returnOnlyChangedValues) {
        yield MapEntry(key, _unwrapValue(updatedTuple.$2));
      }
    }
  }

  @override
  Iterable<String> iterateKeysForValuesChangedToNull() sync* {
    for (final key in List<String>.of(_store.keys)) {
      final tuple = _store[key];
      if (tuple == null) {
        continue;
      }

      if (tuple.$1 && tuple.$2 == null) {
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
    } else if (value is Map<Object?, Object?>) {
      valueToAdd = (initializationCompleted, (value, value.length));
    }

    final oldValue = _store[key];
    final previousValue = _unwrapValue(oldValue?.$2);

    if (oldValue != null && !identical(previousValue, value)) {
      _unsubscribeNestedModels(key, oldValue.$2);
    }

    _store[key] = valueToAdd;

    if (value is BackedModel && !identical(previousValue, value)) {
      value.backingStore?.subscribe((dataKey, prev, next) {
        // all its properties are dirty as the model has been touched
        value.backingStore?.initializationCompleted = false;

        set(key, value);
      }, key);
    } else if (value is Iterable<Object?>) {
      for (final model in value.whereType<BackedModel>()) {
        model.backingStore?.initializationCompleted = false;
        model.backingStore?.subscribe((dataKey, prev, next) {
          model.backingStore?.initializationCompleted = false;
          set(key, value);
        }, key);
      }
    } else if (value is Map<Object?, Object?>) {
      for (final model in value.values.whereType<BackedModel>()) {
        model.backingStore?.initializationCompleted = false;
        model.backingStore?.subscribe((dataKey, prev, next) {
          model.backingStore?.initializationCompleted = false;
          set(key, value);
        }, key);
      }
    }

    for (final subscription in List<BackingStoreSubscriptionCallback>.of(
      _subscriptions.values,
    )) {
      subscription(key, previousValue, value);
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
