import 'package:app_ui/app_ui.dart';
import 'package:employee_repository/employee_repository.dart';

/// {@template employee_card}
/// One row of the employee list — full name, job title, country and salary.
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
        ],
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
