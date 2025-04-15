class VehicleDocument {
  final String? company;
  final String? vehicleNo;
  final int? docType;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final String? issueAuthority;
  final String? city;

  VehicleDocument({
    this.company,
    this.vehicleNo,
    this.docType,
    this.issueDate,
    this.expiryDate,
    this.issueAuthority,
    this.city,
  });

  // Copy with method
  VehicleDocument copyWith({
    String? company,
    String? vehicleNo,
    int? docType,
    DateTime? issueDate,
    DateTime? expiryDate,
    String? issueAuthority,
    String? city,
  }) {
    return VehicleDocument(
      company: company ?? this.company,
      vehicleNo: vehicleNo ?? this.vehicleNo,
      docType: docType ?? this.docType,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      issueAuthority: issueAuthority ?? this.issueAuthority,
      city: city ?? this.city,
    );
  }

  // From JSON factory constructor
  factory VehicleDocument.fromJson(Map<String, dynamic> json) {
    return VehicleDocument(
      company: json['Company'],
      vehicleNo: json['VehicleNo'],
      docType: json['DocType'],
      issueDate: json['IssueDate'] != null ? DateTime.parse(json['IssueDate']) : null,
      expiryDate: json['ExpiryDate'] != null ? DateTime.parse(json['ExpiryDate']) : null,
      issueAuthority: json['IssueAuthority'],
      city: json['City'],
    );
  }

  // To JSON method
  Map<String, dynamic> toJson() {
    return {
      'Company': company,
      'VehicleNo': vehicleNo,
      'DocType': docType,
      'IssueDate': issueDate?.toIso8601String(),
      'ExpiryDate': expiryDate?.toIso8601String(),
      'IssueAuthority': issueAuthority,
      'City': city,
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
    return 'VehicleDocument{company: $company, vehicleNo: $vehicleNo, docType: $docType, '
        'issueDate: ${formatDate(issueDate)}, expiryDate: ${formatDate(expiryDate)}, '
        'issueAuthority: $issueAuthority, city: $city}';
  }
}