/// MaintenanceRecord model for individual service/maintenance entries
/// Matches API: GET Master/GetVehicleMaintenance & POST Vehicle/VehicleMaintenance
class MaintenanceRecord {
  final String? company;
  final int? slNo; // API: SlNo (0 for new, existing for update)
  final String? vehicleNo;
  final String? dt; // API: Dt (date string "YYYY-MM-DD")
  final String? invoiceNo; // API: InvoiceNo
  final int? vendorID; // API: VendorID (garage/workshop)
  final String? vendorName; // API: VendorName (denormalized)
  final int? maintenanceID; // API: MaintenanceID
  final String? maintenanceType; // API: MaintenanceType (denormalized)
  final double? amount; // API: Amount
  final String? remarks; // API: Remarks
  final String? status; // API: Status (e.g. "Scheduled", "Closed")
  final String? image1; // API: Image1

  // Computed / display helpers
  DateTime? get serviceDate => dt != null ? DateTime.tryParse(dt!) : null;

  MaintenanceRecord({
    this.company,
    this.slNo,
    this.vehicleNo,
    this.dt,
    this.invoiceNo,
    this.vendorID,
    this.vendorName,
    this.maintenanceID,
    this.maintenanceType,
    this.amount,
    this.remarks,
    this.status,
    this.image1,
  });

  factory MaintenanceRecord.fromJson(Map<String, dynamic> json) {
    return MaintenanceRecord(
      company: json['Company'] as String?,
      slNo: json['SlNo'] as int?,
      vehicleNo: json['VehicleNo'] as String?,
      dt: json['Dt'] as String?,
      invoiceNo: json['InvoiceNo'] as String?,
      vendorID: json['VendorID'] as int?,
      vendorName: json['VendorName'] as String?,
      maintenanceID: json['MaintenanceID'] as int?,
      maintenanceType: json['MaintenanceType'] as String?,
      amount: (json['Amount'] as num?)?.toDouble(),
      remarks: json['Remarks'] as String?,
      status: json['Status'] as String?,
      image1: json['Image1'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'Company': company,
        'VehicleNo': vehicleNo,
        'SlNo': slNo ?? 0,
        'Dt': dt,
        'InvoiceNo': invoiceNo,
        'VendorID': vendorID,
        'MaintenanceID': maintenanceID,
        'Amount': amount,
        'Remarks': remarks,
        'Status': status,
        'Image1': image1 ?? '',
      };

  MaintenanceRecord copyWith({
    String? company,
    int? slNo,
    String? vehicleNo,
    String? dt,
    String? invoiceNo,
    int? vendorID,
    String? vendorName,
    int? maintenanceID,
    String? maintenanceType,
    double? amount,
    String? remarks,
    String? status,
    String? image1,
  }) {
    return MaintenanceRecord(
      company: company ?? this.company,
      slNo: slNo ?? this.slNo,
      vehicleNo: vehicleNo ?? this.vehicleNo,
      dt: dt ?? this.dt,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      vendorID: vendorID ?? this.vendorID,
      vendorName: vendorName ?? this.vendorName,
      maintenanceID: maintenanceID ?? this.maintenanceID,
      maintenanceType: maintenanceType ?? this.maintenanceType,
      amount: amount ?? this.amount,
      remarks: remarks ?? this.remarks,
      status: status ?? this.status,
      image1: image1 ?? this.image1,
    );
  }

  @override
  String toString() =>
      'MaintenanceRecord(slNo: $slNo, vehicleNo: $vehicleNo, '
      'type: $maintenanceType, dt: $dt, amount: $amount)';
}
