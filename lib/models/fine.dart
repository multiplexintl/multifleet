import 'package:multifleet/models/city/city.dart';
import 'package:multifleet/models/fine_type/fine_type.dart';

import 'status_master/status_master.dart';

class Fine {
  int? fineId;
  String? company;
  String? vehicleNo;
  String? empNo;
  String? empName;
  String? designation;
  // int? fineTypeId;
  FineType? fineType;
  String? fineDate;
  double? amount;
  String? location;
  String? ticketNo;
  City? emirate;
  String? issuingAuthority;
  String? reason;
  // int? fineStatusId;
  StatusMaster? status;
  String? remarks;

  Fine({
    this.fineId,
    this.company,
    this.vehicleNo,
    this.empNo,
    this.empName,
    this.designation,
    this.fineType,
    this.fineDate,
    this.amount,
    this.location,
    this.ticketNo,
    this.emirate,
    this.issuingAuthority,
    this.reason,
    this.status,
    this.remarks,
  });

  @override
  String toString() {
    return 'Fine(fineId: $fineId, company: $company, vehicleNo: $vehicleNo, empNo: $empNo, empName: $empName, fineType: $fineType, fineDate: $fineDate, amount: $amount, location: $location, ticketNo: $ticketNo, emirate: $emirate, issuingAuthority: $issuingAuthority, reason: $reason, status: $status)';
  }

