# employee_repository

Repository layer for the Staffly employee resource — the domain models
(`Employee`, `Salary`) and the orchestration over `employee_api`.

This package is local to the `staffly` monorepo and is not published. It is the
only package that depends on `employee_api`, and the only one the app depends
on, so the presentation layer cannot reach the database directly.

## What it owns

- **`Employee`** — the domain shape, kept distinct from the storage shape
  (`EmployeeRecord`). The mapping between the two lives here.
- **`Salary`** — money as integer minor units, never a `double`. This is the
  single place in the codebase that converts between minor units and text, in
  either direction.
- **Translated exceptions** — an `EmployeeApiException` becomes an
  `EmployeeRepositoryException`, so no `sqflite` or `employee_api` type ever
  reaches the app.

## Why pure Dart

Same reason as `employee_api`: the data and repository layers stay free of the
Flutter SDK, so they run under plain `dart test` with no Flutter host. The
`EmployeeApi` arrives through the constructor, which is what lets these tests
mock it while the real SQLite integration stays proven one layer down.

## Running tests

```sh
dart test
```
