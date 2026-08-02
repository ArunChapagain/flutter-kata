import 'package:employee_repository/employee_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:staffly/app/app.dart';
import 'package:staffly/employees/view/employees_page.dart';

class _MockEmployeeRepository extends Mock implements EmployeeRepository {}

void main() {
  group('App', () {
    late EmployeeRepository employeeRepository;

    setUp(() {
      employeeRepository = _MockEmployeeRepository();
      when(
        () => employeeRepository.fetchEmployees(),
      ).thenAnswer((_) async => []);
    });

    testWidgets('renders $EmployeesPage as home', (tester) async {
      await tester.pumpWidget(App(employeeRepository: employeeRepository));
      expect(find.byType(EmployeesPage), findsOneWidget);
    });
  });
}
