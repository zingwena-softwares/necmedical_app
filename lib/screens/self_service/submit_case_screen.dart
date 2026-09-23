import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_colors.dart';
import '../../core/employer_field_style.dart';
import '../../core/self_service_api_client.dart';
import '../../models/self_service/reference_models.dart';
import '../../providers/self_service/self_service_data_providers.dart';
import '../../providers/self_service/self_service_providers.dart';
import '../../widgets/app_dialog.dart';

class SubmitCaseScreen extends ConsumerStatefulWidget {
  const SubmitCaseScreen({super.key});

  @override
  ConsumerState<SubmitCaseScreen> createState() => _SubmitCaseScreenState();
}

class _SubmitCaseScreenState extends ConsumerState<SubmitCaseScreen> {
  final _formKey = GlobalKey<FormState>();
  LookupEmployer? _employer;

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _complaintCtrl = TextEditingController();

  bool _submitting = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _complaintCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_employer == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select your employer.')));
      return;
    }

    setState(() => _submitting = true);
    try {
      final caseNumber = await ref.read(selfServiceApiServiceProvider).submitCase(
            employerId: _employer!.id,
            firstName: _firstNameCtrl.text.trim(),
            lastName: _lastNameCtrl.text.trim(),
            phoneNumber: _phoneCtrl.text.trim(),
            complaint: _complaintCtrl.text.trim(),
          );
      if (!mounted) return;
      await _showSuccess(caseNumber);
      if (mounted) Navigator.pop(context);
    } on SelfServiceApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _showSuccess(String caseNumber) {
    return AppDialog.show(
      context,
      title: 'Case Submitted',
      icon: Icons.check_circle_outline_rounded,
      iconColor: AppColors.tealDark,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Your case number is:',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(color: AppColors.noticeCardBg, borderRadius: BorderRadius.circular(12)),
            child: Text(caseNumber,
                textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppColors.navy)),
          ),
          const SizedBox(height: 10),
          Text('Save this number — you\'ll need it to track your case.',
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
      appBar: AppBar(title: const Text('Submit a Case')),
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
                  Text('Your details', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
                  const SizedBox(height: 14),
                  lookups.when(
                    data: (data) => _EmployerPicker(
                      employers: data.employers,
                      selected: _employer,
                      onSelected: (e) => setState(() => _employer = e),
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Couldn\'t load employer list: $e', style: const TextStyle(color: AppColors.badgeRed, fontSize: 12)),
                  ),
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
                    controller: _complaintCtrl,
                    maxLines: 5,
                    decoration: employerFieldDecoration(context, label: 'Describe your complaint', icon: Icons.edit_note_rounded),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Please describe what happened' : null,
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
                style: FilledButton.styleFrom(backgroundColor: AppColors.tealDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: _submitting
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                    : const Text('Submit Case', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmployerPicker extends StatelessWidget {
  final List<LookupEmployer> employers;
  final LookupEmployer? selected;
  final ValueChanged<LookupEmployer> onSelected;

  const _EmployerPicker({required this.employers, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Autocomplete<LookupEmployer>(
      displayStringForOption: (e) => e.tradeName,
      optionsBuilder: (textEditingValue) {
        final query = textEditingValue.text.trim().toLowerCase();
        if (query.isEmpty) return const Iterable<LookupEmployer>.empty();
        return employers.where((e) => e.tradeName.toLowerCase().contains(query)).take(30);
      },
      onSelected: onSelected,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        if (selected != null && controller.text != selected!.tradeName) {
          controller.text = selected!.tradeName;
        }
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: employerFieldDecoration(context, label: 'Your employer', icon: Icons.business_outlined, hint: 'Start typing to search'),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 6),
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    title: Text(option.tradeName, style: const TextStyle(fontSize: 13.5)),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
