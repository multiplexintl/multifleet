import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:multifleet/models/company.dart';
import 'package:multifleet/models/fine.dart';
import 'package:multifleet/models/maintenance.dart';
import 'package:multifleet/models/vehicle.dart';
import 'package:multifleet/models/vehicle_assignment_model.dart';
import 'package:multifleet/models/vehicle_docs.dart';
import 'package:multifleet/repo/dashboard_repo.dart';
import 'package:multifleet/services/company_service.dart';

/// DashboardController
/// All stats are computed client-side from the raw lists returned by real APIs.
class DashboardController extends GetxController
    implements CompanyAwareController {
  final companyService = Get.find<CompanyService>();
  final _repo = DashboardRepo();

  // ============================================================
  // LOADING
  // ============================================================

  final isLoadingVehicles = false.obs;
  final isLoadingDocs = false.obs;
  final isLoadingFines = false.obs;
  final isLoadingAssignments = false.obs;
  final isLoadingMaintenance = false.obs;

  bool get isLoading =>
      isLoadingVehicles.value ||
      isLoadingDocs.value ||
      isLoadingFines.value ||
      isLoadingAssignments.value ||
      isLoadingMaintenance.value;

  // ============================================================
  // RAW DATA
  // ============================================================

  final vehicles = <Vehicle>[].obs;
  final documents = <VehicleDocument>[].obs;
  final fines = <Fine>[].obs;
  final assignments = <VehicleAssignment>[].obs;
  final maintenanceRecords = <MaintenanceRecord>[].obs;

  // ============================================================
  // VEHICLE KPIs (computed from vehicles list)
  // ============================================================

  int get totalVehicles => vehicles.length;

  /// Vehicles whose status string contains "active" (case-insensitive)
  int get activeVehicles => vehicles
      .where((v) => v.status?.toLowerCase().contains('active') ?? false)
      .length;

  /// Vehicles whose status string contains "maintenance"
  int get underMaintenance => vehicles
      .where((v) => v.status?.toLowerCase().contains('maint') ?? false)
      .length;

  /// Vehicles with no current assignment (no active assignment record)
  int get unassignedVehicles {
    final assignedNos = assignments
        .where((a) =>
            (a.returnDate == null || a.returnDate!.isEmpty) &&
            a.status?.status?.toLowerCase() == 'active')
        .map((a) => a.vehicleNo)
        .toSet();
    return vehicles.where((v) => !assignedNos.contains(v.vehicleNo)).length;
  }

  // ============================================================
  // DOCUMENT / EXPIRY KPIs
  // ============================================================

  final _today = DateTime.now();

  List<VehicleDocument> get expiredDocs => documents
      .where((d) =>
          d.expiryDate != null && d.expiryDate!.isBefore(_today))
      .toList();

  List<VehicleDocument> get expiringThisWeek => documents
      .where((d) =>
          d.expiryDate != null &&
          !d.expiryDate!.isBefore(_today) &&
          d.expiryDate!
              .isBefore(_today.add(const Duration(days: 7))))
      .toList();

  List<VehicleDocument> get expiringThisMonth => documents
      .where((d) =>
          d.expiryDate != null &&
          !d.expiryDate!.isBefore(_today) &&
          d.expiryDate!
              .isBefore(_today.add(const Duration(days: 30))))
      .toList();

  // ============================================================
  // FINES KPIs
  // ============================================================

  int get totalFines => fines.length;

  List<Fine> get unpaidFines => fines
      .where((f) =>
          f.status?.status?.toLowerCase() == 'unpaid' ||
          f.status?.status?.toLowerCase() == 'pending')
      .toList();

  double get unpaidFineAmount =>
      unpaidFines.fold(0.0, (s, f) => s + (f.amount ?? 0));

  double get totalFineAmount =>
      fines.fold(0.0, (s, f) => s + (f.amount ?? 0));

  /// Top 5 vehicles by fine count
  List<MapEntry<String, int>> get topFinedVehicles {
    final counts = <String, int>{};
    for (final f in fines) {
      if (f.vehicleNo != null) {
        counts[f.vehicleNo!] = (counts[f.vehicleNo!] ?? 0) + 1;
      }
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).toList();
  }

  /// Last 5 fines (most recent by date)
  List<Fine> get recentFines {
    final sorted = List<Fine>.from(fines)
      ..sort((a, b) {
        final da = a.fineDate != null ? DateTime.tryParse(a.fineDate!) : null;
        final db = b.fineDate != null ? DateTime.tryParse(b.fineDate!) : null;
        if (da == null && db == null) return 0;
        if (da == null) return 1;
        if (db == null) return -1;
        return db.compareTo(da);
      });
    return sorted.take(5).toList();
  }

  // ============================================================
  // ASSIGNMENTS KPIs
  // ============================================================

  /// Last 10 assignments, sorted by assignedDate descending
  List<VehicleAssignment> get recentAssignments {
    final sorted = List<VehicleAssignment>.from(assignments)
      ..sort((a, b) {
        final da = a.assignedDate != null
            ? DateTime.tryParse(a.assignedDate!)
            : null;
        final db = b.assignedDate != null
            ? DateTime.tryParse(b.assignedDate!)
            : null;
        if (da == null && db == null) return 0;
        if (da == null) return 1;
        if (db == null) return -1;
        return db.compareTo(da);
      });
    return sorted.take(10).toList();
  }

  // ============================================================
  // MAINTENANCE KPIs
  // ============================================================

  int get scheduledMaintenance => maintenanceRecords
      .where((r) => r.status?.toLowerCase() == 'scheduled')
      .length;

  int get closedMaintenance => maintenanceRecords
      .where((r) => r.status?.toLowerCase() == 'closed')
      .length;

  double get totalMaintenanceSpend =>
      maintenanceRecords.fold(0.0, (s, r) => s + (r.amount ?? 0));

  /// Last 5 maintenance records, sorted by date descending
  List<MaintenanceRecord> get recentMaintenance {
    final sorted = List<MaintenanceRecord>.from(maintenanceRecords)
      ..sort((a, b) {
        final da = a.serviceDate;
        final db = b.serviceDate;
        if (da == null && db == null) return 0;
        if (da == null) return 1;
        if (db == null) return -1;
        return db.compareTo(da);
      });
    return sorted.take(5).toList();
  }

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void onInit() {
    super.onInit();
    companyService.registerController(this);
  }

  @override
  Future<void> onCompanyChanged(Company newCompany) async {
    log('[DashboardController] Company changed to: ${newCompany.id}');
    await _loadDashboard();
  }

  @override
  void onClose() {
    companyService.unregisterController(this);
    super.onClose();
  }

  // ============================================================
  // DATA LOADING
  // ============================================================

  Future<void> _loadDashboard() async {
    final company = companyService.selectedCompanyObs.value?.id ?? '';
    if (company.isEmpty) return;

    await Future.wait([
      _loadVehicles(company),
      _loadDocuments(company),
      _loadFines(company),
      _loadAssignments(company),
      _loadMaintenance(company),
    ]);
  }

  @override
  Future<void> refresh() => _loadDashboard();

  Future<void> _loadVehicles(String company) async {
    isLoadingVehicles.value = true;
    try {
      final result = await _repo.getVehicles(company: company);
      result.fold(
        (err) => log('[DashboardController] Vehicles error: $err'),
        (data) => vehicles.value = data,
      );
    } finally {
      isLoadingVehicles.value = false;
    }
  }

  Future<void> _loadDocuments(String company) async {
    isLoadingDocs.value = true;
    try {
      final result = await _repo.getAllDocuments(company: company);
      result.fold(
        (err) => log('[DashboardController] Docs error: $err'),
        (data) => documents.value = data,
      );
    } finally {
      isLoadingDocs.value = false;
    }
  }

  Future<void> _loadFines(String company) async {
    isLoadingFines.value = true;
    try {
      final result = await _repo.getFines(company: company);
      result.fold(
        (err) => log('[DashboardController] Fines error: $err'),
        (data) => fines.value = data,
      );
    } finally {
      isLoadingFines.value = false;
    }
  }

  Future<void> _loadAssignments(String company) async {
    isLoadingAssignments.value = true;
    try {
      final result = await _repo.getAssignments(company: company);
      result.fold(
        (err) => log('[DashboardController] Assignments error: $err'),
        (data) => assignments.value = data,
      );
    } finally {
      isLoadingAssignments.value = false;
    }
  }

  Future<void> _loadMaintenance(String company) async {
    isLoadingMaintenance.value = true;
    try {
      final result = await _repo.getMaintenance(company: company);
      result.fold(
        (err) => log('[DashboardController] Maintenance error: $err'),
        (data) => maintenanceRecords.value = data,
      );
    } finally {
      isLoadingMaintenance.value = false;
    }
  }

  // ============================================================
  // FORMATTERS
  // ============================================================

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return dateStr;
    return DateFormat('dd MMM yyyy').format(dt);
  }

  String formatDateTime(DateTime? dt) {
    if (dt == null) return '-';
    return DateFormat('dd MMM yyyy').format(dt);
  }

  String formatAmount(double? amount) {
    if (amount == null) return '-';
    return NumberFormat.currency(symbol: 'AED ', decimalDigits: 0)
        .format(amount);
  }

  String formatCompact(double amount) {
    if (amount >= 1000000) {
      return 'AED ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return 'AED ${(amount / 1000).toStringAsFixed(1)}K';
    }
    return 'AED ${amount.toStringAsFixed(0)}';
  }

  // ============================================================
  // NAVIGATION HELPERS
  // ============================================================

  void goToVehicles() => Get.toNamed('/vehicles');
  void goToFines() => Get.toNamed('/fines');
  void goToMaintenance() => Get.toNamed('/maintenance');
  void goToExpiry() => Get.toNamed('/expiry');
  void goToAssignments() => Get.toNamed('/assignments');
  void navigateToMaintenance() => Get.toNamed('/maintenance');
  void navigateToExpiry() => Get.toNamed('/expiry');
  void navigateToFines() => Get.toNamed('/fines');
  void navigateToVehicleDetail(String? vehicleNo) => Get.toNamed('/vehicles');
  void navigateToFineDetail(int? fineId) => Get.toNamed('/fines');

  // ============================================================
  // COLOR HELPERS
  // ============================================================

  Color expiryColor(VehicleDocument doc) {
    if (doc.expiryDate == null) return const Color(0xFF64748B);
    final days = doc.expiryDate!.difference(_today).inDays;
    if (days < 0) return const Color(0xFFEF4444); // expired — red
    if (days <= 7) return const Color(0xFFF97316); // this week — orange
    if (days <= 30) return const Color(0xFFF59E0B); // this month — amber
    return const Color(0xFF22C55E); // ok — green
  }

  Color fineStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid':
        return const Color(0xFF22C55E);
      case 'unpaid':
      case 'pending':
        return const Color(0xFFEF4444);
      case 'disputed':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF64748B);
    }
  }

  Color maintenanceStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'closed':
        return const Color(0xFF22C55E);
      case 'scheduled':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF64748B);
    }
  }

  /// Returns color for a severity level string (used by expiry table).
  Color getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return const Color(0xFFEF4444);
      case 'high':
        return const Color(0xFFF97316);
      case 'medium':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF64748B);
    }
  }

  /// Returns color for a generic status string (used by fines table).
  Color getStatusColor(String? status) => fineStatusColor(status);

  /// Returns color for priority levels (used by maintenance table).
  Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
      case 'high':
        return const Color(0xFFEF4444);
      case 'medium':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF22C55E);
    }
  }

  /// Converts a hex string like "#FF4444" or "FF4444" to a Color.
  Color hexToColor(String hex) {
    final cleaned = hex.replaceFirst('#', '');
    final value = int.tryParse('FF$cleaned', radix: 16);
    return value != null ? Color(value) : const Color(0xFF64748B);
  }

  /// Formats a double as a currency string (AED).
  String formatCurrency(double amount) => formatAmount(amount);

  /// Returns a human-readable "time ago" string from a date string.
  String getTimeAgo(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return dateStr;
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return 'Just now';
  }

  // ============================================================
  // CHART DATA HELPERS (computed from real lists)
  // ============================================================

  /// Vehicle status breakdown for pie/donut chart.
  List<Map<String, dynamic>> get vehicleStatusBreakdown {
    final counts = <String, int>{};
    for (final v in vehicles) {
      final s = v.status ?? 'Unknown';
      counts[s] = (counts[s] ?? 0) + 1;
    }
    final total = vehicles.length;
    if (total == 0) return [];
    final colors = ['#3B82F6', '#22C55E', '#F59E0B', '#EF4444', '#8B5CF6', '#64748B'];
    final entries = counts.entries.toList();
    return List.generate(entries.length, (i) {
      final e = entries[i];
      return {
        'status': e.key,
        'count': e.value,
        'percentage': total > 0 ? (e.value / total * 100) : 0.0,
        'colorHex': colors[i % colors.length],
      };
    });
  }

  /// Monthly fine trend (last 6 months) for line chart.
  List<Map<String, dynamic>> get fineTrendByMonth {
    final now = DateTime.now();
    final months = <String, double>{};
    for (var i = 5; i >= 0; i--) {
      final m = DateTime(now.year, now.month - i, 1);
      final key = '${m.year}-${m.month.toString().padLeft(2, '0')}';
      months[key] = 0.0;
    }
    for (final f in fines) {
      if (f.fineDate == null) continue;
      final dt = DateTime.tryParse(f.fineDate!);
      if (dt == null) continue;
      final key = '${dt.year}-${dt.month.toString().padLeft(2, '0')}';
      if (months.containsKey(key)) {
        months[key] = months[key]! + (f.amount ?? 0);
      }
    }
    final monthNames = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months.entries.map((e) {
      final parts = e.key.split('-');
      final monthIdx = int.parse(parts[1]) - 1;
      return {
        'month': '${monthNames[monthIdx]} ${parts[0]}',
        'monthShort': monthNames[monthIdx],
        'value': e.value,
        'count': fines.where((f) {
          if (f.fineDate == null) return false;
          final dt = DateTime.tryParse(f.fineDate!);
          if (dt == null) return false;
          return '${dt.year}-${dt.month.toString().padLeft(2, '0')}' == e.key;
        }).length,
      };
    }).toList();
  }

  /// Monthly maintenance cost trend (last 6 months) for area chart.
  List<Map<String, dynamic>> get maintenanceCostByMonth {
    final now = DateTime.now();
    final months = <String, double>{};
    for (var i = 5; i >= 0; i--) {
      final m = DateTime(now.year, now.month - i, 1);
      final key = '${m.year}-${m.month.toString().padLeft(2, '0')}';
      months[key] = 0.0;
    }
    for (final r in maintenanceRecords) {
      if (r.dt == null) continue;
      final dt = DateTime.tryParse(r.dt!);
      if (dt == null) continue;
      final key = '${dt.year}-${dt.month.toString().padLeft(2, '0')}';
      if (months.containsKey(key)) {
        months[key] = months[key]! + (r.amount ?? 0);
      }
    }
    final monthNames = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months.entries.map((e) {
      final parts = e.key.split('-');
      final monthIdx = int.parse(parts[1]) - 1;
      return {
        'month': '${monthNames[monthIdx]} ${parts[0]}',
        'monthShort': monthNames[monthIdx],
        'value': e.value,
        'count': maintenanceRecords.where((r) {
          if (r.dt == null) return false;
          final dt = DateTime.tryParse(r.dt!);
          if (dt == null) return false;
          return '${dt.year}-${dt.month.toString().padLeft(2, '0')}' == e.key;
        }).length,
      };
    }).toList();
  }

  /// Expense breakdown by maintenance type for bar chart.
  List<Map<String, dynamic>> get maintenanceExpenseBreakdown {
    final amounts = <String, double>{};
    for (final r in maintenanceRecords) {
      final t = r.maintenanceType ?? 'Other';
      amounts[t] = (amounts[t] ?? 0) + (r.amount ?? 0);
    }
    final total = amounts.values.fold(0.0, (s, v) => s + v);
    final colors = ['#3B82F6', '#22C55E', '#F59E0B', '#EF4444', '#8B5CF6'];
    final sorted = amounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return List.generate(sorted.take(5).length, (i) {
      final e = sorted[i];
      return {
        'category': e.key,
        'amount': e.value,
        'percentage': total > 0 ? (e.value / total * 100) : 0.0,
        'colorHex': colors[i % colors.length],
      };
    });
  }

  /// Fleet utilization percentage (active / total).
  double get fleetUtilizationRate =>
      totalVehicles > 0 ? (activeVehicles / totalVehicles * 100) : 0.0;

  /// Expiring docs within 30 days for table display (sorted by days remaining).
  List<VehicleDocument> get docsExpiringForTable {
    final list = [...expiredDocs, ...expiringThisMonth];
    list.sort((a, b) {
      final da = a.expiryDate?.difference(_today).inDays ?? -999;
      final db = b.expiryDate?.difference(_today).inDays ?? -999;
      return da.compareTo(db);
    });
    return list.take(10).toList();
  }

  /// Scheduled maintenance records — for upcoming table.
  List<MaintenanceRecord> get scheduledMaintenanceRecords =>
      maintenanceRecords
          .where((r) => r.status?.toLowerCase() == 'scheduled')
          .take(10)
          .toList();
}
