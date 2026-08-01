import 'package:bloc/bloc.dart';
import 'package:employee_repository/employee_repository.dart';
import 'package:equatable/equatable.dart';

part 'employees_event.dart';
part 'employees_state.dart';

/// {@template employees_bloc}
/// Owns the employee list — reading it and removing from it.
///
/// The repository arrives by constructor, so nothing here knows that storage
/// is SQLite. Writes deliberately live elsewhere: the add/edit modal has its
/// own cubit, and this bloc learns about a write only by being asked to fetch
/// again.
/// {@endtemplate}
class EmployeesBloc extends Bloc<EmployeesEvent, EmployeesState> {
  /// {@macro employees_bloc}
  ///
  /// Callers pass `employeeRepository:` — the field stays private, so nothing
  /// can reach the data layer back through the bloc.
  EmployeesBloc({required this._employeeRepository})
    : super(const EmployeesState()) {
    on<EmployeesFetchRequested>(_onFetchRequested);
    on<EmployeesEmployeeDeleted>(_onEmployeeDeleted);
    on<EmployeesSearchQueryChanged>(_onSearchQueryChanged);
  }

  final EmployeeRepository _employeeRepository;

  Future<void> _onFetchRequested(
    EmployeesFetchRequested event,
    Emitter<EmployeesState> emit,
  ) async {
    emit(state.copyWith(status: EmployeesStatus.loading));

    try {
      final employees = await _employeeRepository.fetchEmployees();

      emit(
        state.copyWith(
          status: EmployeesStatus.success,
          employees: employees,
        ),
      );
    } on EmployeeRepositoryException {
      emit(state.copyWith(status: EmployeesStatus.failure));
    }
  }

  Future<void> _onEmployeeDeleted(
    EmployeesEmployeeDeleted event,
    Emitter<EmployeesState> emit,
  ) async {
    try {
      await _employeeRepository.deleteEmployee(event.employee.id);

      // Dropped locally rather than refetched: the row is gone, and a second
      // round trip would only confirm what the repository already returned
      // without throwing.
      emit(
        state.copyWith(
          employees: state.employees
              .where((employee) => employee.id != event.employee.id)
              .toList(),
          lastDeletedEmployee: event.employee,
        ),
      );
    } on EmployeeRepositoryException {
      emit(state.copyWith(status: EmployeesStatus.failure));
    }
  }

  void _onSearchQueryChanged(
    EmployeesSearchQueryChanged event,
    Emitter<EmployeesState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }
}
