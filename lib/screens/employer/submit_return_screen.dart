import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_colors.dart';
import '../../core/employer_api_client.dart';
import '../../core/employer_field_style.dart';
import '../../models/employer/return_models.dart';
import '../../providers/employer/employer_data_providers.dart';
import '../../providers/employer/employer_providers.dart';

class SubmitReturnScreen extends ConsumerStatefulWidget {
  const SubmitReturnScreen({super.key});

  @override
  ConsumerState<SubmitReturnScreen> createState() => _SubmitReturnScreenState();
}

class _SubmitReturnScreenState extends ConsumerState<SubmitReturnScreen> {
  int _year = DateTime.now().year;
  int _month = DateTime.now().month;
  int _currency = 2;
  bool _submitting = false;
  final Map<int, TextEditingController> _employeeControllers = {};
  final Map<int, TextEditingController> _employerControllers = {};

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  void dispose() {
    for (final c in _employeeControllers.values) {
      c.dispose();
    }
    for (final c in _employerControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _employeeController(int empId) =>
      _employeeControllers.putIfAbsent(empId, () => TextEditingController(text: '0'));

  TextEditingController _employerController(int empId) =>
      _employerControllers.putIfAbsent(empId, () => TextEditingController(text: '0'));

  Future<void> _submit() async {
    final employees = ref.read(employeesProvider('')).valueOrNull;
    if (employees == null || employees.rows.isEmpty) return;

    final items = employees.rows.map((e) {
      final employeeContr = double.tryParse(_employeeController(e.empId).text) ?? 0;
      final employerContr = double.tryParse(_employerController(e.empId).text) ?? 0;
      return ReturnSubmissionItem(empId: e.empId, employeeContr: employeeContr, employerContr: employerContr);
    }).toList();

    setState(() => _submitting = true);
    try {
      final message = await ref.read(employerApiServiceProvider).submitReturn(
            year: _year,
            month: _month,
            currency: _currency,
            items: items,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      Navigator.pop(context, true);
    } on EmployerApiException catch (e) {
      if (!mounted) return;
      final message = e.statusCode == 409
          ? 'A return has already been submitted for this period and currency.'
          : e.message;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final employees = ref.watch(employeesProvider(''));

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(title: const Text('Submit Return')),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Return Period', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<int>(
                        initialValue: _month,
                        isExpanded: true,
                        decoration: employerFieldDecoration(context, label: 'Month'),
                        items: [
                          for (int m = 1; m <= 12; m++)
                            DropdownMenuItem(value: m, child: Text(_months[m - 1], overflow: TextOverflow.ellipsis)),
                        ],
                        onChanged: (v) => setState(() => _month = v ?? _month),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<int>(
                        initialValue: _year,
                        isExpanded: true,
                        decoration: employerFieldDecoration(context, label: 'Year'),
                        items: [
                          for (int y = DateTime.now().year; y >= DateTime.now().year - 2; y--)
                            DropdownMenuItem(value: y, child: Text('$y')),
                        ],
                        onChanged: (v) => setState(() => _year = v ?? _year),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: _currency,
                  isExpanded: true,
                  decoration: employerFieldDecoration(context, label: 'Currency', icon: Icons.attach_money_rounded),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Currency 1')),
                    DropdownMenuItem(value: 2, child: Text('Currency 2')),
                  ],
                  onChanged: (v) => setState(() => _currency = v ?? 2),
                ),
              ],
            ),
          ),
          Expanded(
            child: employees.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('$e'))),
              data: (result) {
                if (result.rows.isEmpty) {
                  return const Center(child: Text('No employees registered yet.'));
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  children: [
                    Text('Enter contributions for each employee', style: TextStyle(fontSize: 12.5, color: colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 12),
                    ...result.rows.map((employee) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: const BoxDecoration(color: AppColors.iconBgBlue, shape: BoxShape.circle),
                                    child: Center(
                                      child: Text(
                                        employee.name.isNotEmpty ? employee.name[0].toUpperCase() : '?',
                                        style: const TextStyle(color: AppColors.iconBlue, fontWeight: FontWeight.w800, fontSize: 13),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(employee.fullName,
                                            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
                                        Text('${employee.employeeId} · Grade ${employee.grade}',
                                            style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _employeeController(employee.empId),
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: employerFieldDecoration(context, label: 'Employee'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _employerController(employee.empId),
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: employerFieldDecoration(context, label: 'Employer'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )),
                  ],
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
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
                      : const Text('Submit Return', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
