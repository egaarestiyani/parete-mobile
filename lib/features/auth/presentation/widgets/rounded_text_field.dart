import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RoundedTextField extends StatelessWidget {
  const RoundedTextField({
    required this.hint,
    this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.controller,
    this.onChanged,
    this.focusNode,
    this.readOnly = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.prefix,
    super.key,
  });

  final String hint;
  final IconData? prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final bool readOnly;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  /// When set, replaces [prefixIcon] (e.g. flag + dial code row).
  final Widget? prefix;

  @override
  Widget build(BuildContext context) {
    final Widget? prefixWidget = prefix ??
        (prefixIcon == null ? null : Icon(prefixIcon, color: const Color(0xFF8C96AB)));

    return TextField(
      controller: controller,
      onChanged: onChanged,
      focusNode: focusNode,
      readOnly: readOnly,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: prefixWidget,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
