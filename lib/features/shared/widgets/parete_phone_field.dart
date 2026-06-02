import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../auth/presentation/widgets/rounded_text_field.dart';

/// Input nomor HP dengan prefix +62 tetap (sama seperti halaman ganti password).
class ParetePhoneField extends StatelessWidget {
  const ParetePhoneField({
    super.key,
    required this.controller,
    this.hint = 'Masukkan nomor telepon',
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
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
            controller: controller,
            hint: hint,
            keyboardType: TextInputType.phone,
            onChanged: onChanged,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(13),
            ],
          ),
        ),
      ],
    );
  }
}
