/// List state — `EmployeesBloc`, its events and its state.
///
/// Fetching and deletion live here; writes belong to `EmployeeUpsertCubit`.
/// Single-employee loading for the edit route lives in `FetchEmployeeBloc`.
library;

export 'employees_bloc.dart';
export 'fetch_employee_bloc.dart';
