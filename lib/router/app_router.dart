import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../presentation/screens/auth/splash_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/dashboard/dashboard_screen.dart';
import '../presentation/screens/members/members_screen.dart';
import '../presentation/screens/members/member_detail_screen.dart';
import '../presentation/screens/members/add_member_screen.dart';
import '../presentation/screens/chits/chits_screen.dart';
import '../presentation/screens/chits/chit_detail_screen.dart';
import '../presentation/screens/chits/create_chit_screen.dart';
import '../presentation/screens/auctions/auctions_screen.dart';
import '../presentation/screens/auctions/auction_detail_screen.dart';
import '../presentation/screens/auctions/record_auction_screen.dart';
import '../presentation/screens/payments/payments_screen.dart';
import '../presentation/screens/payments/record_payment_screen.dart';
import '../presentation/screens/reports/reports_screen.dart';
import '../presentation/screens/settlements/settlements_screen.dart';
import '../presentation/layouts/app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = _AuthChangeNotifier(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final isSplash = state.matchedLocation == '/splash';
      final isLogin = state.matchedLocation == '/login';

      // Don't interrupt the splash – it handles its own navigation
      if (isSplash) return null;

      // While auth stream is still loading, stay put (avoid premature /login redirect)
      final authAsync = ref.read(authStateProvider);
      if (authAsync.isLoading) return null;

      final isAuthenticated = ref.read(isAuthenticatedProvider);
      if (!isAuthenticated && !isLogin) return '/login';
      if (isAuthenticated && isLogin) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (_, __) => _fadePage(const DashboardScreen()),
          ),
          GoRoute(
            path: '/members',
            pageBuilder: (_, __) => _fadePage(const MembersScreen()),
            routes: [
              GoRoute(
                path: 'add',
                pageBuilder: (ctx, state) => _fadePage(
                  AddMemberScreen(
                    fromChitId: state.uri.queryParameters['fromChit'],
                  ),
                ),
              ),
              GoRoute(
                path: ':id',
                pageBuilder: (ctx, state) => _fadePage(
                  MemberDetailScreen(
                      memberId: state.pathParameters['id']!),
                ),
                routes: [
                  GoRoute(
                    path: 'edit',
                    pageBuilder: (ctx, state) => _fadePage(
                      AddMemberScreen(
                          editId: state.pathParameters['id']),
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/chits',
            pageBuilder: (_, __) => _fadePage(const ChitsScreen()),
            routes: [
              GoRoute(
                path: 'create',
                pageBuilder: (_, __) =>
                    _fadePage(const CreateChitScreen()),
              ),
              GoRoute(
                path: ':id',
                pageBuilder: (ctx, state) => _fadePage(
                  ChitDetailScreen(chitId: state.pathParameters['id']!),
                ),
                routes: [
                  GoRoute(
                    path: 'edit',
                    pageBuilder: (ctx, state) => _fadePage(
                      CreateChitScreen(
                          editId: state.pathParameters['id']),
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/auctions',
            pageBuilder: (_, __) => _fadePage(const AuctionsScreen()),
            routes: [
              GoRoute(
                path: 'new',
                pageBuilder: (ctx, state) => _fadePage(
                  RecordAuctionScreen(
                    initialChitId: state.uri.queryParameters['chit'],
                  ),
                ),
              ),
              GoRoute(
                path: ':id',
                pageBuilder: (ctx, state) => _fadePage(
                  AuctionDetailScreen(
                      auctionId: state.pathParameters['id']!),
                ),
                routes: [
                  GoRoute(
                    path: 'edit',
                    pageBuilder: (ctx, state) => _fadePage(
                      RecordAuctionScreen(
                          editId: state.pathParameters['id']),
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/payments',
            pageBuilder: (_, __) => _fadePage(const PaymentsScreen()),
            routes: [
              GoRoute(
                path: 'record',
                pageBuilder: (ctx, state) {
                  final extra =
                      state.extra as Map<String, String>?;
                  return _fadePage(RecordPaymentScreen(
                    memberId: extra?['member_id'],
                    chitId: extra?['chit_id'],
                    paymentId: extra?['payment_id'],
                  ));
                },
              ),
            ],
          ),
          GoRoute(
            path: '/reports',
            pageBuilder: (_, __) => _fadePage(const ReportsScreen()),
          ),
          GoRoute(
            path: '/settlements',
            pageBuilder: (_, __) =>
                _fadePage(const SettlementsScreen()),
          ),
        ],
      ),
    ],
  );
});

CustomTransitionPage<void> _fadePage(Widget child) {
  return CustomTransitionPage<void>(
    child: child,
    transitionsBuilder: (context, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
  }
}
