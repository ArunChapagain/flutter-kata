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
///
/// Renders a search field that dispatches [EmployeesSearchQueryChanged] on
/// every keystroke; the list narrows to [EmployeesState.visibleEmployees]
/// rather than [EmployeesState.employees].
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
          EmployeesStatus.success => Column(
            children: [
              _SearchField(query: state.searchQuery),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.all(spacing.md),
                  itemCount: state.visibleEmployees.length,
                  separatorBuilder: (context, index) =>
                      SizedBox(height: spacing.sm),
                  itemBuilder: (context, index) =>
                      EmployeeCard(employee: state.visibleEmployees[index]),
                ),
              ),
            ],
          ),
        };
      },
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.appSpacing;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        spacing.md,
        spacing.md,
        spacing.md,
        0,
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search by name, title or country...',
          prefixIcon: Icon(
            Icons.search,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerLowest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(spacing.sm),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: spacing.md,
            vertical: spacing.sm,
          ),
        ),
        onChanged: (value) => context.read<EmployeesBloc>().add(
          EmployeesSearchQueryChanged(query: value),
        ),
      ),
    );
  }
}
