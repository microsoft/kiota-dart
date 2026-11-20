import 'package:microsoft_kiota_abstractions/microsoft_kiota_abstractions.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'in_memory_backing_store_test.mocks.dart';

@GenerateMocks([BackedModel])
void main() {
  group('InMemoryBackingStore', () {
    test('stores values by key', () {
      final store = InMemoryBackingStore()..set('key', 'value');

      expect(store.get<String>('key'), 'value');
    });

    test('clears all values', () {
      final store = InMemoryBackingStore()
        ..set('key', 'value')
        ..set('key2', 'value2')
        ..clear();

      expect(store.get<String>('key'), null);
    });

    test('iterates over all values', () {
      final store = InMemoryBackingStore();

      expect(store.iterate(), isEmpty);

      store
        ..set('key', 'value')
        ..set('key2', 'value2');

      final entries = store.iterate().toList();

      expect(entries, hasLength(2));
      expect(entries.map((e) => e.key), containsAll(['key', 'key2']));
      expect(entries.map((e) => e.value), containsAll(['value', 'value2']));
    });

    test('iterates over all values that have changed to null', () {
      final store = InMemoryBackingStore()
        ..set('name', 'Peter Pan')
        ..set('email', 'peterpan@neverland.com')
        ..set('phone', null);

      final changedToNullEntries = store
          .iterateKeysForValuesChangedToNull()
          .toList();
      final entries = store.iterate().toList();

      expect(entries, hasLength(3));
      expect(changedToNullEntries, hasLength(1));
      expect(changedToNullEntries, contains('phone'));
    });

    test('prevents duplicates in store', () {
      final store = InMemoryBackingStore();

      expect(store.iterate(), isEmpty);

      store
        ..set('key', 'value')
        ..set('key', 'value2');

      expect(store.iterate(), hasLength(1));
      expect(store.get<String>('key'), 'value2');
    });

    test('propagates initialization completed to backed models', () {
      final aModel = MockBackedModel();
      final aStore = InMemoryBackingStore();

      when(aModel.backingStore).thenReturn(aStore);

      final bStore = InMemoryBackingStore();

      expect(aStore.initializationCompleted, isTrue);
      expect(bStore.initializationCompleted, isTrue);

      bStore
        ..set('aModel', aModel)
        ..initializationCompleted = false;

      expect(aStore.initializationCompleted, isFalse);
      expect(bStore.initializationCompleted, isFalse);

      bStore.initializationCompleted = true;

      expect(aStore.initializationCompleted, isTrue);
      expect(bStore.initializationCompleted, isTrue);

      final cModel = MockBackedModel();
      final cStore = InMemoryBackingStore();
      when(cModel.backingStore).thenReturn(cStore);

      bStore.set('cModel', cModel);
    });

    test('subscriptions get notified', () {
      final store = InMemoryBackingStore();

      String? key;
      Object? oldValue;
      Object? newValue;
      final subscriptionId = store.subscribe((k, a, b) {
        key = k;
        oldValue = a;
        newValue = b;
      });

      store.set('name', 'Peter');

      expect(key, 'name');
      expect(oldValue, null);
      expect(newValue, 'Peter');
      expect(subscriptionId, isNotNull);
    });

    test('unwraps stored collections in iterate and subscriber callbacks', () {
      final initialTags = ['a', 'b'];
      final updatedTags = ['a', 'b', 'c'];
      final store = InMemoryBackingStore()..set('tags', initialTags);

      final iterated = store.iterate().toList();
      expect(iterated, hasLength(1));
      expect(iterated.first.key, 'tags');
      expect(iterated.first.value, same(initialTags));

      Object? receivedPrevious;
      Object? receivedNew;
      store
        ..subscribe((k, previous, next) {
          receivedPrevious = previous;
          receivedNew = next;
        })
        ..set('tags', updatedTags);

      expect(receivedPrevious, same(initialTags));
      expect(receivedNew, same(updatedTags));
    });

    test(
      'detects in-place collection mutations immediately in get and iterate',
      () {
        final tagsForGet = ['one'];
        final storeForGet = InMemoryBackingStore()
          ..set('tags', tagsForGet)
          ..initializationCompleted = true
          ..returnOnlyChangedValues = true;

        expect(storeForGet.get<List<String>>('tags'), isNull);
        tagsForGet.add('two');
        expect(storeForGet.get<List<String>>('tags'), equals(['one', 'two']));

        final tagsForIterate = ['alpha'];
        final storeForIterate = InMemoryBackingStore()
          ..set('tags', tagsForIterate)
          ..initializationCompleted = true
          ..returnOnlyChangedValues = true;

        expect(storeForIterate.iterate().toList(), isEmpty);
        tagsForIterate.add('beta');

        final changedEntries = storeForIterate.iterate().toList();
        expect(changedEntries, hasLength(1));
        expect(changedEntries.first.key, 'tags');
        expect(changedEntries.first.value, equals(['alpha', 'beta']));
      },
    );

    test(
      'preserves refreshed collection size snapshot when initializationCompleted is set',
      () {
        final items = ['initial'];
        final store = InMemoryBackingStore()
          ..initializationCompleted = false
          ..set('items', items);

        items.add('added-during-init');

        store
          ..initializationCompleted = true
          ..returnOnlyChangedValues = true;

        expect(store.iterate().toList(), isEmpty);
        expect(store.iterate().toList(), isEmpty);
        expect(store.get<List<String>>('items'), isNull);

        items.add('mutated-after-init');
        expect(
          store.get<List<String>>('items'),
          equals(['initial', 'added-during-init', 'mutated-after-init']),
        );
      },
    );

    test(
      'propagates initializationCompleted and returnOnlyChangedValues to nested models and collections',
      () {
        final directChild = MockBackedModel();
        final directChildStore = InMemoryBackingStore();
        when(directChild.backingStore).thenReturn(directChildStore);

        final listChild = MockBackedModel();
        final listChildStore = InMemoryBackingStore();
        when(listChild.backingStore).thenReturn(listChildStore);

        final parent = InMemoryBackingStore()
          ..set('child', directChild)
          ..set('children', [listChild])
          ..initializationCompleted = false;

        expect(directChildStore.initializationCompleted, isFalse);
        expect(listChildStore.initializationCompleted, isFalse);

        parent
          ..initializationCompleted = true
          ..returnOnlyChangedValues = true;

        expect(directChildStore.initializationCompleted, isTrue);
        expect(listChildStore.initializationCompleted, isTrue);
        expect(directChildStore.returnOnlyChangedValues, isTrue);
        expect(listChildStore.returnOnlyChangedValues, isTrue);

        parent.returnOnlyChangedValues = false;
        expect(directChildStore.returnOnlyChangedValues, isFalse);
        expect(listChildStore.returnOnlyChangedValues, isFalse);
      },
    );

    test(
      'subscribes replaced BackedModel values and unsubscribes detached models',
      () {
        final firstChild = MockBackedModel();
        final firstStore = InMemoryBackingStore();
        when(firstChild.backingStore).thenReturn(firstStore);

        final secondChild = MockBackedModel();
        final secondStore = InMemoryBackingStore();
        when(secondChild.backingStore).thenReturn(secondStore);

        final parent = InMemoryBackingStore()
          ..initializationCompleted = false
          ..set('child', null)
          ..set('child', firstChild)
          ..set('child', secondChild)
          ..initializationCompleted = true
          ..returnOnlyChangedValues = true;

        // Mutating detached firstChild must not overwrite or dirty parent
        firstStore.set('title', 'stale');
        expect(parent.get<BackedModel>('child'), isNull);

        // Mutating active secondChild must mark parent dirty
        secondStore.set('title', 'active');
        expect(parent.get<BackedModel>('child'), same(secondChild));

        // Clearing parent must unsubscribe secondChild
        parent
          ..clear()
          ..returnOnlyChangedValues = false;
        secondStore.set('title', 'after-clear');
        expect(parent.get<BackedModel>('child'), isNull);
      },
    );

    test(
      'allows unsubscribing inside a subscription callback without ConcurrentModificationError',
      () {
        final store = InMemoryBackingStore();
        var secondCalled = false;
        late String firstId;
        firstId = store.subscribe((k, prev, next) {
          store.unsubscribe(firstId);
        });
        store
          ..subscribe((k, prev, next) {
            secondCalled = true;
          })
          ..set('name', 'value');

        expect(secondCalled, isTrue);
      },
    );

    test(
      'tracks Map mutations and unwraps Map values in iterate and subscriptions',
      () {
        final additionalData = <String, Object?>{'first': 1};
        final store = InMemoryBackingStore()
          ..set('additionalData', additionalData);

        final initialEntries = store.iterate().toList();
        expect(initialEntries, hasLength(1));
        expect(initialEntries.first.value, same(additionalData));

        store
          ..initializationCompleted = true
          ..returnOnlyChangedValues = true;

        expect(store.get<Map<String, Object?>>('additionalData'), isNull);
        expect(store.iterate().toList(), isEmpty);

        additionalData['second'] = 2;

        final mutated = store.get<Map<String, Object?>>('additionalData');
        expect(mutated, same(additionalData));
        expect(mutated, equals({'first': 1, 'second': 2}));

        final changedEntries = store.iterate().toList();
        expect(changedEntries, hasLength(1));
        expect(changedEntries.first.value, same(additionalData));

        Object? receivedPrevious;
        store
          ..subscribe((k, prev, next) => receivedPrevious = prev)
          ..set('additionalData', <String, Object?>{'replaced': true});
        expect(receivedPrevious, same(additionalData));
      },
    );

    test(
      'propagates flags and manages subscriptions for BackedModel values inside Maps',
      () {
        final mapChild = MockBackedModel();
        final mapChildStore = InMemoryBackingStore();
        when(mapChild.backingStore).thenReturn(mapChildStore);

        final parent = InMemoryBackingStore()
          ..set('items', <String, Object?>{'a': mapChild})
          ..initializationCompleted = false;

        expect(mapChildStore.initializationCompleted, isFalse);

        parent
          ..initializationCompleted = true
          ..returnOnlyChangedValues = true;

        expect(mapChildStore.initializationCompleted, isTrue);
        expect(mapChildStore.returnOnlyChangedValues, isTrue);
        expect(parent.get<Map<String, Object?>>('items'), isNull);

        mapChildStore.set('status', 'updated');
        expect(parent.get<Map<String, Object?>>('items'), isNotNull);

        parent
          ..set('items', <String, Object?>{})
          ..initializationCompleted = true
          ..returnOnlyChangedValues = true;

        // Detached mapChild should no longer dirty parent
        mapChildStore.set('status', 'detached');
        expect(parent.get<Map<String, Object?>>('items'), isNull);
      },
    );

    test(
      'allocates independent subscription IDs for shared child models across parents',
      () {
        final sharedChild = MockBackedModel();
        final childStore = InMemoryBackingStore();
        when(sharedChild.backingStore).thenReturn(childStore);

        final parentA = InMemoryBackingStore()
          ..set('child', sharedChild)
          ..initializationCompleted = true
          ..returnOnlyChangedValues = true;

        final parentB = InMemoryBackingStore()
          ..set('child', sharedChild)
          ..initializationCompleted = true
          ..returnOnlyChangedValues = true;

        // Clear parentA; parentA must unsubscribe only its own subscription handle
        parentA.clear();

        // Mutating child must still dirty parentB and not repopulate parentA
        childStore.set('name', 'updated');
        expect(parentB.get<BackedModel>('child'), same(sharedChild));
        expect(parentA.get<BackedModel>('child'), isNull);
        expect(parentA.iterate(), isEmpty);

        // Replacing parentB's property must also cleanly unsubscribe without throwing
        parentB.set('child', null);
        childStore.set('name', 'after-null');
        expect(parentB.get<BackedModel>('child'), isNull);
      },
    );

    test(
      'reconciles in-place collection removal and prevents detached child from dirtying parent',
      () {
        final childA = MockBackedModel();
        final storeA = InMemoryBackingStore();
        when(childA.backingStore).thenReturn(storeA);

        final childB = MockBackedModel();
        final storeB = InMemoryBackingStore();
        when(childB.backingStore).thenReturn(storeB);

        final items = <BackedModel>[childA, childB];
        final parent = InMemoryBackingStore()
          ..set('items', items)
          ..initializationCompleted = true
          ..returnOnlyChangedValues = true;

        expect(parent.get<List<BackedModel>>('items'), isNull);

        // Remove childA in place from the list
        items.remove(childA);

        // Access triggers collection consistency and reconciles subscriptions
        expect(parent.get<List<BackedModel>>('items'), equals([childB]));

        parent
          ..initializationCompleted = true
          ..returnOnlyChangedValues = true;

        expect(parent.get<List<BackedModel>>('items'), isNull);

        // Mutating detached childA must not dirty parent
        storeA.set('title', 'detached-change');
        expect(parent.get<List<BackedModel>>('items'), isNull);

        // Mutating retained childB must dirty parent
        storeB.set('title', 'retained-change');
        expect(parent.get<List<BackedModel>>('items'), equals([childB]));
      },
    );

    test(
      'reconciles in-place collection removal followed by clear without repopulating parent',
      () {
        final child = MockBackedModel();
        final childStore = InMemoryBackingStore();
        when(child.backingStore).thenReturn(childStore);

        final list = <BackedModel>[child];
        final parent = InMemoryBackingStore()..set('items', list);

        // Remove in place before clear() is invoked
        list.remove(child);
        parent.clear();

        // Mutating detached child must not repopulate cleared parent
        childStore.set('title', 'after-clear');
        expect(parent.get<List<BackedModel>>('items'), isNull);
        expect(parent.iterate(), isEmpty);
      },
    );

    test(
      'reconciles in-place Map removal followed by clear without repopulating parent',
      () {
        final mapChild = MockBackedModel();
        final mapChildStore = InMemoryBackingStore();
        when(mapChild.backingStore).thenReturn(mapChildStore);

        final map = <String, Object?>{'key': mapChild};
        final parent = InMemoryBackingStore()..set('map', map);

        map.remove('key');
        parent.clear();

        mapChildStore.set('title', 'after-clear');
        expect(parent.get<Map<String, Object?>>('map'), isNull);
        expect(parent.iterate(), isEmpty);
      },
    );

    test(
      'skips callbacks for subscriptions removed during notification and prevents resurrecting cleared parent',
      () {
        final child = MockBackedModel();
        final childStore = InMemoryBackingStore();
        when(child.backingStore).thenReturn(childStore);

        final parent = InMemoryBackingStore()..set('child', child);

        // A child-store subscriber clears parent during child change notification
        childStore
          ..subscribe((k, prev, next) {
            parent.clear();
          })
          ..set('name', 'trigger');

        expect(parent.get<BackedModel>('child'), isNull);
        expect(parent.iterate(), isEmpty);
      },
    );

    test(
      'skips subsequent subscriber if an earlier callback unsubscribes it',
      () {
        final store = InMemoryBackingStore();
        var secondCalled = false;
        const secondId = 'second-sub';

        store
          ..subscribe((k, prev, next) {
            store.unsubscribe(secondId);
          })
          ..subscribe((k, prev, next) {
            secondCalled = true;
          }, secondId)
          ..set('key', 'val');

        expect(secondCalled, isFalse);
      },
    );
  });
}
