import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:multifleet/controllers/general_masters.dart';
import 'package:multifleet/models/city/city.dart';
import 'package:multifleet/models/employee.dart';
import 'package:multifleet/models/fine.dart';
import 'package:multifleet/models/fine_type/fine_type.dart';
import 'package:multifleet/models/maintenance.dart';
import 'package:multifleet/models/status_master/status_master.dart';
import 'package:multifleet/models/tyre.dart';
import 'package:multifleet/models/vehicle.dart';
import 'package:multifleet/models/vehicle_assignment_model.dart';
import 'package:multifleet/models/vehicle_docs.dart';
import 'package:multifleet/repo/assign_repo.dart';
import 'package:multifleet/repo/employee_repo.dart';
import 'package:multifleet/repo/fine_repo.dart';
import 'package:multifleet/repo/maintenance_repo.dart';
import 'package:multifleet/repo/vehicles_repo.dart';
import 'package:multifleet/services/company_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// ============================================================
// IMPORT ERROR
// ============================================================

class ImportError {
  final String vehicleNo;
  final String sheet;
  final int row;
  final String field;
  final String error;

  const ImportError({
    required this.vehicleNo,
    required this.sheet,
    required this.row,
    required this.field,
    required this.error,
  });
}

// ============================================================
// IMPORT SUMMARY
// ============================================================

class ImportSummary {
  int totalEmployees = 0;
  int successEmployees = 0;
  int totalVehicles = 0;
  int successVehicles = 0;
  int skippedVehicles = 0;
  int totalDocuments = 0;
  int successDocuments = 0;
  int totalFines = 0;
  int successFines = 0;
  int totalAssignments = 0;
  int successAssignments = 0;
  int totalMaintenance = 0;
  int successMaintenance = 0;
  int totalTyres = 0;
  int successTyres = 0;
}

// ============================================================
// VEHICLE IMPORT DATA (internal)
// ============================================================

class _VehicleImportData {
  final String vehicleNo;
  final String company;
  Vehicle? vehicle;
  final List<VehicleDocument> documents = [];
  final List<Fine> fines = [];
  final List<VehicleAssignment> assignments = [];
  final List<MaintenanceRecord> maintenanceRecords = [];
  final List<Tyre> tyres = [];

  _VehicleImportData({required this.vehicleNo, required this.company});
}

// ============================================================
// IMPORT CONTROLLER
// ============================================================

class ImportController extends GetxController {
  final _companyService = Get.find<CompanyService>();
  final _masters = Get.find<GeneralMastersController>();

  final _vehiclesRepo = VehiclesRepo();
  final _employeeRepo = EmployeeRepo();
  final _fineRepo = FineRepo();
  final _assignRepo = AssignRepo();
  final _maintenanceRepo = MaintenanceRepo();

  // State
  final isPickingFile = false.obs;
  final isParsing = false.obs;
  final isImporting = false.obs;
  final isGeneratingReport = false.obs;

  final selectedFileName = ''.obs;
  final parsedEmployeeCount = 0.obs;
  final parsedVehicleCount = 0.obs;
  final parsedDocCount = 0.obs;
  final parsedFineCount = 0.obs;
  final parsedAssignmentCount = 0.obs;
  final parsedMaintenanceCount = 0.obs;
  final parsedTyreCount = 0.obs;

  // Progress
  final currentVehicleIndex = 0.obs;
  final totalVehicles = 0.obs;
  final currentVehicleNo = ''.obs;
  final statusMessage = ''.obs;

  // Results
  final errors = <ImportError>[].obs;
  final summary = Rxn<ImportSummary>();
  final errorReportPath = ''.obs;

  // Parsed data
  Map<String, _VehicleImportData> _parsedData = {};
  List<Employee> _parsedEmployees = [];

  String get _company =>
      _companyService.selectedCompanyObs.value?.id ?? '';

  // ==================== FILE PICKING ====================

  Future<void> pickAndParseFile() async {
    isPickingFile.value = true;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        isPickingFile.value = false;
        return;
      }

      final file = result.files.first;
      selectedFileName.value = file.name;
      isPickingFile.value = false;

