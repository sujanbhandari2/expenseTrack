enum DashboardFilter {
  daily,
  monthly,
  sixMonths,
  yearly,
}

extension DashboardFilterX on DashboardFilter {
  String get label {
    switch (this) {
      case DashboardFilter.daily:
        return 'Daily';
      case DashboardFilter.monthly:
        return 'Monthly';
      case DashboardFilter.sixMonths:
        return '6 Months';
      case DashboardFilter.yearly:
        return 'Yearly';
    }
  }
}
