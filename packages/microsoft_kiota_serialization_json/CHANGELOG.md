# Unreleased

## [0.0.8](https://github.com/microsoft/kiota-dart/compare/microsoft_kiota_serialization_json-v0.0.7...microsoft_kiota_serialization_json-v0.0.8) (2026-03-17)


### Bug Fixes

* reduce parse node allocations when deserializing primitive types ([d5ae9a9](https://github.com/microsoft/kiota-dart/commit/d5ae9a93e55a52a7e0dfe12ee7454cbbf019258a))


### Performance Improvements

* extend static converter pattern to JsonParseNode and fix linter violations ([29adfd9](https://github.com/microsoft/kiota-dart/commit/29adfd998f9fd884a26ba62967db99065d5214bf))

## [0.0.7](https://github.com/microsoft/kiota-dart/compare/microsoft_kiota_serialization_json-v0.0.6...microsoft_kiota_serialization_json-v0.0.7) (2025-10-02)


### Bug Fixes

* upgrades sdk version to avoid missing linting rules ([3956396](https://github.com/microsoft/kiota-dart/commit/3956396914955a24cd85bedb4361662c87bf365b))
* use version range for abstractions package ([76dfabb](https://github.com/microsoft/kiota-dart/commit/76dfabb7138531323557a827a6575110f3a4a2d7))
* use version range for abstractions package ([42e397d](https://github.com/microsoft/kiota-dart/commit/42e397dce1c8989434ebcdf391023b3f67f10801))

## [0.0.6](https://github.com/microsoft/kiota-dart/compare/microsoft_kiota_serialization_json-v0.0.5...microsoft_kiota_serialization_json-v0.0.6) (2025-08-05)


### Bug Fixes

* export Uint8List so it can be used by properties with that type ([e578280](https://github.com/microsoft/kiota-dart/commit/e5782807ff41b93d5348251695b3f1783ef28489))
* parse primitives based on their type ([b25f451](https://github.com/microsoft/kiota-dart/commit/b25f45116a40c98106111d76a3bbaf25a9594a14))
* parse primitives based on their type ([3db4f32](https://github.com/microsoft/kiota-dart/commit/3db4f3218982cf71c8151985b41cb73497337416))

## [0.0.5](https://github.com/microsoft/kiota-dart/compare/microsoft_kiota_serialization_json-v0.0.4...microsoft_kiota_serialization_json-v0.0.5) (2025-03-07)


### Bug Fixes

* wrapper types for intersection types should not be serialized as objects ([#97](https://github.com/microsoft/kiota-dart/issues/97)) ([41a5df9](https://github.com/microsoft/kiota-dart/commit/41a5df9b6845b9e15e37d5cc110f15f692cd40ab))

## [0.0.4](https://github.com/microsoft/kiota-dart/compare/microsoft_kiota_serialization_json-v0.0.3...microsoft_kiota_serialization_json-v0.0.4) (2025-02-26)


### Bug Fixes

* type int is not a subtype of double in type cast in json parse node ([209a587](https://github.com/microsoft/kiota-dart/commit/209a587222f166ef2e82d2a777e85b5329173f74))

## [0.0.3](https://github.com/microsoft/kiota-dart/compare/microsoft_kiota_serialization_json-v0.0.2...microsoft_kiota_serialization_json-v0.0.3) (2025-01-29)


### Bug Fixes

* check for null in getBoolValue ([#83](https://github.com/microsoft/kiota-dart/issues/83)) ([77e2826](https://github.com/microsoft/kiota-dart/commit/77e282639802bd427d0b3a28c31a29dd69f3c1f6))

## [0.0.2](https://github.com/microsoft/kiota-dart/compare/microsoft_kiota_serialization_json-v0.0.1...microsoft_kiota_serialization_json-v0.0.2) (2025-01-10)


### Bug Fixes

* Include badge for latest pub.dev version in each package README ([44f6e9d](https://github.com/microsoft/kiota-dart/commit/44f6e9ddd486b70ca8e18a1a41df85d641f9561c))

## [0.0.1] - 2025-01-06

- Initial version.
- Provides parsing and serialization support for the `application/json` content type.
