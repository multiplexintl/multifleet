class LstDocExpiry {
  int? vehDocId;
  String? company;
  String? vehicleNo;
  String? docNo;
  String? issueDate;
  String? expiryDate;
  String? issueAuthority;
  String? city;
  String? remarks;
  String? docDescription;
  String? status;

  LstDocExpiry({
    this.vehDocId,
    this.company,
    this.vehicleNo,
    this.docNo,
    this.issueDate,
    this.expiryDate,
    this.issueAuthority,
    this.city,
    this.remarks,
    this.docDescription,
    this.status,
  });

  @override
  String toString() {
    return 'LstDocExpiry(vehDocId: $vehDocId, company: $company, vehicleNo: $vehicleNo, docNo: $docNo, issueDate: $issueDate, expiryDate: $expiryDate, issueAuthority: $issueAuthority, city: $city, remarks: $remarks, docDescription: $docDescription, status: $status)';
  }

  factory LstDocExpiry.fromJson(Map<String, dynamic> json) => LstDocExpiry(
        vehDocId: json['VehDocID'] as int?,
        company: json['Company'] as String?,
        vehicleNo: json['VehicleNo'] as String?,
        docNo: json['DocNo'] as String?,
        issueDate: json['IssueDate'] as String?,
        expiryDate: json['ExpiryDate'] as String?,
        issueAuthority: json['IssueAuthority'] as String?,
        city: json['City'] as String?,
        remarks: json['Remarks'] as String?,
        docDescription: json['DocDescription'] as String?,
        status: json['Status'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'VehDocID': vehDocId,
        'Company': company,
        'VehicleNo': vehicleNo,
        'DocNo': docNo,
        'IssueDate': issueDate,
        'ExpiryDate': expiryDate,
        'IssueAuthority': issueAuthority,
        'City': city,
        'Remarks': remarks,
        'DocDescription': docDescription,
        'Status': status,
      };

  // Format date to DD/MM/YYYY
  String formatDate(String? date) {
    if (date == null) {
      return '';
    }
    DateTime dateTime = DateTime.parse(date);
    return _formatDate(dateTime);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  LstDocExpiry copyWith({
    int? vehDocId,
    String? company,
    String? vehicleNo,
    String? docNo,
    String? issueDate,
    String? expiryDate,
    String? issueAuthority,
    String? city,
    String? remarks,
    String? docDescription,
    String? status,
  }) {
    return LstDocExpiry(
      vehDocId: vehDocId ?? this.vehDocId,
      company: company ?? this.company,
      vehicleNo: vehicleNo ?? this.vehicleNo,
      docNo: docNo ?? this.docNo,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      issueAuthority: issueAuthority ?? this.issueAuthority,
      city: city ?? this.city,
      remarks: remarks ?? this.remarks,
      docDescription: docDescription ?? this.docDescription,
      status: status ?? this.status,
    );
  }
}
