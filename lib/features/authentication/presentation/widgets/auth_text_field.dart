import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.requiredMessage,
    super.key,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.autofillHints,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String requiredMessage;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Iterable<String>? autofillHints;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      autofillHints: autofillHints,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
      ),
      validator: (value) =>
          value == null || value.trim().isEmpty ? requiredMessage : null,
    );
  }
}
