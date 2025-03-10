# Kiota Libraries for Dart

The Kiota libraries define the basic constructs for Kiota projects needed once an SDK has been generated from an OpenAPI definition and provide default implementations.

A [Kiota](https://github.com/microsoft/kiota) generated project will need a reference to the libraries to build and execute by providing default implementations for serialization, authentication and http transport.

Read more about Kiota [here](https://github.com/microsoft/kiota/blob/main/README.md).

## Build Status

[![Build, Test](https://github.com/microsoft/kiota-dart/actions/workflows/dart.yml/badge.svg?branch=main)](https://github.com/microsoft/kiota-dart/actions/workflows/dart.yml)

## Libraries

| Library                                                                                   | pub.dev Release                                                                                                                                                                 |
|-------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [Abstractions](./packages/microsoft_kiota_abstractions/README.md)                         | [![Pub Version](https://img.shields.io/pub/v/microsoft_kiota_abstractions?logo=dart&label=Latest)](https://pub.dev/packages/microsoft_kiota_abstractions)                       |
| [Http - http package](./packages/microsoft_kiota_http/README.md)                          | [![Pub Version](https://img.shields.io/pub/v/microsoft_kiota_http?logo=dart&label=Latest)](https://pub.dev/packages/microsoft_kiota_http)                                       |
| [Authentication - Azure](./packages/microsoft_kiota_azure/README.md)                      | [![Pub Version](https://img.shields.io/pub/v/microsoft_kiota_azure?logo=dart&label=Latest)](https://pub.dev/packages/microsoft_kiota_azure)                                     |
| [Authentication - OAuth](./packages/microsoft_kiota_oauth/README.md)                      | [![Pub Version](https://img.shields.io/pub/v/microsoft_kiota_oauth?logo=dart&label=Latest)](https://pub.dev/packages/microsoft_kiota_oauth)                                     |
| [Serialization - JSON](./packages/microsoft_kiota_serialization_json/README.md)           | [![Pub Version](https://img.shields.io/pub/v/microsoft_kiota_serialization_json?logo=dart&label=Latest)](https://pub.dev/packages/microsoft_kiota_serialization_json)           |
| [Serialization - FORM](./packages/microsoft_kiota_serialization_form/README.md)           | [![Pub Version](https://img.shields.io/pub/v/microsoft_kiota_serialization_form?logo=dart&label=Latest)](https://pub.dev/packages/microsoft_kiota_serialization_form)           |
| [Serialization - TEXT](./packages/microsoft_kiota_serialization_text/README.md)           | [![Pub Version](https://img.shields.io/pub/v/microsoft_kiota_serialization_text?logo=dart&label=Latest)](https://pub.dev/packages/microsoft_kiota_serialization_text)           |
| [Serialization - MULTIPART](./packages/microsoft_kiota_serialization_multipart/README.md) | [![Pub Version](https://img.shields.io/pub/v/microsoft_kiota_serialization_multipart?logo=dart&label=Latest)](https://pub.dev/packages/microsoft_kiota_serialization_multipart) |
| [Bundle](./packages/microsoft_kiota_bundle/README.md)                                     | [![Pub Version](https://img.shields.io/pub/v/microsoft_kiota_bundle?logo=dart&label=Latest)](https://pub.dev/packages/microsoft_kiota_bundle)                                   |

## Release notes

The Kiota Libraries releases notes are available in each respective package's CHANGELOG.md.

## Debugging

Open this repository in any editor that supports [Dart](https://dart.dev/).
You can use the [Makefile](./Makefile) to run tests for all packages.

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit [https://cla.opensource.microsoft.com](https://cla.opensource.microsoft.com).

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft
trademarks or logos is subject to and must follow
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
