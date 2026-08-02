part of 'fetch_employee_bloc.dart';

/// {@template fetch_employee_event}
/// An instruction directed at [FetchEmployeeBloc].
/// {@endtemplate}
sealed class FetchEmployeeEvent extends Equatable {
  /// {@macro fetch_employee_event}
  const FetchEmployeeEvent();

  @override
  List<Object?> get props => [];
}

/// {@template fetch_employee_requested}
/// Asks the bloc to (re)fetch the employee it was opened on.
///
/// Dispatched automatically by [FetchEmployeeBloc]'s constructor so the page
/// does not have to remember to fire it.
/// {@endtemplate}
final class FetchEmployeeRequested extends FetchEmployeeEvent {
  /// {@macro fetch_employee_requested}
  const FetchEmployeeRequested();
}
