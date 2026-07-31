import 'package:flutter/material.dart';

enum DashboardDestination {
  dashboard('Dashboard', Icons.dashboard_outlined),
  patsansthas('Patsansthas', Icons.account_balance_outlined),
  customers('Customers', Icons.people_outline),
  upiAutopay('UPI AutoPay', Icons.autorenew_outlined),
  eNach('e-NACH', Icons.account_balance_wallet_outlined),
  reports('Reports', Icons.assessment_outlined),
  settings('Settings', Icons.settings_outlined);

  const DashboardDestination(this.label, this.icon);
  final String label;
  final IconData icon;
}