      await _parseFile(file.bytes!);
    } catch (e) {
      isPickingFile.value = false;
      log('[ImportController] File pick error: $e');
      Get.snackbar('Error', 'Failed to pick file: $e');
    }
  }

  // ==================== PARSING ====================

  Future<void> _parseFile(List<int> bytes) async {
    isParsing.value = true;
    statusMessage.value = 'Parsing Excel file...';
    _parsedData = {};
    errors.clear();
    summary.value = null;
    errorReportPath.value = '';

    try {
      final excel = Excel.decodeBytes(bytes);

      _parsedEmployees = [];
      _parseEmployeeSheet(excel);
      _parseVehicleSheet(excel);
      _parseDocumentSheet(excel);
      _parseFineSheet(excel);
      _parseAssignmentSheet(excel);
      _parseMaintenanceSheet(excel);
      _parseTyreSheet(excel);

      parsedEmployeeCount.value = _parsedEmployees.length;
      parsedVehicleCount.value = _parsedData.length;
      parsedDocCount.value =
          _parsedData.values.fold(0, (s, v) => s + v.documents.length);
      parsedFineCount.value =
          _parsedData.values.fold(0, (s, v) => s + v.fines.length);
      parsedAssignmentCount.value =
          _parsedData.values.fold(0, (s, v) => s + v.assignments.length);
      parsedMaintenanceCount.value =
          _parsedData.values.fold(0, (s, v) => s + v.maintenanceRecords.length);
      parsedTyreCount.value =
          _parsedData.values.fold(0, (s, v) => s + v.tyres.length);

      statusMessage.value =
          'Parsed ${parsedVehicleCount.value} vehicles. Ready to import.';
    } catch (e) {
      log('[ImportController] Parse error: $e');
      statusMessage.value = 'Parse error: $e';
    } finally {
      isParsing.value = false;
    }
  }

  // ---- Employees ----
  // Column layout (0-based):
  //  0=Company  1=Employee No  2=Full Name  3=Designation  4=Department
  //  5=Phone    6=Email        7=License No  8=License Expiry  9=Nationality  10=Remarks
  void _parseEmployeeSheet(Excel excel) {
    final sheet = _findSheet(excel, '2. Employees') ??
        _findSheet(excel, '2.Employees') ??
        _findSheet(excel, 'Employees');
    if (sheet == null) return;

    for (int i = 5; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];
      if (row.isEmpty) continue;

      final empNo = _cellStr(row, 1);
      if (empNo.isEmpty) continue;
      if (empNo.toLowerCase().contains('example') ||
          empNo.toLowerCase() == 'employee no') { continue; }

      final rowCompany = _cellStr(row, 0).nullIfEmpty ?? _company;
      if (rowCompany.isEmpty) {
        _addParseError('2. Employees', i + 1, empNo, 'Company',
            'Company is required. Fill column A or select a company in the app.');
      }

      _parsedEmployees.add(Employee(
        company: rowCompany,
        empNo: empNo,
        empName: _cellStr(row, 2).nullIfEmpty,
        designation: _cellStr(row, 3).nullIfEmpty,
        department: _cellStr(row, 4).nullIfEmpty,
        phone: _cellStr(row, 5).nullIfEmpty,
        email: _cellStr(row, 6).nullIfEmpty,
        licenseNo: _cellStr(row, 7).nullIfEmpty,
        licenseExpiry: _cellStr(row, 8).nullIfEmpty,
        nationality: _cellStr(row, 9).nullIfEmpty,
        remarks: _cellStr(row, 10).nullIfEmpty,
      ));
    }
  }

  // ---- Vehicles ----
  void _parseVehicleSheet(Excel excel) {
    final sheet = _findSheet(excel, '1. Vehicles') ??
        _findSheet(excel, '1.Vehicles') ??
        _findSheet(excel, 'Vehicles');
    if (sheet == null) {
      _addParseError('1. Vehicles', 0, '', 'Sheet',
          'Sheet "1. Vehicles" not found in workbook');
      return;
    }

    // Rows 0-4 = title/warning/instructions/example/header; data starts at row 5 (index 5)
    // Column layout (0-based):
    //  0=Company  1=Vehicle No  2=Description  3=Brand  4=Model  5=Year
    //  6=Chassis  7=TrafficFile  8=VehicleType  9=Status  10=Condition
    //  11=City  12=FuelStation  13=InitialOdo  14=CurrentOdo  15=Remarks
    for (int i = 5; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];
      if (row.isEmpty) continue;

      // Col 1 = Vehicle No (after Company was inserted at col 0)
      final vehicleNo = _cellStr(row, 1);
      if (vehicleNo.isEmpty) continue;
      if (vehicleNo.toLowerCase().contains('example') ||
          vehicleNo.toLowerCase() == 'vehicle no') { continue; }

      // Col 0 = Company from sheet; fall back to selected company
      final rowCompany = _cellStr(row, 0).nullIfEmpty ?? _company;
      if (rowCompany.isEmpty) {
        _addParseError('1. Vehicles', i + 1, vehicleNo, 'Company',
            'Company is required. Fill column A or select a company in the app.');
      }

      final typeStr = _cellStr(row, 8);
      final statusStr = _cellStr(row, 9);
      final conditionStr = _cellStr(row, 10);
      final cityStr = _cellStr(row, 11);
      final fuelStationStr = _cellStr(row, 12);

      final typeId = _resolveVehicleTypeId(typeStr);
      if (typeStr.isNotEmpty && typeId == null) {
        _addParseError('1. Vehicles', i + 1, vehicleNo, 'Vehicle Type',
            'Unknown vehicle type: "$typeStr"');
      }

      final statusId = _resolveVehicleStatusId(statusStr);
      if (statusStr.isNotEmpty && statusId == null) {
        _addParseError('1. Vehicles', i + 1, vehicleNo, 'Status',
            'Unknown status: "$statusStr"');
      }

      final conditionId = _resolveConditionId(conditionStr);
      if (conditionStr.isNotEmpty && conditionId == null) {
        _addParseError('1. Vehicles', i + 1, vehicleNo, 'Condition',
            'Unknown condition: "$conditionStr"');
      }

      final fuelStationId = _resolveFuelStationId(fuelStationStr);
      final cityIds = _resolveCityIds(cityStr);

      final data = _VehicleImportData(vehicleNo: vehicleNo, company: rowCompany);
      data.vehicle = Vehicle(
        company: rowCompany,
        vehicleNo: vehicleNo,
        description: _cellStr(row, 2).nullIfEmpty,
        brand: _cellStr(row, 3).nullIfEmpty,
        model: _cellStr(row, 4).nullIfEmpty,
        vYear: _cellInt(row, 5),
        chassisNo: _cellStr(row, 6).nullIfEmpty,
        traficFileNo: _cellStr(row, 7).nullIfEmpty,
        initialOdo: _cellInt(row, 13) ?? 0,
        currentOdo: _cellInt(row, 14) ?? _cellInt(row, 13) ?? 0,
        vehicleTypeId: typeId,
        vehicleStatusId: statusId,
        conditionId: conditionId,
        fuelStationId: fuelStationId,
        cityIds: cityIds.isEmpty ? null : cityIds,
      );

      _parsedData[vehicleNo] = data;
    }
  }

  // ---- Documents ----
  void _parseDocumentSheet(Excel excel) {
    final sheet = _findSheet(excel, '3. Vehicle Documents') ??
        _findSheet(excel, '3.Vehicle Documents') ??
        _findSheet(excel, 'Vehicle Documents');
    if (sheet == null) return;

    for (int i = 5; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];
      if (row.isEmpty) continue;

      final vehicleNo = _cellStr(row, 0);
      if (vehicleNo.isEmpty) continue;
      if (vehicleNo.toLowerCase().contains('example') ||
          vehicleNo.toLowerCase() == 'vehicle no') { continue; }

      final docTypeStr = _cellStr(row, 1);
      final docTypeId = _resolveDocTypeId(docTypeStr);
      if (docTypeStr.isNotEmpty && docTypeId == null) {
        _addParseError('3. Vehicle Documents', i + 1, vehicleNo,
            'Document Type',
            'Unknown document type: "$docTypeStr". Check Master Lists sheet.');
      }

      final expiryDateStr = _cellStr(row, 4);
      final expiryDate = _parseDate(expiryDateStr);
      if (expiryDateStr.isNotEmpty && expiryDate == null) {
        _addParseError('3. Vehicle Documents', i + 1, vehicleNo, 'Expiry Date',
            'Invalid date: "$expiryDateStr". Use YYYY-MM-DD.');
      }

      final doc = VehicleDocument(
        id: 0,
        company: _company,
        vehicleNo: vehicleNo,
        docType: docTypeId,
        documentNo: _cellStr(row, 2).nullIfEmpty,
        issueDate: _parseDate(_cellStr(row, 3)),
        expiryDate: expiryDate,
        issueAuthority: _cellStr(row, 5).nullIfEmpty,
        city: _cellStr(row, 6).nullIfEmpty,
        amount: _cellDouble(row, 7),
        status: _cellStr(row, 8).nullIfEmpty,
        remarks: _cellStr(row, 9).nullIfEmpty,
      );

      _parsedData
          .putIfAbsent(
              vehicleNo, () => _VehicleImportData(vehicleNo: vehicleNo, company: _company))
          .documents
          .add(doc);
    }
  }

  // ---- Fines ----
  void _parseFineSheet(Excel excel) {
    final sheet = _findSheet(excel, '5. Fines') ??
        _findSheet(excel, '5.Fines') ??
        _findSheet(excel, 'Fines');
    if (sheet == null) return;

    for (int i = 5; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];
      if (row.isEmpty) continue;

      final vehicleNo = _cellStr(row, 0);
      if (vehicleNo.isEmpty) continue;
      if (vehicleNo.toLowerCase().contains('example') ||
          vehicleNo.toLowerCase() == 'vehicle no') { continue; }

      final fineTypeStr = _cellStr(row, 3);
      final fineType = _resolveFineType(fineTypeStr);
      if (fineTypeStr.isNotEmpty && fineType == null) {
        _addParseError('5. Fines', i + 1, vehicleNo, 'Fine Type',
            'Unknown fine type: "$fineTypeStr". Check Master Lists sheet.');
      }

      final emirateStr = _cellStr(row, 6);
      final emirateCity =
          emirateStr.isNotEmpty ? City(company: _company, city: emirateStr) : null;

      final fine = Fine(
        fineId: 0,
        company: _company,
        vehicleNo: vehicleNo,
        ticketNo: _cellStr(row, 1).nullIfEmpty,
        fineDate: _cellStr(row, 2).nullIfEmpty,
        fineType: fineType,
        amount: _cellDouble(row, 4),
        location: _cellStr(row, 5).nullIfEmpty,
        emirate: emirateCity,
        issuingAuthority: _cellStr(row, 7).nullIfEmpty,
        empNo: _cellStr(row, 8).nullIfEmpty,
        empName: _cellStr(row, 9).nullIfEmpty,
        reason: _cellStr(row, 10).nullIfEmpty,
        status: _resolveFineStatus(_cellStr(row, 11)),
        remarks: _cellStr(row, 13).nullIfEmpty,
      );

      _parsedData
          .putIfAbsent(
              vehicleNo, () => _VehicleImportData(vehicleNo: vehicleNo, company: _company))
          .fines
          .add(fine);
    }
  }

  // ---- Assignments ----
  void _parseAssignmentSheet(Excel excel) {
    final sheet = _findSheet(excel, '4. Assignments') ??
        _findSheet(excel, '4.Assignments') ??
        _findSheet(excel, 'Assignments');
    if (sheet == null) return;

    for (int i = 5; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];
      if (row.isEmpty) continue;

      final vehicleNo = _cellStr(row, 0);
      if (vehicleNo.isEmpty) continue;
      if (vehicleNo.toLowerCase().contains('example') ||
          vehicleNo.toLowerCase() == 'vehicle no') { continue; }

      final statusStr = _cellStr(row, 5);
      final assignStatus = _resolveAssignmentStatus(statusStr);

      final assignment = VehicleAssignment(
        company: _company,
        vehicleNo: vehicleNo,
        empNo: _cellStr(row, 1).nullIfEmpty,
        empName: _cellStr(row, 2).nullIfEmpty,
        designation: _cellStr(row, 3).nullIfEmpty,
        assignedDate: _cellStr(row, 4).nullIfEmpty,
        returnDate: _cellStr(row, 6).nullIfEmpty,
        remarks: _cellStr(row, 9).nullIfEmpty,
        statusId: assignStatus?.statusId,
        status: assignStatus,
      );

      _parsedData
          .putIfAbsent(
              vehicleNo, () => _VehicleImportData(vehicleNo: vehicleNo, company: _company))
          .assignments
          .add(assignment);
    }
  }

  // ---- Maintenance ----
  void _parseMaintenanceSheet(Excel excel) {
    final sheet = _findSheet(excel, '6. Maintenance') ??
        _findSheet(excel, '6.Maintenance') ??
        _findSheet(excel, 'Maintenance');
    if (sheet == null) return;

    for (int i = 5; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];
      if (row.isEmpty) continue;

      final vehicleNo = _cellStr(row, 0);
      if (vehicleNo.isEmpty) continue;
      if (vehicleNo.toLowerCase().contains('example') ||
          vehicleNo.toLowerCase() == 'vehicle no') { continue; }

      final mainTypeStr = _cellStr(row, 2);
      final mainId = _resolveMaintenanceTypeId(mainTypeStr);
      if (mainTypeStr.isNotEmpty && mainId == null) {
        _addParseError('6. Maintenance', i + 1, vehicleNo, 'Maintenance Type',
            'Unknown maintenance type: "$mainTypeStr". Check Master Lists sheet.');
      }

      final vendorStr = _cellStr(row, 3);
      final vendorId = _resolveVendorId(vendorStr);
      if (vendorStr.isNotEmpty && vendorId == null) {
        _addParseError('6. Maintenance', i + 1, vehicleNo, 'Garage',
            'Unknown garage/vendor: "$vendorStr".');
      }

      final record = MaintenanceRecord(
        company: _company,
        slNo: 0,
        vehicleNo: vehicleNo,
        dt: _cellStr(row, 1).nullIfEmpty,
        maintenanceID: mainId,
        maintenanceType: mainTypeStr.nullIfEmpty,
        vendorID: vendorId,
        vendorName: vendorStr.nullIfEmpty,
        invoiceNo: _cellStr(row, 4).nullIfEmpty,
        amount: _cellDouble(row, 5),
        remarks: _cellStr(row, 11).nullIfEmpty,
        status: _cellStr(row, 10).nullIfEmpty ?? 'Open',
      );

      _parsedData
          .putIfAbsent(
              vehicleNo, () => _VehicleImportData(vehicleNo: vehicleNo, company: _company))
          .maintenanceRecords
          .add(record);
    }
  }

  // ---- Tyres ----
  void _parseTyreSheet(Excel excel) {
    final sheet = _findSheet(excel, '8. Tyres') ??
        _findSheet(excel, '8.Tyres') ??
        _findSheet(excel, 'Tyres');
    if (sheet == null) return;

    for (int i = 5; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];
      if (row.isEmpty) continue;

      final vehicleNo = _cellStr(row, 0);
      if (vehicleNo.isEmpty) continue;
      if (vehicleNo.toLowerCase().contains('example') ||
          vehicleNo.toLowerCase() == 'vehicle no') { continue; }

      final posStr = _cellStr(row, 1);
      final positionMaster = _resolveTyrePosition(posStr);

      final tyre = Tyre(
        company: _company,
        tyreId: 0,
        vehicleNo: vehicleNo,
        position: positionMaster,
        brand: _cellStr(row, 2).nullIfEmpty,
        size: _cellStr(row, 3).nullIfEmpty,
        installDt: _parseDate(_cellStr(row, 4)),
        expDt: _parseDate(_cellStr(row, 5)),
        kmUsed: _cellInt(row, 6),
        status: _cellStr(row, 7).nullIfEmpty ?? 'Active',
        remarks: _cellStr(row, 8).nullIfEmpty,
      );

      _parsedData
          .putIfAbsent(
              vehicleNo, () => _VehicleImportData(vehicleNo: vehicleNo, company: _company))
          .tyres
          .add(tyre);
    }
  }

  // ==================== IMPORT ====================

  Future<void> startImport() async {
    if (_parsedData.isEmpty && _parsedEmployees.isEmpty) return;
    if (_company.isEmpty) {
      Get.snackbar('Error', 'No company selected');
      return;
    }

    isImporting.value = true;
    errors.clear();
    final importSummary = ImportSummary();

    // ── 0. Employees (imported first so they exist when assignments reference them) ──
    importSummary.totalEmployees = _parsedEmployees.length;
    for (int ei = 0; ei < _parsedEmployees.length; ei++) {
      final emp = _parsedEmployees[ei];
      statusMessage.value =
          'Importing employee ${emp.empNo} (${ei + 1}/${_parsedEmployees.length})...';
      final result = await _employeeRepo.saveEmployee(employee: emp);
      result.fold(
        (error) {
          errors.add(ImportError(
            vehicleNo: '-',
            sheet: '2. Employees',
            row: ei + 1,
            field: 'Employee',
            error: 'EmpNo ${emp.empNo}: $error',
          ));
        },
        (_) => importSummary.successEmployees++,
      );
    }

    final vehicleNos = _parsedData.keys.toList();
    importSummary.totalVehicles = vehicleNos.length;
    totalVehicles.value = vehicleNos.length;

    for (int i = 0; i < vehicleNos.length; i++) {
      final vehicleNo = vehicleNos[i];
      currentVehicleIndex.value = i + 1;
      currentVehicleNo.value = vehicleNo;
      statusMessage.value =
          'Importing $vehicleNo (${i + 1}/${vehicleNos.length})...';

      final data = _parsedData[vehicleNo]!;

      // Skip if no vehicle row in sheet 1
      if (data.vehicle == null) {
        importSummary.skippedVehicles++;
        errors.add(ImportError(
          vehicleNo: vehicleNo,
          sheet: '1. Vehicles',
          row: 0,
          field: 'Vehicle',
          error:
              'Vehicle $vehicleNo has related data but no row in "1. Vehicles" sheet',
        ));
        continue;
      }

      // ── 1. Create vehicle (documents + tyres embedded in payload) ───────────
      importSummary.totalDocuments += data.documents.length;
      importSummary.totalTyres += data.tyres.length;

      final vehicleToSave = data.vehicle!.copyWith(
        documents: data.documents.isEmpty ? null : data.documents,
        tyres: data.tyres.isEmpty ? null : data.tyres,
      );

      bool vehicleSuccess = false;
      final vehicleResult =
          await _vehiclesRepo.createUpdateVehicle(vehicleToSave);
      vehicleResult.fold(
        (error) {
          errors.add(ImportError(
            vehicleNo: vehicleNo,
            sheet: '1. Vehicles',
            row: 0,
            field: 'Vehicle',
            error: error ?? 'Failed to create vehicle',
          ));
        },
        (success) {
          if (success) {
            vehicleSuccess = true;
            importSummary.successVehicles++;
            importSummary.successDocuments += data.documents.length;
            importSummary.successTyres += data.tyres.length;
          } else {
            errors.add(ImportError(
              vehicleNo: vehicleNo,
              sheet: '1. Vehicles',
              row: 0,
              field: 'Vehicle',
              error: 'API returned failure for vehicle $vehicleNo',
            ));
          }
        },
      );

      if (!vehicleSuccess) {
        importSummary.skippedVehicles++;
        continue;
      }

      // ── 2. Fines ────────────────────────────────────────────────────────────
      importSummary.totalFines += data.fines.length;
      for (int fi = 0; fi < data.fines.length; fi++) {
        final fineResult = await _fineRepo.addFine(fine: data.fines[fi]);
        fineResult.fold(
          (error) {
            errors.add(ImportError(
              vehicleNo: vehicleNo,
              sheet: '5. Fines',
              row: fi + 1,
              field: 'Fine',
              error: error,
            ));
          },
          (_) => importSummary.successFines++,
        );
      }

      // ── 3. Assignments ───────────────────────────────────────────────────────
      importSummary.totalAssignments += data.assignments.length;
      for (int ai = 0; ai < data.assignments.length; ai++) {
        final assignResult = await _assignRepo.createEditAssignment(
          assignment: data.assignments[ai],
          isAssign: true,
        );
        assignResult.fold(
          (success) {
            if (success) {
              importSummary.successAssignments++;
            } else {
              errors.add(ImportError(
                vehicleNo: vehicleNo,
                sheet: '4. Assignments',
                row: ai + 1,
                field: 'Assignment',
                error: 'API returned failure for assignment row ${ai + 1}',
              ));
            }
          },
          (apiResponse) {
            errors.add(ImportError(
              vehicleNo: vehicleNo,
              sheet: '4. Assignments',
              row: ai + 1,
              field: 'Assignment',
              error: apiResponse.message ?? 'Assignment failed',
            ));
          },
        );
      }

      // ── 4. Maintenance ───────────────────────────────────────────────────────
      importSummary.totalMaintenance += data.maintenanceRecords.length;
      for (int mi = 0; mi < data.maintenanceRecords.length; mi++) {
        final mainResult = await _maintenanceRepo
            .saveMaintenanceRecord(data.maintenanceRecords[mi]);
        mainResult.fold(
          (error) {
            errors.add(ImportError(
              vehicleNo: vehicleNo,
              sheet: '6. Maintenance',
              row: mi + 1,
              field: 'Maintenance',
              error: error,
            ));
          },
          (_) => importSummary.successMaintenance++,
        );
      }
    }

    summary.value = importSummary;
    isImporting.value = false;
    statusMessage.value =
        'Done: ${importSummary.successVehicles}/${importSummary.totalVehicles} vehicles imported.';

    if (errors.isNotEmpty) {
      await _generateErrorReport();
    }
  }

  // ==================== ERROR REPORT ====================

  Future<void> _generateErrorReport() async {
    if (errors.isEmpty) return;
    isGeneratingReport.value = true;

    try {
      final excel = Excel.createExcel();
      final sheet = excel['Import Errors'];
      excel.delete('Sheet1');

      final headers = [
        'Vehicle No',
        'Sheet',
        'Row',
        'Field',
        'Error Description',
      ];
      for (int c = 0; c < headers.length; c++) {
        final cell = sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0));
        cell.value = TextCellValue(headers[c]);
        cell.cellStyle = CellStyle(bold: true);
      }

      for (int i = 0; i < errors.length; i++) {
        final e = errors[i];
        final rowData = [
          e.vehicleNo,
          e.sheet,
          e.row.toString(),
          e.field,
          e.error,
        ];
        for (int c = 0; c < rowData.length; c++) {
          sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: c, rowIndex: i + 1))
              .value = TextCellValue(rowData[c]);
        }
      }

      sheet.setColumnWidth(0, 20);
      sheet.setColumnWidth(1, 25);
      sheet.setColumnWidth(2, 8);
      sheet.setColumnWidth(3, 20);
      sheet.setColumnWidth(4, 60);

      final fileBytes = excel.save();
      if (fileBytes == null) return;

      final uint8Bytes = Uint8List.fromList(fileBytes);

      if (kIsWeb) {
        final xFile = XFile.fromData(
          uint8Bytes,
          name: 'Import_Errors.xlsx',
          mimeType:
              'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        );
        await Share.shareXFiles([xFile], text: 'Import Error Report');
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final path = '${dir.path}/Import_Errors.xlsx';
        await File(path).writeAsBytes(uint8Bytes);
        errorReportPath.value = path;
        log('[ImportController] Error report saved to $path');
      }
    } catch (e) {
      log('[ImportController] Error report generation failed: $e');
    } finally {
      isGeneratingReport.value = false;
    }
  }

  Future<void> downloadErrorReport() async {
    if (errors.isEmpty) return;

    if (errorReportPath.value.isEmpty) {
      await _generateErrorReport();
      return;
    }

    try {
      await Share.shareXFiles(
        [XFile(errorReportPath.value)],
        text: 'Import Error Report',
      );
    } catch (e) {
      Get.snackbar('Error', 'Could not share file: $e');
    }
  }

  void resetImport() {
    _parsedData = {};
    _parsedEmployees = [];
    selectedFileName.value = '';
    parsedEmployeeCount.value = 0;
    parsedVehicleCount.value = 0;
    parsedDocCount.value = 0;
    parsedFineCount.value = 0;
    parsedAssignmentCount.value = 0;
    parsedMaintenanceCount.value = 0;
    parsedTyreCount.value = 0;
    errors.clear();
    summary.value = null;
    errorReportPath.value = '';
    statusMessage.value = '';
    currentVehicleIndex.value = 0;
    totalVehicles.value = 0;
  }

  // ==================== MASTER LOOKUP ====================

  int? _resolveVehicleTypeId(String name) {
    if (name.isEmpty) return null;
    return _masters.vehicleTypeMasters
        .firstWhereOrNull(
            (m) => m.status?.toLowerCase() == name.toLowerCase())
        ?.statusId;
  }

  int? _resolveVehicleStatusId(String name) {
    if (name.isEmpty) return null;
    return _masters.vehicleStatusMasters
        .firstWhereOrNull(
            (m) => m.status?.toLowerCase() == name.toLowerCase())
        ?.statusId;
  }

  int? _resolveConditionId(String name) {
    if (name.isEmpty) return null;
    return _masters.vehicleConditionMasters
        .firstWhereOrNull(
            (m) => m.status?.toLowerCase() == name.toLowerCase())
        ?.statusId;
  }

  int? _resolveFuelStationId(String name) {
    if (name.isEmpty) return null;
    return _masters.availableFuelStations
        .firstWhereOrNull(
            (f) => f.fuelStation?.toLowerCase() == name.toLowerCase())
        ?.fuelStationId;
  }

  List<int> _resolveCityIds(String cityStr) {
    if (cityStr.isEmpty) return [];
    final names = cityStr.split(',').map((e) => e.trim()).toList();
    final ids = <int>[];
    for (final name in names) {
      final id = _masters.companyCity
          .firstWhereOrNull(
              (c) => c.city?.toLowerCase() == name.toLowerCase())
          ?.cityId;
      if (id != null) ids.add(id);
    }
    return ids;
  }

  int? _resolveDocTypeId(String name) {
    if (name.isEmpty) return null;
    return _masters.companyDocumentTypes
        .firstWhereOrNull(
            (d) => d.docDescription?.toLowerCase() == name.toLowerCase())
        ?.docType;
  }

  FineType? _resolveFineType(String name) {
    if (name.isEmpty) return null;
    return _masters.fineTypeMasters.firstWhereOrNull(
        (f) => f.fineType?.toLowerCase() == name.toLowerCase());
  }

  StatusMaster? _resolveFineStatus(String name) {
    if (name.isEmpty) return null;
    return _masters.fineStatusMasters.firstWhereOrNull(
            (s) => s.status?.toLowerCase() == name.toLowerCase()) ??
        StatusMaster(statusId: null, status: name);
  }

  StatusMaster? _resolveAssignmentStatus(String name) {
    if (name.isEmpty) return null;
    return _masters.vehicleAssignmentStatusMasters.firstWhereOrNull(
            (s) => s.status?.toLowerCase() == name.toLowerCase()) ??
        StatusMaster(statusId: null, status: name);
  }

  int? _resolveMaintenanceTypeId(String name) {
    if (name.isEmpty) return null;
    return _masters.mainteneceMasters
        .firstWhereOrNull(
            (m) => m.maintenanceType?.toLowerCase() == name.toLowerCase())
        ?.maintenanceID;
  }

  int? _resolveVendorId(String name) {
    if (name.isEmpty) return null;
    final match = _masters.companyVendors.firstWhereOrNull(
        (v) => v?.vendorName?.toLowerCase() == name.toLowerCase());
    // vendorID is a String in the Vendor model
    return int.tryParse(match?.vendorID ?? '');
  }

  StatusMaster? _resolveTyrePosition(String name) {
    if (name.isEmpty) return null;
    return _masters.tirePositionMaster.firstWhereOrNull(
            (p) => p.status?.toLowerCase() == name.toLowerCase()) ??
        StatusMaster(statusId: null, status: name);
  }

  // ==================== EXCEL HELPERS ====================

  Sheet? _findSheet(Excel excel, String name) {
    for (final sheetName in excel.tables.keys) {
      if (sheetName.toLowerCase().contains(name.toLowerCase()) ||
          name.toLowerCase().contains(sheetName.toLowerCase())) {
        return excel.tables[sheetName];
      }
    }
    return null;
  }

  String _cellStr(List<Data?> row, int col) {
    if (col >= row.length) return '';
    final cell = row[col];
    if (cell == null) return '';
    final v = cell.value;
    if (v == null) return '';
    return v.toString().trim();
  }

  int? _cellInt(List<Data?> row, int col) {
    final s = _cellStr(row, col);
    if (s.isEmpty) return null;
    return int.tryParse(s.replaceAll(',', '').split('.').first);
  }

  double? _cellDouble(List<Data?> row, int col) {
    final s = _cellStr(row, col);
    if (s.isEmpty) return null;
    return double.tryParse(s.replaceAll(',', ''));
  }

  DateTime? _parseDate(String? s) {
    if (s == null || s.isEmpty) return null;
    final iso = DateTime.tryParse(s);
    if (iso != null) return iso;
    // Try DD/MM/YYYY
    final parts = s.split('/');
    if (parts.length == 3) {
      final d = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final y = int.tryParse(parts[2]);
      if (d != null && m != null && y != null) {
        return DateTime(y, m, d);
      }
    }
    return null;
  }

  void _addParseError(
      String sheet, int row, String vehicleNo, String field, String error) {
    errors.add(ImportError(
      vehicleNo: vehicleNo,
      sheet: sheet,
      row: row,
      field: field,
      error: error,
    ));
  }
}

// ==================== STRING EXTENSION ====================

extension _StringNullExt on String {
  String? get nullIfEmpty => isEmpty ? null : this;
}
