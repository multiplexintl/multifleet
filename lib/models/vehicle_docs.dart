class VehicleDocument {
  final int id;
  final String? company;
  final String? vehicleNo;
  final int? docType;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final String? issueAuthority;
  final String? city;
  final String? documentNo;
  final String? remarks;
  final String? status;
  final double? amount;

  VehicleDocument({
    this.id = 0,
    this.company,
    this.vehicleNo,
    this.docType,
    this.issueDate,
    this.expiryDate,
    this.issueAuthority,
    this.city,
    this.remarks,
    this.documentNo,
    this.status,
    this.amount,
  });

  // Copy with method
  VehicleDocument copyWith({
    int? id,
    String? company,
    String? vehicleNo,
    int? docType,
    DateTime? issueDate,
    DateTime? expiryDate,
    String? issueAuthority,
    String? city,
    String? remarks,
    String? documentNo,
    String? status,
    double? amount,
  }) {
    return VehicleDocument(
      id: id ?? this.id,
      company: company ?? this.company,
      vehicleNo: vehicleNo ?? this.vehicleNo,
      docType: docType ?? this.docType,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      issueAuthority: issueAuthority ?? this.issueAuthority,
      city: city ?? this.city,
      remarks: remarks ?? this.remarks,
      documentNo: documentNo ?? this.documentNo,
      status: status ?? this.status,
      amount: amount ?? this.amount,
    );
  }

  // "VehDocID": 11,
  // "Company": "EPIC01",
  // "VehicleNo": "D-25501",
  // "DocType": 1002,
  // "IssueDate": "2025-01-25T00:00:00",
  // "ExpiryDate": "2025-04-01T00:00:00",
  // "IssueAuthority": "RTA",
  // "City": "Dubai",
  // "DocNo": "",
  // "Status": "Expired"

  // From JSON factory constructor
  factory VehicleDocument.fromJson(Map<String, dynamic> json) {
    return VehicleDocument(
      id: json['VehDocID'],
      company: json['Company'],
      vehicleNo: json['VehicleNo'],
      docType: json['DocType'],
      issueDate:
          json['IssueDate'] != null ? DateTime.parse(json['IssueDate']) : null,
      expiryDate: json['ExpiryDate'] != null
          ? DateTime.parse(json['ExpiryDate'])
          : null,
      issueAuthority: json['IssueAuthority'],
      city: json['City'],
      documentNo: json['DocNo'],
      remarks: json['Remarks'],
      status: json['Status'],
      amount: json['Amount'] != null ? (json['Amount'] as num).toDouble() : null,
    );
  }

  // To JSON method
  Map<String, dynamic> toJson() {
    return {
      'VehDocID': id,
      'Company': company,
      'VehicleNo': vehicleNo,
      'DocType': docType,
      'IssueDate': issueDate?.toIso8601String(),
      'ExpiryDate': expiryDate?.toIso8601String(),
      'IssueAuthority': issueAuthority,
      'City': city,
      'Remarks': remarks,
      'DocNo': documentNo,
      'Status': status,
      'Amount': amount,
    };
  }

  // Format date to DD/MM/YYYY
  String formatDate(DateTime? date) {
    if (date == null) {
      return '';
    }
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // toString method
  @override
  String toString() {
    return 'VehicleDocument{id: $id, company: $company, vehicleNo: $vehicleNo, docType: $docType, '
        'issueDate: ${formatDate(issueDate)}, expiryDate: ${formatDate(expiryDate)}, '
        'issueAuthority: $issueAuthority, city: $city, documentNo: $documentNo, remarks: $remarks, status: $status, amount: $amount}';
  }
}
