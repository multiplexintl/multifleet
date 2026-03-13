enum ReportCategory {
  vehicle('Vehicle Reports', 'Fleet inventory and analytics'),
  document('Document Reports', 'Compliance and expiry tracking'),
  fine('Fine Reports', 'Traffic violations and penalties'),
  maintenance('Maintenance Reports', 'Service history and costs'),
  assignment('Assignment Reports', 'Vehicle-employee assignments'),
  financial('Financial Reports', 'Cost analysis and budgeting'),
  operational('Operational Reports', 'Efficiency and performance'),
  tyre('Tyre Reports', 'Tyre inventory and maintenance');

  final String label, description;
  const ReportCategory(this.label, this.description);
}

enum ReportType {
  // Vehicle Reports
  fleetInventory(ReportCategory.vehicle, 'Fleet Inventory',
      'Complete list of all vehicles'),
  vehicleStatus(
      ReportCategory.vehicle, 'Vehicle Status Summary', 'Breakdown by status'),
  mileageReport(
      ReportCategory.vehicle, 'Mileage Report', 'Odometer and distance'),
  vehicleUtilization(
      ReportCategory.vehicle, 'Vehicle Utilization', 'Usage patterns'),
  vehicleAgeAnalysis(
      ReportCategory.vehicle, 'Vehicle Age Analysis', 'Age distribution'),

  // Document Reports
  documentExpirySummary(ReportCategory.document, 'Document Expiry Summary',
      'Documents by expiry'),
  complianceStatus(
      ReportCategory.document, 'Compliance Status', 'Fleet compliance %'),
  documentRenewalSchedule(
      ReportCategory.document, 'Renewal Schedule', 'Upcoming renewals'),
  missingDocuments(
      ReportCategory.document, 'Missing Documents', 'Incomplete documentation'),
  expiredDocuments(
      ReportCategory.document, 'Expired Documents', 'Past due documents'),

  // Fine Reports
  fineSummary(ReportCategory.fine, 'Fine Summary', 'Overall fine statistics'),
  fineByEmployee(
      ReportCategory.fine, 'Fines by Employee', 'Distribution by employee'),
  fineByVehicle(
      ReportCategory.fine, 'Fines by Vehicle', 'Distribution by vehicle'),
  fineByEmirate(
      ReportCategory.fine, 'Fines by Emirate', 'Geographic distribution'),
  fineByType(ReportCategory.fine, 'Fines by Type', 'Violation breakdown'),
  unpaidFines(ReportCategory.fine, 'Unpaid Fines', 'Outstanding fines'),
  fineTrends(ReportCategory.fine, 'Fine Trends', 'Monthly/quarterly trends'),

  // Maintenance Reports
  maintenanceCostAnalysis(
      ReportCategory.maintenance, 'Cost Analysis', 'Cost breakdown'),
  serviceHistory(ReportCategory.maintenance, 'Service History',
      'Complete maintenance log'),
  upcomingMaintenance(
      ReportCategory.maintenance, 'Upcoming Maintenance', 'Scheduled services'),
  overdueMaintenance(
      ReportCategory.maintenance, 'Overdue Maintenance', 'Missed services'),
  maintenanceByVendor(
      ReportCategory.maintenance, 'By Vendor', 'Garage/vendor breakdown'),

  // Assignment Reports
  currentAssignments(
      ReportCategory.assignment, 'Current Assignments', 'Active assignments'),
  assignmentHistory(
      ReportCategory.assignment, 'Assignment History', 'Change log'),
  unassignedVehicles(
      ReportCategory.assignment, 'Unassigned Vehicles', 'Without assignment'),
  assignmentByDepartment(
      ReportCategory.assignment, 'By Department', 'Department distribution'),

  // Financial Reports
  totalCostOwnership(ReportCategory.financial, 'Total Cost of Ownership',
      'Complete cost analysis'),
  monthlyExpenses(
      ReportCategory.financial, 'Monthly Expenses', 'Monthly breakdown'),
  fineExpenses(ReportCategory.financial, 'Fine Expenses', 'Traffic fine costs'),
  maintenanceExpenses(
      ReportCategory.financial, 'Maintenance Expenses', 'Service costs'),

