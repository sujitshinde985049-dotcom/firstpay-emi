import 'package:firstpay/features/dashboard/domain/dashboard_view_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dashboardViewDataProvider = Provider<DashboardViewData>((ref) {
  return const DashboardViewData(
    role: DashboardRole.superAdmin,
    lastLogin: 'Today, 09:30 AM IST',
    metrics: [
      DashboardMetric(label: 'Total Patsansthas', value: '24'),
      DashboardMetric(label: 'Total Customers', value: '18,420'),
      DashboardMetric(label: 'Active UPI Mandates', value: '12,860'),
      DashboardMetric(label: 'Active e-NACH Mandates', value: '4,275'),
      DashboardMetric(label: "Today's Mandates", value: '186'),
      DashboardMetric(label: 'Pending Mandates', value: '94'),
    ],
  );
});
