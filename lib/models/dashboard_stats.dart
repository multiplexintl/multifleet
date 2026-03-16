// ==================== MAIN DASHBOARD MODEL ====================

class DashboardStats {
  final FleetOverview fleetOverview;
  final DocumentAlerts documentAlerts;
  final FineStats fineStats;
  final MaintenanceStats maintenanceStats;
  final List<VehicleStatusBreakdown> vehicleStatusBreakdown;
  final List<MonthlyTrend> fineTrend;
  final List<MonthlyTrend> maintenanceCostTrend;
  final List<ExpenseBreakdown> expenseBreakdown;
  final List<UpcomingMaintenance> upcomingMaintenance;
  final List<RecentFine> recentFines;
  final List<ExpiringDocument> expiringDocuments;
  final List<RecentAssignment> recentAssignments;
  final List<VehicleFineRanking> topVehiclesByFines;
  final RegionalBreakdown? regionalBreakdown;
  final DateTime lastUpdated;

  DashboardStats({
    required this.fleetOverview,
    required this.documentAlerts,
    required this.fineStats,
    required this.maintenanceStats,
    required this.vehicleStatusBreakdown,
    required this.fineTrend,
    required this.maintenanceCostTrend,
    required this.expenseBreakdown,
    required this.upcomingMaintenance,
    required this.recentFines,
    required this.expiringDocuments,
    required this.recentAssignments,
    required this.topVehiclesByFines,
    this.regionalBreakdown,
    required this.lastUpdated,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      fleetOverview: FleetOverview.fromJson(json['fleet_overview'] ?? {}),
      documentAlerts: DocumentAlerts.fromJson(json['document_alerts'] ?? {}),
      fineStats: FineStats.fromJson(json['fine_stats'] ?? {}),
      maintenanceStats:
          MaintenanceStats.fromJson(json['maintenance_stats'] ?? {}),
      vehicleStatusBreakdown: (json['vehicle_status_breakdown'] as List? ?? [])
          .map((e) => VehicleStatusBreakdown.fromJson(e))
          .toList(),
      fineTrend: (json['fine_trend'] as List? ?? [])
          .map((e) => MonthlyTrend.fromJson(e))
          .toList(),
      maintenanceCostTrend: (json['maintenance_cost_trend'] as List? ?? [])
          .map((e) => MonthlyTrend.fromJson(e))
          .toList(),
      expenseBreakdown: (json['expense_breakdown'] as List? ?? [])
          .map((e) => ExpenseBreakdown.fromJson(e))
          .toList(),
      upcomingMaintenance: (json['upcoming_maintenance'] as List? ?? [])
          .map((e) => UpcomingMaintenance.fromJson(e))
          .toList(),
      recentFines: (json['recent_fines'] as List? ?? [])
          .map((e) => RecentFine.fromJson(e))
          .toList(),
      expiringDocuments: (json['expiring_documents'] as List? ?? [])
          .map((e) => ExpiringDocument.fromJson(e))
          .toList(),
      recentAssignments: (json['recent_assignments'] as List? ?? [])
          .map((e) => RecentAssignment.fromJson(e))
          .toList(),
      topVehiclesByFines: (json['top_vehicles_by_fines'] as List? ?? [])
          .map((e) => VehicleFineRanking.fromJson(e))
          .toList(),
      regionalBreakdown: json['regional_breakdown'] != null
          ? RegionalBreakdown.fromJson(json['regional_breakdown'])
          : null,
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'fleet_overview': fleetOverview.toJson(),
        'document_alerts': documentAlerts.toJson(),
        'fine_stats': fineStats.toJson(),
        'maintenance_stats': maintenanceStats.toJson(),
        'vehicle_status_breakdown':
            vehicleStatusBreakdown.map((e) => e.toJson()).toList(),
        'fine_trend': fineTrend.map((e) => e.toJson()).toList(),
        'maintenance_cost_trend':
            maintenanceCostTrend.map((e) => e.toJson()).toList(),
        'expense_breakdown': expenseBreakdown.map((e) => e.toJson()).toList(),
        'upcoming_maintenance':
            upcomingMaintenance.map((e) => e.toJson()).toList(),
        'recent_fines': recentFines.map((e) => e.toJson()).toList(),
        'expiring_documents': expiringDocuments.map((e) => e.toJson()).toList(),
        'recent_assignments': recentAssignments.map((e) => e.toJson()).toList(),
        'top_vehicles_by_fines':
            topVehiclesByFines.map((e) => e.toJson()).toList(),
        'regional_breakdown': regionalBreakdown?.toJson(),
        'last_updated': lastUpdated.toIso8601String(),
      };
}

// ==================== FLEET OVERVIEW ====================

class FleetOverview {
  final int totalVehicles;
  final int activeVehicles;
  final int underMaintenance;
  final int idleVehicles;
  final int totalDrivers;
  final int assignedDrivers;
  final double fleetUtilizationRate;
  final double totalFleetValue;
  final double averageVehicleAge;

