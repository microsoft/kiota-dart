pub-get:
	dart pub get

format:
	dart format packages
	dart format tooling

generate: generate-abstractions generate-bundle generate-http generate-oauth generate-serialization-form generate-serialization-json generate-serialization-multipart

generate-abstractions: pub-get
	cd packages/microsoft_kiota_abstractions && dart run build_runner build --delete-conflicting-outputs

generate-bundle: pub-get
	cd packages/microsoft_kiota_bundle && dart run build_runner build --delete-conflicting-outputs

generate-http: pub-get
	cd packages/microsoft_kiota_http && dart run build_runner build --delete-conflicting-outputs

generate-oauth: pub-get
	cd packages/microsoft_kiota_oauth && dart run build_runner build --delete-conflicting-outputs

generate-serialization-form: pub-get
	cd packages/microsoft_kiota_serialization_form && dart run build_runner build --delete-conflicting-outputs

generate-serialization-json: pub-get
	cd packages/microsoft_kiota_serialization_json && dart run build_runner build --delete-conflicting-outputs

generate-serialization-multipart: pub-get
	cd packages/microsoft_kiota_serialization_multipart && dart run build_runner build --delete-conflicting-outputs

test: test-abstractions test-bundle test-http test-oauth test-serialization-text test-serialization-form test-serialization-json test-serialization-multipart

test-abstractions: generate-abstractions
	cd packages/microsoft_kiota_abstractions && dart test

test-bundle: generate-bundle
	cd packages/microsoft_kiota_bundle && dart test

test-http: generate-http
	cd packages/microsoft_kiota_http && dart test

test-oauth: generate-oauth
	cd packages/microsoft_kiota_oauth && dart test

test-serialization-text:
	cd packages/microsoft_kiota_serialization_text && dart test

test-serialization-form: generate-serialization-form
	cd packages/microsoft_kiota_serialization_form && dart test

test-serialization-json: generate-serialization-json
	cd packages/microsoft_kiota_serialization_json && dart test

test-serialization-multipart: generate-serialization-multipart
	cd packages/microsoft_kiota_serialization_multipart && dart test
