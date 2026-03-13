/// Employee status codes: 'A' = Active, 'R' = Resigned, 'T' = Terminated
class Employee {
  String? company;
  String? empNo;
  String? empName;
  String? designation;
  String? department;
  String? phone;
  String? email;
  String? licenseNo;
  String? licenseExpiry;
  String? nationality;
  String? remarks;
  String? stat; // 'A' | 'R' | 'T'

  Employee({
    this.company,
    this.empNo,
    this.empName,
    this.designation,
    this.department,
    this.phone,
    this.email,
    this.licenseNo,
    this.licenseExpiry,
    this.nationality,
    this.remarks,
    this.stat,
  });

  @override
  String toString() {
    return 'Employee(company: $company, empNo: $empNo, empName: $empName, designation: $designation)';
  }

  bool get isActive => stat == null || stat == 'A';

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
        company: json['Company'] as String?,
        empNo: json['EmpNo'] as String?,
        empName: json['EmpName'] as String?,
        designation: json['Designation'] as String?,
        department: json['Department'] as String?,
        phone: json['Phone'] as String?,
        email: json['Email'] as String?,
        licenseNo: json['LicenseNo'] as String?,
        licenseExpiry: json['LicenseExpiry'] as String?,
        nationality: json['Nationality'] as String?,
        remarks: json['Remarks'] as String?,
        stat: json['Stat'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'Company': company,
        'EmpNo': empNo,
        'EmpName': empName,
        'Designation': designation,
        'Department': department,
        'Phone': phone,
        'Email': email,
        'LicenseNo': licenseNo,
        'LicenseExpiry': licenseExpiry,
        'Nationality': nationality,
        'Remarks': remarks,
        'Stat': stat ?? 'A',
      };

  Employee copyWith({
    String? company,
    String? empNo,
    String? empName,
    String? designation,
    String? department,
    String? phone,
    String? email,
    String? licenseNo,
    String? licenseExpiry,
    String? nationality,
    String? remarks,
    String? stat,
  }) {
    return Employee(
      company: company ?? this.company,
      empNo: empNo ?? this.empNo,
      empName: empName ?? this.empName,
      designation: designation ?? this.designation,
      department: department ?? this.department,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      licenseNo: licenseNo ?? this.licenseNo,
      licenseExpiry: licenseExpiry ?? this.licenseExpiry,
      nationality: nationality ?? this.nationality,
      remarks: remarks ?? this.remarks,
      stat: stat ?? this.stat,
    );
  }
}
