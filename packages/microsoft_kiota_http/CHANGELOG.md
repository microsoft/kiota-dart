# Unreleased

## [0.0.8](https://github.com/microsoft/kiota-dart/compare/microsoft_kiota_http-v0.0.7...microsoft_kiota_http-v0.0.8) (2026-11-06)


### Bug Fixes

* **http,abstractions:** improve request adapter lifecycle, user-agent handling, and header parity ([#168](https://github.com/microsoft/kiota-dart/issues/168)) ([b78ba33](https://github.com/microsoft/kiota-dart/commit/b78ba3343cc8a0a745fc23c8012bb7027cea9ad3))
* **http:** add Uint8List support to sendPrimitive in HttpClientRequestAdapter ([#167](https://github.com/microsoft/kiota-dart/issues/167)) ([d5052b2](https://github.com/microsoft/kiota-dart/commit/d5052b266ede6f121e2f9585fdf7da668ce55c81))

## [0.0.7](https://github.com/microsoft/kiota-dart/compare/microsoft_kiota_http-v0.0.6...microsoft_kiota_http-v0.0.7) (2025-10-02)


### Bug Fixes

* remove relative path for abstractions in examples to avoid conflicts ([e35ea7b](https://github.com/microsoft/kiota-dart/commit/e35ea7b0773a49394b0386aa956cc3100e8db9c6))
* upgrades sdk version to avoid missing linting rules ([3956396](https://github.com/microsoft/kiota-dart/commit/3956396914955a24cd85bedb4361662c87bf365b))
* use version range for abstractions package ([76dfabb](https://github.com/microsoft/kiota-dart/commit/76dfabb7138531323557a827a6575110f3a4a2d7))
* use version range for abstractions package ([42e397d](https://github.com/microsoft/kiota-dart/commit/42e397dce1c8989434ebcdf391023b3f67f10801))

## [0.0.6](https://github.com/microsoft/kiota-dart/compare/microsoft_kiota_http-v0.0.5...microsoft_kiota_http-v0.0.6) (2025-08-05)


### Bug Fixes

* export Uint8List so it can be used by properties with that type ([e578280](https://github.com/microsoft/kiota-dart/commit/e5782807ff41b93d5348251695b3f1783ef28489))

## [0.0.5](https://github.com/microsoft/kiota-dart/compare/microsoft_kiota_http-v0.0.4...microsoft_kiota_http-v0.0.5) (2025-02-19)


### Bug Fixes

* Fix nullable primitive responses ([#87](https://github.com/microsoft/kiota-dart/issues/87)) ([428015b](https://github.com/microsoft/kiota-dart/commit/428015b7eebd7a15ca6326efb2ebc07efed3bcbf))

## [0.0.4](https://github.com/microsoft/kiota-dart/compare/microsoft_kiota_http-v0.0.3...microsoft_kiota_http-v0.0.4) (2025-01-29)


### Bug Fixes

* parameters ordering and requirement for request adapters ([b1a41b5](https://github.com/microsoft/kiota-dart/commit/b1a41b5d3e4c64655ae7b759aee00ed21ff6d8b7))
* parameters ordering and requirement for request adapters ([c6c11a1](https://github.com/microsoft/kiota-dart/commit/c6c11a17ec35c7a51fef6f234b06e6f6c9f44807))

## [0.0.3](https://github.com/microsoft/kiota-dart/compare/microsoft_kiota_http-v0.0.2...microsoft_kiota_http-v0.0.3) (2025-01-17)


### Bug Fixes

* parameters ordering and requirement for request adapters ([b1a41b5](https://github.com/microsoft/kiota-dart/commit/b1a41b5d3e4c64655ae7b759aee00ed21ff6d8b7))
* parameters ordering and requirement for request adapters ([c6c11a1](https://github.com/microsoft/kiota-dart/commit/c6c11a17ec35c7a51fef6f234b06e6f6c9f44807))

## [0.0.2](https://github.com/microsoft/kiota-dart/compare/microsoft_kiota_http-v0.0.1...microsoft_kiota_http-v0.0.2) (2025-01-10)


### Bug Fixes

* Include badge for latest pub.dev version in each package README ([44f6e9d](https://github.com/microsoft/kiota-dart/commit/44f6e9ddd486b70ca8e18a1a41df85d641f9561c))

## [0.0.1] - 2025-01-06

- Initial version.
- Provides an implementation of a `RequestAdapter` that uses `http` to send HTTP requests.
