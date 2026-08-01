import 'package:bloc_test/bloc_test.dart';
import 'package:employee_repository/employee_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:staffly/employees/bloc/bloc.dart';

class _MockEmployeeRepository extends Mock implements EmployeeRepository {}

void main() {
  group(FetchEmployeeBloc, () {
    const arun = Employee(
      id: 'e1b9f0c4',
      fullName: 'Arun Chapagai',
      jobTitle: 'Software Engineer',
      country: 'Nepal',
      salary: Salary(5000050),
    );

    late EmployeeRepository employeeRepository;

    setUp(() {
      employeeRepository = _MockEmployeeRepository();
    });

    FetchEmployeeBloc buildBloc() => FetchEmployeeBloc(
      employeeId: arun.id,
      employeeRepository: employeeRepository,
    );

    test('initial state is FetchEmployeeInitial', () {
      // We stub before construction because the bloc auto-dispatches.
      when(
        () => employeeRepository.fetchEmployee(any()),
      ).thenAnswer((_) async => arun);

      final bloc = buildBloc();
      // The first state before any async work is the initial one.
      expect(bloc.state, isA<FetchEmployeeInitial>());
    });

    group('$FetchEmployeeRequested', () {
      blocTest<FetchEmployeeBloc, FetchEmployeeState>(
        'emits [loading, success] carrying the fetched $Employee',
        setUp: () {
          when(
            () => employeeRepository.fetchEmployee(arun.id),
          ).thenAnswer((_) async => arun);
        },
        // build triggers the auto-dispatch via the constructor.
        build: buildBloc,
        expect: () => [
          isA<FetchEmployeeLoading>(),
          isA<FetchEmployeeSuccess>().having(
            (s) => s.employee,
            'employee',
            arun,
          ),
        ],
        verify: (_) {
          verify(() => employeeRepository.fetchEmployee(arun.id)).called(1);
        },
      );

      blocTest<FetchEmployeeBloc, FetchEmployeeState>(
        'emits [loading, failure] when the repository throws',
        setUp: () {
          when(
            () => employeeRepository.fetchEmployee(any()),
          ).thenThrow(const EmployeeNotFoundException());
        },
        build: buildBloc,
        expect: () => [
          isA<FetchEmployeeLoading>(),
          isA<FetchEmployeeFailure>(),
        ],
      );

      blocTest<FetchEmployeeBloc, FetchEmployeeState>(
        'emits [loading, failure] when storage throws',
        setUp: () {
          when(
            () => employeeRepository.fetchEmployee(any()),
          ).thenThrow(const EmployeeStorageException());
        },
        build: buildBloc,
        expect: () => [
          isA<FetchEmployeeLoading>(),
          isA<FetchEmployeeFailure>(),
        ],
      );

      blocTest<FetchEmployeeBloc, FetchEmployeeState>(
        'can be retried — emits [loading, success] again after failure',
        setUp: () {
          var callCount = 0;
          when(
            () => employeeRepository.fetchEmployee(any()),
          ).thenAnswer((_) async {
            callCount++;
            if (callCount == 1) throw const EmployeeNotFoundException();
            return arun;
          });
        },
        build: buildBloc,
        // The constructor fires once (fails); then we fire again manually.
        act: (bloc) => bloc.add(const FetchEmployeeRequested()),
        expect: () => [
          isA<FetchEmployeeLoading>(), // auto-dispatch loading
          isA<FetchEmployeeFailure>(), // auto-dispatch failure
          isA<FetchEmployeeLoading>(), // manual retry loading
          isA<FetchEmployeeSuccess>().having(
            (s) => s.employee,
            'employee',
            arun,
          ),
        ],
        verify: (_) {
          verify(() => employeeRepository.fetchEmployee(arun.id)).called(2);
        },
      );
    });

    group('$FetchEmployeeSuccess', () {
      test('props include the employee', () {
        expect(
          const FetchEmployeeSuccess(employee: arun).props,
          equals([arun]),
        );
      });
    });
  });
}
