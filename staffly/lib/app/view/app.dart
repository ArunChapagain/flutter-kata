import 'package:app_ui/app_ui.dart';
import 'package:employee_repository/employee_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staffly/app/routes/app_router.dart';
import 'package:staffly/l10n/l10n.dart';

class App extends StatelessWidget {
  const App({
    required this._employeeRepository,
    super.key,
  });

  final EmployeeRepository _employeeRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: _employeeRepository,
      child: MaterialApp.router(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
  }
}
