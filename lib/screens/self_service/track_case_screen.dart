import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_colors.dart';
import '../../core/employer_field_style.dart';
import '../../core/self_service_api_client.dart';
import '../../models/self_service/case_model.dart';
import '../../providers/self_service/self_service_providers.dart';

class TrackCaseScreen extends ConsumerStatefulWidget {
  const TrackCaseScreen({super.key});

  @override
  ConsumerState<TrackCaseScreen> createState() => _TrackCaseScreenState();
}

class _TrackCaseScreenState extends ConsumerState<TrackCaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _caseNumberCtrl = TextEditingController();

  bool _searching = false;
  bool _searched = false;
  SelfServiceCase? _result;
  String? _error;

  @override
  void dispose() {
    _caseNumberCtrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _searching = true;
      _searched = true;
      _error = null;
      _result = null;
    });
    try {
      final result = await ref.read(selfServiceApiServiceProvider).trackCase(_caseNumberCtrl.text.trim());
      setState(() => _result = result);
    } on SelfServiceApiException catch (e) {
      setState(() => _error = e.statusCode == 404 ? null : e.message);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Track My Case')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          Form(
            key: _formKey,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _caseNumberCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: employerFieldDecoration(context, label: 'Case number', icon: Icons.confirmation_number_outlined, hint: 'e.g. CN202609090'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: _searching ? null : _search,
                      style: FilledButton.styleFrom(backgroundColor: AppColors.navy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      child: _searching
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                          : const Text('Track Case', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (_error != null) _MessageCard(icon: Icons.error_outline_rounded, color: AppColors.badgeRed, text: _error!),
          if (_searched && _error == null && _result == null)
            const _MessageCard(
              icon: Icons.search_off_rounded,
              color: AppColors.navy,
              text: 'No case found with that case number. Double-check it and try again.',
            ),
          if (_result != null) _CaseDetail(caseRecord: _result!),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  const _MessageCard({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.noticeCardBg, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(fontSize: 12.5, color: color))),
        ],
      ),
    );
  }
}

class _CaseDetail extends StatelessWidget {
  final SelfServiceCase caseRecord;
  const _CaseDetail({required this.caseRecord});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(caseRecord.caseNumber, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.navy)),
              ),
              if (caseRecord.masterStatus != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.iconBgTeal, borderRadius: BorderRadius.circular(8)),
                  child: Text(caseRecord.masterStatus!.toUpperCase(),
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.iconTeal)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (caseRecord.employerTradeName != null) ...[
            Text('Employer: ${caseRecord.employerTradeName}', style: TextStyle(fontSize: 12.5, color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 4),
          ],
          if (caseRecord.natureCase != null) ...[
            Text('Nature: ${caseRecord.natureCase}', style: TextStyle(fontSize: 12.5, color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 4),
          ],
          if (caseRecord.complaint != null) ...[
            const SizedBox(height: 6),
            Text(caseRecord.complaint!, style: TextStyle(fontSize: 13, color: colorScheme.onSurface)),
          ],
          if (caseRecord.officerComments != null && caseRecord.officerComments!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.noticeCardBg, borderRadius: BorderRadius.circular(10)),
              child: Text('Note from NEC: ${caseRecord.officerComments}', style: const TextStyle(fontSize: 12)),
            ),
          ],
        ],
      ),
    );
  }
}
