import 'money.dart';

class Employee {
  final int empId;
  final String employeeId;
  final String name;
  final String surname;
  final String jobTitle;
  final String grade;
  final int gradeId;
  final double salary;
  final String? dateRegistered;

  Employee({
    required this.empId,
    required this.employeeId,
    required this.name,
    required this.surname,
    required this.jobTitle,
    required this.grade,
    required this.gradeId,
    required this.salary,
    this.dateRegistered,
  });

  String get fullName => '$name $surname'.trim();

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      empId: json['emp_id'] ?? 0,
      employeeId: json['employee_id'] ?? '',
      name: (json['name'] ?? '').toString().trim(),
      surname: (json['surname'] ?? '').toString().trim(),
      jobTitle: json['job_title'] ?? '',
      grade: (json['grade'] ?? '').toString().trim(),
      gradeId: json['grade_id'] ?? 0,
      salary: asDouble(json['salary']),
      dateRegistered: json['date_registered'],
    );
  }
}

class EmployeesResult {
  final int count;
  final List<Employee> rows;

  EmployeesResult({required this.count, required this.rows});

  factory EmployeesResult.fromJson(Map<String, dynamic> json) {
    return EmployeesResult(
      count: (json['summary'] as Map<String, dynamic>?)?['count'] ?? 0,
      rows: (json['rows'] as List<dynamic>? ?? []).map((r) => Employee.fromJson(r as Map<String, dynamic>)).toList(),
    );
  }
}
