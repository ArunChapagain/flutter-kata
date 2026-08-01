part of 'employees_bloc.dart';

/// Where the employee list currently stands.
enum FetchStatus { initial, loading, success, failure }

class FetchState extends Equatable {
  const FetchState({
    this.status = FetchStatus.initial,
    this.employees = const [],
  });

  final FetchStatus status;
  final List<Employee> employees;

  FetchState copyWith({
    FetchStatus? status,
    List<Employee>? employees,
  }) {
    return FetchState(
      status: status ?? this.status,
      employees: employees ?? this.employees,
    );
  }

  @override
  List<Object?> get props => [status, employees];
}

/// Where the deletion of an employee currently stands.
enum DeleteStatus { initial, loading, success, failure }

class DeleteState extends Equatable {
  const DeleteState({
    this.status = DeleteStatus.initial,
    this.deletedEmployee,
  });

  final DeleteStatus status;
  final Employee? deletedEmployee;

  DeleteState copyWith({
    DeleteStatus? status,
    Employee? deletedEmployee,
  }) {
    return DeleteState(
      status: status ?? this.status,
      deletedEmployee: deletedEmployee ?? this.deletedEmployee,
    );
  }

  @override
  List<Object?> get props => [status, deletedEmployee];
}

/// {@template employees_state}
/// Everything the employee list screen needs to render itself.
/// {@endtemplate}
final class EmployeesState extends Equatable {
  /// {@macro employees_state}
  const EmployeesState({
    this.fetchState = const FetchState(),
    this.deleteState = const DeleteState(),
    this.searchQuery = '',
  });

  final FetchState fetchState;
  final DeleteState deleteState;
  final String searchQuery;

  List<Employee> get visibleEmployees {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return fetchState.employees;

    return fetchState.employees
        .where(
          (employee) =>
              employee.fullName.toLowerCase().contains(query) ||
              employee.jobTitle.toLowerCase().contains(query) ||
              employee.country.toLowerCase().contains(query),
        )
        .toList();
  }

  /// Returns a copy of this state with the given fields replaced.
  EmployeesState copyWith({
    FetchState? fetchState,
    DeleteState? deleteState,
    String? searchQuery,
  }) {
    return EmployeesState(
      fetchState: fetchState ?? this.fetchState,
      deleteState: deleteState ?? this.deleteState,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    fetchState,
    deleteState,
    searchQuery,
  ];
}
