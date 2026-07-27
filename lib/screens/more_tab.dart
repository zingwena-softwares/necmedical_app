import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_colors.dart';
import '../core/app_icon.dart';
import '../providers/wordpress_providers.dart';
import '../widgets/skeleton_loaders.dart';
import 'about_screen.dart';
import 'contact_screen.dart';
import 'content_detail_screen.dart';
import 'document_list_screen.dart';
import 'gallery_screen.dart';

class MoreTab extends ConsumerWidget {
  const MoreTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
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
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: ClipOval(
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Image.asset('assets/images/nec_logo.png', fit: BoxFit.contain),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('More from NEC Medical', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                      SizedBox(height: 3),
                      Text(
                        'Explore, download and get in touch',
                        style: TextStyle(color: Colors.white70, fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionLabel('Explore'),
          const SizedBox(height: 10),
          _MoreRow(
            iconAsset: 'assets/icons/gallery_icon.png',
            iconBg: AppColors.iconBgViolet,
            iconColor: AppColors.iconViolet,
            label: 'Gallery',
            subtitle: 'Photos and events',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GalleryScreen())),
          ),
          _MoreRow(
            iconAsset: 'assets/icons/contact_us.png',
            iconBg: AppColors.iconBgBlue,
            iconColor: AppColors.iconBlue,
            label: 'Contact Us',
            subtitle: 'Get in touch with us',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactScreen())),
          ),
          _MoreRow(
            icon: Icons.health_and_safety_rounded,
            iconBg: AppColors.iconBgTeal,
            iconColor: AppColors.iconTeal,
            label: 'About NEC Medical',
            subtitle: 'Who we are and what we do',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())),
          ),
          const SizedBox(height: 22),
          _SectionLabel('Documents & Services'),
          const SizedBox(height: 10),
          _MoreRow(
            icon: Icons.description_rounded,
            iconBg: AppColors.iconBgLavender,
            iconColor: AppColors.iconLavender,
            label: 'Collective Bargaining Agreement',
            subtitle: 'CBA documents',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DocumentListScreen(
                  appBarTitle: 'CBA',
                  badgeLabel: 'CBA',
                  pageProvider: cbaPageProvider,
                  contentProvider: cbaContentProvider,
                ),
              ),
            ),
          ),
          _MoreRow(
            icon: Icons.how_to_reg_rounded,
            iconBg: AppColors.iconBgLavender,
            iconColor: AppColors.iconLavender,
            label: 'Registration',
            subtitle: 'How to register with NEC',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DocumentListScreen(
                  appBarTitle: 'Registration',
                  badgeLabel: 'REGISTRATION',
                  pageProvider: registrationPageProvider,
                  contentProvider: registrationContentProvider,
                ),
              ),
            ),
          ),
          _MoreRow(
            icon: Icons.work_outline_rounded,
            iconBg: AppColors.iconBgLavender,
            iconColor: AppColors.iconLavender,
            label: 'Projects',
            subtitle: 'Ongoing NEC projects',
            onTap: () => _openBySlug(context, ref, 'projects', badgeLabel: 'PROJECTS'),
          ),
        ],
      ),
    );
  }

  Future<void> _openBySlug(BuildContext context, WidgetRef ref, String slug, {String? badgeLabel}) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ShimmerDialogLoader(),
    );
    try {
      final items = await ref.read(wordpressApiServiceProvider).fetchPageBySlug(slug);
      if (!context.mounted) return;
      Navigator.pop(context);
      if (items.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ContentDetailScreen(item: items.first, badgeLabel: badgeLabel)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This page is unavailable right now.')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _MoreRow extends StatelessWidget {
  final IconData? icon;
  final String? iconAsset;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _MoreRow({
    this.icon,
    this.iconAsset,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.onTap,
  }) : assert(icon != null || iconAsset != null);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: iconBg, width: 1.2),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 3)),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                  child: Center(
                    child: iconAsset != null
                        ? AppAssetIcon(iconAsset!, size: 21, color: iconColor)
                        : Icon(icon, size: 21, color: iconColor),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
                      const SizedBox(height: 3),
                      Text(subtitle, style: TextStyle(fontSize: 11.5, color: colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                  child: Icon(Icons.chevron_right_rounded, size: 18, color: iconColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
