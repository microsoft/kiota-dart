# Unreleased

## [0.0.5](https://github.com/microsoft/kiota-dart/compare/microsoft_kiota_serialization_form-v0.0.4...microsoft_kiota_serialization_form-v0.0.5) (2026-03-17)


### Bug Fixes

* reduce parse node allocations when deserializing primitive types ([d5ae9a9](https://github.com/microsoft/kiota-dart/commit/d5ae9a93e55a52a7e0dfe12ee7454cbbf019258a))


### Performance Improvements

* eliminate FormParseNode allocations in collection primitive deserialization ([a614057](https://github.com/microsoft/kiota-dart/commit/a614057665354e511f7611e06295ab903a4ef7d7))
* extend static converter pattern to JsonParseNode and fix linter violations ([29adfd9](https://github.com/microsoft/kiota-dart/commit/29adfd998f9fd884a26ba62967db99065d5214bf))
* reduce parse node allocations when deserializing primitive types ([2006c8d](https://github.com/microsoft/kiota-dart/commit/2006c8d9956d1c46aeb1c3c9b1bf1f8f8c7d3eec))

## [0.0.4](https://github.com/microsoft/kiota-dart/compare/microsoft_kiota_serialization_form-v0.0.3...microsoft_kiota_serialization_form-v0.0.4) (2025-10-02)


### Bug Fixes

* upgrades sdk version to avoid missing linting rules ([3956396](https://github.com/microsoft/kiota-dart/commit/3956396914955a24cd85bedb4361662c87bf365b))
* use version range for abstractions package ([76dfabb](https://github.com/microsoft/kiota-dart/commit/76dfabb7138531323557a827a6575110f3a4a2d7))
* use version range for abstractions package ([42e397d](https://github.com/microsoft/kiota-dart/commit/42e397dce1c8989434ebcdf391023b3f67f10801))

## [0.0.3](https://github.com/microsoft/kiota-dart/compare/microsoft_kiota_serialization_form-v0.0.2...microsoft_kiota_serialization_form-v0.0.3) (2025-08-05)


### Bug Fixes

* export Uint8List so it can be used by properties with that type ([e578280](https://github.com/microsoft/kiota-dart/commit/e5782807ff41b93d5348251695b3f1783ef28489))

## [0.0.2](https://github.com/microsoft/kiota-dart/compare/microsoft_kiota_serialization_form-v0.0.1...microsoft_kiota_serialization_form-v0.0.2) (2025-01-10)


### Bug Fixes

* Include badge for latest pub.dev version in each package README ([44f6e9d](https://github.com/microsoft/kiota-dart/commit/44f6e9ddd486b70ca8e18a1a41df85d641f9561c))

## [0.0.1] - 2025-01-06

- Initial version.
- Provides parsing and serialization support for the `application/x-www-form-urlencoded` content type.
