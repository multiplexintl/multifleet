/// ScheduledService model for upcoming/planned maintenance
/// This tracks services that are scheduled but not yet completed
class ScheduledService {
  final String? company;
  final int? scheduleId;
  final String? vehicleNo;
  final int? maintenanceTypeId;
  final String? maintenanceType; // Denormalized for display
  final int? garageId;
  final String? garageName; // Denormalized for display
  final DateTime? scheduledDate;
  final int? scheduledAtKm; // Schedule when vehicle reaches this KM
  final String? description;
  final double? estimatedCost;
  final String? priority; // low, medium, high, critical
  final String? status; // pending, confirmed, in_progress, completed, cancelled
  final String? notes;
  final bool? isRecurring;
  final int? recurringIntervalKm; // Repeat every X km
  final int? recurringIntervalDays; // Repeat every X days
  final DateTime? reminderDate;
  final bool? reminderSent;
  final DateTime? createdAt;
  final String? createdBy;

  ScheduledService({
    this.company,
    this.scheduleId,
    this.vehicleNo,
    this.maintenanceTypeId,
    this.maintenanceType,
    this.garageId,
    this.garageName,
    this.scheduledDate,
    this.scheduledAtKm,
    this.description,
    this.estimatedCost,
    this.priority,
    this.status,
    this.notes,
    this.isRecurring,
    this.recurringIntervalKm,
    this.recurringIntervalDays,
    this.reminderDate,
    this.reminderSent,
    this.createdAt,
    this.createdBy,
  });

  factory ScheduledService.fromJson(Map<String, dynamic> json) {
    return ScheduledService(
      company: json['Company'] as String?,
      scheduleId: json['ScheduleID'] as int?,
      vehicleNo: json['VehicleNo'] as String?,
      maintenanceTypeId: json['MaintenanceTypeID'] as int?,
      maintenanceType: json['MaintenanceType'] as String?,
      garageId: json['GarageID'] as int?,
      garageName: json['GarageName'] as String?,
      scheduledDate: json['ScheduledDate'] != null
          ? DateTime.tryParse(json['ScheduledDate'].toString())
          : null,
      scheduledAtKm: json['ScheduledAtKm'] as int?,
      description: json['Description'] as String?,
      estimatedCost: (json['EstimatedCost'] as num?)?.toDouble(),
      priority: json['Priority'] as String?,
      status: json['Status'] as String?,
      notes: json['Notes'] as String?,
      isRecurring: json['IsRecurring'] as bool?,
      recurringIntervalKm: json['RecurringIntervalKm'] as int?,
      recurringIntervalDays: json['RecurringIntervalDays'] as int?,
      reminderDate: json['ReminderDate'] != null
          ? DateTime.tryParse(json['ReminderDate'].toString())
          : null,
      reminderSent: json['ReminderSent'] as bool?,
      createdAt: json['CreatedAt'] != null
          ? DateTime.tryParse(json['CreatedAt'].toString())
          : null,
      createdBy: json['CreatedBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'Company': company,
        'ScheduleID': scheduleId,
        'VehicleNo': vehicleNo,
        'MaintenanceTypeID': maintenanceTypeId,
        'MaintenanceType': maintenanceType,
        'GarageID': garageId,
        'GarageName': garageName,
        'ScheduledDate': scheduledDate?.toIso8601String(),
        'ScheduledAtKm': scheduledAtKm,
        'Description': description,
        'EstimatedCost': estimatedCost,
        'Priority': priority,
        'Status': status,
        'Notes': notes,
        'IsRecurring': isRecurring,
        'RecurringIntervalKm': recurringIntervalKm,
        'RecurringIntervalDays': recurringIntervalDays,
        'ReminderDate': reminderDate?.toIso8601String(),
        'ReminderSent': reminderSent,
        'CreatedAt': createdAt?.toIso8601String(),
        'CreatedBy': createdBy,
      };

  ScheduledService copyWith({
    String? company,
    int? scheduleId,
    String? vehicleNo,
    int? maintenanceTypeId,
    String? maintenanceType,
    int? garageId,
    String? garageName,
    DateTime? scheduledDate,
    int? scheduledAtKm,
    String? description,
    double? estimatedCost,
    String? priority,
    String? status,
    String? notes,
    bool? isRecurring,
    int? recurringIntervalKm,
    int? recurringIntervalDays,
    DateTime? reminderDate,
    bool? reminderSent,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return ScheduledService(
      company: company ?? this.company,
      scheduleId: scheduleId ?? this.scheduleId,
      vehicleNo: vehicleNo ?? this.vehicleNo,
      maintenanceTypeId: maintenanceTypeId ?? this.maintenanceTypeId,
      maintenanceType: maintenanceType ?? this.maintenanceType,
      garageId: garageId ?? this.garageId,
      garageName: garageName ?? this.garageName,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledAtKm: scheduledAtKm ?? this.scheduledAtKm,
      description: description ?? this.description,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringIntervalKm: recurringIntervalKm ?? this.recurringIntervalKm,
      recurringIntervalDays:
          recurringIntervalDays ?? this.recurringIntervalDays,
      reminderDate: reminderDate ?? this.reminderDate,
      reminderSent: reminderSent ?? this.reminderSent,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  /// Check if service is due based on date
  bool isDueSoon({int warningDays = 7}) {
    if (scheduledDate == null) return false;
    final now = DateTime.now();
    final daysUntil = scheduledDate!.difference(now).inDays;
    return daysUntil >= 0 && daysUntil <= warningDays;
  }

  /// Check if service is overdue by date
  bool get isOverdueByDate {
    if (scheduledDate == null) return false;
    return scheduledDate!.isBefore(DateTime.now()) && status != 'completed';
  }

  /// Check if service is due based on KM
  bool isDueByKm(int currentOdometer, {int warningThreshold = 500}) {
    if (scheduledAtKm == null) return false;
    return currentOdometer >= (scheduledAtKm! - warningThreshold);
  }

  /// Check if service is overdue by KM
  bool isOverdueByKm(int currentOdometer) {
    if (scheduledAtKm == null) return false;
    return currentOdometer > scheduledAtKm! && status != 'completed';
  }

  /// Get days until scheduled date
  int? get daysUntilDue {
    if (scheduledDate == null) return null;
    return scheduledDate!.difference(DateTime.now()).inDays;
  }

  /// Get km until scheduled service
  int? kmUntilDue(int currentOdometer) {
    if (scheduledAtKm == null) return null;
    return scheduledAtKm! - currentOdometer;
  }

  @override
  String toString() =>
      'ScheduledService(scheduleId: $scheduleId, vehicleNo: $vehicleNo, '
      'type: $maintenanceType, date: $scheduledDate, status: $status)';
}

/// Priority levels for scheduled services
class ServicePriority {
  static const String low = 'low';
  static const String medium = 'medium';
  static const String high = 'high';
  static const String critical = 'critical';

  static List<String> get all => [low, medium, high, critical];
}

/// Status options for scheduled services
class ServiceStatus {
  static const String pending = 'pending';
  static const String confirmed = 'confirmed';
  static const String inProgress = 'in_progress';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';

  static List<String> get all =>
      [pending, confirmed, inProgress, completed, cancelled];

  static List<String> get active => [pending, confirmed, inProgress];
}
