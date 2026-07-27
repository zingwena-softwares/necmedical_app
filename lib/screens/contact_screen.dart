import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_colors.dart';
import '../models/office_contact.dart';
import '../providers/wordpress_providers.dart';
import '../widgets/skeleton_loaders.dart';
import 'appointment_screen.dart';

class ContactScreen extends ConsumerWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offices = ref.watch(officeContactsProvider);
    final rawPage = ref.watch(contactPageProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Contact Us')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.navy, AppColors.navyLight]),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('We\'re here to help', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                        SizedBox(height: 4),
                        Text('Get in touch with us for any enquiries or support.',
                            style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.support_agent_rounded, color: Colors.white, size: 40),
                ],
              ),
            ),
            const SizedBox(height: 20),
            offices.when(
              loading: () => const Column(
                children: [InfoCardSkeleton(), InfoCardSkeleton(), InfoCardSkeleton()],
              ),
              error: (_, __) => _fallbackRawContent(context, rawPage),
              data: (list) {
                if (list.isEmpty) return _fallbackRawContent(context, rawPage);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: list.map((o) => _OfficeCard(office: o)).toList(),
                );
              },
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => launchUrl(Uri.parse('mailto:info@necmedical.org.zw')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tealDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.mail_outline_rounded, size: 18),
                label: const Text('Send an Inquiry'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppointmentScreen())),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.navy,
                  side: const BorderSide(color: AppColors.navy),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.event_available_rounded, size: 18),
                label: const Text('Schedule a DA Appointment'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackRawContent(BuildContext context, AsyncValue rawPage) {
    return rawPage.when(
      loading: () => const Column(
        children: [InfoCardSkeleton(), InfoCardSkeleton()],
      ),
      error: (e, __) => Text('$e'),
      data: (page) => page == null ? const Text('Contact information is unavailable right now.') : Html(data: page.htmlContent),
    );
  }
}

class _OfficeCard extends StatelessWidget {
  final OfficeContact office;
  const _OfficeCard({required this.office});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(office.city, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
          const SizedBox(height: 10),
          _row(context, Icons.phone_rounded, office.phone, onTap: () => launchUrl(Uri.parse('tel:${office.phone.replaceAll(' ', '')}'))),
          const SizedBox(height: 8),
          _row(context, Icons.email_outlined, office.email, onTap: () => launchUrl(Uri.parse('mailto:${office.email}'))),
          const SizedBox(height: 8),
          _row(context, Icons.location_on_outlined, office.address),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, IconData icon, String text, {VoidCallback? onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.tealDark),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontSize: 12.5, color: colorScheme.onSurfaceVariant, height: 1.3))),
        ],
      ),
    );
  }
}
