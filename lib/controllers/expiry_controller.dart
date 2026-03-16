import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:multifleet/models/company.dart';
import 'package:multifleet/models/tyre.dart';
import 'package:multifleet/models/vehicle.dart';
import 'package:multifleet/services/company_service.dart';
import 'package:multifleet/widgets/custom_widgets.dart';

import '../models/doc_master.dart';
import '../models/vehicle_docs.dart';
import '../repo/vehicles_repo.dart';

/// ============================================================
/// EXPIRY STATUS ENUM
/// ============================================================
/// Granular status categories for document expiration tracking

enum ExpiryStatus {
  expired, // Past due
  critical, // ≤7 days
  warning, // 8-30 days
  upcoming, // 31-60 days
  valid, // >60 days
  unknown, // No expiry date
}

/// ============================================================
/// EXPIRY ITEM MODEL
/// ============================================================
/// Flattened model combining vehicle + document for easy filtering

class ExpiryItem {
  final Vehicle vehicle;
  final VehicleDocument document;
  final String? documentTypeName;
  final ExpiryStatus status;
  final int daysUntilExpiry;

  ExpiryItem({
    required this.vehicle,
    required this.document,
    this.documentTypeName,
    required this.status,
    required this.daysUntilExpiry,
  });

  String get vehicleNo => vehicle.vehicleNo ?? 'Unknown';
  String get vehicleName =>
      '${vehicle.brand ?? ''} ${vehicle.model ?? ''}'.trim();
  DateTime? get expiryDate => document.expiryDate;
  int get docType => document.docType ?? 0;
}

/// ============================================================
/// RENEWAL HISTORY MODEL
/// ============================================================

class RenewalHistoryItem {
  final int? id;
  final int? vehicleId;
  final int? docType;
  final String? docTypeName;
  final DateTime? previousExpiryDate;
  final DateTime? newExpiryDate;
  final DateTime? renewalDate;
  final double? cost;
  final String? provider;
  final String? policyNumber;
  final String? remarks;
  final String? renewedBy;
  final String? documentUrl;

  RenewalHistoryItem({
    this.id,
    this.vehicleId,
    this.docType,
    this.docTypeName,
    this.previousExpiryDate,
    this.newExpiryDate,
    this.renewalDate,
    this.cost,
    this.provider,
    this.policyNumber,
    this.remarks,
    this.renewedBy,
    this.documentUrl,
  });

  factory RenewalHistoryItem.fromJson(Map<String, dynamic> json) {
    return RenewalHistoryItem(
      id: json['id'],
      vehicleId: json['vehicleId'],
      docType: json['docType'],
      docTypeName: json['docTypeName'],
      previousExpiryDate: json['previousExpiryDate'] != null
          ? DateTime.tryParse(json['previousExpiryDate'])
          : null,
      newExpiryDate: json['newExpiryDate'] != null
          ? DateTime.tryParse(json['newExpiryDate'])
          : null,
      renewalDate: json['renewalDate'] != null
          ? DateTime.tryParse(json['renewalDate'])
          : null,
      cost: json['cost']?.toDouble(),
      provider: json['provider'],
      policyNumber: json['policyNumber'],
      remarks: json['remarks'],
      renewedBy: json['renewedBy'],
      documentUrl: json['documentUrl'],
    );
  }
}

/// ============================================================
/// CALENDAR EVENT MODEL
/// ============================================================

class CalendarExpiryEvent {
  final DateTime date;
  final List<ExpiryItem> items;

  CalendarExpiryEvent({
    required this.date,
    required this.items,
  });

  int get count => items.length;

  ExpiryStatus get worstStatus {
    if (items.any((i) => i.status == ExpiryStatus.expired)) {
      return ExpiryStatus.expired;
    }
    if (items.any((i) => i.status == ExpiryStatus.critical)) {
      return ExpiryStatus.critical;
    }
    if (items.any((i) => i.status == ExpiryStatus.warning)) {
      return ExpiryStatus.warning;
    }
    if (items.any((i) => i.status == ExpiryStatus.upcoming)) {
      return ExpiryStatus.upcoming;
    }
    return ExpiryStatus.valid;
  }
}

/// ============================================================
/// EXPIRY CONTROLLER
/// ============================================================

