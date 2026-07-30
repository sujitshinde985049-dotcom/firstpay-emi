import 'package:firstpay/app/theme/firstpay_spacing.dart';
import 'package:flutter/material.dart';

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: FirstPaySpacing.controlHeight,
      child: FilledButton(onPressed: onPressed, child: Text(label)),
    );
  }
}
