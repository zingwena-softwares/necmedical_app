import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/app_colors.dart';
import '../../core/app_icon.dart';
import '../../models/wp_content_item.dart';
import '../../providers/wordpress_providers.dart';
import '../../widgets/skeleton_loaders.dart';
import '../about_screen.dart';
import '../contact_screen.dart';
import '../content_detail_screen.dart';
import '../employer_portal_screen.dart';
import '../gallery_screen.dart';
import '../home_screen.dart';
import '../self_service_screen.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _HomeHeader(),
              SizedBox(height: 16),
              _HeroBanner(),
              SizedBox(height: 24),
              _QuickActionsSection(),
              SizedBox(height: 20),
              _LatestNoticeCard(),
              SizedBox(height: 20),
              _ServicePortalsRow(),
              SizedBox(height: 16),
              _UpcomingHearingsRow(),
              SizedBox(height: 24),
              _LatestInsightsSection(),
              SizedBox(height: 20),
              _AboutCard(),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// HEADER — logo, title/subtitle, notification bell, profile
// ═══════════════════════════════════════════════════════════════
class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.navy, width: 1.5),
              color: colorScheme.surface,
            ),
            child: ClipOval(
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Image.asset('assets/images/nec_logo.png', fit: BoxFit.contain),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NEC Medical',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: AppColors.navy),
                ),
                Text(
                  'National Employment Council\nfor the Medical and Allied Industry',
                  style: TextStyle(fontSize: 10.5, height: 1.3, color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _iconButton(
            context,
            icon: Icons.notifications_none_rounded,
            showBadge: true,
            onTap: () => _comingSoon(context),
          ),
          const SizedBox(width: 8),
          _iconButton(
            context,
            icon: Icons.person_outline_rounded,
            showBadge: false,
            onTap: () => _comingSoon(context),
          ),
        ],
      ),
    );
  }

  static void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon')),
    );
  }

  static Widget _iconButton(
    BuildContext context, {
    required IconData icon,
    required bool showBadge,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Stack(
          children: [
            Center(child: Icon(icon, size: 20, color: AppColors.navy)),
            if (showBadge)
              Positioned(
                right: 9,
                top: 9,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: AppColors.badgeRed, shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// HERO BANNER — headline + Employer Portal / Self Service buttons
// ═══════════════════════════════════════════════════════════════
class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.navy, AppColors.navyLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(
            // TODO: swap for a real teamwork/hands photo asset once supplied.
            image: const AssetImage('assets/images/hero_teamwork.jpg'),
            fit: BoxFit.cover,
            opacity: 0.25,
            onError: (exception, stackTrace) {},
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Working together for\nfair labour relations and\na healthier industry.',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, height: 1.35),
            ),
            const SizedBox(height: 10),
            Container(width: 36, height: 3, decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _heroPortalButton(
                    context,
                    iconAsset: 'assets/icons/employee_portal_icon.png',
                    title: 'Employer Portal',
                    subtitle: 'Manage your business\nand employees',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmployerPortalScreen())),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _heroPortalButton(
                    context,
                    iconAsset: 'assets/icons/self_service_portal.png',
                    title: 'Self Service',
                    subtitle: 'Access your cases\nand hearings',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SelfServiceScreen())),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroPortalButton(
    BuildContext context, {
    required String iconAsset,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(color: AppColors.teal, shape: BoxShape.circle),
                child: Center(child: AppAssetIcon(iconAsset, size: 17, color: Colors.white)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title,
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.navy),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text(subtitle,
                        style: const TextStyle(fontSize: 9, height: 1.2, color: Color(0xFF6B7280)),
                        maxLines: 2),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.navy),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// QUICK ACTIONS — Notices / Blog / Gallery / Contact Us
// ═══════════════════════════════════════════════════════════════
class _QuickActionsSection extends ConsumerWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _SectionHeader(
            title: 'Quick Actions',
            onViewAll: () => HomeScreen.of(context)?.setCurrentIndex(HomeNavigation.moreIndex),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  iconAsset: 'assets/icons/notice_icon.png',
                  iconBg: AppColors.iconBgLavender,
                  iconColor: AppColors.iconLavender,
                  label: 'Notices',
                  subtitle: 'Latest updates\nand circulars',
                  onTap: () => HomeScreen.of(context)?.setCurrentIndex(HomeNavigation.noticesIndex),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickActionCard(
                  iconAsset: 'assets/icons/blog_icon.png',
                  iconBg: AppColors.iconBgTeal,
                  iconColor: AppColors.iconTeal,
                  label: 'Blog',
                  subtitle: 'Insights and\narticles',
                  onTap: () => HomeScreen.of(context)?.setCurrentIndex(HomeNavigation.blogIndex),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickActionCard(
                  iconAsset: 'assets/icons/gallery_icon.png',
                  iconBg: AppColors.iconBgViolet,
                  iconColor: AppColors.iconViolet,
                  label: 'Gallery',
                  subtitle: 'Photos and\nevents',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GalleryScreen())),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickActionCard(
                  iconAsset: 'assets/icons/contact_us.png',
                  iconBg: AppColors.iconBgBlue,
                  iconColor: AppColors.iconBlue,
                  label: 'Contact Us',
                  subtitle: 'Get in touch\nwith us',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactScreen())),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String iconAsset;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.iconAsset,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Center(child: AppAssetIcon(iconAsset, size: 20, color: iconColor)),
              ),
              const SizedBox(height: 8),
              Text(label,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: colorScheme.onSurface),
                  textAlign: TextAlign.center,
                  maxLines: 1),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: TextStyle(fontSize: 9.5, height: 1.2, color: colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                  maxLines: 2),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// LATEST NOTICE CARD
// ═══════════════════════════════════════════════════════════════
class _LatestNoticeCard extends ConsumerWidget {
  const _LatestNoticeCard();

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notices = ref.watch(noticesProvider);
    return notices.when(
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        final WpContentItem item = items.first;
        final d = item.date;
        final dateStr = '${d.day} ${_months[d.month - 1]} ${d.year}';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.noticeCardBg, borderRadius: BorderRadius.circular(20)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'LATEST NOTICE',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.tealDark, letterSpacing: 0.6),
                      ),
                      const SizedBox(height: 4),
                      Text(item.title,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.navy),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const AppAssetIcon('assets/icons/calendar_icon.png', size: 12, color: Color(0xFF6B7280)),
                          const SizedBox(width: 4),
                          Text(dateStr, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.excerpt.isNotEmpty ? item.excerpt : 'Tap Read More for the full notice.',
                        style: const TextStyle(fontSize: 11.5, height: 1.4, color: Color(0xFF4B5563)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ContentDetailScreen(item: item)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Read More', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.tealDark)),
                            SizedBox(width: 2),
                            Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.tealDark),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _noticeGlyph(),
              ],
            ),
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: NoticeCardSkeleton(),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.noticeCardBg, borderRadius: BorderRadius.circular(20)),
          child: Row(
            children: [
              const Expanded(child: Text('Couldn\'t load the latest notice', style: TextStyle(fontSize: 12, color: Color(0xFF4B5563)))),
              GestureDetector(
                onTap: () => ref.invalidate(noticesProvider),
                child: const Text('Retry', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.tealDark)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _noticeGlyph() {
    return SizedBox(
      width: 64,
      height: 80,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                4,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Container(height: 3, width: i.isEven ? 34 : 22, color: const Color(0xFFE5E7EB)),
                ),
              ),
            ),
          ),
          Positioned(
            right: -6,
            bottom: -6,
            child: Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(color: AppColors.teal, shape: BoxShape.circle),
              child: const Icon(Icons.file_download_rounded, size: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// EMPLOYER PORTAL / SELF SERVICE GRADIENT CARDS
// ═══════════════════════════════════════════════════════════════
class _ServicePortalsRow extends StatelessWidget {
  const _ServicePortalsRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _ServicePortalCard(
              gradientStart: AppColors.navy,
              gradientEnd: AppColors.navyLight,
              label: 'EMPLOYER SERVICES',
              title: 'Employer Portal',
              iconAsset: 'assets/icons/employee_portal_icon.png',
              features: const ['Statements', 'Returns', 'Payments', 'Employee Management'],
              buttonLabel: 'Access Portal',
              buttonColor: AppColors.navy,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmployerPortalScreen())),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ServicePortalCard(
              gradientStart: AppColors.tealDark,
              gradientEnd: AppColors.teal,
              label: 'EMPLOYEE SERVICES',
              title: 'Self Service',
              iconAsset: 'assets/icons/self_service_portal.png',
              features: const ['Cases & Disputes', 'Hearings', 'Arbitration', 'Case Tracking'],
              buttonLabel: 'Access Portal',
              buttonColor: AppColors.tealDark,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SelfServiceScreen())),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServicePortalCard extends StatelessWidget {
  final Color gradientStart;
  final Color gradientEnd;
  final String label;
  final String title;
  final String iconAsset;
  final List<String> features;
  final String buttonLabel;
  final Color buttonColor;
  final VoidCallback onTap;

  const _ServicePortalCard({
    required this.gradientStart,
    required this.gradientEnd,
    required this.label,
    required this.title,
    required this.iconAsset,
    required this.features,
    required this.buttonLabel,
    required this.buttonColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [gradientStart, gradientEnd], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label,
                    style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
              ),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), shape: BoxShape.circle),
                child: Center(child: AppAssetIcon(iconAsset, size: 15, color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          ...features.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, size: 13, color: Colors.white),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(f,
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(buttonLabel, style: TextStyle(color: buttonColor, fontSize: 12, fontWeight: FontWeight.w700)),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios_rounded, size: 10, color: buttonColor),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// UPCOMING HEARINGS
// ═══════════════════════════════════════════════════════════════
class _UpcomingHearingsRow extends StatelessWidget {
  const _UpcomingHearingsRow();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SelfServiceScreen())),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(color: AppColors.iconBgBlue, shape: BoxShape.circle),
                  child: const Center(child: AppAssetIcon('assets/icons/calendar_icon.png', size: 19, color: AppColors.iconBlue)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Upcoming Hearings',
                          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
                      const SizedBox(height: 2),
                      Text('No upcoming hearings scheduled',
                          style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
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

// ═══════════════════════════════════════════════════════════════
// LATEST INSIGHTS — horizontal blog list
// ═══════════════════════════════════════════════════════════════
class _LatestInsightsSection extends ConsumerWidget {
  const _LatestInsightsSection();

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(blogPostsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _SectionHeader(
            title: 'Latest Insights',
            onViewAll: () => HomeScreen.of(context)?.setCurrentIndex(HomeNavigation.blogIndex),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: posts.when(
            data: (items) {
              if (items.isEmpty) return const SizedBox.shrink();
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length.clamp(0, 6),
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final item = items[i];
                  final d = item.date;
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ContentDetailScreen(item: item)),
                    ),
                    child: SizedBox(
                      width: 150,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              height: 80,
                              width: 150,
                              child: item.featuredImageUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: item.featuredImageUrl!,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => Container(color: Theme.of(context).colorScheme.surfaceContainerHighest),
                                      errorWidget: (_, __, ___) => Container(color: Theme.of(context).colorScheme.surfaceContainerHighest),
                                    )
                                  : Container(color: Theme.of(context).colorScheme.surfaceContainerHighest),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(item.title,
                              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, height: 1.25, color: Theme.of(context).colorScheme.onSurface),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 3),
                          Text('${d.day} ${_months[d.month - 1]} ${d.year}',
                              style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: const [
                InsightCardSkeleton(),
                SizedBox(width: 12),
                InsightCardSkeleton(),
                SizedBox(width: 12),
                InsightCardSkeleton(),
              ],
            ),
            error: (error, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Couldn\'t load blog posts', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => ref.invalidate(blogPostsProvider),
                    child: const Text('Retry', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.tealDark)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ABOUT NEC MEDICAL
// ═══════════════════════════════════════════════════════════════
class _AboutCard extends ConsumerWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.aboutCardBg, borderRadius: BorderRadius.circular(18)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(color: AppColors.navy, shape: BoxShape.circle),
              child: ClipOval(
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Image.asset('assets/images/nec_logo.png', fit: BoxFit.contain),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('About NEC Medical',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.navy)),
                  const SizedBox(height: 4),
                  const Text(
                    'The National Employment Council for the Medical and Allied Industry '
                    'promotes fair labour practices, resolves disputes and supports the '
                    'growth of a sustainable and harmonious industry.',
                    style: TextStyle(fontSize: 11, height: 1.4, color: Color(0xFF4B5563)),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Learn More', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.tealDark)),
                        SizedBox(width: 2),
                        Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.tealDark),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SHARED
// ═══════════════════════════════════════════════════════════════
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;
  const _SectionHeader({required this.title, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
        GestureDetector(
          onTap: onViewAll,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('View All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.tealDark)),
              SizedBox(width: 2),
              Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.tealDark),
            ],
          ),
        ),
      ],
    );
  }
}
