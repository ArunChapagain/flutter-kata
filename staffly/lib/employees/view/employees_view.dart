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
// ignore: comment_references
/// rather than [EmployeesState.employees].
/// {@endtemplate}
class EmployeesView extends StatelessWidget {
  /// {@macro employees_view}
  const EmployeesView({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;

    return BlocConsumer<EmployeesBloc, EmployeesState>(
      listenWhen: (previous, current) =>
          previous.deleteState != current.deleteState,
      listener: (context, state) {
        if (state.deleteState.status == DeleteStatus.success &&
            state.deleteState.deletedEmployee != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  '${state.deleteState.deletedEmployee!.fullName} deleted',
                ),
              ),
            );
        } else if (state.deleteState.status == DeleteStatus.failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Failed to delete employee'),
              ),
            );
        }
      },
      builder: (context, state) {
        return switch (state.fetchState.status) {
          FetchStatus.initial || FetchStatus.loading => const Center(
            child: CircularProgressIndicator(),
          ),
          FetchStatus.failure => const AppEmptyState(
            icon: Icons.error_outline,
            title: 'Something went wrong',
            message: "We couldn't load your employees. Please try again.",
          ),
          FetchStatus.success when state.fetchState.employees.isEmpty =>
            const AppEmptyState(
              icon: Icons.people_outline,
              title: 'No employees yet',
              message: 'Add your first employee to get started.',
            ),
          FetchStatus.success => Column(
            children: [
              _SearchField(query: state.searchQuery),
              if (state.visibleEmployees.isEmpty)
                const Expanded(
                  child: AppEmptyState(
                    icon: Icons.search_off,
                    title: 'No results found',
                    message: 'No employees match your search query.',
                  ),
                )
              else
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
