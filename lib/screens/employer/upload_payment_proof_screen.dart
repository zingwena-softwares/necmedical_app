import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_colors.dart';
import '../../core/employer_api_client.dart';
import '../../core/employer_field_style.dart';
import '../../providers/employer/employer_providers.dart';

class UploadPaymentProofScreen extends ConsumerStatefulWidget {
  const UploadPaymentProofScreen({super.key});

  @override
  ConsumerState<UploadPaymentProofScreen> createState() => _UploadPaymentProofScreenState();
}

class _UploadPaymentProofScreenState extends ConsumerState<UploadPaymentProofScreen> {
  DateTime _paymentDate = DateTime.now();
  int _currency = 2;
  final _amountController = TextEditingController();
  PlatformFile? _pickedFile;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(context: context, initialDate: _paymentDate, firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (picked != null) setState(() => _paymentDate = picked);
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.single;
      if (file.size > 10 * 1024 * 1024) {
        if (mounted) setState(() => _error = 'File must be 10MB or smaller');
        return;
      }
      setState(() {
        _pickedFile = file;
        _error = null;
      });
    }
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || _pickedFile?.path == null) {
      setState(() => _error = 'Enter a valid amount and choose a file to upload');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final iso = '${_paymentDate.year.toString().padLeft(4, '0')}-${_paymentDate.month.toString().padLeft(2, '0')}-${_paymentDate.day.toString().padLeft(2, '0')}';
      final message = await ref.read(employerApiServiceProvider).uploadPaymentProof(
            paymentDate: iso,
            paymentCurrency: _currency,
            paymentAmount: amount,
            filePath: _pickedFile!.path!,
            fileName: _pickedFile!.name,
          );
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
      appBar: AppBar(title: const Text('Upload Payment Proof')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.tealDark, AppColors.teal]),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.upload_file_rounded, color: AppColors.tealDark, size: 22),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Upload Payment Proof', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                        SizedBox(height: 3),
                        Text('Attach your receipt so we can confirm your payment',
                            style: TextStyle(color: Colors.white70, fontSize: 11.5)),
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
                  InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: employerFieldDecoration(context, label: 'Payment Date', icon: Icons.calendar_today_outlined),
                      child: Text('${_paymentDate.year}-${_paymentDate.month.toString().padLeft(2, '0')}-${_paymentDate.day.toString().padLeft(2, '0')}'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<int>(
                    initialValue: _currency,
                    isExpanded: true,
                    decoration: employerFieldDecoration(context, label: 'Currency', icon: Icons.attach_money_rounded),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('ZWG')),
                      DropdownMenuItem(value: 2, child: Text('USD')),
                    ],
                    onChanged: (v) => setState(() => _currency = v ?? 2),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: employerFieldDecoration(context, label: 'Amount Paid', icon: Icons.payments_outlined),
                  ),
                  const SizedBox(height: 14),
                  Material(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _pickFile,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _pickedFile != null ? AppColors.tealDark.withValues(alpha: 0.4) : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(color: AppColors.iconBgTeal, shape: BoxShape.circle),
                              child: const Icon(Icons.attach_file_rounded, color: AppColors.tealDark, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _pickedFile?.name ?? 'Choose PDF, JPG or PNG (max 10MB)',
                                style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                  : const Text('Upload', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
