/// MaintenanceMaster model (moved here for completeness)
class MaintenanceMaster {
  final int? maintenanceID;
  final String? maintenanceType;
  final int? defaultIntervalKm; // Suggested interval in km
  final int? defaultIntervalDays; // Suggested interval in days

  MaintenanceMaster({
    this.maintenanceID,
    this.maintenanceType,
    this.defaultIntervalKm,
    this.defaultIntervalDays,
  });

  factory MaintenanceMaster.fromJson(Map<String, dynamic> json) {
    return MaintenanceMaster(
      maintenanceID: json['MaintenanceID'] as int?,
      maintenanceType: json['MaintenanceType'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'MaintenanceID': maintenanceID,
        'MaintenanceType': maintenanceType,
      };

  @override
  String toString() =>
      'MaintenanceMaster(id: $maintenanceID, type: $maintenanceType)';
}

/// Statistics model for dashboard
class MaintenanceStats {
  final int totalRecordsThisMonth;
  final double totalSpendThisMonth;
  final double totalSpendYTD;
  final int overdueServices;
  final int dueSoonServices;
  final int pendingScheduled;
  final int completedThisMonth;

  MaintenanceStats({
    required this.totalRecordsThisMonth,
    required this.totalSpendThisMonth,
    required this.totalSpendYTD,
    required this.overdueServices,
    required this.dueSoonServices,
    required this.pendingScheduled,
    required this.completedThisMonth,
  });

  factory MaintenanceStats.fromJson(Map<String, dynamic> json) {
    return MaintenanceStats(
      totalRecordsThisMonth: json['TotalRecordsThisMonth'] as int? ?? 0,
      totalSpendThisMonth:
          (json['TotalSpendThisMonth'] as num?)?.toDouble() ?? 0,
      totalSpendYTD: (json['TotalSpendYTD'] as num?)?.toDouble() ?? 0,
      overdueServices: json['OverdueServices'] as int? ?? 0,
      dueSoonServices: json['DueSoonServices'] as int? ?? 0,
      pendingScheduled: json['PendingScheduled'] as int? ?? 0,
      completedThisMonth: json['CompletedThisMonth'] as int? ?? 0,
    );
  }
}

/// Vehicle service summary for quick overview
class VehicleServiceSummary {
  final String vehicleNo;
  final int totalServices;
  final double totalSpend;
  final DateTime? lastServiceDate;
  final String? lastServiceType;
  final DateTime? nextScheduledDate;
  final String? nextScheduledType;

  VehicleServiceSummary({
    required this.vehicleNo,
    required this.totalServices,
    required this.totalSpend,
    this.lastServiceDate,
    this.lastServiceType,
    this.nextScheduledDate,
    this.nextScheduledType,
  });

  factory VehicleServiceSummary.fromJson(Map<String, dynamic> json) {
    return VehicleServiceSummary(
      vehicleNo: json['VehicleNo'] as String? ?? '',
      totalServices: json['TotalServices'] as int? ?? 0,
      totalSpend: (json['TotalSpend'] as num?)?.toDouble() ?? 0,
      lastServiceDate: json['LastServiceDate'] != null
          ? DateTime.tryParse(json['LastServiceDate'].toString())
          : null,
      lastServiceType: json['LastServiceType'] as String?,
      nextScheduledDate: json['NextScheduledDate'] != null
          ? DateTime.tryParse(json['NextScheduledDate'].toString())
          : null,
      nextScheduledType: json['NextScheduledType'] as String?,
    );
  }
}

// class MaintenanceMaster {
//   final String? company;
//   final int? maintenanceID;
//   final String? maintenanceType;

//   MaintenanceMaster({
//     this.company,
//     this.maintenanceID,
//     this.maintenanceType,
//   });

//   // Copy with method
//   MaintenanceMaster copyWith({
//     String? company,
//     int? maintenanceID,
//     String? maintenanceType,
//   }) {
//     return MaintenanceMaster(
//       company: company ?? this.company,
//       maintenanceID: maintenanceID ?? this.maintenanceID,
//       maintenanceType: maintenanceType ?? this.maintenanceType,
//     );
//   }

//   // From JSON factory constructor
//   factory MaintenanceMaster.fromJson(Map<String, dynamic> json) {
//     return MaintenanceMaster(
//       company: json['Company'],
//       maintenanceID: json['MaintenanceID'],
//       maintenanceType: json['MaintenanceType'],
//     );
//   }

//   // To JSON method
//   Map<String, dynamic> toJson() {
//     return {
//       'Company': company,
//       'MaintenanceID': maintenanceID,
//       'MaintenanceType': maintenanceType,
//     };
//   }

//   // toString method
//   @override
//   String toString() {
//     return 'MaintenanceMaster{company: $company, maintenanceID: $maintenanceID, MaintenanceType: $maintenanceType}';
//   }
// }
