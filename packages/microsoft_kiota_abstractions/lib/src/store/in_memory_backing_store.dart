part of '../../microsoft_kiota_abstractions.dart';

class InMemoryBackingStore implements BackingStore {
  final Map<String, (bool, Object?)> _store = {};
  final Map<String, BackingStoreSubscriptionCallback> _subscriptions = {};
  final Map<String, Map<BackedModel, String>> _nestedSubscriptions = {};

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

      final models = _nestedSubscriptions[key];
      if (models != null) {
        for (final model in models.keys) {
          model.backingStore?.initializationCompleted = value;
        }
      }

      _store[key] = (!value, updatedTuple.$2);
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

      _reconcileNestedSubscriptions(key, value.$1);

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

      _reconcileNestedSubscriptions(key, value.$1);

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

      _ensureCollectionPropertyIsConsistent(key, tuple.$2);

      final models = _nestedSubscriptions[key];
      if (models != null) {
        for (final model in models.keys) {
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
    for (final models in _nestedSubscriptions.values) {
      for (final entry in models.entries) {
        entry.key.backingStore?.unsubscribe(entry.value);
      }
    }
    _nestedSubscriptions.clear();
    _store.clear();
  }

  void _collectBackedModels(Object? value, Set<BackedModel> models) {
    final unwrapped = _unwrapValue(value);
    if (unwrapped is BackedModel) {
      models.add(unwrapped);
    } else if (unwrapped is Iterable<Object?>) {
      for (final item in unwrapped) {
        _collectBackedModels(item, models);
      }
    } else if (unwrapped is Map<Object?, Object?>) {
      for (final item in unwrapped.values) {
        _collectBackedModels(item, models);
      }
    }
  }

  Set<BackedModel> _extractBackedModels(Object? value) {
    final models = Set<BackedModel>.identity();
    _collectBackedModels(value, models);
    return models;
  }

  void _reconcileNestedSubscriptions(String key, Object? value) {
    final currentModels = _extractBackedModels(value);
    final registered = _nestedSubscriptions[key];

    if (registered != null) {
      final removedModels = <BackedModel>[];
      for (final model in registered.keys) {
        if (!currentModels.contains(model)) {
          removedModels.add(model);
        }
      }

      for (final model in removedModels) {
        final subId = registered.remove(model);
        if (subId != null) {
          model.backingStore?.unsubscribe(subId);
        }
      }

      if (registered.isEmpty && currentModels.isEmpty) {
        _nestedSubscriptions.remove(key);
      }
    }

    if (currentModels.isNotEmpty) {
      final map = _nestedSubscriptions.putIfAbsent(
        key,
        Map<BackedModel, String>.identity,
      );

      for (final model in currentModels) {
        if (!map.containsKey(model)) {
          final targetStore = model.backingStore;
          if (targetStore != null) {
            if (!initializationCompleted) {
              targetStore.initializationCompleted = false;
            }
            if (returnOnlyChangedValues &&
                !targetStore.returnOnlyChangedValues) {
              targetStore.returnOnlyChangedValues = true;
            }

            final subscriptionId = const Uuid().v4();
            final registeredId = targetStore.subscribe((dataKey, prev, next) {
              if (!_store.containsKey(key)) {
                return;
              }
              final currentRegistered = _nestedSubscriptions[key];
              if (currentRegistered == null ||
                  !currentRegistered.containsKey(model)) {
                return;
              }

              targetStore.initializationCompleted = false;
              final currentTuple = _store[key];
              if (currentTuple == null) {
                return;
              }
              final currentValue = _unwrapValue(currentTuple.$2);
              set(key, currentValue);
            }, subscriptionId);

            final handle = registeredId.isNotEmpty
                ? registeredId
                : subscriptionId;
            map[model] = handle;
          }
        }
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

    _store[key] = valueToAdd;

    _reconcileNestedSubscriptions(key, value);

    for (final entry
        in List<MapEntry<String, BackingStoreSubscriptionCallback>>.of(
          _subscriptions.entries,
        )) {
      if (_subscriptions.containsKey(entry.key)) {
        entry.value(key, previousValue, value);
      }
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
