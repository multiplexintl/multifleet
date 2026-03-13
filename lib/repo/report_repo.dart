import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:multifleet/models/doc_master.dart';
import 'package:multifleet/models/fine.dart';
import 'package:multifleet/models/maintenance.dart';
import 'package:multifleet/models/maintenance_master.dart';
import 'package:multifleet/models/tyre.dart';
import 'package:multifleet/models/vehicle.dart';

import 'package:multifleet/models/vehicle_docs.dart';
import 'package:multifleet/repo/assign_repo.dart';
import 'package:multifleet/repo/fine_repo.dart';
import 'package:multifleet/repo/maintenance_repo.dart';
import 'package:multifleet/repo/vehicles_repo.dart';

import '../models/vehicle_assignment_model.dart';

/// ============================================================
/// REPORT REPOSITORY
/// ============================================================
/// Centralized data fetching for the Reports module.
/// Aggregates data from multiple repos and transforms for reporting.
/// ============================================================

class ReportRepository {
  // Singleton
  static final ReportRepository _instance = ReportRepository._internal();
  factory ReportRepository() => _instance;
  ReportRepository._internal();

  // Repos
  final _vehiclesRepo = VehiclesRepo();
  final _fineRepo = FineRepo();
  final _assignRepo = AssignRepo();
  final _maintenanceRepo = MaintenanceRepo();

  // Cached master data (loaded once per session)
  List<DocumentMaster>? _cachedDocTypes;
  List<MaintenanceMaster>? _cachedMaintenanceTypes;
  String? _cachedCompany;

  // ==================== MASTER DATA ====================

  /// Load document types for mapping docType ID → description
  Future<Map<int, String>> getDocTypeMap(String company) async {
    if (_cachedDocTypes == null || _cachedCompany != company) {
      final result =
          await _vehiclesRepo.getAllVehicleDocumentMaster(company: company);
      result.fold(
        (error) => log('[ReportRepo] DocTypes error: $error'),
        (data) {
          _cachedDocTypes = data;
          _cachedCompany = company;
        },
      );
    }

    final map = <int, String>{};
    for (final doc in _cachedDocTypes ?? []) {
      if (doc.docType != null) {
        map[doc.docType!] = doc.docDescription ?? 'Unknown';
      }
    }
    return map;
  }

  /// Load maintenance types for mapping
  // Future<Map<int, String>> getMaintenanceTypeMap(String company) async {
  //   if (_cachedMaintenanceTypes == null || _cachedCompany != company) {
  //     final result = await _maintenanceRepo. (company);
  //     result.fold(
  //       (error) => log('[ReportRepo] MaintenanceTypes error: $error'),
  //       (data) => _cachedMaintenanceTypes = data,
  //     );
  //   }

  //   final map = <int, String>{};
  //   for (final m in _cachedMaintenanceTypes ?? []) {
  //     if (m.maintenanceID != null) {
  //       map[m.maintenanceID!] = m.maintenanceType ?? 'Unknown';
  //     }
  //   }
  //   return map;
  // }

  /// Clear cached master data (call on company change)
  void clearCache() {
    _cachedDocTypes = null;
    _cachedMaintenanceTypes = null;
    _cachedCompany = null;
  }

  // ==================== VEHICLE DATA ====================

  /// Fetch all vehicles as Map for reporting
  Future<Either<String, List<Map<String, dynamic>>>> getVehiclesForReport(
    String company,
  ) async {
    final result = await _vehiclesRepo.getAllVehicles(company: company);

    return result.fold(
      (error) => Left(error),
      (vehicles) {
        final data = vehicles.map((v) => _vehicleToMap(v)).toList();
        log('[ReportRepo] Fetched ${data.length} vehicles');
        return Right(data);
      },
    );
  }

  Map<String, dynamic> _vehicleToMap(Vehicle v) {
    return {
      'vehicleNo': v.vehicleNo,
      'description': v.description,
      'brand': v.brand,
      'model': v.model,
      'type': v.type,
      'status': v.status,
      // 'city': v.city?.join(', ') ?? '',
      // 'cityList': v.city ?? [],
      'vYear': v.vYear,
      'currentOdo': v.currentOdo ?? 0,
      'initialOdo': v.initialOdo ?? 0,
      'chassisNo': v.chassisNo,
      'condition': v.condition,
      'traficFileNo': v.traficFileNo,
      'fuelStation': v.fuelStation,
      'company': v.company,
    };
  }

  // ==================== DOCUMENT DATA ====================

