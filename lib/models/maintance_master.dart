class MaintenanceType {
  final String? company;
  final int? maintenanceID;
  final String? maintenanceType;

  MaintenanceType({
    this.company,
    this.maintenanceID,
    this.maintenanceType,
  });

  // Copy with method
  MaintenanceType copyWith({
    String? company,
    int? maintenanceID,
    String? maintenanceType,
  }) {
    return MaintenanceType(
      company: company ?? this.company,
      maintenanceID: maintenanceID ?? this.maintenanceID,
      maintenanceType: maintenanceType ?? this.maintenanceType,
    );
  }

  // From JSON factory constructor
  factory MaintenanceType.fromJson(Map<String, dynamic> json) {
    return MaintenanceType(
      company: json['Company'],
      maintenanceID: json['MaintenanceID'],
      maintenanceType: json['MaintenanceType'],
    );
  }

  // To JSON method
  Map<String, dynamic> toJson() {
    return {
      'Company': company,
      'MaintenanceID': maintenanceID,
      'MaintenanceType': maintenanceType,
    };
  }

  // toString method
  @override
  String toString() {
    return 'MaintenanceType{company: $company, maintenanceID: $maintenanceID, maintenanceType: $maintenanceType}';
  }
}