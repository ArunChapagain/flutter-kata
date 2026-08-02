part of 'employees_bloc.dart';

/// {@template employees_event}
/// Something that happened to the employee list.
///
/// Adding and editing are absent on purpose: those belong to the upsert form's
/// own cubit, which writes and then leaves the list to refetch. What is left
/// here is the list's own work — loading it, and removing from it.
/// {@endtemplate}
sealed class EmployeesEvent extends Equatable {
  /// {@macro employees_event}
  const EmployeesEvent();

  @override
  List<Object?> get props => [];
}

/// {@template employees_fetch_requested}
/// The list should be (re)read from storage.
///
/// Dispatched when the page first appears and again after any write, which is
/// what keeps the database the single source of truth rather than an
/// in-memory copy that can drift from it.
/// {@endtemplate}
final class EmployeesFetchRequested extends EmployeesEvent {
  /// {@macro employees_fetch_requested}
  const EmployeesFetchRequested();
}

/// {@template employees_employee_deleted}
/// The given [employee] should be removed.
///
/// Carries the whole employee rather than just its id so the bloc can hold on
/// to it after deletion — an undo has nothing to restore from otherwise.
/// {@endtemplate}
final class EmployeesEmployeeDeleted extends EmployeesEvent {
  /// {@macro employees_employee_deleted}
  const EmployeesEmployeeDeleted({required this.employee});

  /// The employee to remove.
  final Employee employee;

  @override
  List<Object?> get props => [employee];
}

/// {@template employees_search_query_changed}
/// The user typed [query] into the search field.
///
/// Filtering happens locally against the list already in memory — see
/// [EmployeesState.visibleEmployees] — so this only ever updates state, and
/// never asks the repository for anything.
/// {@endtemplate}
final class EmployeesSearchQueryChanged extends EmployeesEvent {
  /// {@macro employees_search_query_changed}
  const EmployeesSearchQueryChanged({required this.query});

  /// What the user has typed so far.
  final String query;

  @override
  List<Object?> get props => [query];
}
