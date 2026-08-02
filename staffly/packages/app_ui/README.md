# app_ui

Design system for Staffly — the theme and the handful of UI primitives the
employees feature is assembled from.

This package is local to the `staffly` monorepo and is not published.

## What it owns

- **`AppTheme.light`** — the single `ThemeData` the app runs on. Colours,
  typography and component styling are all configured here, so no widget in
  `lib/` inlines a `Color`, a `TextStyle` or a `BorderRadius`.
- **`AppColors`** — the raw palette the `ColorScheme` is built from.
- **`AppSpacing`** / **`AppRadii`** — spacing and corner-radius tokens, exposed
  as `ThemeExtension`s because Material has no equivalent.
- **Primitives** — `AppCard`, `AppTextFormField`, `AppConfirmDialog` and
  `AppEmptyState`.

## Why it stays domain-agnostic

Nothing here knows what an employee is. `EmployeeCard` lives in
`lib/employees/widgets/` instead, because putting it here would force a design
system package to depend on `employee_repository` and invert the dependency
graph.

## Typography

Inter ships with the package (`lib/fonts/`) rather than being fetched at
runtime, so rendering is identical offline and across platforms. It is licensed
under the SIL Open Font License 1.1 — see [`lib/fonts/OFL.txt`](lib/fonts/OFL.txt).

## Running tests

```sh
flutter test
```
