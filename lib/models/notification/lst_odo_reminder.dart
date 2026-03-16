class LstOdoReminder {
  String? company;
  String? vehicleNo;
  int? currentOdo;

  LstOdoReminder({this.company, this.vehicleNo, this.currentOdo});

  @override
  String toString() {
    return 'LstOdoReminder(company: $company, vehicleNo: $vehicleNo, currentOdo: $currentOdo)';
  }

  factory LstOdoReminder.fromJson(Map<String, dynamic> json) {
    return LstOdoReminder(
      company: json['Company'] as String?,
      vehicleNo: json['VehicleNo'] as String?,
      currentOdo: json['CurrentOdo'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'Company': company,
        'VehicleNo': vehicleNo,
        'CurrentOdo': currentOdo,
      };

  LstOdoReminder copyWith({
    String? company,
    String? vehicleNo,
    int? currentOdo,
  }) {
    return LstOdoReminder(
      company: company ?? this.company,
      vehicleNo: vehicleNo ?? this.vehicleNo,
      currentOdo: currentOdo ?? this.currentOdo,
    );
  }
}