  /// Fetch all documents as Map for reporting (with type names resolved)
  Future<Either<String, List<Map<String, dynamic>>>> getDocumentsForReport(
    String company,
  ) async {
    // Load doc type mapping first
    final docTypeMap = await getDocTypeMap(company);

    final result = await _vehiclesRepo.getVehicleDocument(company: company);

    return result.fold(
      (error) {
        // Handle "not found" as empty list, not error
        if (error.contains('Not Found')) {
          return const Right(<Map<String, dynamic>>[]);
        }
        return Left(error);
      },
      (documents) {
        final data =
            documents.map((d) => _documentToMap(d, docTypeMap)).toList();
        log('[ReportRepo] Fetched ${data.length} documents');
        return Right(data);
      },
    );
  }

  Map<String, dynamic> _documentToMap(
      VehicleDocument d, Map<int, String> docTypeMap) {
    final now = DateTime.now();
    final daysToExpiry = d.expiryDate?.difference(now).inDays;

    String expiryStatus;
    if (daysToExpiry == null) {
      expiryStatus = 'Unknown';
    } else if (daysToExpiry < 0) {
      expiryStatus = 'Expired';
    } else if (daysToExpiry <= 7) {
      expiryStatus = 'Critical';
    } else if (daysToExpiry <= 30) {
      expiryStatus = 'Warning';
    } else if (daysToExpiry <= 60) {
      expiryStatus = 'Upcoming';
    } else {
      expiryStatus = 'Valid';
    }

    return {
      'id': d.id,
      'vehicleNo': d.vehicleNo,
      'docType': d.docType,
      'docTypeName': docTypeMap[d.docType] ?? 'Type ${d.docType}',
      'documentNo': d.documentNo,
      'issueDate': d.issueDate,
      'expiryDate': d.expiryDate,
      'daysToExpiry': daysToExpiry ?? 0,
      'expiryStatus': expiryStatus,
      'issueAuthority': d.issueAuthority,
      'city': d.city,
      'status': d.status ?? expiryStatus,
      'remarks': d.remarks,
      'amount': d.amount,
      'company': d.company,
    };
  }

  // ==================== FINE DATA ====================

  /// Fetch all fines as Map for reporting
  Future<Either<String, List<Map<String, dynamic>>>> getFinesForReport(
    String company,
  ) async {
    final result = await _fineRepo.getFines(company: company, vehicleNo: '');

    return result.fold(
      (error) => Left(error),
      (fines) {
        final data = fines.map((f) => _fineToMap(f)).toList();
        log('[ReportRepo] Fetched ${data.length} fines');
        return Right(data);
      },
    );
  }

  Map<String, dynamic> _fineToMap(Fine f) {
    DateTime? fineDate;
    if (f.fineDate != null) {
      fineDate = DateTime.tryParse(f.fineDate!);
    }

    return {
      'fineId': f.fineId,
      'vehicleNo': f.vehicleNo,
      'empNo': f.empNo,
      'empName': f.empName,
      'designation': f.designation,
      'fineType': f.fineType?.fineType ?? '',
      'fineDate': fineDate,
      'fineDateStr': f.fineDate,
      'amount': f.amount ?? 0.0,
      'location': f.location,
      'ticketNo': f.ticketNo,
      'emirate': f.emirate?.city ?? '',
      'issuingAuthority': f.issuingAuthority,
      'reason': f.reason,
      'status': f.status?.status ?? '',
      'remarks': f.remarks,
      'company': f.company,
      'isPaid': f.isPaid,
      'isOverdue': f.isOverdue,
    };
  }

  // ==================== ASSIGNMENT DATA ====================

  /// Fetch all assignments as Map for reporting
  Future<Either<String, List<Map<String, dynamic>>>> getAssignmentsForReport(
    String company,
  ) async {
    final result = await _assignRepo.getAllAssignmets(company: company);

    return result.fold(
      (error) => Left(error),
      (assignments) {
        final data = assignments.map((a) => _assignmentToMap(a)).toList();
        log('[ReportRepo] Fetched ${data.length} assignments');
        return Right(data);
      },
    );
  }

