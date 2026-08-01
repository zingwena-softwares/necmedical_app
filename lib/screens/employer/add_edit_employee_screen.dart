import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_colors.dart';
import '../../core/employer_api_client.dart';
import '../../core/employer_field_style.dart';
import '../../models/employer/employee_model.dart';
import '../../providers/employer/employer_providers.dart';

class AddEditEmployeeScreen extends ConsumerStatefulWidget {
  final Employee? employee;
  const AddEditEmployeeScreen({super.key, this.employee});

  @override
  ConsumerState<AddEditEmployeeScreen> createState() => _AddEditEmployeeScreenState();
}

class _AddEditEmployeeScreenState extends ConsumerState<AddEditEmployeeScreen> {
  late final TextEditingController _employeeIdController;
  late final TextEditingController _nameController;
  late final TextEditingController _surnameController;
  late final TextEditingController _gradeController;
  late final TextEditingController _salaryController;
  bool _submitting = false;
  String? _error;

  bool get _isEdit => widget.employee != null;

  @override
  void initState() {
    super.initState();
    final e = widget.employee;
    _employeeIdController = TextEditingController(text: e?.employeeId ?? '');
    _nameController = TextEditingController(text: e?.name ?? '');
    _surnameController = TextEditingController(text: e?.surname ?? '');
    _gradeController = TextEditingController(text: e?.grade ?? '');
    _salaryController = TextEditingController(text: e != null ? e.salary.toStringAsFixed(2) : '');
  }

  @override
  void dispose() {
    _employeeIdController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _gradeController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final employeeId = _employeeIdController.text.trim();
    final name = _nameController.text.trim();
    final surname = _surnameController.text.trim();
    final grade = _gradeController.text.trim();
    final salary = double.tryParse(_salaryController.text.trim());

    if (employeeId.isEmpty || name.isEmpty || surname.isEmpty || grade.isEmpty || salary == null) {
      setState(() => _error = 'Fill in all fields with a valid salary amount');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final service = ref.read(employerApiServiceProvider);
      final message = _isEdit
          ? await service.updateEmployee(
              empId: widget.employee!.empId,
              employeeId: employeeId,
              name: name,
              surname: surname,
              grade: grade,
              salary: salary,
            )
          : await service.createEmployee(employeeId: employeeId, name: name, surname: surname, grade: grade, salary: salary);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      Navigator.pop(context, true);
    } on EmployerApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(title: Text(_isEdit ? 'Edit Employee' : 'Add Employee')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.navy, AppColors.navyLight]),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Icon(_isEdit ? Icons.edit_rounded : Icons.person_add_alt_1_rounded, color: AppColors.navy, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_isEdit ? 'Edit Employee' : 'New Employee',
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 3),
                        Text(
                          _isEdit ? 'Update this employee\'s details' : 'Register a new employee for contributions',
                          style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _employeeIdController,
                    decoration: employerFieldDecoration(context, label: 'Employee ID', icon: Icons.badge_outlined),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          decoration: employerFieldDecoration(context, label: 'First Name', icon: Icons.person_outline_rounded),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _surnameController,
                          decoration: employerFieldDecoration(context, label: 'Surname'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _gradeController,
                          decoration: employerFieldDecoration(context, label: 'Grade Code', hint: 'e.g. C1', icon: Icons.grade_outlined),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _salaryController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: employerFieldDecoration(context, label: 'Salary', icon: Icons.attach_money_rounded),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: AppColors.badgeRed, fontSize: 12.5)),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _submitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(_isEdit ? 'Save Changes' : 'Add Employee', style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
