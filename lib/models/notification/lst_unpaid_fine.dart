class LstUnpaidFine {
  int? fineId;
  String? company;
  String? vehicleNo;
  String? empNo;
  String? fineType;
  String? fineDate;
  String? location;
  String? ticketNo;
  String? emirate;
  String? issuingAuthority;
  String? reason;
  String? status;
  String? empName;

  LstUnpaidFine({
    this.fineId,
    this.company,
    this.vehicleNo,
    this.empNo,
    this.fineType,
    this.fineDate,
    this.location,
    this.ticketNo,
    this.emirate,
    this.issuingAuthority,
    this.reason,
    this.status,
    this.empName,
  });

  @override
  String toString() {
    return 'LstUnpaidFine(fineId: $fineId, company: $company, vehicleNo: $vehicleNo, empNo: $empNo, fineType: $fineType, fineDate: $fineDate, location: $location, ticketNo: $ticketNo, emirate: $emirate, issuingAuthority: $issuingAuthority, reason: $reason, status: $status, empName: $empName)';
  }

  factory LstUnpaidFine.fromJson(Map<String, dynamic> json) => LstUnpaidFine(
        fineId: json['FineID'] as int?,
        company: json['Company'] as String?,
        vehicleNo: json['VehicleNo'] as String?,
        empNo: json['EmpNo'] as String?,
        fineType: json['FineType'] as String?,
        fineDate: json['FineDate'] as String?,
        location: json['Location'] as String?,
        ticketNo: json['TicketNo'] as String?,
        emirate: json['Emirate'] as String?,
        issuingAuthority: json['IssuingAuthority'] as String?,
        reason: json['Reason'] as String?,
        status: json['Status'] as String?,
        empName: json['EmpName'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'FineID': fineId,
        'Company': company,
        'VehicleNo': vehicleNo,
        'EmpNo': empNo,
        'FineType': fineType,
        'FineDate': fineDate,
        'Location': location,
        'TicketNo': ticketNo,
        'Emirate': emirate,
        'IssuingAuthority': issuingAuthority,
        'Reason': reason,
        'Status': status,
        'EmpName': empName,
      };

  LstUnpaidFine copyWith({
    int? fineId,
    String? company,
    String? vehicleNo,
    String? empNo,
    String? fineType,
    String? fineDate,
    String? location,
    String? ticketNo,
    String? emirate,
    String? issuingAuthority,
    String? reason,
    String? status,
    String? empName,
  }) {
    return LstUnpaidFine(
      fineId: fineId ?? this.fineId,
      company: company ?? this.company,
      vehicleNo: vehicleNo ?? this.vehicleNo,
      empNo: empNo ?? this.empNo,
      fineType: fineType ?? this.fineType,
      fineDate: fineDate ?? this.fineDate,
      location: location ?? this.location,
      ticketNo: ticketNo ?? this.ticketNo,
      emirate: emirate ?? this.emirate,
      issuingAuthority: issuingAuthority ?? this.issuingAuthority,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      empName: empName ?? this.empName,
    );
  }
}
