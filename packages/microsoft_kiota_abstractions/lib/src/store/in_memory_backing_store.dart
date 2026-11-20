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

      final unwrapped = _unwrapValue(updatedTuple.$2);
      if (unwrapped is BackedModel) {
        unwrapped.backingStore?.initializationCompleted = value;
      } else if (unwrapped is Iterable<Object?>) {
        for (final model in unwrapped.whereType<BackedModel>()) {
          model.backingStore?.initializationCompleted = value;
        }
      } else if (unwrapped is Map<Object?, Object?>) {
        for (final model in unwrapped.values.whereType<BackedModel>()) {
          model.backingStore?.initializationCompleted = value;
        }
      }

      var freshValue = updatedTuple.$2;
      if (unwrapped is Iterable<Object?>) {
        freshValue = (unwrapped, List<Object?>.of(unwrapped));
      } else if (unwrapped is Map<Object?, Object?>) {
        freshValue = (unwrapped, Map<Object?, Object?>.of(unwrapped));
      }

      _store[key] = (!value, freshValue);
    }
  }

  bool _hasMapChanged(
    Map<Object?, Object?> current,
    Map<Object?, Object?> snapshot,
  ) {
    if (current.length != snapshot.length) {
      return true;
    }
    for (final entry in current.entries) {
      if (!snapshot.containsKey(entry.key)) {
        return true;
      }
      final snapVal = snapshot[entry.key];
      if (!identical(entry.value, snapVal) && entry.value != snapVal) {
        return true;
      }
    }
    return false;
  }

  bool _hasIterableChanged(Iterable<Object?> current, List<Object?> snapshot) {
    if (current.length != snapshot.length) {
      return true;
    }
    var i = 0;
    for (final item in current) {
      final snapVal = snapshot[i++];
      if (!identical(item, snapVal) && item != snapVal) {
        return true;
      }
    }
    return false;
  }

  void _checkNestedModelConsistency(
    BackedModel model, [
    Set<BackingStore>? visited,
  ]) {
    final store = model.backingStore;
    if (store == null) {
      return;
    }
    visited ??= Set<BackingStore>.identity();
    if (!visited.add(store)) {
      return;
    }

    if (store is InMemoryBackingStore) {
      for (final key in List<String>.of(store._store.keys)) {
        final tuple = store._store[key];
        if (tuple != null) {
          store._ensureCollectionPropertyIsConsistent(key, tuple.$2, visited);
        }
      }
    } else {
      for (final entry in store.iterate()) {
        store.get<Object?>(entry.key);
      }
    }
  }

  void _ensureCollectionPropertyIsConsistent(
    String key,
    Object? value, [
    Set<BackingStore>? visited,
  ]) {
    if (value is (Iterable<Object?>, List<Object?>)) {
      for (final model in value.$1.whereType<BackedModel>()) {
        _checkNestedModelConsistency(model, visited);
      }

      _reconcileNestedSubscriptions(key, value.$1);

      if (_hasIterableChanged(value.$1, value.$2)) {
        set(key, value.$1);
      }
    } else if (value is (Map<Object?, Object?>, Map<Object?, Object?>)) {
      for (final model in value.$1.values.whereType<BackedModel>()) {
        _checkNestedModelConsistency(model, visited);
      }

      _reconcileNestedSubscriptions(key, value.$1);

      if (_hasMapChanged(value.$1, value.$2)) {
        set(key, value.$1);
      }
    } else if (value is BackedModel) {
      _checkNestedModelConsistency(value, visited);
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

      final unwrapped = _unwrapValue(tuple.$2);
      if (unwrapped is BackedModel) {
        final nestedStore = unwrapped.backingStore;
        if (nestedStore != null &&
            nestedStore.returnOnlyChangedValues != value) {
          nestedStore.returnOnlyChangedValues = value;
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
    final unwrappedValue = _unwrapValue(value);
    final currentModels = _extractBackedModels(unwrappedValue);
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

      final isDirectModel = unwrappedValue is BackedModel;

      for (final model in currentModels) {
        if (!map.containsKey(model)) {
          final targetStore = model.backingStore;
          if (targetStore != null) {
            if (!initializationCompleted) {
              targetStore.initializationCompleted = false;
            }
            if (isDirectModel &&
                returnOnlyChangedValues &&
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
    if (value is (Iterable<Object?>, Object?)) {
      return value.$1;
    }
    if (value is (Map<Object?, Object?>, Object?)) {
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
      valueToAdd = (initializationCompleted, (value, List<Object?>.of(value)));
    } else if (value is Map<Object?, Object?>) {
      valueToAdd = (
        initializationCompleted,
        (value, Map<Object?, Object?>.of(value)),
      );
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
