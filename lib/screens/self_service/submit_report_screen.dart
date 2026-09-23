import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_colors.dart';
import '../../core/employer_field_style.dart';
import '../../core/self_service_api_client.dart';
import '../../models/self_service/reference_models.dart';
import '../../providers/self_service/self_service_data_providers.dart';
import '../../providers/self_service/self_service_providers.dart';
import '../../widgets/app_dialog.dart';

class SubmitReportScreen extends ConsumerStatefulWidget {
  const SubmitReportScreen({super.key});

  @override
  ConsumerState<SubmitReportScreen> createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends ConsumerState<SubmitReportScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _preset;

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _employerNameCtrl = TextEditingController();
  final _complaintCtrl = TextEditingController();

  bool _submitting = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _employerNameCtrl.dispose();
    _complaintCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_preset == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select what this report is about.')));
      return;
    }

    setState(() => _submitting = true);
    try {
      final result = await ref.read(selfServiceApiServiceProvider).submitReport(
            preset: _preset!,
            employeeFirstName: _firstNameCtrl.text.trim(),
            employeeLastName: _lastNameCtrl.text.trim(),
            employeePhone: _phoneCtrl.text.trim(),
            employeeEmail: _emailCtrl.text.trim(),
            employerName: _employerNameCtrl.text.trim(),
            complaint: _complaintCtrl.text.trim(),
          );
      if (!mounted) return;
      await _showSuccess(result.referenceNumber);
      if (mounted) Navigator.pop(context);
    } on SelfServiceApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _showSuccess(String referenceNumber) {
    return AppDialog.show(
      context,
      title: 'Report Submitted',
      icon: Icons.check_circle_outline_rounded,
      iconColor: AppColors.iconViolet,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Your reference number is:',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(color: AppColors.noticeCardBg, borderRadius: BorderRadius.circular(12)),
            child: Text(referenceNumber,
                textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppColors.navy)),
          ),
          const SizedBox(height: 10),
          Text('Please keep this for your own records — it can\'t currently be looked up again in the app.',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lookups = ref.watch(selfServiceLookupsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Submit a Report')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('What happened?', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
                  const SizedBox(height: 14),
                  lookups.when(
                    data: (data) => DropdownButtonFormField<String>(
                      initialValue: _preset,
                      isExpanded: true,
                      decoration: employerFieldDecoration(context, label: 'Type of report', icon: Icons.category_outlined),
                      items: data.reportPresets
                          .map((p) => DropdownMenuItem(value: p, child: Text(reportPresetLabel(p))))
                          .toList(),
                      onChanged: (v) => setState(() => _preset = v),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Couldn\'t load report types: $e', style: const TextStyle(color: AppColors.badgeRed, fontSize: 12)),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _complaintCtrl,
                    maxLines: 5,
                    decoration: employerFieldDecoration(context, label: 'Describe what happened', icon: Icons.edit_note_rounded),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Please describe what happened' : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your details', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _firstNameCtrl,
                          decoration: employerFieldDecoration(context, label: 'First name', icon: Icons.person_outline),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _lastNameCtrl,
                          decoration: employerFieldDecoration(context, label: 'Last name'),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: employerFieldDecoration(context, label: 'Phone number', icon: Icons.phone_outlined),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: employerFieldDecoration(context, label: 'Email (optional)', icon: Icons.email_outlined),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _employerNameCtrl,
                    decoration: employerFieldDecoration(context, label: 'Employer name (optional)', icon: Icons.business_outlined),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: _submitting ? null : _submit,
                style: FilledButton.styleFrom(backgroundColor: AppColors.iconViolet, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: _submitting
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                    : const Text('Submit Report', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