  FleetOverview({
    required this.totalVehicles,
    required this.activeVehicles,
    required this.underMaintenance,
    required this.idleVehicles,
    required this.totalDrivers,
    required this.assignedDrivers,
    required this.fleetUtilizationRate,
    required this.totalFleetValue,
    required this.averageVehicleAge,
  });

  factory FleetOverview.fromJson(Map<String, dynamic> json) {
    return FleetOverview(
      totalVehicles: json['total_vehicles'] ?? 0,
      activeVehicles: json['active_vehicles'] ?? 0,
      underMaintenance: json['under_maintenance'] ?? 0,
      idleVehicles: json['idle_vehicles'] ?? 0,
      totalDrivers: json['total_drivers'] ?? 0,
      assignedDrivers: json['assigned_drivers'] ?? 0,
      fleetUtilizationRate: (json['fleet_utilization_rate'] ?? 0).toDouble(),
      totalFleetValue: (json['total_fleet_value'] ?? 0).toDouble(),
      averageVehicleAge: (json['average_vehicle_age'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'total_vehicles': totalVehicles,
        'active_vehicles': activeVehicles,
        'under_maintenance': underMaintenance,
        'idle_vehicles': idleVehicles,
        'total_drivers': totalDrivers,
        'assigned_drivers': assignedDrivers,
        'fleet_utilization_rate': fleetUtilizationRate,
        'total_fleet_value': totalFleetValue,
        'average_vehicle_age': averageVehicleAge,
      };
}

// ==================== DOCUMENT ALERTS ====================

class DocumentAlerts {
  final int expiredCount;
  final int expiringIn7Days;
  final int expiringIn30Days;
  final int expiringIn60Days;
  final double complianceRate;

  DocumentAlerts({
    required this.expiredCount,
    required this.expiringIn7Days,
    required this.expiringIn30Days,
    required this.expiringIn60Days,
    required this.complianceRate,
  });

  factory DocumentAlerts.fromJson(Map<String, dynamic> json) {
    return DocumentAlerts(
      expiredCount: json['expired_count'] ?? 0,
      expiringIn7Days: json['expiring_in_7_days'] ?? 0,
      expiringIn30Days: json['expiring_in_30_days'] ?? 0,
      expiringIn60Days: json['expiring_in_60_days'] ?? 0,
      complianceRate: (json['compliance_rate'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'expired_count': expiredCount,
        'expiring_in_7_days': expiringIn7Days,
        'expiring_in_30_days': expiringIn30Days,
        'expiring_in_60_days': expiringIn60Days,
        'compliance_rate': complianceRate,
      };

  int get totalAlerts => expiredCount + expiringIn7Days + expiringIn30Days;
}

// ==================== FINE STATISTICS ====================

class FineStats {
  final int totalFines;
  final int unpaidFines;
  final int paidFines;
  final int disputedFines;
  final double totalFineAmount;
  final double unpaidAmount;
  final double paidAmountYTD;
  final double paidAmountMTD;
  final double averageFineAmount;

  FineStats({
    required this.totalFines,
    required this.unpaidFines,
    required this.paidFines,
    required this.disputedFines,
    required this.totalFineAmount,
    required this.unpaidAmount,
    required this.paidAmountYTD,
    required this.paidAmountMTD,
    required this.averageFineAmount,
  });

  factory FineStats.fromJson(Map<String, dynamic> json) {
    return FineStats(
      totalFines: json['total_fines'] ?? 0,
      unpaidFines: json['unpaid_fines'] ?? 0,
      paidFines: json['paid_fines'] ?? 0,
      disputedFines: json['disputed_fines'] ?? 0,
      totalFineAmount: (json['total_fine_amount'] ?? 0).toDouble(),
      unpaidAmount: (json['unpaid_amount'] ?? 0).toDouble(),
      paidAmountYTD: (json['paid_amount_ytd'] ?? 0).toDouble(),
      paidAmountMTD: (json['paid_amount_mtd'] ?? 0).toDouble(),
      averageFineAmount: (json['average_fine_amount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'total_fines': totalFines,
        'unpaid_fines': unpaidFines,
        'paid_fines': paidFines,
        'disputed_fines': disputedFines,
        'total_fine_amount': totalFineAmount,
        'unpaid_amount': unpaidAmount,
        'paid_amount_ytd': paidAmountYTD,
        'paid_amount_mtd': paidAmountMTD,
        'average_fine_amount': averageFineAmount,
      };
}

// ==================== MAINTENANCE STATISTICS ====================

class MaintenanceStats {
  final int scheduledCount;
  final int overdueCount;
  final int completedMTD;
  final int completedYTD;
  final double costMTD;
  final double costYTD;
  final double averageCostPerVehicle;

  MaintenanceStats({
    required this.scheduledCount,
    required this.overdueCount,
    required this.completedMTD,
    required this.completedYTD,
    required this.costMTD,
    required this.costYTD,
    required this.averageCostPerVehicle,
  });

  factory MaintenanceStats.fromJson(Map<String, dynamic> json) {
    return MaintenanceStats(
      scheduledCount: json['scheduled_count'] ?? 0,
      overdueCount: json['overdue_count'] ?? 0,
      completedMTD: json['completed_mtd'] ?? 0,
      completedYTD: json['completed_ytd'] ?? 0,
      costMTD: (json['cost_mtd'] ?? 0).toDouble(),
      costYTD: (json['cost_ytd'] ?? 0).toDouble(),
      averageCostPerVehicle: (json['average_cost_per_vehicle'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'scheduled_count': scheduledCount,
        'overdue_count': overdueCount,
        'completed_mtd': completedMTD,
        'completed_ytd': completedYTD,
        'cost_mtd': costMTD,
        'cost_ytd': costYTD,
        'average_cost_per_vehicle': averageCostPerVehicle,
      };
}

// ==================== VEHICLE STATUS BREAKDOWN ====================

class VehicleStatusBreakdown {
  final String status;
  final int count;
  final double percentage;
  final String colorHex;

  VehicleStatusBreakdown({
    required this.status,
    required this.count,
    required this.percentage,
    required this.colorHex,
  });

  factory VehicleStatusBreakdown.fromJson(Map<String, dynamic> json) {
    return VehicleStatusBreakdown(
      status: json['status'] ?? '',
      count: json['count'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
      colorHex: json['color_hex'] ?? '#64748B',
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'count': count,
        'percentage': percentage,
        'color_hex': colorHex,
      };
}

// ==================== MONTHLY TREND ====================

class MonthlyTrend {
  final String month;
  final String monthShort;
  final double value;
  final int count;

  MonthlyTrend({
    required this.month,
    required this.monthShort,
    required this.value,
    required this.count,
  });

  factory MonthlyTrend.fromJson(Map<String, dynamic> json) {
    return MonthlyTrend(
      month: json['month'] ?? '',
      monthShort: json['month_short'] ?? '',
      value: (json['value'] ?? 0).toDouble(),
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'month': month,
        'month_short': monthShort,
        'value': value,
        'count': count,
      };
}

// ==================== EXPENSE BREAKDOWN ====================

class ExpenseBreakdown {
  final String category;
  final double amount;
  final double percentage;
  final String colorHex;

  ExpenseBreakdown({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.colorHex,
  });

  factory ExpenseBreakdown.fromJson(Map<String, dynamic> json) {
    return ExpenseBreakdown(
      category: json['category'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      percentage: (json['percentage'] ?? 0).toDouble(),
      colorHex: json['color_hex'] ?? '#64748B',
    );
  }

  Map<String, dynamic> toJson() => {
        'category': category,
        'amount': amount,
        'percentage': percentage,
        'color_hex': colorHex,
      };
}

// ==================== UPCOMING MAINTENANCE ====================

class UpcomingMaintenance {
  final int id;
  final String vehicleNo;
  final String vehicleType;
  final String maintenanceType;
  final DateTime dueDate;
  final int daysUntilDue;
  final String priority;
  final double estimatedCost;

  UpcomingMaintenance({
    required this.id,
    required this.vehicleNo,
    required this.vehicleType,
    required this.maintenanceType,
    required this.dueDate,
    required this.daysUntilDue,
    required this.priority,
    required this.estimatedCost,
  });

  factory UpcomingMaintenance.fromJson(Map<String, dynamic> json) {
    return UpcomingMaintenance(
      id: json['id'] ?? 0,
      vehicleNo: json['vehicle_no'] ?? '',
      vehicleType: json['vehicle_type'] ?? '',
      maintenanceType: json['maintenance_type'] ?? '',
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'])
          : DateTime.now(),
      daysUntilDue: json['days_until_due'] ?? 0,
      priority: json['priority'] ?? 'normal',
      estimatedCost: (json['estimated_cost'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'vehicle_no': vehicleNo,
        'vehicle_type': vehicleType,
        'maintenance_type': maintenanceType,
        'due_date': dueDate.toIso8601String(),
        'days_until_due': daysUntilDue,
        'priority': priority,
        'estimated_cost': estimatedCost,
      };
}

// ==================== RECENT FINE ====================

class RecentFine {
  final int id;
  final String vehicleNo;
  final String ticketNo;
  final String fineType;
  final double amount;
  final String status;
  final DateTime fineDate;
  final String? employeeName;

  RecentFine({
    required this.id,
    required this.vehicleNo,
    required this.ticketNo,
    required this.fineType,
    required this.amount,
    required this.status,
    required this.fineDate,
    this.employeeName,
  });

  factory RecentFine.fromJson(Map<String, dynamic> json) {
    return RecentFine(
      id: json['id'] ?? 0,
      vehicleNo: json['vehicle_no'] ?? '',
      ticketNo: json['ticket_no'] ?? '',
      fineType: json['fine_type'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      fineDate: json['fine_date'] != null
          ? DateTime.parse(json['fine_date'])
          : DateTime.now(),
      employeeName: json['employee_name'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'vehicle_no': vehicleNo,
        'ticket_no': ticketNo,
        'fine_type': fineType,
        'amount': amount,
        'status': status,
        'fine_date': fineDate.toIso8601String(),
        'employee_name': employeeName,
      };
}

// ==================== EXPIRING DOCUMENT ====================

class ExpiringDocument {
  final int id;
  final String vehicleNo;
  final String documentType;
  final DateTime expiryDate;
  final int daysUntilExpiry;
  final String severity; // critical, warning, info

  ExpiringDocument({
    required this.id,
    required this.vehicleNo,
    required this.documentType,
    required this.expiryDate,
    required this.daysUntilExpiry,
    required this.severity,
  });

  factory ExpiringDocument.fromJson(Map<String, dynamic> json) {
    return ExpiringDocument(
      id: json['id'] ?? 0,
      vehicleNo: json['vehicle_no'] ?? '',
      documentType: json['document_type'] ?? '',
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'])
          : DateTime.now(),
      daysUntilExpiry: json['days_until_expiry'] ?? 0,
      severity: json['severity'] ?? 'info',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'vehicle_no': vehicleNo,
        'document_type': documentType,
        'expiry_date': expiryDate.toIso8601String(),
        'days_until_expiry': daysUntilExpiry,
        'severity': severity,
      };
}

// ==================== RECENT ASSIGNMENT ====================

class RecentAssignment {
  final int id;
  final String vehicleNo;
  final String employeeName;
  final String employeeNo;
  final DateTime assignedDate;
  final String status;

  RecentAssignment({
    required this.id,
    required this.vehicleNo,
    required this.employeeName,
    required this.employeeNo,
    required this.assignedDate,
    required this.status,
  });

  factory RecentAssignment.fromJson(Map<String, dynamic> json) {
    return RecentAssignment(
      id: json['id'] ?? 0,
      vehicleNo: json['vehicle_no'] ?? '',
      employeeName: json['employee_name'] ?? '',
      employeeNo: json['employee_no'] ?? '',
      assignedDate: json['assigned_date'] != null
          ? DateTime.parse(json['assigned_date'])
          : DateTime.now(),
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'vehicle_no': vehicleNo,
        'employee_name': employeeName,
        'employee_no': employeeNo,
        'assigned_date': assignedDate.toIso8601String(),
        'status': status,
      };
}

// ==================== VEHICLE FINE RANKING ====================

class VehicleFineRanking {
  final String vehicleNo;
  final int fineCount;
  final double totalAmount;
  final String topFineType;

  VehicleFineRanking({
    required this.vehicleNo,
    required this.fineCount,
    required this.totalAmount,
    required this.topFineType,
  });

  factory VehicleFineRanking.fromJson(Map<String, dynamic> json) {
    return VehicleFineRanking(
      vehicleNo: json['vehicle_no'] ?? '',
      fineCount: json['fine_count'] ?? 0,
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      topFineType: json['top_fine_type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'vehicle_no': vehicleNo,
        'fine_count': fineCount,
        'total_amount': totalAmount,
        'top_fine_type': topFineType,
      };
}

// ==================== REGIONAL BREAKDOWN ====================

class RegionalBreakdown {
  final List<RegionStats> regions;

  RegionalBreakdown({required this.regions});

  factory RegionalBreakdown.fromJson(Map<String, dynamic> json) {
    return RegionalBreakdown(
      regions: (json['regions'] as List? ?? [])
          .map((e) => RegionStats.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'regions': regions.map((e) => e.toJson()).toList(),
      };
}

class RegionStats {
  final String regionCode;
  final String regionName;
  final int vehicleCount;
  final int activeVehicles;
  final int fineCount;
  final double fineAmount;
  final double maintenanceCost;
  final int expiringDocuments;

  RegionStats({
    required this.regionCode,
    required this.regionName,
    required this.vehicleCount,
    required this.activeVehicles,
    required this.fineCount,
    required this.fineAmount,
    required this.maintenanceCost,
    required this.expiringDocuments,
  });

  factory RegionStats.fromJson(Map<String, dynamic> json) {
    return RegionStats(
      regionCode: json['region_code'] ?? '',
      regionName: json['region_name'] ?? '',
      vehicleCount: json['vehicle_count'] ?? 0,
      activeVehicles: json['active_vehicles'] ?? 0,
      fineCount: json['fine_count'] ?? 0,
      fineAmount: (json['fine_amount'] ?? 0).toDouble(),
      maintenanceCost: (json['maintenance_cost'] ?? 0).toDouble(),
      expiringDocuments: json['expiring_documents'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'region_code': regionCode,
        'region_name': regionName,
        'vehicle_count': vehicleCount,
        'active_vehicles': activeVehicles,
        'fine_count': fineCount,
        'fine_amount': fineAmount,
        'maintenance_cost': maintenanceCost,
        'expiring_documents': expiringDocuments,
      };
}

// ==================== DATE RANGE FILTER ====================

enum DateRangePreset {
  today,
  yesterday,
  thisWeek,
  lastWeek,
  thisMonth,
  lastMonth,
  thisQuarter,
  lastQuarter,
  thisYear,
  lastYear,
  custom,
}

class DateRangeFilter {
  final DateTime startDate;
  final DateTime endDate;
  final DateRangePreset preset;

  DateRangeFilter({
    required this.startDate,
    required this.endDate,
    required this.preset,
  });

  factory DateRangeFilter.fromPreset(DateRangePreset preset) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (preset) {
      case DateRangePreset.today:
        return DateRangeFilter(
          startDate: today,
          endDate: today
              .add(const Duration(days: 1))
              .subtract(const Duration(seconds: 1)),
          preset: preset,
        );

      case DateRangePreset.yesterday:
        final yesterday = today.subtract(const Duration(days: 1));
        return DateRangeFilter(
          startDate: yesterday,
          endDate: today.subtract(const Duration(seconds: 1)),
          preset: preset,
        );

      case DateRangePreset.thisWeek:
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
        return DateRangeFilter(
          startDate: startOfWeek,
          endDate: now,
          preset: preset,
        );

      case DateRangePreset.lastWeek:
        final startOfLastWeek =
            today.subtract(Duration(days: today.weekday + 6));
        final endOfLastWeek = today.subtract(Duration(days: today.weekday));
        return DateRangeFilter(
          startDate: startOfLastWeek,
          endDate: endOfLastWeek.subtract(const Duration(seconds: 1)),
          preset: preset,
        );

      case DateRangePreset.thisMonth:
        return DateRangeFilter(
          startDate: DateTime(now.year, now.month, 1),
          endDate: now,
          preset: preset,
        );

      case DateRangePreset.lastMonth:
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        final endOfLastMonth = DateTime(now.year, now.month, 0);
        return DateRangeFilter(
          startDate: lastMonth,
          endDate: endOfLastMonth,
          preset: preset,
        );

      case DateRangePreset.thisQuarter:
        final quarterStart =
            DateTime(now.year, ((now.month - 1) ~/ 3) * 3 + 1, 1);
        return DateRangeFilter(
          startDate: quarterStart,
          endDate: now,
          preset: preset,
        );

      case DateRangePreset.lastQuarter:
        final currentQuarterStart = ((now.month - 1) ~/ 3) * 3 + 1;
        final lastQuarterStart = DateTime(
          currentQuarterStart == 1 ? now.year - 1 : now.year,
          currentQuarterStart == 1 ? 10 : currentQuarterStart - 3,
          1,
        );
        final lastQuarterEnd = DateTime(now.year, currentQuarterStart, 0);
        return DateRangeFilter(
          startDate: lastQuarterStart,
          endDate: lastQuarterEnd,
          preset: preset,
        );

      case DateRangePreset.thisYear:
        return DateRangeFilter(
          startDate: DateTime(now.year, 1, 1),
          endDate: now,
          preset: preset,
        );

      case DateRangePreset.lastYear:
        return DateRangeFilter(
          startDate: DateTime(now.year - 1, 1, 1),
          endDate: DateTime(now.year - 1, 12, 31),
          preset: preset,
        );

      case DateRangePreset.custom:
        return DateRangeFilter(
          startDate: today.subtract(const Duration(days: 30)),
          endDate: now,
          preset: preset,
        );
    }
  }

  String get displayName {
    switch (preset) {
      case DateRangePreset.today:
        return 'Today';
      case DateRangePreset.yesterday:
        return 'Yesterday';
      case DateRangePreset.thisWeek:
        return 'This Week';
      case DateRangePreset.lastWeek:
        return 'Last Week';
      case DateRangePreset.thisMonth:
        return 'This Month';
      case DateRangePreset.lastMonth:
        return 'Last Month';
      case DateRangePreset.thisQuarter:
        return 'This Quarter';
      case DateRangePreset.lastQuarter:
        return 'Last Quarter';
      case DateRangePreset.thisYear:
        return 'This Year';
      case DateRangePreset.lastYear:
        return 'Last Year';
      case DateRangePreset.custom:
        return 'Custom Range';
    }
  }

  DateRangeFilter copyWith({
    DateTime? startDate,
    DateTime? endDate,
    DateRangePreset? preset,
  }) {
    return DateRangeFilter(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      preset: preset ?? this.preset,
    );
  }
}
