import 'package:app_ui/app_ui.dart';
import 'package:employee_repository/employee_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:staffly/l10n/l10n.dart';

extension PumpApp on WidgetTester {
  /// Pumps a widget inside a [MaterialApp] with theme and l10n.
  ///
  /// Optionally wraps the widget tree in a [RepositoryProvider] when
  /// [employeeRepository] is provided.
  Future<void> pumpApp(
    Widget widget, {
    EmployeeRepository? employeeRepository,
  }) {
    Widget app = MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: widget),
    );

    if (employeeRepository != null) {
      app = RepositoryProvider.value(
        value: employeeRepository,
        child: app,
      );
    }

    return pumpWidget(app);
  }

  /// Pumps a widget inside a [MaterialApp.router] using the given [GoRouter].
  ///
  /// Use this instead of [pumpApp] when the widget under test navigates via
  /// `context.push` / `context.pop` from go_router.
  Future<void> pumpRouted(
    GoRouter goRouter, {
    EmployeeRepository? employeeRepository,
  }) {
    Widget app = MaterialApp.router(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: goRouter,
    );

    if (employeeRepository != null) {
      app = RepositoryProvider.value(
        value: employeeRepository,
        child: app,
      );
    }

    return pumpWidget(app);
  }
}
