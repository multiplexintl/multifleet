class User {
  String? company;
  String? empNo;
  String? empName;
  String? status;

  User({this.company, this.empNo, this.empName, this.status});

  @override
  String toString() {
    return 'User(company: $company, empNo: $empNo, empName: $empName, status: $status)';
  }

  factory User.fromJson(Map<String, dynamic> json) => User(
        company: json['Company'] as String?,
        empNo: json['EmpNo'] as String?,
        empName: json['EmpName'] as String?,
        status: json['Status'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'Company': company,
        'EmpNo': empNo,
        'EmpName': empName,
        'Status': status,
      };
}
