import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_colors.dart';
import '../../core/employer_api_client.dart';
import '../../models/employer/employee_model.dart';
import '../../providers/employer/employer_data_providers.dart';
import '../../providers/employer/employer_providers.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/shimmer_box.dart';
import 'add_edit_employee_screen.dart';

class EmployeesScreen extends ConsumerStatefulWidget {
  const EmployeesScreen({super.key});

  @override
  ConsumerState<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends ConsumerState<EmployeesScreen> {
  final _searchController = TextEditingController();
  String _search = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _search = value.trim());
    });
  }

  Future<void> _openEdit([Employee? employee]) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddEditEmployeeScreen(employee: employee)),
    );
    if (changed == true) ref.invalidate(employeesProvider(_search));
  }

  Future<void> _confirmDelete(Employee employee) async {
    final confirmed = await AppDialog.confirm(
      context,
      title: 'Remove employee?',
      message: 'Remove ${employee.fullName} from your registered employees?',
      icon: Icons.person_remove_outlined,
      confirmLabel: 'Remove',
      destructive: true,
    );
    if (!confirmed) return;
    try {
      final message = await ref.read(employerApiServiceProvider).deleteEmployee(employee.empId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      ref.invalidate(employeesProvider(_search));
    } on EmployerApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final employees = ref.watch(employeesProvider(_search));

    return Scaffold(
      appBar: AppBar(title: const Text('Employees')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.navy,
        onPressed: () => _openEdit(),
        child: const Icon(Icons.add_rounded),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Search employees',
                prefixIcon: Icon(Icons.search_rounded),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          Expanded(
            child: employees.when(
              loading: () => AppShimmer(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: List.generate(
                    6,
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ShimmerBox(width: double.infinity, height: 66, borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ),
              error: (e, _) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('$e'))),
              data: (result) {
                if (result.rows.isEmpty) {
                  return const Center(child: Text('No employees found.'));
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                  children: result.rows.map((employee) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          title: Text(employee.fullName, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
                          subtitle: Text('${employee.employeeId} · ${employee.jobTitle} · Grade ${employee.grade}',
                              style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _openEdit(employee);
                              } else if (value == 'delete') {
                                _confirmDelete(employee);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(value: 'delete', child: Text('Remove')),
                            ],
                          ),
                          onTap: () => _openEdit(employee),
                        ),
                      ))
                      .toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