  Map<String, dynamic> _assignmentToMap(VehicleAssignment a) {
    DateTime? assignedDate;
    DateTime? returnDate;

    if (a.assignedDate != null) {
      assignedDate = DateTime.tryParse(a.assignedDate!);
    }
    if (a.returnDate != null) {
      returnDate = DateTime.tryParse(a.returnDate!);
    }

    int? durationDays;
    if (assignedDate != null) {
      final endDate = returnDate ?? DateTime.now();
      durationDays = endDate.difference(assignedDate).inDays;
    }

    return {
      'vehicleNo': a.vehicleNo,
      'empNo': a.empNo,
      'empName': a.empName,
      'designation': a.designation,
      // 'department': a.department,
      'assignedDate': assignedDate,
      'assignedDateStr': a.assignedDate,
      'returnDate': returnDate,
      'returnDateStr': a.returnDate,
      'durationDays': durationDays ?? 0,
      'status': a.status,
      'remarks': a.remarks,
      'company': a.company,
      // 'isActive': a.status?.toLowerCase() == 'active',
    };
  }

  // ==================== TYRE DATA ====================

  /// Fetch all tyres for a company (loops through vehicles)
  /// Note: This can be slow for large fleets - consider caching or backend API
  Future<Either<String, List<Map<String, dynamic>>>> getTyresForReport(
    String company,
  ) async {
    // First get all vehicles
    final vehiclesResult = await _vehiclesRepo.getAllVehicles(company: company);

    return vehiclesResult.fold(
      (error) => Left(error),
      (vehicles) async {
        final allTyres = <Map<String, dynamic>>[];

        // Fetch tyres for each vehicle (in batches to avoid overwhelming API)
        for (final vehicle in vehicles) {
          if (vehicle.vehicleNo == null) continue;

          final tyreResult = await _vehiclesRepo.getAllVehicleTyres(
            company: company,
            vehicleNumber: vehicle.vehicleNo!,
          );

          tyreResult.fold(
            (error) {
              // Ignore "not found" errors, just skip this vehicle
              if (!error.contains('Not Found')) {
                log('[ReportRepo] Tyre fetch error for ${vehicle.vehicleNo}: $error');
              }
            },
            (tyres) {
              for (final t in tyres) {
                allTyres.add(_tyreToMap(t, vehicle));
              }
            },
          );
        }

        log('[ReportRepo] Fetched ${allTyres.length} tyres from ${vehicles.length} vehicles');
        return Right(allTyres);
      },
    );
  }

  Map<String, dynamic> _tyreToMap(Tyre t, Vehicle v) {
    final now = DateTime.now();
    int? daysToExpiry;
    String expiryStatus = 'Unknown';

    if (t.expDt != null) {
      daysToExpiry = t.expDt!.difference(now).inDays;
      if (daysToExpiry < 0) {
        expiryStatus = 'Expired';
      } else if (daysToExpiry <= 30) {
        expiryStatus = 'Warning';
      } else {
        expiryStatus = 'Valid';
      }
    }

    return {
      'tyreId': t.tyreId,
      'vehicleNo': t.vehicleNo ?? v.vehicleNo,
      'vehicleBrand': v.brand,
      'vehicleModel': v.model,
      'position': t.position,
      'brand': t.brand,
      'size': t.size,
      'installDt': t.installDt,
      'expDt': t.expDt,
      'daysToExpiry': daysToExpiry ?? 0,
      'expiryStatus': expiryStatus,
      'kmUsed': t.kmUsed ?? 0,
      'status': t.status,
      'remarks': t.remarks,
      'createdDt': t.createdDt,
    };
  }

  // ==================== MAINTENANCE DATA ====================

  Future<Either<String, List<Map<String, dynamic>>>> getMaintenanceForReport(
    String company,
  ) async {
    final result = await _maintenanceRepo.getVehicleMaintenance(company: company);

    return result.fold(
      (error) {
        if (error.contains('Not Found')) {
          return const Right(<Map<String, dynamic>>[]);
        }
        return Left(error);
      },
      (records) {
        final data = records.map((m) => _maintenanceToMap(m)).toList();
        log('[ReportRepo] Fetched ${data.length} maintenance records');
        return Right(data);
      },
    );
  }

  Map<String, dynamic> _maintenanceToMap(MaintenanceRecord m) {
    return {
      'recordId': m.slNo,
      'vehicleNo': m.vehicleNo,
      'maintenanceType': m.maintenanceType,
      'maintenanceID': m.maintenanceID,
      'serviceDate': m.serviceDate,
      'invoiceNo': m.invoiceNo,
      'vendorID': m.vendorID,
      'garageName': m.vendorName,
      'amount': m.amount ?? 0.0,
      'remarks': m.remarks,
      'status': m.status,
      'company': m.company,
    };
  }
}
