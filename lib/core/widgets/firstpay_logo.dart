import 'package:firstpay/app/theme/firstpay_colors.dart';
import 'package:flutter/material.dart';

class FirstPayLogo extends StatelessWidget {
  const FirstPayLogo({super.key, this.fontSize = 24});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleLarge?.copyWith(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
    );
    return Semantics(
      label: 'FirstPay',
      child: ExcludeSemantics(
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'FIRST',
                style: style?.copyWith(color: FirstPayColors.primaryNavy),
              ),
              TextSpan(
                text: 'PAY',
                style: style?.copyWith(color: FirstPayColors.successGreen),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
