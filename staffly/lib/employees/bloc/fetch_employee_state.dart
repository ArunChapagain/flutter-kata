part of 'fetch_employee_bloc.dart';

/// {@template fetch_employee_state}
/// Where [FetchEmployeeBloc]'s single-employee load currently stands.
/// {@endtemplate}
sealed class FetchEmployeeState extends Equatable {
  /// {@macro fetch_employee_state}
  const FetchEmployeeState();

  @override
  List<Object?> get props => [];
}

/// {@template fetch_employee_initial}
/// The bloc has been created but has not yet started loading.
///
/// In practice this state lasts for only one frame because [FetchEmployeeBloc]
/// dispatches [FetchEmployeeRequested] during construction.
/// {@endtemplate}
final class FetchEmployeeInitial extends FetchEmployeeState {
  /// {@macro fetch_employee_initial}
  const FetchEmployeeInitial();
}

/// {@template fetch_employee_loading}
/// The repository call is in flight.
/// {@endtemplate}
final class FetchEmployeeLoading extends FetchEmployeeState {
  /// {@macro fetch_employee_loading}
  const FetchEmployeeLoading();
}

/// {@template fetch_employee_success}
/// The repository returned [employee].
/// {@endtemplate}
final class FetchEmployeeSuccess extends FetchEmployeeState {
  /// {@macro fetch_employee_success}
  const FetchEmployeeSuccess({required this.employee});

  /// The employee that was loaded.
  final Employee employee;

  @override
  List<Object?> get props => [employee];
}

/// {@template fetch_employee_failure}
/// The repository threw an exception; the employee could not be loaded.
/// {@endtemplate}
final class FetchEmployeeFailure extends FetchEmployeeState {
  /// {@macro fetch_employee_failure}
  const FetchEmployeeFailure();
}
