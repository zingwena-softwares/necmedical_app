import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

/// Shared filter card (date-from, date-to, currency) used by Statements,
/// Invoices and Payments — kept as one widget so all three read as the same
/// polished component instead of three slightly-different hand-rolled bars.
class DateRangeCurrencyFilter extends StatelessWidget {
  final DateTime dateFrom;
  final DateTime dateTo;
  final int currency;
  final ValueChanged<bool> onPickDate;
  final ValueChanged<int> onCurrencyChanged;

  const DateRangeCurrencyFilter({
    super.key,
    required this.dateFrom,
    required this.dateTo,
    required this.currency,
    required this.onPickDate,
    required this.onCurrencyChanged,
  });

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _fmt(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: _dateChip(context, 'From', dateFrom, () => onPickDate(true))),
              const SizedBox(width: 10),
              Expanded(child: _dateChip(context, 'To', dateTo, () => onPickDate(false))),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<int>(
            initialValue: currency,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Currency',
              isDense: true,
              prefixIcon: const Icon(Icons.attach_money_rounded, size: 18),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.navy, width: 1.6),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 1, child: Text('ZWG')),
              DropdownMenuItem(value: 2, child: Text('USD')),
            ],
            onChanged: (v) => onCurrencyChanged(v ?? 2),
          ),
        ],
      ),
    );
  }

  Widget _dateChip(BuildContext context, String label, DateTime date, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 14, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label, style: TextStyle(fontSize: 9.5, color: colorScheme.onSurfaceVariant)),
                    Text(_fmt(date),
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
