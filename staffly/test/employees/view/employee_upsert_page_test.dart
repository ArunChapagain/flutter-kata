import 'package:app_ui/app_ui.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:employee_repository/employee_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:staffly/app/routes/routes.dart';
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

/// Creates a [GoRouter] for testing a standalone view that might pop.
GoRouter _testRouterForView(Widget view) {
  return GoRouter(
    initialLocation: '/upsert',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: Text('Home')),
        routes: [
          GoRoute(
            path: 'upsert',
            builder: (_, _) => view,
          ),
        ],
      ),
    ],
  );
}

/// Pumps [EmployeeUpsertView] with a mocked cubit inside a routed app.
Future<void> _pumpView(
  WidgetTester tester,
  EmployeeUpsertCubit cubit,
) {
  return tester.pumpRouted(
    _testRouterForView(
      BlocProvider<EmployeeUpsertCubit>.value(
        value: cubit,
        child: const EmployeeUpsertView(),
      ),
    ),
  );
}

/// Creates a [GoRouter] whose initial route is [EmployeesPage] with a second
/// route for the upsert page, wired as the real app router is.
GoRouter _testRouter({
  required EmployeeRepository employeeRepository,
}) {
  return GoRouter(
    initialLocation: Routes.home,
    routes: [
      GoRoute(
        path: Routes.home,
        builder: (_, _) => RepositoryProvider.value(
          value: employeeRepository,
          child: const EmployeesPage(),
        ),
      ),
      GoRoute(
        path: Routes.upsert,
        builder: (_, state) {
          final employee = state.extra as Employee?;
          return RepositoryProvider.value(
            value: employeeRepository,
            child: EmployeeUpsertPage(employee: employee),
          );
        },
      ),
    ],
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

    testWidgets(
      'has a FAB that opens an $EmployeeUpsertPage for a new employee',
      (tester) async {
        final goRouter = _testRouter(
          employeeRepository: employeeRepository,
        );

        await tester.pumpRouted(goRouter);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        expect(find.byType(EmployeeUpsertPage), findsOneWidget);
      },
    );

    testWidgets(
      'FAB opens the modal with no pre-filled employee (adding mode)',
      (tester) async {
        final goRouter = _testRouter(
          employeeRepository: employeeRepository,
        );

        await tester.pumpRouted(goRouter);
        await tester.pumpAndSettle();

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
    late EmployeeRepository employeeRepository;

    setUp(() {
      employeeRepository = _MockEmployeeRepository();
      when(
        () => employeeRepository.fetchEmployees(),
      ).thenAnswer((_) async => [_arun]);
    });

    testWidgets(
      'opens an $EmployeeUpsertPage when the Edit button is tapped',
      (tester) async {
        final goRouter = _testRouter(
          employeeRepository: employeeRepository,
        );

        await tester.pumpRouted(goRouter);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Edit'));
        await tester.pumpAndSettle();

        expect(find.byType(EmployeeUpsertPage), findsOneWidget);
      },
    );

    testWidgets(
      'opens the modal in editing mode (title says "Edit Employee")',
      (tester) async {
        final goRouter = _testRouter(
          employeeRepository: employeeRepository,
        );

        await tester.pumpRouted(goRouter);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Edit'));
        await tester.pumpAndSettle();

        expect(find.text('Edit Employee'), findsOneWidget);
      },
    );
  });

  group('$EmployeeUpsertView', () {
    late EmployeeUpsertCubit cubit;

    setUp(() {
      cubit = _MockEmployeeUpsertCubit();

      // Default: empty pure state (adding mode).
      when(() => cubit.state).thenReturn(const EmployeeUpsertState());
    });

    // ── Field → cubit wiring ─────────────────────────────────────────────

    testWidgets('calls fullNameChanged on every keystroke', (tester) async {
      await _pumpView(tester, cubit);

      await tester.enterText(
        find.byKey(const Key('upsertForm_fullName_textField')),
        'Arun',
      );

      verify(() => cubit.fullNameChanged('Arun')).called(1);
    });

    testWidgets('calls jobTitleChanged on every keystroke', (tester) async {
      await _pumpView(tester, cubit);

      await tester.enterText(
        find.byKey(const Key('upsertForm_jobTitle_textField')),
        'Engineer',
      );

      verify(() => cubit.jobTitleChanged('Engineer')).called(1);
    });

    testWidgets('calls salaryChanged on every keystroke', (tester) async {
      await _pumpView(tester, cubit);

      await tester.enterText(
        find.byKey(const Key('upsertForm_salary_textField')),
        '50000',
      );

      verify(() => cubit.salaryChanged('50000')).called(1);
    });

    testWidgets(
      'calls countryChanged when a country is selected from the dropdown',
      (tester) async {
        await _pumpView(tester, cubit);

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

        await _pumpView(tester, cubit);

        expect(find.text('Full name is required'), findsOneWidget);
      },
    );

    testWidgets(
      'does not show full-name error when the field is pure (untouched)',
      (tester) async {
        // Default state has pure inputs — no errors yet.
        await _pumpView(tester, cubit);

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

        await _pumpView(tester, cubit);

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

        await _pumpView(tester, cubit);

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

        await _pumpView(tester, cubit);

        expect(find.text('Enter a valid salary'), findsOneWidget);
      },
    );

    // ── Submit gating ────────────────────────────────────────────────────

    testWidgets('submit button is disabled when the form is invalid', (
      tester,
    ) async {
      // Default state: pure (not valid).
      await _pumpView(tester, cubit);

      final submitFinder = find.byKey(const Key('upsertForm_submit_button'));
      final button = tester.widget<FilledButton>(submitFinder);
      expect(button.onPressed, isNull);
    });

    testWidgets('submit button is enabled when the form is valid', (
      tester,
    ) async {
      when(() => cubit.state).thenReturn(_validState);

      await _pumpView(tester, cubit);

      final submitFinder = find.byKey(const Key('upsertForm_submit_button'));
      final button = tester.widget<FilledButton>(submitFinder);
      expect(button.onPressed, isNotNull);
    });

    testWidgets('tapping submit calls cubit.submitted()', (tester) async {
      when(() => cubit.state).thenReturn(_validState);
      when(() => cubit.submitted()).thenAnswer((_) async {});

      await _pumpView(tester, cubit);

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

        await _pumpView(tester, cubit);

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        // The submit button must be disabled during submission.
        final button = tester.widget<FilledButton>(
          find.byKey(const Key('upsertForm_submit_button')),
        );
        expect(button.onPressed, isNull);
      },
    );

    // ── Success: pop ─────────────────────────────────────────────────────

    testWidgets(
      'pops the modal on success',
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

        await _pumpView(tester, cubit);
        await tester.pumpAndSettle();

        // The view should have popped — EmployeeUpsertView is gone.
        expect(find.byType(EmployeeUpsertView), findsNothing);
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

        await _pumpView(tester, cubit);
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
