import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/responsive.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';

class AppShell extends ConsumerWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = Responsive.isMobile(context);

    if (isMobile) {
      return _MobileShell(child: child);
    }
    return _DesktopShell(child: child);
  }
}

// Desktop: persistent left sidebar
class _DesktopShell extends ConsumerWidget {
  final Widget child;
  const _DesktopShell({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          _Sidebar(),
          Expanded(
            child: Column(
              children: [
                _TopBar(),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Mobile: drawer navigation
class _MobileShell extends ConsumerStatefulWidget {
  final Widget child;
  const _MobileShell({required this.child});

  @override
  ConsumerState<_MobileShell> createState() => _MobileShellState();
}

class _MobileShellState extends ConsumerState<_MobileShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: Drawer(
        backgroundColor: AppColors.sidebarBg,
        child: _SidebarContent(),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TopBar(
              onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(child: widget.child),
          ],
        ),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: AppColors.sidebarBg,
      child: _SidebarContent(),
    );
  }
}

class _SidebarContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(languageProvider);
    final location = GoRouterState.of(context).matchedLocation;

    return Column(
      children: [
        // Logo
        Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.currency_rupee,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.appName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    AppStrings.enterprise,
                    style: const TextStyle(
                      color: AppColors.textOnDarkMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(color: Colors.white12, height: 1),
        const SizedBox(height: 8),

        // Nav items
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            children: [
              _NavItem(
                icon: Icons.dashboard_outlined,
                label: AppStrings.dashboard,
                route: '/dashboard',
                active: location.startsWith('/dashboard'),
              ),
              _NavItem(
                icon: Icons.people_alt_outlined,
                label: AppStrings.customers,
                route: '/members',
                active: location.startsWith('/members'),
              ),
              _NavItem(
                icon: Icons.savings_outlined,
                label: AppStrings.chitFunds,
                route: '/chits',
                active: location.startsWith('/chits'),
              ),
              _NavItem(
                icon: Icons.gavel_outlined,
                label: AppStrings.auctions,
                route: '/auctions',
                active: location.startsWith('/auctions'),
              ),
              _NavItem(
                icon: Icons.payments_outlined,
                label: AppStrings.payments,
                route: '/payments',
                active: location.startsWith('/payments'),
              ),
              _NavItem(
                icon: Icons.handshake_outlined,
                label: AppStrings.settlements,
                route: '/settlements',
                active: location.startsWith('/settlements'),
              ),
              _NavItem(
                icon: Icons.bar_chart_outlined,
                label: AppStrings.reports,
                route: '/reports',
                active: location.startsWith('/reports'),
              ),
            ],
          ),
        ),

        const Divider(color: Colors.white12, height: 1),
        // Bottom actions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            children: [
              _NavItem(
                icon: Icons.help_outline,
                label: AppStrings.helpCenter,
                route: '/help',
                active: false,
              ),
              _NavItem(
                icon: Icons.logout,
                label: AppStrings.logout,
                route: '/logout',
                active: false,
                onTap: () async {
                  await ref.read(loginProvider.notifier).logout();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool active;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.active,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: active
          ? BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.3)),
            )
          : null,
      child: ListTile(
        dense: true,
        leading: Icon(
          icon,
          color: active ? AppColors.primaryLight : AppColors.textOnDarkMuted,
          size: 18,
        ),
        title: Text(
          label,
          style: TextStyle(
            color:
                active ? Colors.white : AppColors.textOnDarkMuted,
            fontSize: 13,
            fontWeight:
                active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onTap: onTap ?? () => context.go(route),
        minLeadingWidth: 20,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      ),
    );
  }
}

class _TopBar extends ConsumerWidget {
  final VoidCallback? onMenuTap;
  const _TopBar({this.onMenuTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = Responsive.isMobile(context);
    final compact = Responsive.width(context) < 400;
    final lang = ref.watch(languageProvider);

    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : (isMobile ? 12 : 20),
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (isMobile) ...[
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: onMenuTap,
            ),
            const SizedBox(width: 8),
          ],
          // Page title via route
          Expanded(
            child: _RouteTitle(),
          ),
          if (!isMobile) const Spacer(),
          if (isMobile) const SizedBox(width: 4),
          // Search
          if (!isMobile)
            Container(
              width: 220,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(Icons.search,
                      size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.search,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(width: 12),

          // Language toggle
          GestureDetector(
            onTap: () =>
                ref.read(languageProvider.notifier).toggleLanguage(),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.chipBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                lang == AppLanguage.tamil ? 'EN' : 'த',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          if (!compact) ...[
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined,
                      color: AppColors.textSecondary),
                  onPressed: () {},
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined,
                  color: AppColors.textSecondary),
              onPressed: () {},
            ),
          ],

          // Avatar
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary,
            child: Text(
              'A',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteTitle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(languageProvider);
    final location = GoRouterState.of(context).matchedLocation;
    String title = '';
    String subtitle = '';

    if (location.startsWith('/dashboard')) {
      title = AppStrings.dashboard;
    } else if (location.contains('/members/add')) {
      title = AppStrings.newMember;
    } else if (location.startsWith('/members')) {
      title = AppStrings.customers;
    } else if (location.contains('/chits/create')) {
      title = AppStrings.createNewChit;
      subtitle = AppStrings.createChit;
    } else if (location.startsWith('/chits')) {
      title = AppStrings.chitFunds;
    } else if (location.contains('/auctions/new')) {
      title = AppStrings.monthlyAuctionEntry;
      subtitle = AppStrings.recordAuctionSubtitle;
    } else if (RegExp(r'/auctions/[^/]+$').hasMatch(location)) {
      title = AppStrings.auctionDetailTitle;
    } else if (location.startsWith('/auctions')) {
      title = AppStrings.auctions;
    } else if (location.startsWith('/payments')) {
      title = AppStrings.payments;
    } else if (location.startsWith('/reports')) {
      title = AppStrings.reports;
    } else if (location.startsWith('/settlements')) {
      title = AppStrings.settlements;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (subtitle.isNotEmpty)
          Text(subtitle,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.textMuted)),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
