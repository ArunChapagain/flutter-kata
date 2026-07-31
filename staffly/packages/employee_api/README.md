# employee_api

Data layer for the Staffly employee resource — the storage models and the
SQLite-backed service that persists them.

This package is local to the `staffly` monorepo and is not published. It is
consumed through `employee_repository`; the app never depends on it directly.

## Why pure Dart

`sqflite` is a Flutter plugin, so depending on it here would drag the Flutter
SDK into the data layer. This package depends on `sqflite_common` — the
pure-Dart half of the same library — and receives a `DatabaseFactory` through
its constructor instead of creating one:

- production injects `databaseFactory` from `package:sqflite`,
- tests inject `databaseFactoryFfi` from `sqflite_common_ffi`, opened at
  `inMemoryDatabasePath`.

Tests therefore run against real SQLite — real schema, real constraints, real
SQL — under plain `dart test`, with no Flutter host and no hand-rolled fake
database.

## Running tests

```sh
dart test
```