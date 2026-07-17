import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_colors.dart';
import '../core/app_icon.dart';
import '../providers/wordpress_providers.dart';
import '../widgets/skeleton_loaders.dart';
import 'about_screen.dart';
import 'contact_screen.dart';
import 'content_detail_screen.dart';
import 'gallery_screen.dart';

class MoreTab extends ConsumerWidget {
  const MoreTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
          const Divider(height: 32),
          _MoreRow(
            icon: Icons.description_rounded,
            iconBg: AppColors.iconBgLavender,
            iconColor: AppColors.iconLavender,
            label: 'Collective Bargaining Agreement',
            subtitle: 'CBA documents',
            onTap: () => _openBySlug(context, ref, 'cba'),
          ),
          _MoreRow(
            icon: Icons.how_to_reg_rounded,
            iconBg: AppColors.iconBgLavender,
            iconColor: AppColors.iconLavender,
            label: 'Registration',
            subtitle: 'How to register with NEC',
            onTap: () => _openBySlug(context, ref, 'registration'),
          ),
          _MoreRow(
            icon: Icons.work_outline_rounded,
            iconBg: AppColors.iconBgLavender,
            iconColor: AppColors.iconLavender,
            label: 'Projects',
            subtitle: 'Ongoing NEC projects',
            onTap: () => _openBySlug(context, ref, 'projects'),
          ),
        ],
      ),
    );
  }

  Future<void> _openBySlug(BuildContext context, WidgetRef ref, String slug) async {
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
        Navigator.push(context, MaterialPageRoute(builder: (_) => ContentDetailScreen(item: items.first)));
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
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                  child: Center(
                    child: iconAsset != null
                        ? AppAssetIcon(iconAsset!, size: 19, color: iconColor)
                        : Icon(icon, size: 19, color: iconColor),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: TextStyle(fontSize: 11.5, color: colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, size: 20, color: colorScheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
