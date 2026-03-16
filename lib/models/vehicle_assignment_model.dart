import 'package:flutter/material.dart';
import 'package:multifleet/models/status_master/status_master.dart';

class VehicleAssignment {
  String? company;
  String? vehicleNo;
  String? empNo;
  String? empName;
  String? designation;
  String? assignedDate;
  String? returnDate;
  String? remarks;
  String? image1;
  String? image2;
  String? image3;
  String? image4;
  String? image5;
  String? image6;

  /// Full status object (populated from GET response via master lookup).
  StatusMaster? status;

  /// Raw status ID from API — used for POST body.
  int? statusId;

  VehicleAssignment({
    this.company,
    this.vehicleNo,
    this.empNo,
    this.empName,
    this.designation,
    this.assignedDate,
    this.returnDate,
    this.remarks,
    this.image1,
    this.image2,
    this.image3,
    this.image4,
    this.image5,
    this.image6,
    this.status,
    this.statusId,
  });

  @override
  String toString() {
    return 'VehicleAssignment(company: $company, vehicleNo: $vehicleNo, '
        'empNo: $empNo, empName: $empName, designation: $designation, '
        'assignedDate: $assignedDate, returnDate: $returnDate, '
        'remarks: $remarks, status: $status, statusId: $statusId)';
  }

  factory VehicleAssignment.fromJson(Map<String, dynamic> json) {
    return VehicleAssignment(
      company: json['Company'] as String?,
      vehicleNo: json['VehicleNo'] as String?,
      empNo: json['EmpNo'] as String?,
      empName: json['EmpName'] as String?,
      designation: json['Designation'] as String?,
      assignedDate: json['AssignedDate'] as String?,
      returnDate: json['ReturnDate'] as String?,
      remarks: json['Remarks'] as String?,
      image1: json['Image1'] as String?,
      image2: json['Image2'] as String?,
      image3: json['Image3'] as String?,
      image4: json['Image4'] as String?,
      image5: json['Image5'] as String?,
      image6: json['Image6'] as String?,
      // Build a StatusMaster from the flat GET fields
      status: (json['StatusID'] != null || json['Status'] != null)
          ? StatusMaster(
              statusId: json['StatusID'] as int?,
              status: json['Status'] as String?,
            )
          : null,
      statusId: json['StatusID'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'Company': company,
        'VehicleNo': vehicleNo,
        'EmpNo': empNo,
        'EmpName': empName,
        'Designation': designation,
        'AssignedDate': assignedDate,
        'ReturnDate': returnDate,
        'Remarks': remarks,
        'Image1': image1,
        'Image2': image2,
        'Image3': image3,
        'Image4': image4,
        'Image5': image5,
        'Image6': image6,
        'Status': status?.status,
        'StatusID': statusId ?? status?.statusId,
      };

  /// Payload used for INSERT / UPDATE calls.
  Map<String, dynamic> toJsonAssignUpdate() => {
        'Company': company,
        'VehicleNo': vehicleNo,
        'EmpNo': empNo,
        'AssignedDate': assignedDate,
        'ReturnDate': returnDate,
        'Remarks': remarks,
        'Image1': image1,
        'Image2': image2,
        'Image3': image3,
        'Image4': image4,
        'Image5': image5,
        'Image6': image6,
        'VehicleAssignmentStatusID': statusId ?? status?.statusId,
      };

  VehicleAssignment copyWith({
    String? company,
    String? vehicleNo,
    String? empNo,
    String? empName,
    String? designation,
    String? assignedDate,
    String? returnDate,
    String? remarks,
    String? image1,
    String? image2,
    String? image3,
    String? image4,
    String? image5,
    String? image6,
    StatusMaster? status,
    int? statusId,
  }) {
    return VehicleAssignment(
      company: company ?? this.company,
      vehicleNo: vehicleNo ?? this.vehicleNo,
      empNo: empNo ?? this.empNo,
      empName: empName ?? this.empName,
      designation: designation ?? this.designation,
      assignedDate: assignedDate ?? this.assignedDate,
      returnDate: returnDate ?? this.returnDate,
      remarks: remarks ?? this.remarks,
      image1: image1 ?? this.image1,
      image2: image2 ?? this.image2,
      image3: image3 ?? this.image3,
      image4: image4 ?? this.image4,
      image5: image5 ?? this.image5,
      image6: image6 ?? this.image6,
      status: status ?? this.status,
      statusId: statusId ?? this.statusId,
    );
  }
}

/// Returns the display color for a given assignment status string.
/// Used by both the dropdown and the assignment detail card.
Color assignmentStatusColor(String? status) {
  switch ((status ?? '').toLowerCase()) {
    case 'assigned':
      return const Color(0xFF2196F3); // blue
    case 'returned':
      return const Color(0xFF4CAF50); // green
    case 'terminated':
      return const Color(0xFFF44336); // red
    case 'on leave':
      return const Color(0xFFFF9800); // orange
    case 'pending':
      return const Color(0xFFFFC107); // amber
    case 'active':
      return const Color(0xFF4CAF50); // green
    case 'inactive':
      return const Color(0xFF9E9E9E); // grey
    default:
      return const Color(0xFF9E9E9E); // grey
  }
}

// GET json
// [
//     {
//         "Company": "EPIC01",
//         "VehicleNo": "DXB-10011",
//         "EmpNo": "MX0071",
//         "EmpName": "Bhim Prasad Laksam",
//         "Designation": "Driver",
//         "AssignedDate": "2026-02-19T00:00:00",
//         "ReturnDate": null,
//         "Remarks": "awsef",
//         "Image1": "",
//         "Image2": "",
//         "Image3": "",
//         "Image4": "",
//         "Image5": "",
//         "Image6": "",
//         "Status": "Assigned",
//         "StatusID": 1
//     }
// ]

// POST Json
// {
//   "Company": "EPIC01",
//   "VehicleNo": "AB-99675",
//   "EmpNo": "MX1559",
//   "AssignedDate": "2027-01-01",
//   "ReturnDate": "2027-01-31",
//   "Remarks": "",
//   "Image1": null,
//   "Image2": null,
//   "Image3": null,
//   "Image4": null,
//   "Image5": null,
//   "Image6": null,
//   "VehicleAssignmentStatusID":1
// }
