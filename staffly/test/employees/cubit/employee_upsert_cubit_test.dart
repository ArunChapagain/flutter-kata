import 'package:bloc_test/bloc_test.dart';
import 'package:employee_repository/employee_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:staffly/employees/cubit/cubit.dart';
import 'package:staffly/employees/models/models.dart';

class _MockEmployeeRepository extends Mock implements EmployeeRepository {}

void main() {
  group(EmployeeUpsertCubit, () {
    const arun = Employee(
      id: 'e1b9f0c4',
      fullName: 'Arun Chapagai',
      jobTitle: 'Software Engineer',
      country: 'Nepal',
      salary: Salary(5000050),
    );

    // A form the user has filled in completely and correctly, used wherever a
    // test needs to talk about submission rather than about how the fields got
    // there. Seeded directly so these tests do not go through the `*Changed`
    // methods — a bug in one of those should fail its own test, not every
    // submission test as well.
    const completed = EmployeeUpsertState(
      fullName: FullName.dirty('Sam Rai'),
      jobTitle: JobTitle.dirty('Designer'),
      country: Country.dirty('Nepal'),
      salary: SalaryInput.dirty('42000'),
    );

    // The same form, but opened on an existing employee rather than blank.
    const editing = EmployeeUpsertState(
      initialEmployee: arun,
      fullName: FullName.dirty('Arun Chapagain'),
      jobTitle: JobTitle.dirty('Senior Software Engineer'),
      country: Country.dirty('Nepal'),
      salary: SalaryInput.dirty('60000.25'),
    );

    late EmployeeRepository employeeRepository;

    setUpAll(() {
      registerFallbackValue(const Salary(0));
      registerFallbackValue(arun);
    });

    setUp(() {
      employeeRepository = _MockEmployeeRepository();
    });

    EmployeeUpsertCubit buildCubit({Employee? initialEmployee}) =>
        EmployeeUpsertCubit(
          employeeRepository: employeeRepository,
          initialEmployee: initialEmployee,
        );

    group(EmployeeUpsertState, () {
      test('is not valid while its inputs are untouched', () {
        expect(const EmployeeUpsertState().isValid, isFalse);
      });

      test('is valid once every input holds a valid value', () {
        expect(completed.isValid, isTrue);
      });

      test('is not valid while any single input is invalid', () {
        expect(
          completed.copyWith(fullName: const FullName.dirty()).isValid,
          isFalse,
        );
        expect(
          completed.copyWith(jobTitle: const JobTitle.dirty()).isValid,
          isFalse,
        );
        expect(
          completed.copyWith(country: const Country.dirty('Atlantis')).isValid,
          isFalse,
        );
        expect(
          completed.copyWith(salary: const SalaryInput.dirty('abc')).isValid,
          isFalse,
        );
      });

      test('keeps the fields it was not asked to replace', () {
        expect(
          completed.copyWith(status: FormzSubmissionStatus.inProgress),
          equals(
            const EmployeeUpsertState(
              fullName: FullName.dirty('Sam Rai'),
              jobTitle: JobTitle.dirty('Designer'),
              country: Country.dirty('Nepal'),
              salary: SalaryInput.dirty('42000'),
              status: FormzSubmissionStatus.inProgress,
            ),
          ),
        );
      });

      test('is editing only when it was opened on an $Employee', () {
        expect(const EmployeeUpsertState().isEditing, isFalse);
        expect(editing.isEditing, isTrue);
      });
    });

    test('starts out blank and untouched when adding', () {
      expect(buildCubit().state, equals(const EmployeeUpsertState()));
    });

    test('starts out filled in from the $Employee being edited', () {
      expect(
        buildCubit(initialEmployee: arun).state,
        equals(
          const EmployeeUpsertState(
            initialEmployee: arun,
            fullName: FullName.dirty('Arun Chapagai'),
            jobTitle: JobTitle.dirty('Software Engineer'),
            country: Country.dirty('Nepal'),
            // Seeded from toEditString, not format: a grouped '50,000.50'
            // would fail its own validator the moment the form was opened.
            salary: SalaryInput.dirty('50000.50'),
          ),
        ),
      );
    });

    test('opens an edit form that is already valid', () {
      // The user should be able to open an employee, change nothing and still
      // submit — a pre-filled form that reports itself invalid would block on
      // values it supplied.
      expect(buildCubit(initialEmployee: arun).state.isValid, isTrue);
    });

    group('fullNameChanged', () {
      blocTest<EmployeeUpsertCubit, EmployeeUpsertState>(
        'emits the typed name as a dirty $FullName',
        build: buildCubit,
        act: (cubit) => cubit.fullNameChanged('Sam Rai'),
        expect: () => const [
          EmployeeUpsertState(fullName: FullName.dirty('Sam Rai')),
        ],
      );
    });

    group('jobTitleChanged', () {
      blocTest<EmployeeUpsertCubit, EmployeeUpsertState>(
        'emits the typed title as a dirty $JobTitle',
        build: buildCubit,
        act: (cubit) => cubit.jobTitleChanged('Designer'),
        expect: () => const [
          EmployeeUpsertState(jobTitle: JobTitle.dirty('Designer')),
        ],
      );
    });

    group('countryChanged', () {
      blocTest<EmployeeUpsertCubit, EmployeeUpsertState>(
        'emits the selected country as a dirty $Country',
        build: buildCubit,
        act: (cubit) => cubit.countryChanged('Nepal'),
        expect: () => const [
          EmployeeUpsertState(country: Country.dirty('Nepal')),
        ],
      );
    });

    group('salaryChanged', () {
      blocTest<EmployeeUpsertCubit, EmployeeUpsertState>(
        'emits the typed amount as a dirty $SalaryInput',
        build: buildCubit,
        act: (cubit) => cubit.salaryChanged('42000'),
        expect: () => const [
          EmployeeUpsertState(salary: SalaryInput.dirty('42000')),
        ],
      );
    });

    group('submitted', () {
      blocTest<EmployeeUpsertCubit, EmployeeUpsertState>(
        'does nothing at all while the form is incomplete',
        build: buildCubit,
        act: (cubit) => cubit.submitted(),
        expect: () => const <EmployeeUpsertState>[],
        verify: (_) {
          verifyNever(
            () => employeeRepository.createEmployee(
              fullName: any(named: 'fullName'),
              jobTitle: any(named: 'jobTitle'),
              country: any(named: 'country'),
              salary: any(named: 'salary'),
            ),
          );
          verifyNever(() => employeeRepository.updateEmployee(any()));
        },
      );

      blocTest<EmployeeUpsertCubit, EmployeeUpsertState>(
        'emits [inProgress, success] and creates the $Employee when adding',
        setUp: () {
          when(
            () => employeeRepository.createEmployee(
              fullName: any(named: 'fullName'),
              jobTitle: any(named: 'jobTitle'),
              country: any(named: 'country'),
              salary: any(named: 'salary'),
            ),
          ).thenAnswer((_) async => arun);
        },
        build: buildCubit,
        seed: () => completed,
        act: (cubit) => cubit.submitted(),
        expect: () => const [
          EmployeeUpsertState(
            fullName: FullName.dirty('Sam Rai'),
            jobTitle: JobTitle.dirty('Designer'),
            country: Country.dirty('Nepal'),
            salary: SalaryInput.dirty('42000'),
            status: FormzSubmissionStatus.inProgress,
          ),
          EmployeeUpsertState(
            fullName: FullName.dirty('Sam Rai'),
            jobTitle: JobTitle.dirty('Designer'),
            country: Country.dirty('Nepal'),
            salary: SalaryInput.dirty('42000'),
            status: FormzSubmissionStatus.success,
          ),
        ],
        verify: (_) {
          verify(
            () => employeeRepository.createEmployee(
              fullName: 'Sam Rai',
              jobTitle: 'Designer',
              country: 'Nepal',
              // The rupees the user typed, crossed into paisa exactly once.
              salary: const Salary(4200000),
            ),
          ).called(1);
        },
      );

      blocTest<EmployeeUpsertCubit, EmployeeUpsertState>(
        'trims the free-text fields before creating the $Employee',
        setUp: () {
          when(
            () => employeeRepository.createEmployee(
              fullName: any(named: 'fullName'),
              jobTitle: any(named: 'jobTitle'),
              country: any(named: 'country'),
              salary: any(named: 'salary'),
            ),
          ).thenAnswer((_) async => arun);
        },
        build: buildCubit,
        seed: () => completed.copyWith(
          fullName: const FullName.dirty('  Sam Rai  '),
          jobTitle: const JobTitle.dirty('  Designer  '),
        ),
        act: (cubit) => cubit.submitted(),
        verify: (_) {
          verify(
            () => employeeRepository.createEmployee(
              fullName: 'Sam Rai',
              jobTitle: 'Designer',
              country: 'Nepal',
              salary: const Salary(4200000),
            ),
          ).called(1);
        },
      );

      blocTest<EmployeeUpsertCubit, EmployeeUpsertState>(
        'emits [inProgress, success] and updates the $Employee when editing',
        setUp: () {
          when(
            () => employeeRepository.updateEmployee(any()),
          ).thenAnswer((_) async => arun);
        },
        build: () => buildCubit(initialEmployee: arun),
        seed: () => editing,
        act: (cubit) => cubit.submitted(),
        expect: () => [
          editing.copyWith(status: FormzSubmissionStatus.inProgress),
          editing.copyWith(status: FormzSubmissionStatus.success),
        ],
        verify: (_) {
          verify(
            () => employeeRepository.updateEmployee(
              // The employee it opened on, carrying the edits — so the id
              // survives and the update lands on the right row.
              const Employee(
                id: 'e1b9f0c4',
                fullName: 'Arun Chapagain',
                jobTitle: 'Senior Software Engineer',
                country: 'Nepal',
                salary: Salary(6000025),
              ),
            ),
          ).called(1);
        },
      );

      blocTest<EmployeeUpsertCubit, EmployeeUpsertState>(
        'emits [inProgress, failure] when the repository throws',
        setUp: () {
          when(
            () => employeeRepository.createEmployee(
              fullName: any(named: 'fullName'),
              jobTitle: any(named: 'jobTitle'),
              country: any(named: 'country'),
              salary: any(named: 'salary'),
            ),
          ).thenThrow(const EmployeeStorageException());
        },
        build: buildCubit,
        seed: () => completed,
        act: (cubit) => cubit.submitted(),
        expect: () => [
          completed.copyWith(status: FormzSubmissionStatus.inProgress),
          completed.copyWith(status: FormzSubmissionStatus.failure),
        ],
      );
    });
  });
}
