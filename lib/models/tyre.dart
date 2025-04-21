class Tyre {
  final int? tyreId;
  final String? vehicleNo;
  final String? position;
  final String? brand;
  final String? size;
  final DateTime? installDt;
  final DateTime? expDt;
  final int? kmUsed;
  final String? remarks;
  final DateTime? createdDt;

  Tyre({
    this.tyreId,
    this.vehicleNo,
    this.position,
    this.brand,
    this.size,
    this.installDt,
    this.expDt,
    this.kmUsed,
    this.remarks,
    this.createdDt,
  });

  // Copy with method
  Tyre copyWith({
    int? tyreId,
    String? vehicleNo,
    String? position,
    String? brand,
    String? size,
    DateTime? installDt,
    DateTime? expDt,
    int? kmUsed,
    String? remarks,
    DateTime? createdDt,
  }) {
    return Tyre(
      tyreId: tyreId ?? this.tyreId,
      vehicleNo: vehicleNo ?? this.vehicleNo,
      position: position ?? this.position,
      brand: brand ?? this.brand,
      size: size ?? this.size,
      installDt: installDt ?? this.installDt,
      expDt: expDt ?? this.expDt,
      kmUsed: kmUsed ?? this.kmUsed,
      remarks: remarks ?? this.remarks,
      createdDt: createdDt ?? this.createdDt,
    );
  }

  // From JSON factory constructor with minimum date handling
  factory Tyre.fromJson(Map<String, dynamic> json) {
    return Tyre(
      tyreId: json['TyreId'],
      vehicleNo: json['VehicleNo'],
      position: json['Position'],
      brand: json['Brand'],
      size: json['Size'],
      installDt: _parseDate(json['InstallDt']),
      expDt: _parseDate(json['ExpDt']),
      kmUsed: json['KMUsed'],
      remarks: json['Remarks'],
      createdDt: _parseDate(json['CreatedDt']),
    );
  }

  // Helper method to parse dates and handle minimum date values
  static DateTime? _parseDate(dynamic dateValue) {
    if (dateValue == null) return null;

    try {
      final date = DateTime.parse(dateValue.toString());

      // Check if this is a minimum date (year 1 or 0001-01-01)
      if (date.year <= 1) return null;

      return date;
    } catch (e) {
      return null; // Return null for invalid dates
    }
  }

  // To JSON method
  Map<String, dynamic> toJson() {
    return {
      'TyreId': tyreId,
      'VehicleNo': vehicleNo,
      'Position': position,
      'Brand': brand,
      'Size': size,
      'InstallDt': installDt?.toIso8601String(),
      'ExpDt': expDt?.toIso8601String(),
      'KMUsed': kmUsed,
      'Remarks': remarks,
      'CreatedDt': createdDt?.toIso8601String(),
    };
  }

  // Format date to DD/MM/YYYY with null handling
  String formatDate(DateTime? date) {
    if (date == null || date.year <= 1) {
      return '';
    }
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // toString method
  @override
  String toString() {
    return 'Tyre{tyreId: $tyreId, vehicleNo: $vehicleNo, position: $position, brand: $brand, size: $size, '
        'installDt: ${formatDate(installDt)}, expDt: ${formatDate(expDt)}, kmUsed: $kmUsed, '
        'remarks: $remarks, createdDt: ${formatDate(createdDt)}}';
  }
}
