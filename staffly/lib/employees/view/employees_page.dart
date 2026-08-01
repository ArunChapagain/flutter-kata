import 'package:app_ui/app_ui.dart';
import 'package:employee_repository/employee_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:staffly/app/routes/routes.dart';
import 'package:staffly/employees/bloc/bloc.dart';
import 'package:staffly/employees/view/employees_view.dart';

/// {@template employees_page}
/// The root of the employee list screen.
///
/// Owns the [EmployeesBloc] lifetime and the app bar, keeping both out of
/// [EmployeesView], which only renders what the bloc emits.  Following the
/// Page/View split from the VGV layered-architecture guidance: the Page
/// provides and bootstraps, the View consumes.
/// {@endtemplate}
class EmployeesPage extends StatelessWidget {
  /// {@macro employees_page}
  const EmployeesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EmployeesBloc(
        employeeRepository: context.read<EmployeeRepository>(),
      )..add(const EmployeesFetchRequested()),
      child: const _Scaffold(),
    );
  }
}

class _Scaffold extends StatelessWidget {
  const _Scaffold();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Employee Directory',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Manage your team members and details',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        toolbarHeight: 72,
        backgroundColor: theme.scaffoldBackgroundColor,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: const EmployeesView(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () async {
          final didChange = await context.push<bool>(Routes.upsert);
          if (didChange == true && context.mounted) {
            context.read<EmployeesBloc>().add(const EmployeesFetchRequested());
          }
        },
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }
}
