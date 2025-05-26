#!/usr/bin/env bash

MIN_COVERAGE=100

flutter pub get &&
dart format --set-exit-if-changed lib test &&
flutter analyze lib test &&
dart run coverage:test_with_coverage --fail-under $MIN_COVERAGE