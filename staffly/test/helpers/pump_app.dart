import 'package:app_ui/app_ui.dart';
import 'package:employee_repository/employee_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staffly/l10n/l10n.dart';

extension PumpApp on WidgetTester {
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
}
