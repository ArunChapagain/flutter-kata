import 'package:employee_repository/employee_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staffly/employees/widgets/widgets.dart';

import '../../helpers/helpers.dart';

void main() {
  group(EmployeeCard, () {
    const employee = Employee(
      id: 'e1b9f0c4',
      fullName: 'Jane Doe',
      jobTitle: 'Senior Product Designer',
      country: 'United States',
      salary: Salary(14500000),
    );

    testWidgets(
      'renders the full name, job title, country and formatted salary',
      (tester) async {
        await tester.pumpApp(const EmployeeCard(employee: employee));

        expect(find.text(employee.fullName), findsOneWidget);
        expect(find.text(employee.jobTitle), findsOneWidget);
        expect(find.text(employee.country), findsOneWidget);
        expect(find.text(employee.salary.format()), findsOneWidget);
      },
    );
  });
}
