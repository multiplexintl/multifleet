class VehicleMaintenance {
  String? company;
  String? vehicleNo;
  int? slNo;
  String? dt;
  String? invoiceNo;
  int? vendorId;
  int? maintenanceId;
  double? amount;
  String? remarks;
  String? status;
  String? image1;
  String? maintenanceType;
  String? vendorName;

  VehicleMaintenance({
    this.company,
    this.vehicleNo,
    this.slNo,
    this.dt,
    this.invoiceNo,
    this.vendorId,
    this.maintenanceId,
    this.amount,
    this.remarks,
    this.status,
    this.image1,
    this.maintenanceType,
    this.vendorName,
  });

  @override
  String toString() {
    return 'VehicleMaintenance(company: $company, vehicleNo: $vehicleNo, slNo: $slNo, dt: $dt, invoiceNo: $invoiceNo, vendorId: $vendorId, maintenanceId: $maintenanceId, amount: $amount, remarks: $remarks, status: $status, image1: $image1, maintenanceType: $maintenanceType, vendorName: $vendorName)';
  }

  factory VehicleMaintenance.fromJson(Map<String, dynamic> json) {
    return VehicleMaintenance(
      company: json['Company'] as String?,
      vehicleNo: json['VehicleNo'] as String?,
      slNo: json['SlNo'] as int?,
      dt: json['Dt'] as String?,
      invoiceNo: json['InvoiceNo'] as String?,
      vendorId: json['VendorID'] as int?,
      maintenanceId: json['MaintenanceID'] as int?,
      amount: (json['Amount'] as num?)?.toDouble(),
      remarks: json['Remarks'] as String?,
      status: json['Status'] as String?,
      image1: json['Image1'] as String?,
      maintenanceType: json['MaintenanceType'] as String?,
      vendorName: json['VendorName'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'Company': company,
        'VehicleNo': vehicleNo,
        'SlNo': slNo,
        'Dt': dt,
        'InvoiceNo': invoiceNo,
        'VendorID': vendorId,
        'MaintenanceID': maintenanceId,
        'Amount': amount,
        'Remarks': remarks,
        'Status': status,
        'Image1': image1,
        'MaintenanceType': maintenanceType,
        'VendorName': vendorName,
      };

  VehicleMaintenance copyWith({
    String? company,
    String? vehicleNo,
    int? slNo,
    String? dt,
    String? invoiceNo,
    int? vendorId,
    int? maintenanceId,
    double? amount,
    String? remarks,
    String? status,
    String? image1,
    String? maintenanceType,
    String? vendorName,
  }) {
    return VehicleMaintenance(
      company: company ?? this.company,
      vehicleNo: vehicleNo ?? this.vehicleNo,
      slNo: slNo ?? this.slNo,
      dt: dt ?? this.dt,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      vendorId: vendorId ?? this.vendorId,
      maintenanceId: maintenanceId ?? this.maintenanceId,
      amount: amount ?? this.amount,
      remarks: remarks ?? this.remarks,
      status: status ?? this.status,
      image1: image1 ?? this.image1,
      maintenanceType: maintenanceType ?? this.maintenanceType,
      vendorName: vendorName ?? this.vendorName,
    );
  }
}
