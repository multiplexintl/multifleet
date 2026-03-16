import 'package:multifleet/models/status_master/status_master.dart';

class Tyre {
  final String company;
  final int tyreId;
  final String vehicleNo;
  final StatusMaster? position;
  final String? brand;
  final String? size;
  final DateTime? installDt;
  final DateTime? expDt;
  final int? kmUsed;
  final String? remarks;
  final String? status;
  final DateTime? createdDt;
  final bool deleteAllowed;

  // Constructor
  Tyre({
    required this.company,
    required this.tyreId,
    required this.vehicleNo,
    this.position,
    this.brand,
    this.size,
    this.installDt,
    this.expDt,
    this.kmUsed,
    this.remarks,
    this.status,
    this.createdDt,
    this.deleteAllowed = false,
  });

  // Copy with method
  Tyre copyWith({
    String? company,
    int? tyreId,
    String? vehicleNo,
    StatusMaster? position,
    String? brand,
    String? size,
    DateTime? installDt,
    DateTime? expDt,
    int? kmUsed,
    String? remarks,
    String? status,
    DateTime? createdDt,
    bool? deleteAllowed,
  }) {
    return Tyre(
      company: company ?? this.company,
      tyreId: tyreId ?? this.tyreId,
      vehicleNo: vehicleNo ?? this.vehicleNo,
      position: position ?? this.position,
      brand: brand ?? this.brand,
      size: size ?? this.size,
      installDt: installDt ?? this.installDt,
      expDt: expDt ?? this.expDt,
      kmUsed: kmUsed ?? this.kmUsed,
      remarks: remarks ?? this.remarks,
      status: status ?? this.status,
      createdDt: createdDt ?? this.createdDt,
      deleteAllowed: deleteAllowed ?? this.deleteAllowed,
    );
  }

  // From JSON factory constructor with minimum date handling
  factory Tyre.fromJson(Map<String, dynamic> json) {
    // Position comes as a string from GET; PositionID may or may not be present.
    final posStr = json['Position'] as String?;
    final posId = json['PositionID'] as int?;
    final positionMaster =
        posStr != null ? StatusMaster(statusId: posId, status: posStr) : null;

    return Tyre(
      company: json['Company'],
      tyreId: json['TyreId'],
      vehicleNo: json['VehicleNo'],
      position: positionMaster,
      brand: json['Brand'],
      size: json['Size'],
      installDt: _parseDate(json['InstallDt']),
      expDt: _parseDate(json['ExpDt']),
      kmUsed: json['KMUsed'],
      remarks: json['Remarks'],
      status: json['Status'],
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
      'Company': company,
      'TyreId': tyreId,
      'VehicleNo': vehicleNo,
      'Position': position?.statusId,
      // 'Position': position?.status,
      'Brand': brand,
      'Size': size,
      'InstallDt': installDt?.toIso8601String(),
      'ExpDt': expDt?.toIso8601String(),
      'KMUsed': kmUsed,
      'Remarks': remarks,
      'Status': status,
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
    return 'Tyre{ company: $company, tyreId: $tyreId, vehicleNo: $vehicleNo, position: $position, brand: $brand, size: $size, installDt: ${formatDate(installDt)}, expDt: ${formatDate(expDt)}, kmUsed: $kmUsed, remarks: $remarks, status: $status, createdDt: ${formatDate(createdDt)}}';
  }
}

// [
//     {
//         "TyreId": 197,
//         "VehicleNo": "DXB-10012",
//         "Position": "Front Left (FL)",
//         "Brand": "Yokohama",
//         "Size": "205/65R16",
//         "InstallDt": "2026-02-17T00:00:00",
//         "ExpDt": "2028-02-17T00:00:00",
//         "KMUsed": 18980,
//         "Remarks": "",
//         "CreatedDt": "2026-02-17T17:19:33",
//         "Status": "Active",
//         "Company": "EPIC01"
//     },
//     {
//         "TyreId": 198,
//         "VehicleNo": "DXB-10012",
//         "Position": "Front Right (FR)",
//         "Brand": "Yokohama",
//         "Size": "205/65R16",
//         "InstallDt": "2025-10-17T00:00:00",
//         "ExpDt": "2028-02-17T00:00:00",
//         "KMUsed": 18707,
//         "Remarks": "",
//         "CreatedDt": "2026-02-17T17:19:33",
//         "Status": "Active",
//         "Company": "EPIC01"
//     }
// ]