  // Operational Reports
  fleetEfficiency(
      ReportCategory.operational, 'Fleet Efficiency', 'Performance metrics'),
  downtimeAnalysis(ReportCategory.operational, 'Downtime Analysis',
      'Unavailability tracking'),
  vehicleAssignmentStatus(
      ReportCategory.operational, 'Assignment Status', 'Fleet deployment'),

  // Tyre Reports
  tyreInventory(ReportCategory.tyre, 'Tyre Inventory', 'Stock and status'),
  tyreCostAnalysis(
      ReportCategory.tyre, 'Tyre Cost Analysis', 'Expense breakdown'),
  tyreExpiry(ReportCategory.tyre, 'Tyre Expiry', 'Upcoming replacements'),
  tyreByVehicle(
      ReportCategory.tyre, 'Tyres by Vehicle', 'Per-vehicle breakdown'),
  tyreByBrand(ReportCategory.tyre, 'Tyres by Brand', 'Brand distribution'),

  // Custom
  custom(ReportCategory.vehicle, 'Custom Report', 'Build your own');

  final ReportCategory category;
  final String label, description;
  const ReportType(this.category, this.label, this.description);

  static List<ReportType> forCategory(ReportCategory cat) => ReportType.values
      .where((t) => t.category == cat && t != ReportType.custom)
      .toList();
}

enum ColumnDataType {
  text,
  number,
  currency,
  percentage,
  date,
  dateTime,
  status,
  boolean,
  list,
}

enum AggregationType {
  none,
  count,
  sum,
  average,
  min,
  max,
  countDistinct,
}

enum SortDirection {
  ascending('Ascending', 'A → Z'),
  descending('Descending', 'Z → A');

  final String label, hint;
  const SortDirection(this.label, this.hint);
}

enum GroupByOption {
  none('No Grouping'),
  vehicle('By Vehicle'),
  employee('By Employee'),
  status('By Status'),
  type('By Type'),
  month('By Month'),
  quarter('By Quarter'),
  year('By Year'),
  emirate('By Emirate'),
  city('By City'),
  brand('By Brand'),
  model('By Model'),
  department('By Department'),
  position('By Position'),
  expiryStatus('By Expiry Status');

  final String label;
  const GroupByOption(this.label);
}

enum ChartType {
  none('No Chart'),
  bar('Bar Chart'),
  horizontalBar('Horizontal Bar'),
  line('Line Chart'),
  pie('Pie Chart'),
  donut('Donut Chart'),
  area('Area Chart'),
  stackedBar('Stacked Bar'),
  gauge('Gauge');

  final String label;
  const ChartType(this.label);
}

enum ExportFormat {
  pdf('PDF', 'pdf'),
  excel('Excel', 'xlsx'),
  csv('CSV', 'csv');

  final String label, extension;
  const ExportFormat(this.label, this.extension);
}

/// Date range options for reports
/// Includes both historical (past) and future date ranges
enum ReportDateRange {
  // Historical ranges
  today('Today'),
  yesterday('Yesterday'),
  thisWeek('This Week'),
  lastWeek('Last Week'),
  thisMonth('This Month'),
  lastMonth('Last Month'),
  thisQuarter('This Quarter'),
  lastQuarter('Last Quarter'),
  thisYear('This Year'),
  lastYear('Last Year'),
  last7Days('Last 7 Days'),
  last30Days('Last 30 Days'),
  last90Days('Last 90 Days'),
  last12Months('Last 12 Months'),

  // Future ranges (for expiry reports)
  next7Days('Next 7 Days'),
  next30Days('Next 30 Days'),
  next60Days('Next 60 Days'),
  next90Days('Next 90 Days'),

  // All time
  allTime('All Time'),

  // Custom
  custom('Custom Range');

  final String label;
  const ReportDateRange(this.label);

