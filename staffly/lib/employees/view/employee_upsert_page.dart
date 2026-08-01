import 'package:app_ui/app_ui.dart';
import 'package:employee_repository/employee_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:staffly/employees/bloc/bloc.dart';
import 'package:staffly/employees/cubit/cubit.dart';
import 'package:staffly/employees/models/countries.dart';

/// {@template employee_upsert_page}
/// The root of the add/edit employee screen.
///
/// Owns the [EmployeeUpsertCubit] lifetime and provides it to the view.
/// Accepts an optional [employee] to edit; if null, creates a new employee.
/// {@endtemplate}
class EmployeeUpsertPage extends StatelessWidget {
  /// {@macro employee_upsert_page}
  const EmployeeUpsertPage({this.employee, super.key});

  /// The employee to edit, or null to create a new one.
  final Employee? employee;

  /// Route to navigate to this page.
  static Route<void> route({Employee? employee}) {
    return MaterialPageRoute<void>(
      builder: (_) => EmployeeUpsertPage(employee: employee),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EmployeeUpsertCubit(
        employeeRepository: context.read<EmployeeRepository>(),
        initialEmployee: employee,
      ),
      child: const EmployeeUpsertView(),
    );
  }
}

/// {@template employee_upsert_view}
/// The body of the add/edit employee screen.
///
/// Consumes the [EmployeeUpsertCubit] and renders the form fields.
/// Displays an [AppTextFormField] for full name, job title, and salary,
/// and a Dropdown for country.
/// {@endtemplate}
class EmployeeUpsertView extends StatelessWidget {
  /// {@macro employee_upsert_view}
  const EmployeeUpsertView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.appSpacing;
    final isEditing = context.select(
      (EmployeeUpsertCubit cubit) => cubit.state.isEditing,
    );
    final title = isEditing ? 'Edit Employee' : 'Add Employee';

    return BlocListener<EmployeeUpsertCubit, EmployeeUpsertState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status.isSuccess) {
          Navigator.of(context).pop();
          context.read<EmployeesBloc>().add(const EmployeesFetchRequested());
        } else if (state.status.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: const Text('Something went wrong. Please try again.'),
                backgroundColor: theme.colorScheme.error,
              ),
            );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: false,
          toolbarHeight: 72,
        ),
        body: const _Form(),
        bottomNavigationBar: const _BottomBar(),
      ),
    );
  }
}

class _Form extends StatelessWidget {
  const _Form();

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _FullNameInput(),
          SizedBox(height: spacing.md),
          const _JobTitleInput(),
          SizedBox(height: spacing.md),
          const _CountryInput(),
          SizedBox(height: spacing.md),
          const _SalaryInput(),
        ],
      ),
    );
  }
}

class _FullNameInput extends StatelessWidget {
  const _FullNameInput();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeeUpsertCubit, EmployeeUpsertState>(
      buildWhen: (previous, current) => previous.fullName != current.fullName,
      builder: (context, state) {
        return AppTextFormField(
          key: const Key('upsertForm_fullName_textField'),
          label: 'Full Name',
          isRequired: true,
          initialValue: state.fullName.value,
          hintText: 'Enter full name',
          prefixIcon: Icons.person_outline,
          errorText:
              state.fullName.displayError != null
                  ? 'Full name is required'
                  : null,
          onChanged: (value) =>
              context.read<EmployeeUpsertCubit>().fullNameChanged(value),
        );
      },
    );
  }
}

class _JobTitleInput extends StatelessWidget {
  const _JobTitleInput();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeeUpsertCubit, EmployeeUpsertState>(
      buildWhen: (previous, current) => previous.jobTitle != current.jobTitle,
      builder: (context, state) {
        return AppTextFormField(
          key: const Key('upsertForm_jobTitle_textField'),
          label: 'Job Title',
          isRequired: true,
          initialValue: state.jobTitle.value,
          hintText: 'Enter job title',
          prefixIcon: Icons.work_outline,
          errorText:
              state.jobTitle.displayError != null
                  ? 'Job title is required'
                  : null,
          onChanged: (value) =>
              context.read<EmployeeUpsertCubit>().jobTitleChanged(value),
        );
      },
    );
  }
}

class _CountryInput extends StatelessWidget {
  const _CountryInput();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.appSpacing;
    final labelStyle = theme.textTheme.titleSmall;

    return BlocBuilder<EmployeeUpsertCubit, EmployeeUpsertState>(
      buildWhen: (previous, current) => previous.country != current.country,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Country', style: labelStyle),
                SizedBox(width: spacing.xxs),
                Text(
                  '*',
                  style: labelStyle?.copyWith(color: theme.colorScheme.error),
                ),
              ],
            ),
            SizedBox(height: spacing.xs),
            DropdownButtonFormField<String>(
              key: const Key('upsertForm_country_dropdown'),
              value: state.country.value.isEmpty ? null : state.country.value,
              decoration: InputDecoration(
                hintText: 'Select country',
                prefixIcon: const Icon(Icons.public),
                errorText:
                    state.country.displayError != null
                        ? 'Please select a country'
                        : null,
              ),
              items: Countries.all.map((country) {
                return DropdownMenuItem(
                  value: country,
                  child: Text(country),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  context.read<EmployeeUpsertCubit>().countryChanged(value);
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class _SalaryInput extends StatelessWidget {
  const _SalaryInput();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeeUpsertCubit, EmployeeUpsertState>(
      buildWhen: (previous, current) => previous.salary != current.salary,
      builder: (context, state) {
        return AppTextFormField(
          key: const Key('upsertForm_salary_textField'),
          label: 'Salary',
          isRequired: true,
          initialValue: state.salary.value,
          hintText: 'Enter salary',
          prefixIcon: Icons.attach_money,
          errorText:
              state.salary.displayError != null
                  ? 'Enter a valid salary'
                  : null,
          onChanged: (value) =>
              context.read<EmployeeUpsertCubit>().salaryChanged(value),
        );
      },
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.appSpacing;

    return BlocBuilder<EmployeeUpsertCubit, EmployeeUpsertState>(
      buildWhen: (previous, current) =>
          previous.status != current.status || previous.isValid != current.isValid,
      builder: (context, state) {
        final isSubmitting = state.status.isInProgress;
        final isValid = state.isValid;
        final isEditing = state.isEditing;

        return Container(
          padding: EdgeInsets.all(spacing.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: isSubmitting ? null : () => Navigator.of(context).pop(),
                    child: Text(
                      'Back',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: isSubmitting
                            ? theme.colorScheme.onSurface.withOpacity(0.38)
                            : theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: spacing.md),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    key: const Key('upsertForm_submit_button'),
                    onPressed: (isValid && !isSubmitting)
                        ? () => context.read<EmployeeUpsertCubit>().submitted()
                        : null,
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: spacing.md),
                    ),
                    child: isSubmitting
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.onPrimary,
                            ),
                          )
                        : Text(isEditing ? 'Save Changes' : 'Add Employee'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