class ExpiryController extends GetxController
    implements CompanyAwareController {
  final companyService = Get.find<CompanyService>();
  final _vehicleRepo = VehiclesRepo();

  // ==================== LOADING STATES ====================

  final isLoading = false.obs;
  final isLoadingDocTypes = false.obs;
  final isSubmitting = false.obs;
  final isLoadingHistory = false.obs;
  final isExporting = false.obs;

  // ==================== DOCUMENT TYPES (FROM API) ====================

  final availableDocumentTypes = <DocumentMaster>[].obs;

  // ==================== VEHICLES & EXPIRY DATA ====================

  final vehicles = <Vehicle>[].obs;
  final expiryItems = <ExpiryItem>[].obs;
  final filteredExpiryItems = <ExpiryItem>[].obs;

  // ==================== FILTERS ====================

  final searchController = TextEditingController();
  final selectedDocTypeFilter = Rx<int?>(null); // null = All
  final selectedStatusFilter = Rx<ExpiryStatus?>(null); // null = All
  final selectedVehicleTypeFilter = ''.obs; // '' = All
  final selectedTimeframeFilter = ''.obs; // '' = All

  final vehicleTypeOptions = <String>[].obs;
  final timeframeOptions =
      ['This Month', 'Next Month', '3 Months', '6 Months', 'This Year'].obs;

  // ==================== QUICK FILTER (STAT CARD CLICK) ====================

  final activeQuickFilter = Rx<ExpiryStatus?>(null);

  // ==================== SORT ====================

  final sortBy = 'expiry'.obs; // 'expiry', 'vehicle', 'docType'
  final sortAscending = true.obs;

  // ==================== VIEW MODES ====================

  final isGroupedByVehicle = true.obs;
  final showCalendarView = false.obs;
  final expandedVehicles = <String>{}.obs;

  // ==================== COMPARISON VIEW ====================

  final showComparisonView = false.obs;
  final selectedExpiryItem = Rx<ExpiryItem?>(null);
  final renewalHistory = <RenewalHistoryItem>[].obs;

  // ==================== RENEWAL FORM ====================

  final renewalFormKey = GlobalKey<FormState>();
  final newExpiryDate = Rx<DateTime?>(null);
  final renewalDate = Rx<DateTime?>(DateTime.now());
  final renewalCostController = TextEditingController();
  final renewalProviderController = TextEditingController();
  final renewalPolicyController = TextEditingController();
  final renewalRemarksController = TextEditingController();
  final renewalDocumentFile = Rx<File?>(null);
  final renewalDocumentBytes = Rx<Uint8List?>(null);
  final renewalDocumentName = ''.obs;

  // ==================== CALENDAR DATA ====================

  final calendarEvents = <DateTime, CalendarExpiryEvent>{}.obs;
  final selectedCalendarDate = Rx<DateTime?>(null);
  final focusedMonth = DateTime.now().obs;

  // ==================== LIFECYCLE ====================

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
    // registerController fires onCompanyChanged (→ _initialize) immediately
    // if company is already set, or waits for CompanyService restore on refresh.
    companyService.registerController(this);
  }

  @override
  Future<void> onCompanyChanged(Company newCompany) async {
    _initialize(company: newCompany.id);
  }

  @override
  void onClose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    renewalCostController.dispose();
    renewalProviderController.dispose();
    renewalPolicyController.dispose();
    renewalRemarksController.dispose();
    super.onClose();
  }

  void _onSearchChanged() {
    _applyFiltersInternal();
  }

  Future<void> _initialize({String? company}) async {
    await loadDocumentTypes(company: company);
    await loadVehiclesWithDocuments();
  }

  // ==================== LOAD DOCUMENT TYPES ====================

  Future<void> loadDocumentTypes({String? company}) async {
    isLoadingDocTypes.value = true;

    try {
      final companyId =
          company ?? companyService.selectedCompanyObs.value?.id ?? '';

      final response =
          await _vehicleRepo.getAllVehicleDocumentMaster(company: companyId);

      response.fold(
        (error) {
          log('[ExpiryController] Load doc types error: $error');
        },
        (docs) {
          availableDocumentTypes.value = docs;
          log('[ExpiryController] Loaded ${docs.length} document types');
        },
      );
    } catch (e) {
      log('[ExpiryController] Doc types exception: $e');
    } finally {
      isLoadingDocTypes.value = false;
    }
  }

  // ==================== LOAD VEHICLES WITH DOCUMENTS ====================

  // Future<void> loadVehiclesWithDocuments({String? company}) async {
  //   isLoading.value = true;

  //   try {
  //     final companyId =
  //         company ?? companyService.selectedCompanyObs.value?.id ?? '';

  //     final result = await _vehicleRepo.getAllVehicles(company: companyId);

  //     result.fold(
  //       (error) {
  //         log('[ExpiryController] Load vehicles error: $error');
  //         CustomWidget.customSnackBar(
  //           isError: true,
  //           title: 'Error',
  //           message: error,
  //         );
  //       },
  //       (data) {
  //         log('[ExpiryController] Loaded ${data.length} vehicles');
  //         vehicles.value = data;
  //         _extractVehicleTypes();
  //         _buildExpiryItems();
  //         _applyFiltersInternal();
  //         _buildCalendarEvents();
  //       },
  //     );
  //   } catch (e) {
  //     log('[ExpiryController] Exception: $e');
  //     CustomWidget.customSnackBar(
  //       isError: true,
  //       title: 'Error',
  //       message: 'Failed to load vehicles',
  //     );
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  Future<void> loadVehiclesWithDocuments() async {
    isLoading.value = true;
    try {
      // Get the basic vehicle details first
      await getVehicles();

      if (vehicles.isNotEmpty) {
        // Create a map to easily find vehicles by vehicleNo
        Map<String?, Vehicle> vehicleMap = {};
        for (var vehicle in vehicles) {
          if (vehicle.vehicleNo != null) {
            vehicleMap[vehicle.vehicleNo] = vehicle;
          }
        }
        // log(vehicleMap.toString());
        // Fetch documents for each vehicle
        await fetchAndAttachDocuments(vehicleMap);

        // Fetch tyres for each vehicle
        await fetchAndAttachTyres(vehicleMap);

        // Update the original and filtered lists with the enhanced vehicles
        vehicles.value = vehicleMap.values.toList();
        _extractVehicleTypes();
        _buildExpiryItems();
        _applyFiltersInternal();
        _buildCalendarEvents();
      }
    } on Exception catch (e) {
      log('Error getting comprehensive vehicle data: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getVehicles() async {
    isLoading.value = true;
    try {
      var result = await VehiclesRepo().getAllVehicles(
          company: '${companyService.selectedCompanyObs.value?.id}');
      result.fold((error) {
        log(error);
      }, (vehicles) {
        this.vehicles.value = vehicles;
        // filteredVehicles.value = List.from(vehicles);
      });
    } on Exception catch (e) {
      log(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Helper function to fetch and attach documents
  Future<void> fetchAndAttachDocuments(Map<String?, Vehicle> vehicleMap) async {
    try {
      // Assuming you have a repository method to get documents for all vehicles or by company
      var result = await VehiclesRepo().getVehicleDocument(
          company: '${companyService.selectedCompanyObs.value?.id}');

      result.fold((error) {
        log('Error fetching vehicle documents: $error');
      }, (documents) {
        // Group documents by vehicleNo
        Map<String?, List<VehicleDocument>> docsByVehicle = {};

        for (var doc in documents) {
          if (doc.vehicleNo != null) {
            docsByVehicle.putIfAbsent(doc.vehicleNo, () => []);
            docsByVehicle[doc.vehicleNo]!.add(doc);
          }
        }

        // Attach documents to corresponding vehicles
        docsByVehicle.forEach((vehicleNo, docs) {
          if (vehicleMap.containsKey(vehicleNo)) {
            vehicleMap[vehicleNo] = vehicleMap[vehicleNo]!.withDocuments(docs);
          }
        });
      });
    } catch (e) {
      log('Exception in fetchAndAttachDocuments: ${e.toString()}');
    }
  }

  // Helper function to fetch and attach tyres
  Future<void> fetchAndAttachTyres(Map<String?, Vehicle> vehicleMap) async {
    log("vehicleMap");
    try {
      // Assuming you have a repository method to get tyres for all vehicles or by company
      var result = await VehiclesRepo().getAllVehicleTyres(
        company: companyService.selectedCompanyObs.value!.id!,
        vehicleNumber: vehicleMap.values.first.vehicleNo!,
      );

      result.fold((error) {
        log('Error fetching vehicle tyres: $error');
      }, (tyres) {
        // Group tyres by vehicleNo
        Map<String?, List<Tyre>> tyresByVehicle = {};

        for (var tyre in tyres) {
          tyresByVehicle.putIfAbsent(tyre.vehicleNo, () => []);
          tyresByVehicle[tyre.vehicleNo]!.add(tyre);
        }

        // Attach tyres to corresponding vehicles
        tyresByVehicle.forEach((vehicleNo, vehicleTyres) {
          if (vehicleMap.containsKey(vehicleNo)) {
            vehicleMap[vehicleNo] =
                vehicleMap[vehicleNo]!.withTyres(vehicleTyres);
          }
        });
      });
    } catch (e) {
      log('Exception in fetchAndAttachTyres: ${e.toString()}');
    }
  }

  void _extractVehicleTypes() {
    final types = vehicles
        .where((v) => v.type != null && v.type!.isNotEmpty)
        .map((v) => v.type!)
        .toSet()
        .toList();
    types.sort();
    vehicleTypeOptions.value = types;
  }

  void _buildExpiryItems() {
    final items = <ExpiryItem>[];

    for (final vehicle in vehicles) {
      if (vehicle.documents == null || vehicle.documents!.isEmpty) continue;

      for (final doc in vehicle.documents!) {
        if (doc.expiryDate == null) continue;

        final docTypeName = _getDocumentTypeName(doc.docType);
        final status = _calculateExpiryStatus(doc.expiryDate);
        final daysUntil = _calculateDaysUntilExpiry(doc.expiryDate);

        items.add(ExpiryItem(
          vehicle: vehicle,
          document: doc,
          documentTypeName: docTypeName,
          status: status,
          daysUntilExpiry: daysUntil,
        ));
      }
    }

    expiryItems.value = items;
  }

  String _getDocumentTypeName(int? docType) {
    if (docType == null) return 'Unknown';

    final docMaster =
        availableDocumentTypes.firstWhereOrNull((d) => d.docType == docType);
    return docMaster?.docDescription ?? 'Document #$docType';
  }

  ExpiryStatus _calculateExpiryStatus(DateTime? expiryDate) {
    if (expiryDate == null) return ExpiryStatus.unknown;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    final daysUntil = expiry.difference(today).inDays;

    if (daysUntil < 0) return ExpiryStatus.expired;
    if (daysUntil <= 7) return ExpiryStatus.critical;
    if (daysUntil <= 30) return ExpiryStatus.warning;
    if (daysUntil <= 60) return ExpiryStatus.upcoming;
    return ExpiryStatus.valid;
  }

  int _calculateDaysUntilExpiry(DateTime? expiryDate) {
    if (expiryDate == null) return -9999;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return expiry.difference(today).inDays;
  }

  // ==================== FILTERS ====================

  void applyFilters() {
    _applyFiltersInternal();
    CustomWidget.customSnackBar(
      title: 'Filters Applied',
      message: '${filteredExpiryItems.length} items found',
      isError: false,
    );
  }

  void _applyFiltersInternal() {
    var result = List<ExpiryItem>.from(expiryItems);

    // Text search
    if (searchController.text.isNotEmpty) {
      final query = searchController.text.toLowerCase();
      result = result.where((item) {
        return item.vehicleNo.toLowerCase().contains(query) ||
            item.vehicleName.toLowerCase().contains(query) ||
            (item.documentTypeName?.toLowerCase().contains(query) ?? false) ||
            (item.vehicle.chassisNo?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Document type filter
    if (selectedDocTypeFilter.value != null) {
      result = result
          .where((item) => item.docType == selectedDocTypeFilter.value)
          .toList();
    }

    // Status filter (from dropdown OR quick filter)
    final statusToFilter =
        activeQuickFilter.value ?? selectedStatusFilter.value;
    if (statusToFilter != null) {
      result = result.where((item) => item.status == statusToFilter).toList();
    }

    // Vehicle type filter
    if (selectedVehicleTypeFilter.value.isNotEmpty) {
      result = result
          .where((item) => item.vehicle.type == selectedVehicleTypeFilter.value)
          .toList();
    }

    // Timeframe filter
    if (selectedTimeframeFilter.value.isNotEmpty) {
      final now = DateTime.now();
      DateTime cutoffDate;

      switch (selectedTimeframeFilter.value) {
        case 'This Month':
          cutoffDate = DateTime(now.year, now.month + 1, 0);
          break;
        case 'Next Month':
          cutoffDate = DateTime(now.year, now.month + 2, 0);
          break;
        case '3 Months':
          cutoffDate = DateTime(now.year, now.month + 3, now.day);
          break;
        case '6 Months':
          cutoffDate = DateTime(now.year, now.month + 6, now.day);
          break;
        case 'This Year':
          cutoffDate = DateTime(now.year, 12, 31);
          break;
        default:
          cutoffDate = DateTime(now.year + 10, 1, 1);
      }

      result = result.where((item) {
        if (item.expiryDate == null) return false;
        return item.expiryDate!.isBefore(cutoffDate) ||
            item.expiryDate!.isAtSameMomentAs(cutoffDate);
      }).toList();
    }

    // Apply sorting
    _sortItems(result);

    filteredExpiryItems.value = result;
  }

  void _sortItems(List<ExpiryItem> items) {
    switch (sortBy.value) {
      case 'expiry':
        items.sort((a, b) {
          final comparison = a.daysUntilExpiry.compareTo(b.daysUntilExpiry);
          return sortAscending.value ? comparison : -comparison;
        });
        break;
      case 'vehicle':
        items.sort((a, b) {
          final comparison = a.vehicleNo.compareTo(b.vehicleNo);
          return sortAscending.value ? comparison : -comparison;
        });
        break;
      case 'docType':
        items.sort((a, b) {
          final comparison =
              (a.documentTypeName ?? '').compareTo(b.documentTypeName ?? '');
          return sortAscending.value ? comparison : -comparison;
        });
        break;
    }
  }

  void clearFilters() {
    searchController.clear();
    selectedDocTypeFilter.value = null;
    selectedStatusFilter.value = null;
    selectedVehicleTypeFilter.value = '';
    selectedTimeframeFilter.value = '';
    activeQuickFilter.value = null;

    filteredExpiryItems.value = List.from(expiryItems);
    _sortItems(filteredExpiryItems);

    CustomWidget.customSnackBar(
      title: 'Filters Cleared',
      message: 'Showing all expiry items',
      isError: false,
    );
  }

  bool get hasActiveFilters {
    return searchController.text.isNotEmpty ||
        selectedDocTypeFilter.value != null ||
        selectedStatusFilter.value != null ||
        selectedVehicleTypeFilter.value.isNotEmpty ||
        selectedTimeframeFilter.value.isNotEmpty ||
        activeQuickFilter.value != null;
  }

  // ==================== QUICK FILTER (STAT CARD) ====================

  void setQuickFilter(ExpiryStatus? status) {
    if (activeQuickFilter.value == status) {
      activeQuickFilter.value = null; // Toggle off
    } else {
      activeQuickFilter.value = status;
    }
    // Clear dropdown status filter when using quick filter
    if (status != null) {
      selectedStatusFilter.value = null;
    }
    _applyFiltersInternal();
  }

  // ==================== SORT ====================

  void setSortBy(String field) {
    if (sortBy.value == field) {
      sortAscending.value = !sortAscending.value;
    } else {
      sortBy.value = field;
      sortAscending.value = true;
    }
    _applyFiltersInternal();
  }

  // ==================== VIEW MODES ====================

  void toggleGroupedView() {
    isGroupedByVehicle.value = !isGroupedByVehicle.value;
    if (!isGroupedByVehicle.value) {
      expandedVehicles.clear();
    }
  }

  void toggleCalendarView() {
    showCalendarView.value = !showCalendarView.value;
    if (showCalendarView.value) {
      _buildCalendarEvents();
    }
  }

  void toggleVehicleExpanded(String vehicleNo) {
    if (expandedVehicles.contains(vehicleNo)) {
      expandedVehicles.remove(vehicleNo);
    } else {
      expandedVehicles.add(vehicleNo);
    }
  }

  Map<String, List<ExpiryItem>> get groupedByVehicle {
    final grouped = <String, List<ExpiryItem>>{};
    for (final item in filteredExpiryItems) {
      final key = item.vehicleNo;
      grouped.putIfAbsent(key, () => []).add(item);
    }
    return grouped;
  }

  // ==================== COMPARISON / DETAIL VIEW ====================

  Future<void> selectExpiryItem(ExpiryItem item) async {
    selectedExpiryItem.value = item;
    showComparisonView.value = true;
    await loadRenewalHistory(item);
  }

  void closeComparisonView() {
    showComparisonView.value = false;
    selectedExpiryItem.value = null;
    renewalHistory.clear();
    _clearRenewalForm();
  }

  Future<void> loadRenewalHistory(ExpiryItem item) async {
    isLoadingHistory.value = true;

    try {
      // final companyId = companyService.selectedCompanyObs.value?.id ?? '';

      // final result = await _vehicleRepo.getDocumentRenewalHistory(
      //   company: companyId,
      //   vehicleId: item.vehicle.vehicleNo ?? 0,
      //   docType: item.docType,
      // );

      // result.fold(
      //   (error) {
      //     log('[ExpiryController] Load history error: $error');
      //     // Don't show error snackbar - history might just be empty
      //   },
      //   (data) {
      //     renewalHistory.value = data.map((json) =>
      //         RenewalHistoryItem.fromJson(json)).toList();
      //     // Sort by renewal date descending
      //     renewalHistory.sort((a, b) {
      //       if (a.renewalDate == null && b.renewalDate == null) return 0;
      //       if (a.renewalDate == null) return 1;
      //       if (b.renewalDate == null) return -1;
      //       return b.renewalDate!.compareTo(a.renewalDate!);
      //     });
      //   },
      // );
    } catch (e) {
      log('[ExpiryController] History exception: $e');
    } finally {
      isLoadingHistory.value = false;
    }
  }

  // ==================== RENEWAL ====================

  void _clearRenewalForm() {
    newExpiryDate.value = null;
    renewalDate.value = DateTime.now();
    renewalCostController.clear();
    renewalProviderController.clear();
    renewalPolicyController.clear();
    renewalRemarksController.clear();
    renewalDocumentFile.value = null;
    renewalDocumentBytes.value = null;
    renewalDocumentName.value = '';
  }

  void setRenewalDocument(File? file, {Uint8List? bytes, String? name}) {
    renewalDocumentFile.value = file;
    renewalDocumentBytes.value = bytes;
    renewalDocumentName.value = name ?? file?.path.split('/').last ?? '';
  }

  Future<bool> submitRenewal(ExpiryItem item) async {
    if (!_validateRenewalForm()) return false;

    isSubmitting.value = true;

    try {
      final companyId = companyService.selectedCompanyObs.value?.id ?? '';

      // Prepare renewal data
      final renewalData = {
        'vehicleId': item.vehicle.vehicleNo,
        'docType': item.docType,
        'previousExpiryDate': item.expiryDate?.toIso8601String(),
        'newExpiryDate': newExpiryDate.value?.toIso8601String(),
        'renewalDate': renewalDate.value?.toIso8601String(),
        'cost': double.tryParse(renewalCostController.text) ?? 0,
        'provider': renewalProviderController.text.trim(),
        'policyNumber': renewalPolicyController.text.trim(),
        'remarks': renewalRemarksController.text.trim(),
      };

      // final result = await _vehicleRepo.renewDocument(
      //   company: companyId,
      //   data: renewalData,
      //   documentFile: renewalDocumentFile.value,
      //   documentBytes: renewalDocumentBytes.value,
      //   documentName: renewalDocumentName.value,
      // );

      // return result.fold(
      //   (error) {
      //     CustomWidget.customSnackBar(
      //       isError: true,
      //       title: 'Error',
      //       message: error,
      //     );
      //     return false;
      //   },
      //   (success) {
      //     CustomWidget.customSnackBar(
      //       isError: false,
      //       title: 'Success',
      //       message: 'Document renewed successfully',
      //     );

      //     // Refresh data
      //     loadVehiclesWithDocuments();
      //     closeComparisonView();
      //     return true;
      //   },
      // );
      return true;
    } catch (e) {
      log('[ExpiryController] Renewal exception: $e');
      CustomWidget.customSnackBar(
        isError: true,
        title: 'Error',
        message: 'Failed to renew document',
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  bool _validateRenewalForm() {
    if (newExpiryDate.value == null) {
      CustomWidget.customSnackBar(
        isError: true,
        title: 'Validation Error',
        message: 'Please select new expiry date',
      );
      return false;
    }

    if (renewalDate.value == null) {
      CustomWidget.customSnackBar(
        isError: true,
        title: 'Validation Error',
        message: 'Please select renewal date',
      );
      return false;
    }

    if (newExpiryDate.value!.isBefore(renewalDate.value!)) {
      CustomWidget.customSnackBar(
        isError: true,
        title: 'Validation Error',
        message: 'New expiry date must be after renewal date',
      );
      return false;
    }

    return true;
  }

  // ==================== BULK RENEWAL ====================

  // Future<void> scheduleBulkRenewal({
  //   required DateTime scheduledDate,
  //   required String provider,
  //   String? remarks,
  // }) async {
  //   if (selectedItems.isEmpty) {
  //     CustomWidget.customSnackBar(
  //       isError: true,
  //       title: 'Error',
  //       message: 'Please select items to schedule',
  //     );
  //     return;
  //   }

  //   isSubmitting.value = true;

  //   try {
  //     final companyId = companyService.selectedCompanyObs.value?.id ?? '';

  //     final items = selectedItems
  //         .map((item) => {
  //               'vehicleId': item.vehicle.vehicleNo,
  //               'docType': item.docType,
  //             })
  //         .toList();

  //     // final result = await _vehicleRepo.scheduleBulkRenewal(
  //     //   company: companyId,
  //     //   items: items,
  //     //   scheduledDate: scheduledDate,
  //     //   provider: provider,
  //     //   remarks: remarks,
  //     // );

  //     // result.fold(
  //     //   (error) {
  //     //     CustomWidget.customSnackBar(
  //     //       isError: true,
  //     //       title: 'Error',
  //     //       message: error,
  //     //     );
  //     //   },
  //     //   (success) {
  //     //     CustomWidget.customSnackBar(
  //     //       isError: false,
  //     //       title: 'Success',
  //     //       message: '${selectedItems.length} renewals scheduled',
  //     //     );
  //     //     toggleSelectionMode();
  //     //   },
  //     // );
  //   } catch (e) {
  //     log('[ExpiryController] Bulk renewal exception: $e');
  //     CustomWidget.customSnackBar(
  //       isError: true,
  //       title: 'Error',
  //       message: 'Failed to schedule renewals',
  //     );
  //   } finally {
  //     isSubmitting.value = false;
  //   }
  // }

  // ==================== CALENDAR ====================

  void _buildCalendarEvents() {
    final events = <DateTime, CalendarExpiryEvent>{};

    for (final item in expiryItems) {
      if (item.expiryDate == null) continue;

      final dateKey = DateTime(
        item.expiryDate!.year,
        item.expiryDate!.month,
        item.expiryDate!.day,
      );

      if (events.containsKey(dateKey)) {
        events[dateKey]!.items.add(item);
      } else {
        events[dateKey] = CalendarExpiryEvent(
          date: dateKey,
          items: [item],
        );
      }
    }

    calendarEvents.value = events;
  }

  void selectCalendarDate(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    selectedCalendarDate.value = dateKey;

    // Filter to show only items expiring on this date
    final event = calendarEvents[dateKey];
    if (event != null) {
      filteredExpiryItems.value = event.items;
    }
    update();
  }

  void clearCalendarSelection() {
    selectedCalendarDate.value = null;
    _applyFiltersInternal();
  }

  List<ExpiryItem> getEventsForDay(DateTime day) {
    final dateKey = DateTime(day.year, day.month, day.day);
    return calendarEvents[dateKey]?.items ?? [];
  }

  void setFocusedMonth(DateTime month) {
    focusedMonth.value = DateTime(month.year, month.month, 1);
  }

  // ==================== EXPORT ====================

  Future<void> exportToExcel() async {
    isExporting.value = true;

    try {
      final companyId = companyService.selectedCompanyObs.value?.id ?? '';
      final companyName =
          companyService.selectedCompanyObs.value?.name ?? 'MultiFleet';

      // Build export data
      final exportData = filteredExpiryItems
          .map((item) => {
                'Vehicle No': item.vehicleNo,
                'Vehicle': item.vehicleName,
                'Vehicle Type': item.vehicle.type ?? '-',
                'Document Type': item.documentTypeName ?? '-',
                'Expiry Date': item.expiryDate != null
                    ? DateFormat('dd/MM/yyyy').format(item.expiryDate!)
                    : '-',
                'Days Remaining': item.daysUntilExpiry,
                'Status': getStatusLabel(item.status),
              })
          .toList();

      // final result = await _vehicleRepo.exportExpiryReport(
      //   company: companyId,
      //   data: exportData,
      //   fileName: '${companyName}_Expiry_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}',
      // );

      // result.fold(
      //   (error) {
      //     CustomWidget.customSnackBar(
      //       isError: true,
      //       title: 'Export Failed',
      //       message: error,
      //     );
      //   },
      //   (filePath) {
      //     CustomWidget.customSnackBar(
      //       isError: false,
      //       title: 'Export Successful',
      //       message: 'Report saved to downloads',
      //     );
      //   },
      // );
    } catch (e) {
      log('[ExpiryController] Export exception: $e');
      CustomWidget.customSnackBar(
        isError: true,
        title: 'Export Failed',
        message: 'Failed to export report',
      );
    } finally {
      isExporting.value = false;
    }
  }

  Future<void> exportToCsv() async {
    isExporting.value = true;

    try {
      final companyName =
          companyService.selectedCompanyObs.value?.name ?? 'MultiFleet';

      // Build CSV content
      final buffer = StringBuffer();
      buffer.writeln(
          'Vehicle No,Vehicle,Vehicle Type,Document Type,Expiry Date,Days Remaining,Status');

      for (final item in filteredExpiryItems) {
        buffer.writeln([
          item.vehicleNo,
          '"${item.vehicleName}"',
          item.vehicle.type ?? '-',
          item.documentTypeName ?? '-',
          item.expiryDate != null
              ? DateFormat('dd/MM/yyyy').format(item.expiryDate!)
              : '-',
          item.daysUntilExpiry,
          getStatusLabel(item.status),
        ].join(','));
      }

      final fileName =
          '${companyName}_Expiry_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv';

      // final result = await _vehicleRepo.saveCsvFile(
      //   content: buffer.toString(),
      //   fileName: fileName,
      // );

      // result.fold(
      //   (error) {
      //     CustomWidget.customSnackBar(
      //       isError: true,
      //       title: 'Export Failed',
      //       message: error,
      //     );
      //   },
      //   (filePath) {
      //     CustomWidget.customSnackBar(
      //       isError: false,
      //       title: 'Export Successful',
      //       message: 'CSV saved to downloads',
      //     );
      //   },
      // );
    } catch (e) {
      log('[ExpiryController] CSV export exception: $e');
    } finally {
      isExporting.value = false;
    }
  }

  // ==================== STATISTICS ====================

  int get totalDocuments => expiryItems.length;

  int get expiredCount =>
      expiryItems.where((i) => i.status == ExpiryStatus.expired).length;

  int get criticalCount =>
      expiryItems.where((i) => i.status == ExpiryStatus.critical).length;

  int get warningCount =>
      expiryItems.where((i) => i.status == ExpiryStatus.warning).length;

  int get upcomingCount =>
      expiryItems.where((i) => i.status == ExpiryStatus.upcoming).length;

  int get validCount =>
      expiryItems.where((i) => i.status == ExpiryStatus.valid).length;

  int get filteredCount => filteredExpiryItems.length;

  double get compliancePercentage {
    if (totalDocuments == 0) return 100.0;
    final nonExpired = totalDocuments - expiredCount;
    return (nonExpired / totalDocuments) * 100;
  }

  int getCountByDocType(int docType) {
    return expiryItems.where((i) => i.docType == docType).length;
  }

  int getExpiringCountByDocType(int docType) {
    return expiryItems
        .where((i) =>
            i.docType == docType &&
            (i.status == ExpiryStatus.expired ||
                i.status == ExpiryStatus.critical ||
                i.status == ExpiryStatus.warning))
        .length;
  }

  // ==================== HELPERS ====================

  String getStatusLabel(ExpiryStatus status) {
    switch (status) {
      case ExpiryStatus.expired:
        return 'Expired';
      case ExpiryStatus.critical:
        return 'Critical';
      case ExpiryStatus.warning:
        return 'Warning';
      case ExpiryStatus.upcoming:
        return 'Upcoming';
      case ExpiryStatus.valid:
        return 'Valid';
      case ExpiryStatus.unknown:
        return 'Unknown';
    }
  }

  Color getStatusColor(ExpiryStatus status) {
    switch (status) {
      case ExpiryStatus.expired:
        return const Color(0xFFEF4444); // Red
      case ExpiryStatus.critical:
        return const Color(0xFFDC2626); // Darker Red
      case ExpiryStatus.warning:
        return const Color(0xFFF59E0B); // Amber
      case ExpiryStatus.upcoming:
        return const Color(0xFF3B82F6); // Blue
      case ExpiryStatus.valid:
        return const Color(0xFF22C55E); // Green
      case ExpiryStatus.unknown:
        return const Color(0xFF64748B); // Slate
    }
  }

  Color getStatusBgColor(ExpiryStatus status) {
    switch (status) {
      case ExpiryStatus.expired:
        return const Color(0xFFFEE2E2); // Red light
      case ExpiryStatus.critical:
        return const Color(0xFFFECACA); // Red lighter
      case ExpiryStatus.warning:
        return const Color(0xFFFEF3C7); // Amber light
      case ExpiryStatus.upcoming:
        return const Color(0xFFDBEAFE); // Blue light
      case ExpiryStatus.valid:
        return const Color(0xFFDCFCE7); // Green light
      case ExpiryStatus.unknown:
        return const Color(0xFFF1F5F9); // Slate light
    }
  }

  IconData getStatusIcon(ExpiryStatus status) {
    switch (status) {
      case ExpiryStatus.expired:
        return Icons.error;
      case ExpiryStatus.critical:
        return Icons.warning_amber;
      case ExpiryStatus.warning:
        return Icons.access_time;
      case ExpiryStatus.upcoming:
        return Icons.schedule;
      case ExpiryStatus.valid:
        return Icons.check_circle;
      case ExpiryStatus.unknown:
        return Icons.help_outline;
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd MMM yyyy').format(date);
  }

  String formatDateShort(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd/MM/yy').format(date);
  }

  String formatDaysRemaining(int days) {
    if (days < 0) {
      final absDays = days.abs();
      return '$absDays day${absDays == 1 ? '' : 's'} overdue';
    } else if (days == 0) {
      return 'Expires today';
    } else if (days == 1) {
      return '1 day left';
    } else {
      return '$days days left';
    }
  }

  String formatCurrency(double? amount) {
    if (amount == null) return '-';
    return NumberFormat.currency(
      symbol: companyService.selectedCompanyObs.value?.currency ?? 'AED ',
      decimalDigits: 2,
    ).format(amount);
  }

  // ==================== REFRESH ====================

  Future<void> refreshUI() async {
    await _initialize();
  }
}

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:multifleet/controllers/vehicle_listing_controller.dart';
// import 'package:multifleet/models/vehicle.dart';

// class ExpiryDetailsController extends GetxController {
//   var vehicleCon = Get.find<VehicleListingController>();
//   // Filter options
//   final expiryTypeOptions = ['All', 'Insurance', 'Mulkiya', 'Service'].obs;
//   final selectedExpiryType = 'All'.obs;

//   final timeframeOptions =
//       ['All', 'This Month', 'Next Month', '3 Months', '6 Months'].obs;
//   final selectedTimeframe = 'All'.obs;

//   RxList<String> vehicleTypeOptions = <String>[].obs;
//   final selectedVehicleType = 'All'.obs;

//   // Data
//   final vehiclesList = RxList<Vehicle>([]);
//   final filteredVehiclesList = RxList<Vehicle>([]);
//   final selectedVehicle = Rx<Vehicle?>(null);

//   // For comparison view
//   final showComparisonView = false.obs;
//   final previousData = Rx<Vehicle?>(null);

//   // Search
//   final searchController = TextEditingController();
//   final isSearching = false.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     // Load sample data
//     vehicleTypeOptions.value = vehicleCon.getVehicleTypes();
//     vehiclesList.value = vehicleCon.originalVehicles;
//     // Initialize filtered list
//     filteredVehiclesList.value = vehiclesList;

//     // Add listeners for filtering
//     ever(selectedExpiryType, (_) => applyFilters());
//     ever(selectedTimeframe, (_) => applyFilters());
//     ever(selectedVehicleType, (_) => applyFilters());
//   }

//   @override
//   void onClose() {
//     searchController.dispose();
//     super.onClose();
//   }

//   void selectVehicle(Vehicle vehicle) {
//     selectedVehicle.value = vehicle;
//     showComparisonView.value = true;
//   }

//   void closeComparisonView() {
//     showComparisonView.value = false;
//     selectedVehicle.value = null;
//     previousData.value = null;
//   }

//   void applyFilters() {
//     List<Vehicle> result = List.from(vehiclesList);

//     // Apply vehicle type filter
//     if (selectedVehicleType.value != 'All') {
//       result =
//           result.where((v) => v.type == selectedVehicleType.value).toList();
//     }

//     // Apply timeframe filter
//     if (selectedTimeframe.value != 'All') {
//       DateTime now = DateTime.now();
//       DateTime cutoffDate;

//       switch (selectedTimeframe.value) {
//         case 'This Month':
//           cutoffDate = DateTime(now.year, now.month + 1, 1);
//           break;
//         case 'Next Month':
//           cutoffDate = DateTime(now.year, now.month + 2, 1);
//           break;
//         case '3 Months':
//           cutoffDate = DateTime(now.year, now.month + 3, 1);
//           break;
//         case '6 Months':
//           cutoffDate = DateTime(now.year, now.month + 6, 1);
//           break;
//         default:
//           cutoffDate = DateTime(now.year + 1, now.month, now.day);
//       }

//       // Filter based on expiry type - using the documents list
//       if (selectedExpiryType.value == 'All') {
//         // Check all document types
//         result = result.where((v) {
//           if (v.documents == null || v.documents!.isEmpty) return false;

//           // Check if any document expires within the timeframe
//           return v.documents!.any((doc) =>
//               doc.expiryDate != null &&
//               doc.expiryDate!.isAfter(now) &&
//               doc.expiryDate!.isBefore(cutoffDate));
//         }).toList();
//       } else if (selectedExpiryType.value == 'Insurance') {
//         // Filter insurance documents (docType 1001)
//         result = result.where((v) {
//           if (v.documents == null || v.documents!.isEmpty) return false;

//           // Find insurance documents
//           var insuranceDocs = v.documents!.where((doc) => doc.docType == 1001);
//           if (insuranceDocs.isEmpty) return false;

//           // Check if any insurance document expires within the timeframe
//           return insuranceDocs.any((doc) =>
//               doc.expiryDate != null &&
//               doc.expiryDate!.isAfter(now) &&
//               doc.expiryDate!.isBefore(cutoffDate));
//         }).toList();
//       } else if (selectedExpiryType.value == 'Mulkiya') {
//         // Filter registration documents (docType 1002)
//         result = result.where((v) {
//           if (v.documents == null || v.documents!.isEmpty) return false;

//           // Find registration documents
//           var registrationDocs =
//               v.documents!.where((doc) => doc.docType == 1002);
//           if (registrationDocs.isEmpty) return false;

//           // Check if any registration document expires within the timeframe
//           return registrationDocs.any((doc) =>
//               doc.expiryDate != null &&
//               doc.expiryDate!.isAfter(now) &&
//               doc.expiryDate!.isBefore(cutoffDate));
//         }).toList();
//       } else if (selectedExpiryType.value == 'Service') {
//         // If you have a specific docType for service or handle it differently,
//         // you would implement that logic here
//         // For now, let's assume service is docType 1003
//         result = result.where((v) {
//           if (v.documents == null || v.documents!.isEmpty) return false;

//           // Find service documents
//           var serviceDocs = v.documents!.where((doc) => doc.docType == 1003);
//           if (serviceDocs.isEmpty) return false;

//           // Check if any service document expires within the timeframe
//           return serviceDocs.any((doc) =>
//               doc.expiryDate != null &&
//               doc.expiryDate!.isAfter(now) &&
//               doc.expiryDate!.isBefore(cutoffDate));
//         }).toList();
//       }
//     } else {
//       // If no timeframe filter, still apply expiry type filter
//       if (selectedExpiryType.value == 'Insurance') {
//         result = result
//             .where((v) =>
//                 v.documents != null &&
//                 v.documents!.any(
//                     (doc) => doc.docType == 1001 && doc.expiryDate != null))
//             .toList();
//       } else if (selectedExpiryType.value == 'Mulkiya') {
//         result = result
//             .where((v) =>
//                 v.documents != null &&
//                 v.documents!.any(
//                     (doc) => doc.docType == 1002 && doc.expiryDate != null))
//             .toList();
//       } else if (selectedExpiryType.value == 'Service') {
//         result = result
//             .where((v) =>
//                 v.documents != null &&
//                 v.documents!.any(
//                     (doc) => doc.docType == 1003 && doc.expiryDate != null))
//             .toList();
//       }
//     }

//     // Apply search if active
//     if (isSearching.value && searchController.text.isNotEmpty) {
//       final searchTerm = searchController.text.toLowerCase();
//       result = result
//           .where((v) =>
//               (v.vehicleNo?.toLowerCase().contains(searchTerm) ?? false) ||
//               (v.brand?.toLowerCase().contains(searchTerm) ?? false) ||
//               (v.model?.toLowerCase().contains(searchTerm) ?? false) ||
//               (v.chassisNo?.toLowerCase().contains(searchTerm) ?? false) ||
//               (v.description?.toLowerCase().contains(searchTerm) ?? false))
//           .toList();
//     }

//     filteredVehiclesList.value = result;
//   }

//   void search(String query) {
//     isSearching.value = query.isNotEmpty;
//     applyFilters();
//   }

//   void clearSearch() {
//     searchController.clear();
//     isSearching.value = false;
//     applyFilters();
//   }

//   String getExpiryStatus(DateTime? expiryDate) {
//     if (expiryDate == null) return 'Unknown';

//     final now = DateTime.now();
//     final daysUntilExpiry = expiryDate.difference(now).inDays;

//     if (daysUntilExpiry < 0) return 'Expired';
//     if (daysUntilExpiry <= 30) return 'Soon';
//     return 'Valid';
//   }

//   Color getStatusColor(String status) {
//     switch (status) {
//       case 'Expired':
//         return Colors.red;
//       case 'Soon':
//         return Colors.orange;
//       case 'Valid':
//         return Colors.green;
//       default:
//         return Colors.grey;
//     }
//   }
// }
