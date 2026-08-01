import 'package:app_ui/app_ui.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:employee_repository/employee_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:staffly/employees/bloc/bloc.dart';
import 'package:staffly/employees/cubit/cubit.dart';
import 'package:staffly/employees/models/country.dart';
import 'package:staffly/employees/models/full_name.dart';
import 'package:staffly/employees/models/job_title.dart';
import 'package:staffly/employees/models/salary_input.dart';
import 'package:staffly/employees/view/view.dart';
import 'package:staffly/employees/widgets/employee_card.dart';

import '../../helpers/helpers.dart';

// ---------------------------------------------------------------------------
// Doubles
// ---------------------------------------------------------------------------

class _MockEmployeesBloc extends MockBloc<EmployeesEvent, EmployeesState>
    implements EmployeesBloc {}

class _MockEmployeeUpsertCubit extends MockCubit<EmployeeUpsertState>
    implements EmployeeUpsertCubit {}

// ---------------------------------------------------------------------------
// Shared fixture
// ---------------------------------------------------------------------------

const _arun = Employee(
  id: 'e1b9f0c4',
  fullName: 'Arun Chapagai',
  jobTitle: 'Software Engineer',
  country: 'Nepal',
  salary: Salary(5000050),
);

// A state where every field is dirty and valid (used to seed submission tests).
const _validState = EmployeeUpsertState(
  fullName: FullName.dirty('Arun Chapagai'),
  jobTitle: JobTitle.dirty('Software Engineer'),
  country: Country.dirty('Nepal'),
  salary: SalaryInput.dirty('50000.50'),
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Pumps [EmployeeUpsertView] with mocked cubit (and an ancestor bloc so the
/// view can dispatch [EmployeesFetchRequested] on success).
Future<void> _pumpView(
  WidgetTester tester,
  EmployeeUpsertCubit cubit, {
  required EmployeesBloc bloc,
}) {
  return tester.pumpApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<EmployeesBloc>.value(value: bloc),
        BlocProvider<EmployeeUpsertCubit>.value(value: cubit),
      ],
      child: const EmployeeUpsertView(),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('$EmployeesPage — FAB', () {
    late EmployeeRepository employeeRepository;

    setUp(() {
      employeeRepository = _MockEmployeeRepository();
      when(
        () => employeeRepository.fetchEmployees(),
      ).thenAnswer((_) async => [_arun]);
    });

    Widget buildPage() => const EmployeesPage();

    testWidgets(
      'has a FAB that opens an $EmployeeUpsertPage for a new employee',
      (tester) async {
        await tester.pumpApp(
          buildPage(),
          employeeRepository: employeeRepository,
        );
        await tester.pump(); // let the fetch settle

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        expect(find.byType(EmployeeUpsertPage), findsOneWidget);
      },
    );

    testWidgets(
      'FAB opens the modal with no pre-filled employee (adding mode)',
      (tester) async {
        await tester.pumpApp(
          buildPage(),
          employeeRepository: employeeRepository,
        );
        await tester.pump();

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        // In adding mode the app bar title says "Add Employee".
        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text('Add Employee'),
          ),
          findsOneWidget,
        );
      },
    );
  });

  group('$EmployeeCard — Edit button', () {
    late EmployeesBloc employeesBloc;
    late EmployeeRepository employeeRepository;

    setUpAll(() {
      registerFallbackValue(const EmployeesFetchRequested());
      registerFallbackValue(
        const EmployeesEmployeeDeleted(employee: _arun),
      );
    });

    setUp(() {
      employeesBloc = _MockEmployeesBloc();
      employeeRepository = _MockEmployeeRepository();
      when(() => employeesBloc.state).thenReturn(
        const EmployeesState(
          status: EmployeesStatus.success,
          employees: [_arun],
        ),
      );
      when(
        () => employeeRepository.fetchEmployees(),
      ).thenAnswer((_) async => [_arun]);
    });

    Widget buildCard() => BlocProvider.value(
      value: employeesBloc,
      child: const EmployeeCard(employee: _arun),
    );

    testWidgets(
      'opens an $EmployeeUpsertPage when the Edit button is tapped',
      (tester) async {
        await tester.pumpApp(
          buildCard(),
          employeeRepository: employeeRepository,
        );

        await tester.tap(find.text('Edit'));
        await tester.pumpAndSettle();

        expect(find.byType(EmployeeUpsertPage), findsOneWidget);
      },
    );

    testWidgets(
      'opens the modal in editing mode (title says "Edit Employee")',
      (tester) async {
        await tester.pumpApp(
          buildCard(),
          employeeRepository: employeeRepository,
        );

        await tester.tap(find.text('Edit'));
        await tester.pumpAndSettle();

        expect(find.text('Edit Employee'), findsOneWidget);
      },
    );
  });

  group('$EmployeeUpsertView', () {
    late EmployeeUpsertCubit cubit;
    late EmployeesBloc bloc;

    setUpAll(() {
      registerFallbackValue(const EmployeesFetchRequested());
    });

    setUp(() {
      cubit = _MockEmployeeUpsertCubit();
      bloc = _MockEmployeesBloc();

      // Default: empty pure state (adding mode).
      when(() => cubit.state).thenReturn(const EmployeeUpsertState());
      when(() => bloc.state).thenReturn(
        const EmployeesState(status: EmployeesStatus.success),
      );
    });

    // ── Field → cubit wiring ─────────────────────────────────────────────

    testWidgets('calls fullNameChanged on every keystroke', (tester) async {
      await _pumpView(tester, cubit, bloc: bloc);

      await tester.enterText(
        find.byKey(const Key('upsertForm_fullName_textField')),
        'Arun',
      );

      verify(() => cubit.fullNameChanged('Arun')).called(1);
    });

    testWidgets('calls jobTitleChanged on every keystroke', (tester) async {
      await _pumpView(tester, cubit, bloc: bloc);

      await tester.enterText(
        find.byKey(const Key('upsertForm_jobTitle_textField')),
        'Engineer',
      );

      verify(() => cubit.jobTitleChanged('Engineer')).called(1);
    });

    testWidgets('calls salaryChanged on every keystroke', (tester) async {
      await _pumpView(tester, cubit, bloc: bloc);

      await tester.enterText(
        find.byKey(const Key('upsertForm_salary_textField')),
        '50000',
      );

      verify(() => cubit.salaryChanged('50000')).called(1);
    });

    testWidgets(
      'calls countryChanged when a country is selected from the dropdown',
      (tester) async {
        await _pumpView(tester, cubit, bloc: bloc);

        await tester.tap(find.byKey(const Key('upsertForm_country_dropdown')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Afghanistan').last);
        await tester.pumpAndSettle();

        verify(() => cubit.countryChanged('Afghanistan')).called(1);
      },
    );

    // ── Validation error surface ─────────────────────────────────────────

    testWidgets(
      'shows full-name error only once the field is dirty',
      (tester) async {
        when(() => cubit.state).thenReturn(
          const EmployeeUpsertState(
            fullName: FullName.dirty(), // dirty + invalid → show error
          ),
        );

        await _pumpView(tester, cubit, bloc: bloc);

        expect(find.text('Full name is required'), findsOneWidget);
      },
    );

    testWidgets(
      'does not show full-name error when the field is pure (untouched)',
      (tester) async {
        // Default state has pure inputs — no errors yet.
        await _pumpView(tester, cubit, bloc: bloc);

        expect(find.text('Full name is required'), findsNothing);
      },
    );

    testWidgets(
      'shows job-title error only once the field is dirty',
      (tester) async {
        when(() => cubit.state).thenReturn(
          const EmployeeUpsertState(
            jobTitle: JobTitle.dirty(),
          ),
        );

        await _pumpView(tester, cubit, bloc: bloc);

        expect(find.text('Job title is required'), findsOneWidget);
      },
    );

    testWidgets(
      'shows country error only once the field is dirty',
      (tester) async {
        when(() => cubit.state).thenReturn(
          const EmployeeUpsertState(
            country: Country.dirty(),
          ),
        );

        await _pumpView(tester, cubit, bloc: bloc);

        expect(find.text('Please select a country'), findsOneWidget);
      },
    );

    testWidgets(
      'shows salary error only once the field is dirty and invalid',
      (tester) async {
        when(() => cubit.state).thenReturn(
          const EmployeeUpsertState(
            salary: SalaryInput.dirty('abc'),
          ),
        );

        await _pumpView(tester, cubit, bloc: bloc);

        expect(find.text('Enter a valid salary'), findsOneWidget);
      },
    );

    // ── Submit gating ────────────────────────────────────────────────────

    testWidgets('submit button is disabled when the form is invalid', (
      tester,
    ) async {
      // Default state: pure (not valid).
      await _pumpView(tester, cubit, bloc: bloc);

      final submitFinder = find.byKey(const Key('upsertForm_submit_button'));
      final button = tester.widget<FilledButton>(submitFinder);
      expect(button.onPressed, isNull);
    });

    testWidgets('submit button is enabled when the form is valid', (
      tester,
    ) async {
      when(() => cubit.state).thenReturn(_validState);

      await _pumpView(tester, cubit, bloc: bloc);

      final submitFinder = find.byKey(const Key('upsertForm_submit_button'));
      final button = tester.widget<FilledButton>(submitFinder);
      expect(button.onPressed, isNotNull);
    });

    testWidgets('tapping submit calls cubit.submitted()', (tester) async {
      when(() => cubit.state).thenReturn(_validState);
      when(() => cubit.submitted()).thenAnswer((_) async {});

      await _pumpView(tester, cubit, bloc: bloc);

      await tester.tap(find.byKey(const Key('upsertForm_submit_button')));
      await tester.pump();

      verify(() => cubit.submitted()).called(1);
    });

    // ── In-progress state ────────────────────────────────────────────────

    testWidgets(
      'shows a CircularProgressIndicator and disables the form while inProgress',
      (tester) async {
        when(() => cubit.state).thenReturn(
          _validState.copyWith(status: FormzSubmissionStatus.inProgress),
        );

        await _pumpView(tester, cubit, bloc: bloc);

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        // The submit button must be disabled during submission.
        final button = tester.widget<FilledButton>(
          find.byKey(const Key('upsertForm_submit_button')),
        );
        expect(button.onPressed, isNull);
      },
    );

    // ── Success: pop + refetch ───────────────────────────────────────────

    testWidgets(
      'pops the modal and dispatches $EmployeesFetchRequested on success',
      (tester) async {
        // Start with a valid, pre-submission state, then emit success.
        whenListen(
          cubit,
          Stream.fromIterable([
            _validState,
            _validState.copyWith(status: FormzSubmissionStatus.success),
          ]),
          initialState: _validState,
        );

        await _pumpView(tester, cubit, bloc: bloc);
        await tester.pumpAndSettle();

        // The view should have popped — EmployeeUpsertView is gone.
        expect(find.byType(EmployeeUpsertView), findsNothing);

        verify(
          () => bloc.add(const EmployeesFetchRequested()),
        ).called(1);
      },
    );

    // ── Failure state ────────────────────────────────────────────────────

    testWidgets(
      'shows an error snackbar and does NOT close the modal on failure',
      (tester) async {
        whenListen(
          cubit,
          Stream.fromIterable([
            _validState,
            _validState.copyWith(status: FormzSubmissionStatus.failure),
          ]),
          initialState: _validState,
        );

        await _pumpView(tester, cubit, bloc: bloc);
        await tester.pump();

        expect(find.byType(SnackBar), findsOneWidget);
        // Modal is still open.
        expect(find.byType(EmployeeUpsertView), findsOneWidget);
      },
    );
  });
}

// ---------------------------------------------------------------------------
// Additional mock needed for the integration-style FAB / edit tests above
// ---------------------------------------------------------------------------

class _MockEmployeeRepository extends Mock implements EmployeeRepository {}
