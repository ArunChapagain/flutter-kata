# Staffly

---

## Getting Started 🚀

This project contains 3 flavors:

- development
- staging
- production

To run the desired flavor either use the launch configuration in VSCode/Android Studio or use the following commands:

```sh
# Development
$ flutter run --flavor development --target lib/main_development.dart

# Staging
$ flutter run --flavor staging --target lib/main_staging.dart

# Production
$ flutter run --flavor production --target lib/main_production.dart
```

_\*Staffly works on iOS, Android, Web, and Windows._

---

## Running Tests 🧪

To run all unit and widget tests use the following command:

```sh
$ very_good test --coverage --test-randomize-ordering-seed random
```

To view the generated coverage report you can use [lcov](https://github.com/linux-test-project/lcov).

```sh
# Generate Coverage Report
$ genhtml coverage/lcov.info -o coverage/

# Open Coverage Report
$ open coverage/index.html
```

---

## Bloc Lints 🔍

This project uses the [bloc_lint](https://pub.dev/packages/bloc_lint) package to enforce best practices using [bloc](https://pub.dev/packages/bloc).

To validate linter errors, run

```bash
dart run bloc_tools:bloc lint .
```

You can also validate with VSCode-based IDEs using the [official bloc extension](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc).

To learn more, visit https://bloclibrary.dev/lint/

---

## Git Hooks (Husky) 

This project uses the Dart [husky](https://pub.dev/packages/husky) package to manage Git hooks. Hooks live in the `.husky/` directory and are committed to the repository so every developer shares the same checks.

### Hooks in this project

| Hook | Purpose |
| --- | --- |
| `commit-msg` | Enforces the commit message convention `<type>(<scope>): <description>` (e.g. `feat: add login screen`, `fix(nav): (wip) broken navigation`). |
| `pre-commit` | Blocks direct commits to protected branches (`main`, `dev`, `prod`). |
| `pre-push` | Runs `dart format .` and `dart fix --apply`, then auto-commits any resulting changes before the push continues. |

### Setup for new developers

> **Note:** This repo's `.git` directory lives one level above `staffly/` (at the repository root), while `pubspec.yaml` lives inside `staffly/`. Husky's own `dart run husky install` command requires `.git` and `pubspec.yaml` to be in the *same* directory, so it cannot be used here — it will fail with `.git can't be found.` if run from `staffly/`, or `Found no pubspec.yaml file` if run from the repo root. Instead, wire up the hooks with a single `git config` command, run once per clone from the **repository root** (the parent of `staffly/`):

```sh
$ flutter pub get         # from staffly/, installs dependencies
$ git config core.hooksPath staffly/.husky   # from the repo root
```

This points Git's `core.hooksPath` directly at `staffly/.husky/`, so the versioned hooks take effect for your local clone. You only need to run it once per clone; verify it with `git config --get core.hooksPath`.

#### Platform notes

- **macOS / Linux**: No extra setup needed. If a hook fails to run with a "permission denied" error, re-add the executable bit:

  ```sh
  $ chmod +x staffly/.husky/commit-msg staffly/.husky/pre-commit staffly/.husky/pre-push
  ```

- **Windows**: Works out of the box with [Git for Windows](https://git-scm.com/download/win), which ships the `sh` shell used to run the hook scripts. No `chmod` step is required. If you're using WSL, follow the macOS/Linux instructions above instead.

### Bypassing hooks

Not recommended, but if you need to skip `commit-msg`/`pre-commit` for a single commit:

```sh
$ git commit -m "..." --no-verify
```

`pre-push` doesn't support `--no-verify`, so use the `HUSKY` environment variable instead:

```sh
$ HUSKY=0 git push
```

---

## Working with Translations 🌐

This project follows the [official internationalization guide for Flutter][internationalization_link] using [ARB files][arb_documentation_link] for translations.

### Adding Strings

1. To add a new localizable string, open the `app_en.arb` file at `lib/l10n/arb/app_en.arb` and add a new key/value pair with the relevant description (optional):

```arb
{
    "@@locale": "en",
    "counterAppBarTitle": "Counter",
    "@counterAppBarTitle": {
        "description": "Text shown in the AppBar of the Counter Page"
    },
    "helloWorld": "Hello World",
    "@helloWorld": {
        "description": "Hello World greeting."
    }
}
```

1. Use the new string:

```dart
import 'package:staffly/l10n/l10n.dart';

@override
Widget build(BuildContext context) {
  final l10n = context.l10n;
  return Text(l10n.helloWorld);
}
```

### Adding Supported Locales

Update the `CFBundleLocalizations` array in the `Info.plist` at `ios/Runner/Info.plist` to include the new locale.

```xml
    ...

    <key>CFBundleLocalizations</key>
	<array>
		<string>en</string>
		<string>es</string>
	</array>

    ...
```

### Adding Translations

1. For each supported locale, add a new ARB file in `lib/l10n/arb`:

```
├── l10n
│   ├── arb
│   │   ├── app_en.arb
│   │   └── app_es.arb
```

1. Add the translated strings to the new `.arb` file:

`app_es.arb`

```arb
{
    "@@locale": "es",
    "counterAppBarTitle": "Contador",
    "@counterAppBarTitle": {
        "description": "Texto mostrado en la AppBar de la página del contador"
    },
    "helloWorld": "Hola Mundo",
    "@helloWorld": {
        "description": "Saludo Hola Mundo."
    }    
}
```

### Generating Translations

To use the latest translations changes, you will need to generate them:

```sh
flutter gen-l10n --arb-dir="lib/l10n/arb"
```

Alternatively, run `flutter run` and code generation will take place automatically.

[internationalization_link]: https://docs.flutter.dev/ui/internationalization
[arb_documentation_link]: https://github.com/google/app-resource-bundle
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
