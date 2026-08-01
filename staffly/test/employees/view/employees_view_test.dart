import 'package:app_ui/app_ui.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:employee_repository/employee_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:staffly/employees/bloc/bloc.dart';
import 'package:staffly/employees/view/view.dart';
import 'package:staffly/employees/widgets/widgets.dart';

import '../../helpers/helpers.dart';

class _MockEmployeesBloc extends MockBloc<EmployeesEvent, EmployeesState>
    implements EmployeesBloc {}

void main() {
  group(EmployeesView, () {
    const arun = Employee(
      id: 'e1b9f0c4',
      fullName: 'Arun Chapagai',
      jobTitle: 'Software Engineer',
      country: 'Nepal',
      salary: Salary(5000050),
    );

    const sam = Employee(
      id: '7d3a1f52',
      fullName: 'Sam Rai',
      jobTitle: 'Designer',
      country: 'Nepal',
      salary: Salary(4200000),
    );

    late EmployeesBloc employeesBloc;

    setUpAll(() {
      registerFallbackValue(const EmployeesSearchQueryChanged(query: ''));
    });

    setUp(() {
      employeesBloc = _MockEmployeesBloc();
    });

    Widget buildSubject() =>
        BlocProvider.value(value: employeesBloc, child: const EmployeesView());

    testWidgets('shows a loading indicator while the list is loading', (
      tester,
    ) async {
      when(
        () => employeesBloc.state,
      ).thenReturn(
        const EmployeesState(
          fetchState: FetchState(status: FetchStatus.loading),
        ),
      );

      await tester.pumpApp(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders one $EmployeeCard per employee once the list loads', (
      tester,
    ) async {
      when(() => employeesBloc.state).thenReturn(
        const EmployeesState(
          fetchState: FetchState(
            status: FetchStatus.success,
            employees: [arun, sam],
          ),
        ),
      );

      await tester.pumpApp(buildSubject());

      expect(find.byType(EmployeeCard), findsNWidgets(2));
    });

    testWidgets(
      'shows an $AppEmptyState once the list loads with nothing in it',
      (
        tester,
      ) async {
        when(
          () => employeesBloc.state,
        ).thenReturn(
          const EmployeesState(
            fetchState: FetchState(status: FetchStatus.success),
          ),
        );

        await tester.pumpApp(buildSubject());

        expect(find.byType(AppEmptyState), findsOneWidget);
        expect(find.text('No employees yet'), findsOneWidget);
      },
    );

    testWidgets('shows an $AppEmptyState when the list fails to load', (
      tester,
    ) async {
      when(
        () => employeesBloc.state,
      ).thenReturn(
        const EmployeesState(
          fetchState: FetchState(status: FetchStatus.failure),
        ),
      );

      await tester.pumpApp(buildSubject());

      expect(find.byType(AppEmptyState), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
    });

    group('search field', () {
      testWidgets('renders a search field when the list has loaded', (
        tester,
      ) async {
        when(() => employeesBloc.state).thenReturn(
          const EmployeesState(
            fetchState: FetchState(
              status: FetchStatus.success,
              employees: [arun, sam],
            ),
          ),
        );

        await tester.pumpApp(buildSubject());

        expect(find.byType(TextField), findsOneWidget);
      });

      testWidgets(
        'dispatches $EmployeesSearchQueryChanged when the user types',
        (tester) async {
          when(() => employeesBloc.state).thenReturn(
            const EmployeesState(
              fetchState: FetchState(
                status: FetchStatus.success,
                employees: [arun, sam],
              ),
            ),
          );

          await tester.pumpApp(buildSubject());

          await tester.enterText(find.byType(TextField), 'Arun');

          verify(
            () => employeesBloc.add(
              const EmployeesSearchQueryChanged(query: 'Arun'),
            ),
          ).called(1);
        },
      );

      testWidgets(
        'renders only employees matching the search query (visibleEmployees)',
        (tester) async {
          // State with searchQuery applied: visibleEmployees returns only [arun]
          when(() => employeesBloc.state).thenReturn(
            const EmployeesState(
              fetchState: FetchState(
                status: FetchStatus.success,
                employees: [arun, sam],
              ),
              searchQuery: 'Arun',
            ),
          );

          await tester.pumpApp(buildSubject());

          // Only Arun's card should render; Sam's should not
          expect(find.text(arun.fullName), findsOneWidget);
          expect(find.text(sam.fullName), findsNothing);
        },
      );

      testWidgets(
        'shows an $AppEmptyState when search yields no results',
        (tester) async {
          when(() => employeesBloc.state).thenReturn(
            const EmployeesState(
              fetchState: FetchState(
                status: FetchStatus.success,
                employees: [arun, sam],
              ),
              searchQuery: 'NonExistentEmployee',
            ),
          );

          await tester.pumpApp(buildSubject());

          expect(find.byType(AppEmptyState), findsOneWidget);
          expect(find.text('No results found'), findsOneWidget);
        },
      );
    });
  });
}
