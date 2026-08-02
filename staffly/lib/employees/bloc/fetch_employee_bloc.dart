import 'package:bloc/bloc.dart';
import 'package:employee_repository/employee_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:staffly/employees/bloc/employees_bloc.dart';
import 'package:staffly/employees/cubit/employee_upsert_cubit.dart';
import 'package:staffly/employees/view/employee_upsert_page.dart';

part 'fetch_employee_event.dart';
part 'fetch_employee_state.dart';

/// {@template fetch_employee_bloc}
/// Fetches a single employee by id from storage.
///
// ignore: comment_references
/// Created by [EmployeeUpsertPage] when the route carries an [employeeId] path
/// parameter (deep-link or card tap). The page shows a loading indicator until
/// this bloc emits [FetchEmployeeSuccess], at which point it seeds
/// [EmployeeUpsertCubit] with the result.
///
/// Keeping this work in a separate bloc means [EmployeesBloc] does not need to
/// know about single-employee reads, and [EmployeeUpsertCubit] does not need a
/// loading state of its own.
/// {@endtemplate}
class FetchEmployeeBloc extends Bloc<FetchEmployeeEvent, FetchEmployeeState> {
  /// {@macro fetch_employee_bloc}
  ///
  /// Pass [_employeeId] for the employee to load and [_employeeRepository] for
  /// the data layer. The first fetch is triggered automatically.
  FetchEmployeeBloc({
    required this._employeeId,
    required this._employeeRepository,
  }) : super(const FetchEmployeeInitial()) {
    on<FetchEmployeeRequested>(_onRequested);
    add(const FetchEmployeeRequested());
  }

  final String _employeeId;
  final EmployeeRepository _employeeRepository;

  Future<void> _onRequested(
    FetchEmployeeRequested event,
    Emitter<FetchEmployeeState> emit,
  ) async {
    emit(const FetchEmployeeLoading());

    try {
      final employee = await _employeeRepository.fetchEmployee(_employeeId);
      emit(FetchEmployeeSuccess(employee: employee));
    } on EmployeeRepositoryException {
      emit(const FetchEmployeeFailure());
    }
  }
}
