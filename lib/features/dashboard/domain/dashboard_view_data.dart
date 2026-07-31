enum DashboardRole {
  superAdmin('Super Admin'),
  patsansthaAdmin('Patsanstha Admin');

  const DashboardRole(this.label);

  final String label;
}

class DashboardMetric {
  const DashboardMetric({required this.label, required this.value});

  final String label;
  final String value;
}

class DashboardViewData {
  const DashboardViewData({
    required this.role,
    required this.lastLogin,
    required this.metrics,
  });

  final DashboardRole role;
  final String lastLogin;
  final List<DashboardMetric> metrics;
}
