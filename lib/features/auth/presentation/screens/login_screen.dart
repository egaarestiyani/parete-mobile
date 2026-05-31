import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/services/auth_service.dart';
import '../../../home/presentation/screens/home_dashboard_screen.dart';
import '../../../shared/widgets/parete_logo.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../presentation/widgets/rounded_text_field.dart';
import 'change_password_screen.dart';

/// Format contoh: RT05-2026-087
final RegExp _familyIdPattern = RegExp(r'^RT\d{2}-\d{4}-\d{3}$', caseSensitive: false);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color _headerBlue = Color(0xFF3A8FD9);

  final TextEditingController _familyIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _submitting = false;

  bool get _idRegistered {
    final t = _familyIdController.text.trim();
    return _familyIdPattern.hasMatch(t);
  }

  @override
  void initState() {
    super.initState();
    _familyIdController.addListener(_onFieldsChanged);
    _passwordController.addListener(_onFieldsChanged);
  }

  void _onFieldsChanged() => setState(() {});

  Future<void> _submitLogin() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      final auth = context.read<AuthService>();
      final warga = await auth.login(
        idKeluarga: _familyIdController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      if (warga.harusGantiPassword) {
        Navigator.pushReplacementNamed(context, ChangePasswordScreen.routeName);
      } else {
        Navigator.pushReplacementNamed(context, HomeDashboardScreen.routeName);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _familyIdController.removeListener(_onFieldsChanged);
    _passwordController.removeListener(_onFieldsChanged);
    _familyIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleLarge;

    return Scaffold(
      body: ColoredBox(
        color: _headerBlue,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 28),
              const Center(
                child: PareteLogo(variant: PareteLogoVariant.light, height: 52),
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Akses informasi dan layanan RT\ndengan lebih mudah',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _LoginStepIndicator(),
                        const SizedBox(height: AppSpacing.xl),
                        Text('ID Keluarga', style: titleStyle),
                        const SizedBox(height: AppSpacing.xs),
                        RoundedTextField(
                          controller: _familyIdController,
                          hint: 'Masukkan nama pengguna',
                          prefixIcon: Icons.person_outline_rounded,
                          suffixIcon: _idRegistered
                              ? const Icon(Icons.check_circle, color: AppColors.green, size: 22)
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _idRegistered
                              ? 'ID terdaftar'
                              : 'ID diberikan oleh Admin RT saat pendaftaran',
                          style: TextStyle(
                            color: _idRegistered ? AppColors.green : AppColors.mutedText,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text('Kata Sandi', style: titleStyle),
                        const SizedBox(height: AppSpacing.xs),
                        RoundedTextField(
                          controller: _passwordController,
                          hint: 'Masukkan kata sandi',
                          obscureText: _obscurePassword,
                          prefixIcon: Icons.lock_outline_rounded,
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: const Color(0xFF8C96AB),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm + 2),
                          decoration: BoxDecoration(
                            color: AppColors.warningBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFF6E09A)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline, color: AppColors.warningText, size: 20),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    style: const TextStyle(
                                      color: AppColors.warningText,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      height: 1.35,
                                    ),
                                    children: const [
                                      TextSpan(text: 'Password awal kamu adalah '),
                                      TextSpan(
                                        text: 'warga123',
                                        style: TextStyle(fontWeight: FontWeight.w800),
                                      ),
                                      TextSpan(
                                        text:
                                            '. Kamu akan diminta menggantinya setelah login pertama.',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        PrimaryButton(
                          label: _submitting ? 'Memproses...' : 'Masuk',
                          onPressed: _submitting ? null : _submitLogin,
                          expanded: true,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Center(
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.mutedText,
                              textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('lupa akses?'),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm + 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.chat_rounded, color: AppColors.green, size: 22),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  'Butuh bantuan masuk? Hubungi Admin RT via WhatsApp',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppColors.darkBlueText,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        height: 1.35,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginStepIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const active = AppColors.primaryBlue;
    const inactiveFill = Color(0xFFE8ECF2);
    const inactiveText = Color(0xFF9AA3B5);
    const line = Color(0xFFDDE3EE);

    Widget circle(String label, {required bool isActive}) {
      return Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? active : inactiveFill,
          shape: BoxShape.circle,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : inactiveText,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      );
    }

    return Row(
      children: [
        circle('1', isActive: true),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Container(height: 2, color: line),
          ),
        ),
        circle('2', isActive: false),
      ],
    );
  }
}