  /// Returns the date range based on the enum value
  DateTimeRange getRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return switch (this) {
      // Historical
      ReportDateRange.today => DateTimeRange(start: today, end: now),
      ReportDateRange.yesterday => DateTimeRange(
          start: today.subtract(const Duration(days: 1)),
          end: today.subtract(const Duration(seconds: 1)),
        ),
      ReportDateRange.thisWeek => DateTimeRange(
          start: today.subtract(Duration(days: today.weekday - 1)),
          end: now,
        ),
      ReportDateRange.lastWeek => DateTimeRange(
          start: today.subtract(Duration(days: today.weekday + 6)),
          end: today.subtract(Duration(days: today.weekday)),
        ),
      ReportDateRange.thisMonth => DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: now,
        ),
      ReportDateRange.lastMonth => DateTimeRange(
          start: DateTime(now.year, now.month - 1, 1),
          end: DateTime(now.year, now.month, 0),
        ),
      ReportDateRange.thisQuarter => DateTimeRange(
          start: DateTime(now.year, ((now.month - 1) ~/ 3) * 3 + 1, 1),
          end: now,
        ),
      ReportDateRange.lastQuarter => _lastQuarterRange(now),
      ReportDateRange.thisYear => DateTimeRange(
          start: DateTime(now.year, 1, 1),
          end: now,
        ),
      ReportDateRange.lastYear => DateTimeRange(
          start: DateTime(now.year - 1, 1, 1),
          end: DateTime(now.year - 1, 12, 31),
        ),
      ReportDateRange.last7Days => DateTimeRange(
          start: today.subtract(const Duration(days: 7)),
          end: now,
        ),
      ReportDateRange.last30Days => DateTimeRange(
          start: today.subtract(const Duration(days: 30)),
          end: now,
        ),
      ReportDateRange.last90Days => DateTimeRange(
          start: today.subtract(const Duration(days: 90)),
          end: now,
        ),
      ReportDateRange.last12Months => DateTimeRange(
          start: DateTime(now.year - 1, now.month, now.day),
          end: now,
        ),

      // Future ranges
      ReportDateRange.next7Days => DateTimeRange(
          start: today,
          end: today.add(const Duration(days: 7)),
        ),
      ReportDateRange.next30Days => DateTimeRange(
          start: today,
          end: today.add(const Duration(days: 30)),
        ),
      ReportDateRange.next60Days => DateTimeRange(
          start: today,
          end: today.add(const Duration(days: 60)),
        ),
      ReportDateRange.next90Days => DateTimeRange(
          start: today,
          end: today.add(const Duration(days: 90)),
        ),

      // All time - very wide range
      ReportDateRange.allTime => DateTimeRange(
          start: DateTime(2000, 1, 1),
          end: DateTime(2100, 12, 31),
        ),

      // Default for custom
      _ => DateTimeRange(
          start: today.subtract(const Duration(days: 30)),
          end: now,
        ),
    };
  }

  static DateTimeRange _lastQuarterRange(DateTime now) {
    final currentQuarter = ((now.month - 1) ~/ 3);
    final lastQuarterStart = currentQuarter == 0
        ? DateTime(now.year - 1, 10, 1)
        : DateTime(now.year, (currentQuarter - 1) * 3 + 1, 1);
    final lastQuarterEnd = currentQuarter == 0
        ? DateTime(now.year - 1, 12, 31)
        : DateTime(now.year, currentQuarter * 3, 0);
    return DateTimeRange(start: lastQuarterStart, end: lastQuarterEnd);
  }
}

enum FilterOperator {
  equals('Equals', '='),
  notEquals('Not Equals', '≠'),
  contains('Contains', '∋'),
  notContains('Not Contains', '∌'),
  startsWith('Starts With', '^'),
  endsWith('Ends With', '\$'),
  greaterThan('Greater Than', '>'),
  lessThan('Less Than', '<'),
  greaterOrEqual('Greater or Equal', '≥'),
  lessOrEqual('Less or Equal', '≤'),
  between('Between', '↔'),
  inList('In List', '∈'),
  notInList('Not In List', '∉'),
  isEmpty('Is Empty', '∅'),
  isNotEmpty('Is Not Empty', '≠∅');

  final String label, symbol;
  const FilterOperator(this.label, this.symbol);
}

/// Date range helper class
class DateTimeRange {
  final DateTime start, end;
  const DateTimeRange({required this.start, required this.end});

  bool contains(DateTime d) =>
      d.isAfter(start.subtract(const Duration(seconds: 1))) &&
      d.isBefore(end.add(const Duration(seconds: 1)));

  Duration get duration => end.difference(start);
  int get days => duration.inDays;
}