  factory Fine.fromJson(Map<String, dynamic> json) {
    var fineType = FineType(
      company: json['Company'] as String?,
      fineTypeId: json['FineTypeID'] as int?,
      fineType: json['FineType'] as String?,
    );

    var fineStatus = StatusMaster(
      statusId: json['FineStatusID'] as int?,
      status: json['Status'] as String?,
    );
    var city = City(
        company: json['Company'] as String?, city: json['Emirate'] as String?);

    return Fine(
      fineId: json['FineID'] as int?,
      company: json['Company'] as String?,
      vehicleNo: json['VehicleNo'] as String?,
      empNo: json['EmpNo'] as String?,
      empName: json['EmpName'] as String?,
      designation: json['Designation'] as String?,
      fineType: fineType,
      fineDate: json['FineDate'] as String?,
      amount: json['Amount'] != null
          ? (json['Amount'] is int
              ? (json['Amount'] as int).toDouble()
              : json['Amount'] as double)
          : null,
      location: json['Location'] as String?,
      ticketNo: json['TicketNo'] as String?,
      emirate: city,
      issuingAuthority: json['IssuingAuthority'] as String?,
      reason: json['Reason'] as String?,
      status: fineStatus,
      remarks: json['Remarks'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'FineID': fineId,
        'Company': company,
        'VehicleNo': vehicleNo,
        'EmpNo': empNo,
        'EmpName': empName,
        'Designation': designation,
        'FineTypeID': fineType?.fineTypeId,
        'FineType': fineType?.fineType,
        'FineDate': fineDate,
        'Amount': amount,
        'Location': location,
        'TicketNo': ticketNo,
        'Emirate': emirate?.city,
        'IssuingAuthority': issuingAuthority,
        'Reason': reason,
        'FineStatusID': status?.statusId,
        'Status': status?.status,
        'Remarks': remarks,
      };

  /// POST body for both add (FineID=0) and update (FineID>0) — same API endpoint
  Map<String, dynamic> toCreateJson() => {
        'FineID': fineId ?? 0,
        'Company': company,
        'VehicleNo': vehicleNo,
        'EmpNo': empNo,
        'FineTypeID': fineType?.fineTypeId,
        'FineDate': fineDate,
        'Amount': amount,
        'Location': location,
        'TicketNo': ticketNo,
        'Emirate': emirate?.city,
        'IssuingAuthority': issuingAuthority,
        'Reason': reason,
        'FineStatusID': status?.statusId,
        'Remarks': remarks ?? '',
      };

  Fine copyWith({
    int? fineId,
    String? company,
    String? vehicleNo,
    String? empNo,
    String? empName,
    String? designation,
    FineType? fineType,
    String? fineDate,
    double? amount,
    String? location,
    String? ticketNo,
    City? emirate,
    String? issuingAuthority,
    String? reason,
    StatusMaster? status,
    String? remarks,
    String? createdAt,
    String? updatedAt,
  }) {
    return Fine(
      fineId: fineId ?? this.fineId,
      company: company ?? this.company,
      vehicleNo: vehicleNo ?? this.vehicleNo,
      empNo: empNo ?? this.empNo,
      empName: empName ?? this.empName,
      designation: designation ?? this.designation,
      fineType: fineType ?? this.fineType,
      fineDate: fineDate ?? this.fineDate,
      amount: amount ?? this.amount,
      location: location ?? this.location,
      ticketNo: ticketNo ?? this.ticketNo,
      emirate: emirate ?? this.emirate,
      issuingAuthority: issuingAuthority ?? this.issuingAuthority,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
    );
  }

  /// Check if this fine is paid
  bool get isPaid => status?.status?.toLowerCase() == 'paid';

  /// Check if this fine is overdue (unpaid and past due date)
  bool get isOverdue {
    if (isPaid) return false;
    if (fineDate == null) return false;
    try {
      final date = DateTime.parse(fineDate!);
      return DateTime.now().difference(date).inDays > 30;
    } catch (e) {
      return false;
    }
  }
}

// GET Json Response
// [
//     {
//         "FineID": 26,
//         "Company": "EPIC01",
//         "VehicleNo": "DXB-10011",
//         "EmpNo": "MX1495",
//         "FineType": "Parking in Disabled Spot",
//         "FineDate": "2026-02-10T17:45:09.18",
//         "Location": "Highway",
//         "TicketNo": "TKT-91381",
//         "Emirate": "Dubai",
//         "IssuingAuthority": "Dubai Police",
//         "Reason": "Auto generated fine",
//         "Status": "Unpaid",
//         "EmpName": "",
//         "FineTypeID": 1008,
//         "FineStatusID": 1,
//         "Amount": 1133.00,
//         "Remarks": null
//     },
//     {
//         "FineID": 21,
//         "Company": "EPIC01",
//         "VehicleNo": "DXB-10011",
//         "EmpNo": "MX1495",
//         "FineType": "Exceeding Truck Weight Limit",
//         "FineDate": "2026-02-04T17:45:03.03",
//         "Location": "Main Street",
//         "TicketNo": "TKT-294571",
//         "Emirate": "Dubai",
//         "IssuingAuthority": "Dubai Police",
//         "Reason": "Auto generated fine",
//         "Status": "Unpaid",
//         "EmpName": "",
//         "FineTypeID": 1014,
//         "FineStatusID": 1,
//         "Amount": 1134.00,
//         "Remarks": null
//     },
//     {
//         "FineID": 31,
//         "Company": "EPIC01",
//         "VehicleNo": "DXB-10011",
//         "EmpNo": "MX1495",
//         "FineType": "Overloading Truck",
//         "FineDate": "2026-02-03T17:45:10.04",
//         "Location": "Main Street",
//         "TicketNo": "TKT-289552",
//         "Emirate": "Dubai",
//         "IssuingAuthority": "Dubai Police",
//         "Reason": "Auto generated fine",
//         "Status": "Disputed",
//         "EmpName": "",
//         "FineTypeID": 1013,
//         "FineStatusID": 3,
//         "Amount": 1145.00,
//         "Remarks": null
//     },
//     {
//         "FineID": 11,
//         "Company": "EPIC01",
//         "VehicleNo": "DXB-10011",
//         "EmpNo": "MX1495",
//         "FineType": "Expired Registration",
//         "FineDate": "2026-01-15T00:00:00",
//         "Location": "Salik Gate",
//         "TicketNo": "TKT-003",
//         "Emirate": "Dubai",
//         "IssuingAuthority": "RTA",
//         "Reason": "Salik Violation",
//         "Status": "Unpaid",
//         "EmpName": "",
//         "FineTypeID": 1010,
//         "FineStatusID": 1,
//         "Amount": 1120.00,
//         "Remarks": null
//     },
//     {
//         "FineID": 10,
//         "Company": "EPIC01",
//         "VehicleNo": "DXB-10011",
//         "EmpNo": "MX1495",
//         "FineType": "Using Mobile While Driving",
//         "FineDate": "2026-01-12T00:00:00",
//         "Location": "Al Barsha",
//         "TicketNo": "TKT-002",
//         "Emirate": "Dubai",
//         "IssuingAuthority": "RTA",
//         "Reason": "Illegal Parking",
//         "Status": "Paid",
//         "EmpName": "",
//         "FineTypeID": 1005,
//         "FineStatusID": 2,
//         "Amount": 1115.00,
//         "Remarks": null
//     },
//     {
//         "FineID": 9,
//         "Company": "EPIC01",
//         "VehicleNo": "DXB-10011",
//         "EmpNo": "MX1495",
//         "FineType": "Speeding",
//         "FineDate": "2026-01-10T00:00:00",
//         "Location": "Sheikh Zayed Road",
//         "TicketNo": "TKT-001",
//         "Emirate": "Dubai",
//         "IssuingAuthority": "Dubai Police",
//         "Reason": "Speeding 120km/h",
//         "Status": "Unpaid",
//         "EmpName": "",
//         "FineTypeID": 1001,
//         "FineStatusID": 1,
//         "Amount": 1109.00,
//         "Remarks": null
//     },
//     {
//         "FineID": 38,
//         "Company": "EPIC01",
//         "VehicleNo": "AA-22222",
//         "EmpNo": "MX0072",
//         "FineType": "Speeding",
//         "FineDate": "2026-01-10T00:00:00",
//         "Location": "Sheikh Zayed Road",
//         "TicketNo": "TCKT-987654",
//         "Emirate": "Dubai",
//         "IssuingAuthority": "Dubai Police",
//         "Reason": "Exceeded speed limit",
//         "Status": "Unpaid",
//         "EmpName": "Muhammad Ghafoor Arshad",
//         "FineTypeID": 1001,
//         "FineStatusID": 1,
//         "Amount": 150.00,
//         "Remarks": null
//     },
//     {
//         "FineID": 16,
//         "Company": "EPIC01",
//         "VehicleNo": "DXB-10012",
//         "EmpNo": "MX1694",
//         "FineType": "Using Mobile While Driving",
//         "FineDate": "2026-01-05T00:00:00",
//         "Location": "Deira",
//         "TicketNo": "TKT-100",
//         "Emirate": "Dubai",
//         "IssuingAuthority": "RTA",
//         "Reason": "Paid Parking Expired",
//         "Status": "Paid",
//         "EmpName": "",
//         "FineTypeID": 1005,
//         "FineStatusID": 2,
//         "Amount": 1121.00,
//         "Remarks": null
//     }
// ]

// POST Json body
// {
//   "FineID": 1,
//   "Company": "EPIC01",
//   "VehicleNo": "AA-22222",
//   "EmpNo": "MX0072",
//   "FineTypeID": 1001,
//   "FineDate": "2026-01-10",
//   "Location": "Sheikh Zayed Road",
//   "TicketNo": "TCKT-987654",
//   "Emirate": "Dubai",
//   "IssuingAuthority": "Dubai Police",
//   "Reason": "Exceeded speed limit",
//   "FineStatusID": 1,
//   "Amount": 150,
//   "Remarks" : ""
// }
