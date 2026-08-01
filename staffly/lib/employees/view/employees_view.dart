import 'package:app_ui/app_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staffly/employees/bloc/bloc.dart';
import 'package:staffly/employees/widgets/widgets.dart';

/// {@template employees_view}
/// The body of the employee list screen.
///
/// Consumes an `EmployeesBloc` provided by an ancestor — `EmployeesPage`,
/// per the Page/View split — and switches on its status rather than owning
/// any state itself.
/// {@endtemplate}
class EmployeesView extends StatelessWidget {
  /// {@macro employees_view}
  const EmployeesView({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;

    return BlocBuilder<EmployeesBloc, EmployeesState>(
      builder: (context, state) {
        return switch (state.status) {
          EmployeesStatus.initial || EmployeesStatus.loading => const Center(
            child: CircularProgressIndicator(),
          ),
          EmployeesStatus.failure => const AppEmptyState(
            icon: Icons.error_outline,
            title: 'Something went wrong',
            message: "We couldn't load your employees. Please try again.",
          ),
          EmployeesStatus.success when state.employees.isEmpty =>
            const AppEmptyState(
              icon: Icons.people_outline,
              title: 'No employees yet',
              message: 'Add your first employee to get started.',
            ),
          EmployeesStatus.success => ListView.separated(
            padding: EdgeInsets.all(spacing.md),
            itemCount: state.employees.length,
            separatorBuilder: (context, index) => SizedBox(height: spacing.sm),
            itemBuilder: (context, index) =>
                EmployeeCard(employee: state.employees[index]),
          ),
        };
      },
    );
  }
}
