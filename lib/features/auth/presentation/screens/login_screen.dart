import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_contact.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/api/auth_storage.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/services/auth_service.dart';
import '../../../home/presentation/screens/home_dashboard_screen.dart';
import '../../../shared/widgets/parete_bubble_background.dart';
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
  final TextEditingController _familyIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _helpSectionKey = GlobalKey();
  bool _obscurePassword = true;
  bool _submitting = false;
  bool _showFirstLoginHint = true;

  bool get _idFormatValid {
    final t = _familyIdController.text.trim();
    return _familyIdPattern.hasMatch(t);
  }

  bool get _canSubmit {
    if (_submitting) return false;
    if (!AppConfig.authEnabled) return true;
    return _idFormatValid && _passwordController.text.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _familyIdController.addListener(_onFieldsChanged);
    _passwordController.addListener(_onFieldsChanged);
    _loadSavedId();
  }

  Future<void> _loadSavedId() async {
    final saved = await AuthStorage().getIdKeluarga();
    if (saved != null && saved.isNotEmpty && mounted) {
      _familyIdController.text = saved;
    }
    await _refreshLoginHints();
  }

  Future<void> _refreshLoginHints() async {
    if (!AppConfig.authEnabled) {
      if (mounted) setState(() => _showFirstLoginHint = false);
      return;
    }
    final id = _familyIdController.text.trim().toUpperCase();
    if (!_familyIdPattern.hasMatch(id)) {
      if (mounted) setState(() => _showFirstLoginHint = true);
      return;
    }
    final ready = await AuthStorage().isPasswordReady(id);
    if (mounted) setState(() => _showFirstLoginHint = !ready);
  }

  void _onFieldsChanged() {
    _refreshLoginHints();
    setState(() {});
  }

  Future<void> _submitLogin() async {
    if (!_canSubmit) {
      if (AppConfig.authEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Masukkan ID Keluarga (format RT05-2026-001) dan kata sandi dari Admin RT.',
            ),
          ),
        );
      }
      return;
    }
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      final auth = context.read<AuthService>();
      final warga = await auth.login(
        idKeluarga: _familyIdController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      await auth.refreshWarga();
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

  Future<void> _openWhatsApp(Uri uri) async {
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!mounted) return;
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka WhatsApp.')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuka WhatsApp.')),
      );
    }
  }

  void _onLupaAkses() {
    _openWhatsApp(AppContact.adminWhatsAppLupaAkses);
  }

  @override
  void dispose() {
    _familyIdController.removeListener(_onFieldsChanged);
    _passwordController.removeListener(_onFieldsChanged);
    _scrollController.dispose();
    _familyIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleLarge;

    return Scaffold(
      body: PareteBubbleBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 32,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const PareteLogo(variant: PareteLogoVariant.light, height: 48),
                    const SizedBox(height: AppSpacing.sm),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      child: Text(
                        'Akses informasi dan layanan RT dengan lebih mudah',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.98),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 68,
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
                    controller: _scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_showFirstLoginHint) ...[
                          const _LoginStepIndicator(),
                          const SizedBox(height: AppSpacing.lg),
                        ] else ...[
                          Text(
                            'Masuk ke akun Anda',
                            style: titleStyle?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkBlueText,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                        Text('ID Keluarga', style: titleStyle),
                        const SizedBox(height: AppSpacing.xs),
                        RoundedTextField(
                          controller: _familyIdController,
                          hint: 'RT05-2026-001',
                          prefixIcon: Icons.person_outline_rounded,
                          textCapitalization: TextCapitalization.characters,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _idFormatValid
                              ? (_showFirstLoginHint
                                  ? 'Format ID benar — pastikan sudah terdaftar di Admin RT'
                                  : 'Masukkan kata sandi yang sudah Anda buat sebelumnya')
                              : 'ID diberikan oleh Admin RT saat pendaftaran warga',
                          style: TextStyle(
                            color: _idFormatValid ? AppColors.primaryBlue : AppColors.mutedText,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text('Kata Sandi', style: titleStyle),
                        const SizedBox(height: AppSpacing.xs),
                        RoundedTextField(
                          controller: _passwordController,
                          hint: _showFirstLoginHint
                              ? 'Masukkan kata sandi'
                              : 'Kata sandi Anda',
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
                        if (_showFirstLoginHint)
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
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm + 2),
                            decoration: BoxDecoration(
                              color: AppColors.lightBlueBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.lock_reset_rounded, color: AppColors.primaryBlue, size: 20),
                                SizedBox(width: AppSpacing.xs),
                                Expanded(
                                  child: Text(
                                    'Gunakan kata sandi pribadi yang sudah Anda buat. '
                                    'Jika lupa, hubungi Admin RT lewat "lupa akses?" di bawah.',
                                    style: TextStyle(
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
                        const SizedBox(height: AppSpacing.lg),
                        PrimaryButton(
                          label: _submitting ? 'Memproses...' : 'Masuk',
                          onPressed: _canSubmit ? _submitLogin : null,
                          expanded: true,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _LupaAksesDivider(onTap: _onLupaAkses),
                        const SizedBox(height: AppSpacing.md),
                        KeyedSubtree(
                          key: _helpSectionKey,
                          child: _WhatsAppHelpCard(
                            onTap: () => _openWhatsApp(AppContact.adminWhatsApp),
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

class _LupaAksesDivider extends StatelessWidget {
  const _LupaAksesDivider({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const line = AppColors.border;
    const labelStyle = TextStyle(
      color: AppColors.primaryBlue,
      fontWeight: FontWeight.w700,
      fontSize: 14,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.primaryBlue,
    );

    return Row(
      children: [
        const Expanded(child: Divider(color: line, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text('lupa akses?', style: labelStyle),
            ),
          ),
        ),
        const Expanded(child: Divider(color: line, height: 1)),
      ],
    );
  }
}

class _WhatsAppHelpCard extends StatelessWidget {
  const _WhatsAppHelpCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 4,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.chat_rounded, color: Color(0xFF25D366), size: 24),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Butuh bantuan masuk?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.darkBlueText,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            height: 1.35,
                          ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Hubungi Admin RT via WhatsApp',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
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
  const _LoginStepIndicator();

  @override
  Widget build(BuildContext context) {
    const active = AppColors.primaryBlue;
    const inactiveFill = Color(0xFFE8ECF2);
    const inactiveText = AppColors.mutedText;
    const line = AppColors.border;

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
