import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/services/auth_service.dart';
import '../../../home/presentation/screens/home_dashboard_screen.dart';
import '../../../shared/widgets/parete_logo.dart';
import '../../../shared/widgets/primary_button.dart';
import '../widgets/rounded_text_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  static const String routeName = '/change-password';

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  static const Color _headerBlue = Color(0xFF3A8FD9);

  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_onChanged);
    _confirmPasswordController.addListener(_onChanged);
    _phoneController.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _newPasswordController.removeListener(_onChanged);
    _confirmPasswordController.removeListener(_onChanged);
    _phoneController.removeListener(_onChanged);
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String get _newPw => _newPasswordController.text;

  bool get _ruleMin8 => _newPw.length >= 8;
  bool get _ruleUpper => RegExp('[A-Z]').hasMatch(_newPw);
  bool get _ruleDigit => RegExp('[0-9]').hasMatch(_newPw);
  bool get _ruleSpecial => RegExp(r'[^A-Za-z0-9]').hasMatch(_newPw);

  int get _rulesPassed =>
      (_ruleMin8 ? 1 : 0) + (_ruleUpper ? 1 : 0) + (_ruleDigit ? 1 : 0) + (_ruleSpecial ? 1 : 0);

  bool get _allRulesMet => _rulesPassed == 4;

  bool get _showPasswordHints => _newPw.isNotEmpty;

  bool get _passwordsMatch =>
      _newPasswordController.text.isNotEmpty &&
      _newPasswordController.text == _confirmPasswordController.text;

  bool get _phoneFilled => _phoneController.text.trim().isNotEmpty;

  bool get _canSubmit => _allRulesMet && _passwordsMatch && _phoneFilled;

  Future<void> _submit() async {
    if (!_canSubmit || _submitting) return;
    setState(() => _submitting = true);
    try {
      await context.read<AuthService>().changePassword(
            passwordBaru: _newPasswordController.text,
            nomorHp: _phoneController.text.trim(),
          );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, HomeDashboardScreen.routeName);
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
                        _ChangePasswordStepIndicator(),
                        const SizedBox(height: AppSpacing.lg),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm + 2),
                          decoration: BoxDecoration(
                            color: AppColors.warningBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFF6E09A)),
                          ),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.lock_outline_rounded, color: AppColors.warningText, size: 20),
                              SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  'Kamu masih menggunakan kata sandi default. Ganti sekarang untuk keamanan akunmu.',
                                  style: TextStyle(
                                    color: AppColors.warningText,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text('Kata Sandi Baru', style: titleStyle),
                        const SizedBox(height: AppSpacing.xs),
                        RoundedTextField(
                          controller: _newPasswordController,
                          hint: 'Masukkan kata sandi',
                          obscureText: _obscureNew,
                          prefixIcon: Icons.lock_outline_rounded,
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _obscureNew = !_obscureNew),
                            icon: Icon(
                              _obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: const Color(0xFF8C96AB),
                            ),
                          ),
                        ),
                        if (_showPasswordHints) ...[
                          const SizedBox(height: AppSpacing.sm),
                          _PasswordStrengthMeter(filledSegments: _rulesPassed),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            _allRulesMet ? 'Kata sandi cukup kuat' : 'Lengkapi syarat kata sandi di bawah',
                            style: TextStyle(
                              color: _allRulesMet ? AppColors.green : AppColors.mutedText,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _PasswordRuleRow(
                                text: 'Minimal 8 karakter',
                                met: _ruleMin8,
                              ),
                              _PasswordRuleRow(
                                text: 'Mengandung huruf besar',
                                met: _ruleUpper,
                              ),
                              _PasswordRuleRow(
                                text: 'Mengandung angka',
                                met: _ruleDigit,
                              ),
                              _PasswordRuleRow(
                                text: 'Mengandung karakter khusus',
                                met: _ruleSpecial,
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        Text('Konfirmasi Kata Sandi', style: titleStyle),
                        const SizedBox(height: AppSpacing.xs),
                        RoundedTextField(
                          controller: _confirmPasswordController,
                          hint: 'Masukkan kata sandi',
                          obscureText: _obscureConfirm,
                          prefixIcon: Icons.lock_outline_rounded,
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                            icon: Icon(
                              _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: const Color(0xFF8C96AB),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text('Nomor HP', style: titleStyle),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 52,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('🇮🇩', style: TextStyle(fontSize: 18)),
                                  SizedBox(width: 6),
                                  Text(
                                    '+62',
                                    style: TextStyle(
                                      color: AppColors.darkBlueText,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: RoundedTextField(
                                controller: _phoneController,
                                hint: 'Masukkan nomor telepon',
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        PrimaryButton(
                          label: _submitting ? 'Menyimpan...' : 'Simpan dan Lanjut',
                          onPressed: _canSubmit && !_submitting ? _submit : null,
                          expanded: true,
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

class _ChangePasswordStepIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const line = Color(0xFFDDE3EE);

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle),
          child: const Icon(Icons.check, color: Colors.white, size: 18),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Container(height: 2, color: line),
          ),
        ),
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.primaryBlue,
            shape: BoxShape.circle,
          ),
          child: const Text(
            '2',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ),
      ],
    );
  }
}

class _PasswordStrengthMeter extends StatelessWidget {
  const _PasswordStrengthMeter({required this.filledSegments});

  /// 0–4 segmen terisi hijau sesuai jumlah syarat yang terpenuhi.
  final int filledSegments;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (i) {
        final active = i < filledSegments;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < 3 ? 4 : 0),
            child: Container(
              height: 5,
              decoration: BoxDecoration(
                color: active ? AppColors.green : AppColors.border,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _PasswordRuleRow extends StatelessWidget {
  const _PasswordRuleRow({required this.text, required this.met});

  final String text;
  final bool met;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: met
                ? const Icon(Icons.check_circle, size: 18, color: AppColors.green)
                : Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFB8C0D4), width: 1.5),
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: met ? AppColors.green : AppColors.mutedText,
                fontWeight: FontWeight.w600,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
