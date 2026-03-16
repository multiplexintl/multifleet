class FuelStation {
  String? company;
  int? fuelStationId;
  String? fuelStation;

  FuelStation({this.company, this.fuelStationId, this.fuelStation});

  @override
  String toString() {
    return 'FuelStation(company: $company, fuelStationId: $fuelStationId, fuelStation: $fuelStation)';
  }

  factory FuelStation.fromJson(Map<String, dynamic> json) => FuelStation(
        company: json['Company'] as String?,
        fuelStationId: json['FuelStationID'] as int?,
        fuelStation: json['FuelStation'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'Company': company,
        'FuelStationID': fuelStationId,
        'FuelStation': fuelStation,
      };

  FuelStation copyWith({
    String? company,
    int? fuelStationId,
    String? fuelStation,
  }) {
    return FuelStation(
      company: company ?? this.company,
      fuelStationId: fuelStationId ?? this.fuelStationId,
      fuelStation: fuelStation ?? this.fuelStation,
    );
  }
}
