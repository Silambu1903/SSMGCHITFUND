import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/login_util.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/language_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierCtrl =
      TextEditingController(text: AppStrings.adminLoginPhone);
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(loginProvider.notifier).login(
          _identifierCtrl.text.trim(),
          _passCtrl.text,
        );
    if (ok && mounted) context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(languageProvider);
    final loginState = ref.watch(loginProvider);
    final isLoading = loginState.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;
          if (isWide) {
            return Row(
              children: [
                Expanded(flex: 55, child: _HeroPanel(isCompact: false)),
                Expanded(
                  flex: 45,
                  child: _LoginPanel(
                    formKey: _formKey,
                    identifierCtrl: _identifierCtrl,
                    passCtrl: _passCtrl,
                    obscure: _obscure,
                    rememberMe: _rememberMe,
                    isLoading: isLoading,
                    loginState: loginState,
                    onToggleObscure: () =>
                        setState(() => _obscure = !_obscure),
                    onRememberChanged: (v) =>
                        setState(() => _rememberMe = v ?? false),
                    onSubmit: _submit,
                  ),
                ),
              ],
            );
          }
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                children: [
                  SizedBox(
                    height: 280,
                    child: _HeroPanel(isCompact: true),
                  ),
                  _LoginPanel(
                    formKey: _formKey,
                    identifierCtrl: _identifierCtrl,
                    passCtrl: _passCtrl,
                    obscure: _obscure,
                    rememberMe: _rememberMe,
                    isLoading: isLoading,
                    loginState: loginState,
                    onToggleObscure: () =>
                        setState(() => _obscure = !_obscure),
                    onRememberChanged: (v) =>
                        setState(() => _rememberMe = v ?? false),
                    onSubmit: _submit,
                    embedded: true,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  final bool isCompact;
  const _HeroPanel({required this.isCompact});

  static const _gold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/login_ganesha_bg.png',
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.45),
                Colors.black.withValues(alpha: 0.72),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            isCompact ? 28 : 48,
            isCompact ? 32 : 48,
            isCompact ? 28 : 48,
            isCompact ? 24 : 48,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 44,
                height: 3,
                decoration: BoxDecoration(
                  color: _gold,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.loginBrandName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isCompact ? 22 : 32,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                  letterSpacing: 0.2,
                ),
              ),
              if (!isCompact) ...[
                const SizedBox(height: 36),
                Wrap(
                  spacing: 32,
                  runSpacing: 20,
                  children: [
                    _FeatureChip(
                      icon: Icons.verified_user_outlined,
                      label: AppStrings.loginFeatureSafe,
                    ),
                    _FeatureChip(
                      icon: Icons.trending_up_rounded,
                      label: AppStrings.loginFeatureGrowth,
                    ),
                    _FeatureChip(
                      icon: Icons.savings_outlined,
                      label: AppStrings.loginFeatureSavings,
                    ),
                    _FeatureChip(
                      icon: Icons.support_agent_outlined,
                      label: AppStrings.loginFeatureSupport,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureChip({required this.icon, required this.label});

  static const _gold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Row(
        children: [
          Icon(icon, color: _gold, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginPanel extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController identifierCtrl;
  final TextEditingController passCtrl;
  final bool obscure;
  final bool rememberMe;
  final bool isLoading;
  final AsyncValue<void> loginState;
  final VoidCallback onToggleObscure;
  final ValueChanged<bool?> onRememberChanged;
  final VoidCallback onSubmit;
  final bool embedded;

  const _LoginPanel({
    required this.formKey,
    required this.identifierCtrl,
    required this.passCtrl,
    required this.obscure,
    required this.rememberMe,
    required this.isLoading,
    required this.loginState,
    required this.onToggleObscure,
    required this.onRememberChanged,
    required this.onSubmit,
    this.embedded = false,
  });

  static const _navy = Color(0xFF002147);
  static const _loginBg = Color(0xFFF4F6F9);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _loginBg,
      child: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: embedded ? 24 : 40,
                vertical: embedded ? 24 : 32,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Material(
                  elevation: embedded ? 2 : 8,
                  shadowColor: Colors.black.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 36, 32, 32),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppStrings.loginWelcomeTitle,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: _navy,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppStrings.loginWelcomeSubtitle,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 28),
                          if (loginState.hasError) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: AppColors.errorLight,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.error
                                      .withValues(alpha: 0.25),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline,
                                      color: AppColors.error, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      loginState.error.toString(),
                                      style: const TextStyle(
                                        color: AppColors.error,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          Text(
                            AppStrings.loginPhoneLabel,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: identifierCtrl,
                            keyboardType: TextInputType.emailAddress,
                            enabled: !isLoading,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[\w@.+-\s]')),
                            ],
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return AppStrings.enterEmailOrMobile;
                              }
                              if (!isValidLoginIdentifier(v)) {
                                return AppStrings.invalidEmailOrMobile;
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: AppStrings.loginPhoneHint,
                              prefixIcon: const Icon(Icons.person_outline,
                                  size: 20, color: AppColors.textMuted),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: AppColors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: _navy, width: 1.5),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 14),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            AppStrings.password,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: passCtrl,
                            obscureText: obscure,
                            enabled: !isLoading,
                            validator: (v) => (v?.isEmpty ?? true)
                                ? AppStrings.enterPassword
                                : null,
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              prefixIcon: const Icon(Icons.lock_outline,
                                  size: 20, color: AppColors.textMuted),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscure
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 20,
                                  color: AppColors.textMuted,
                                ),
                                onPressed: onToggleObscure,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: AppColors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: _navy, width: 1.5),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 14),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              SizedBox(
                                height: 36,
                                child: Checkbox(
                                  value: rememberMe,
                                  onChanged: onRememberChanged,
                                  activeColor: _navy,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      onRememberChanged(!rememberMe),
                                  child: Text(
                                    AppStrings.rememberMe,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  AppStrings.forgotPassword,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: _navy,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : onSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _navy,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          AppStrings.loginSignIn,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.arrow_forward,
                                            size: 18),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              onPressed: () {},
              icon: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                  color: Colors.white,
                ),
                child: const Icon(Icons.help_outline,
                    size: 16, color: AppColors.textMuted),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Column(
              children: [
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 20,
                  runSpacing: 4,
                  children: [
                    _FooterLink(label: AppStrings.privacyPolicy),
                    _FooterLink(label: AppStrings.terms),
                    _FooterLink(label: AppStrings.security),
                    _FooterLink(label: AppStrings.help),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.loginCopyright,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String label;
  const _FooterLink({required this.label});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}
