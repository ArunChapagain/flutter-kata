import 'package:app_ui/app_ui.dart';
import 'package:employee_repository/employee_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staffly/employees/bloc/bloc.dart';
import 'package:staffly/employees/view/view.dart';

/// {@template employee_card}
/// One row of the employee list — full name, job title, country and salary,
/// with Edit and Delete actions at the bottom.
///
/// Delete opens an [AppConfirmDialog] before dispatching
/// [EmployeesEmployeeDeleted] to the ancestor [EmployeesBloc].
/// {@endtemplate}
class EmployeeCard extends StatelessWidget {
  /// {@macro employee_card}
  const EmployeeCard({required this.employee, super.key});

  /// The employee this card describes.
  final Employee employee;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.appSpacing;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: spacing.lg,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  _initialsOf(employee.fullName),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(employee.fullName, style: theme.textTheme.titleMedium),
                    Text(
                      employee.jobTitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.sm),
          _IconLabel(icon: Icons.public, label: employee.country),
          SizedBox(height: spacing.xxs),
          _IconLabel(
            icon: Icons.work_outline,
            label: employee.salary.format(),
          ),
          SizedBox(height: spacing.sm),
          const Divider(height: 1),
          SizedBox(height: spacing.sm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    EmployeeUpsertPage.route(employee: employee),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit'),
                ),
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _confirmDelete(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.errorContainer,
                    foregroundColor: theme.colorScheme.onErrorContainer,
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Delete'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AppConfirmDialog(
        title: 'Delete employee',
        message:
            'Are you sure you want to delete ${employee.fullName}? '
            'This action cannot be undone.',
        confirmLabel: 'Delete',
        cancelLabel: 'Cancel',
        onConfirm: () {
          Navigator.of(context, rootNavigator: true).pop();
          context.read<EmployeesBloc>().add(
            EmployeesEmployeeDeleted(employee: employee),
          );
        },
        onCancel: () => Navigator.of(context, rootNavigator: true).pop(),
      ),
    );
  }

  static String _initialsOf(String fullName) {
    final words = fullName.trim().split(RegExp(r'\s+'));
    final first = words.first.isEmpty ? '' : words.first[0];
    final last = words.length > 1 && words.last.isNotEmpty ? words.last[0] : '';
    return '$first$last'.toUpperCase();
  }
}

class _IconLabel extends StatelessWidget {
  const _IconLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.appSpacing;

    return Row(
      children: [
        Icon(icon, size: spacing.md, color: theme.colorScheme.onSurfaceVariant),
        SizedBox(width: spacing.xs),
        Text(label, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
