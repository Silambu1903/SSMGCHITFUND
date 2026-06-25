import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scale = Tween(begin: 0.8, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _ctrl.forward();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Show splash for at least 1.5 s for branding
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    // If Supabase already has a restored session, navigate immediately
    final existing = Supabase.instance.client.auth.currentSession;
    if (existing != null) {
      context.go('/dashboard');
      return;
    }

    // Otherwise wait up to 3 s for the auth stream to emit a session
    // (covers the async localStorage restore on web / token refresh)
    bool resolved = false;
    final sub = Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      if (!mounted || resolved) return;
      resolved = true;
      final hasSession = event.session != null;
      context.go(hasSession ? '/dashboard' : '/login');
    });

    // Fallback: if stream doesn't fire within 3 s, go to login
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted || resolved) {
      await sub.cancel();
      return;
    }
    resolved = true;
    await sub.cancel();
    context.go('/login');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sidebarBg,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.currency_rupee,
                      color: Colors.white, size: 44),
                ),
                const SizedBox(height: 20),
                Text(
                  AppStrings.appName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.appTagline,
                  style: const TextStyle(
                    color: AppColors.textOnDarkMuted,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 40),
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
