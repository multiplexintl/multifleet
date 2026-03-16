import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:multifleet/models/company.dart';
import 'package:multifleet/models/vendor.dart';
import 'package:multifleet/models/vehicle.dart';

import 'package:multifleet/services/company_service.dart';
import 'package:multifleet/widgets/custom_widgets.dart';

import '../models/maintenance.dart';
import '../models/maintenance_master.dart';
import '../repo/maintenance_repo.dart';
import '../repo/vehicles_repo.dart';
import '../repo/vendor_repo.dart';
import 'general_masters.dart';

/// MaintenanceController - Handles all maintenance/service related operations
/// Implements CompanyAwareController for company switching support
class MaintenanceController extends GetxController
    implements CompanyAwareController {
  final companyService = Get.find<CompanyService>();
  final _repo = MaintenanceRepo();
  final _vehicleRepo = VehiclesRepo();
  final _vendorRepo = VendorRepo();
  final genCon = Get.find<GeneralMastersController>();

  // ============================================================
  // VIEW STATE
  // ============================================================

  /// Current view mode: 'dashboard', 'vehicle'
  final currentView = 'dashboard'.obs;

  /// Show/hide bulk upload section
  final showBulkUpload = false.obs;

  // ============================================================
  // LOADING STATES
  // ============================================================

  final isLoading = false.obs;
  final isLoadingRecords = false.obs;
  final isSubmitting = false.obs;
  final isSearchingVehicle = false.obs;
  final isLoadingVendors = false.obs;

  // ============================================================
  // VENDOR (GARAGE/WORKSHOP) MASTER
  // ============================================================

  final vendors = <Vendor>[].obs;

  Future<void> loadVendors() async {
    final company = companyService.selectedCompanyObs.value?.id ?? '';
    if (company.isEmpty) return;
    isLoadingVendors.value = true;
    try {
      final result = await _vendorRepo.getVendorMaster(company: company);
      result.fold(
        (error) => log('[MaintenanceController] Vendors error: $error'),
        (data) => vendors.value = data,
      );
    } finally {
      isLoadingVendors.value = false;
    }
  }

  // ============================================================
  // FILTER STATE
  // ============================================================

  /// Quick filter chips
  final filterOptions = ['All', 'Scheduled', 'Closed'].obs;
  final selectedFilter = 'All'.obs;

  /// Search
  final searchController = TextEditingController();
  final isSearching = false.obs;

  /// Date range filter
  final startDateFilter = Rx<DateTime?>(null);
  final endDateFilter = Rx<DateTime?>(null);

  /// Service type filter
  final selectedServiceType = Rx<int?>(null);

  /// Vendor filter
  final selectedVendorFilter = Rx<String?>(null); // vendorID as String

  /// Show/hide the filter panel
  final showFilters = false.obs;

  // ============================================================
  // LISTS
  // ============================================================

  /// All maintenance records for dashboard (all vehicles)
  final allRecords = <MaintenanceRecord>[].obs;
  final filteredAllRecords = <MaintenanceRecord>[].obs;

  /// Maintenance records for selected vehicle
  final maintenanceRecords = <MaintenanceRecord>[].obs;
  final filteredRecords = <MaintenanceRecord>[].obs;

  // ============================================================
  // VEHICLE SEARCH & SELECTION
  // ============================================================

  final plateNumberController = TextEditingController();
  final vehicleFound = false.obs;
  final selectedVehicle = Rx<Vehicle?>(null);

  // ============================================================
  // ADD/EDIT MAINTENANCE FORM
  // ============================================================

  final invoiceNumberController = TextEditingController();
  final remarksController = TextEditingController();
  final totalAmountController = TextEditingController();

  final selectedDate = Rx<DateTime>(DateTime.now());
  final selectedMaintenanceType = Rx<MaintenanceMaster?>(null);
  final selectedVendor = Rx<Vendor?>(null);
  final selectedStatus = 'Scheduled'.obs;

  final statusOptions = ['Scheduled', 'Closed'].obs;

  /// Currently editing record (null for new)
  final editingRecord = Rx<MaintenanceRecord?>(null);

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
    ever(selectedFilter, (_) => _applyFilters());
    // registerController fires onCompanyChanged immediately if company is
    // already set, or waits for CompanyService restore on refresh.
    companyService.registerController(this);
  }

  @override
  Future<void> onCompanyChanged(Company newCompany) async {
    log('[MaintenanceController] Company changed to: ${newCompany.id}');
    _initializeData();
  }

  @override
  void onClose() {
    searchController.removeListener(_onSearchChanged);
    _disposeControllers();
    companyService.unregisterController(this);
    super.onClose();
  }

  void _disposeControllers() {
    searchController.dispose();
    plateNumberController.dispose();
    invoiceNumberController.dispose();
    remarksController.dispose();
    totalAmountController.dispose();
  }

  void _onSearchChanged() {
    isSearching.value = searchController.text.isNotEmpty;
    _applyFilters();
  }

  // ============================================================
  // INITIALIZATION
  // ============================================================

  Future<void> _initializeData() async {
    await Future.wait([
      loadAllRecords(),
      loadVendors(),
    ]);
  }

  @override
  Future<void> refresh() async {
    await _initializeData();
    if (vehicleFound.value && selectedVehicle.value != null) {
      await loadVehicleRecords(selectedVehicle.value!.vehicleNo ?? '');
    }
  }

  // ============================================================
  // LOAD ALL MAINTENANCE RECORDS (Dashboard)
  // ============================================================

  Future<void> loadAllRecords({
    String? fromDt,
    String? toDt,
    String? status,
  }) async {
    isLoading.value = true;
    try {
      final company = companyService.selectedCompanyObs.value?.id ?? '';
      if (company.isEmpty) return;

      final result = await _repo.getVehicleMaintenance(
        company: company,
        fromDt: fromDt,
        toDt: toDt,
        status: status,
      );

      result.fold(
        (error) {
          log('[MaintenanceController] All records error: $error');
          CustomWidget.customSnackBar(
            isError: true,
            title: 'Error',
            message: 'Failed to load maintenance records',
          );
        },
        (data) {
          allRecords.value = data;
          _applyFilters();
        },
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // VEHICLE SEARCH
  // ============================================================

  Future<void> searchVehicle() async {
    if (plateNumberController.text.isEmpty) {
      CustomWidget.customSnackBar(
        isError: true,
        title: 'Error',
        message: 'Please enter a plate number',
      );
      return;
    }

    log(plateNumberController.text);

    isSearchingVehicle.value = true;
    showBulkUpload.value = false;

    try {
      final company = companyService.selectedCompanyObs.value?.id ?? '';
      final plateNo = plateNumberController.text.trim();

      final result = await _vehicleRepo.getAllVehicles(
        company: company,
        query: plateNo,
      );

      result.fold(
        (error) {
          vehicleFound.value = false;
          selectedVehicle.value = null;
          CustomWidget.customSnackBar(
            isError: true,
            title: 'Not Found',
            message: 'Vehicle not found: $error',
          );
        },
        (vehicles) async {
          vehicleFound.value = true;
          selectedVehicle.value = vehicles.first;
          currentView.value = 'vehicle';
          await loadVehicleRecords(selectedVehicle.value?.vehicleNo ?? '');
        },
      );
    } finally {
      isSearchingVehicle.value = false;
    }
  }

  void clearSearch() {
    plateNumberController.clear();
    vehicleFound.value = false;
    selectedVehicle.value = null;
    maintenanceRecords.clear();
    filteredRecords.clear();
    currentView.value = 'dashboard';
  }

  // ============================================================
  // LOAD VEHICLE MAINTENANCE RECORDS
  // ============================================================

  Future<void> loadVehicleRecords(String vehicleNo) async {
    isLoadingRecords.value = true;
    try {
      final company = companyService.selectedCompanyObs.value?.id ?? '';
      final result = await _repo.getVehicleMaintenance(
        company: company,
        vehicleNo: vehicleNo,
      );

      result.fold(
        (error) {
          log('[MaintenanceController] Vehicle records error: $error');
        },
        (data) {
          // Sort by date descending
          data.sort((a, b) {
            final da = a.serviceDate;
            final db = b.serviceDate;
            if (da == null && db == null) return 0;
            if (da == null) return 1;
            if (db == null) return -1;
            return db.compareTo(da);
          });
          maintenanceRecords.value = data;
          filteredRecords.value = List.from(data);
        },
      );
    } finally {
      isLoadingRecords.value = false;
    }
  }

  // ============================================================
  // FILTERS
  // ============================================================

  void _applyFilters() {
    List<MaintenanceRecord> result = List.from(allRecords);

    // Quick filter by status
    if (selectedFilter.value != 'All') {
      result = result
          .where((r) =>
              r.status?.toLowerCase() ==
              selectedFilter.value.toLowerCase())
          .toList();
    }

    // Search filter
    if (isSearching.value && searchController.text.isNotEmpty) {
      final query = searchController.text.toLowerCase();
      result = result
          .where((r) =>
              (r.vehicleNo?.toLowerCase().contains(query) ?? false) ||
              (r.maintenanceType?.toLowerCase().contains(query) ?? false) ||
              (r.vendorName?.toLowerCase().contains(query) ?? false) ||
              (r.invoiceNo?.toLowerCase().contains(query) ?? false) ||
              (r.remarks?.toLowerCase().contains(query) ?? false))
          .toList();
    }

    // Service type filter
    if (selectedServiceType.value != null) {
      result = result
          .where((r) => r.maintenanceID == selectedServiceType.value)
          .toList();
    }

    // Vendor filter
    if (selectedVendorFilter.value != null) {
      result = result
          .where((r) => r.vendorID?.toString() == selectedVendorFilter.value)
          .toList();
    }

    // Date range filter
    if (startDateFilter.value != null) {
      result = result.where((r) {
        final d = r.serviceDate;
        return d != null && !d.isBefore(startDateFilter.value!);
      }).toList();
    }
    if (endDateFilter.value != null) {
      result = result.where((r) {
        final d = r.serviceDate;
        return d != null &&
            !d.isAfter(
                endDateFilter.value!.add(const Duration(days: 1)));
      }).toList();
    }

    filteredAllRecords.value = result;
  }

  /// Public wrapper so the filter panel in the view can trigger re-filtering
  /// after updating individual filter observables directly.
  void applyFilters() => _applyFilters();

  void setQuickFilter(String filter) {
    selectedFilter.value = filter;
  }

  void clearFilters() {
    selectedFilter.value = 'All';
    searchController.clear();
    isSearching.value = false;
    selectedServiceType.value = null;
    selectedVendorFilter.value = null;
    startDateFilter.value = null;
    endDateFilter.value = null;
    _applyFilters();
  }

  bool get hasActiveFilters {
    return selectedFilter.value != 'All' ||
        searchController.text.isNotEmpty ||
        selectedServiceType.value != null ||
        selectedVendorFilter.value != null ||
        startDateFilter.value != null ||
        endDateFilter.value != null;
  }

  // ============================================================
  // COMPUTED STATS FROM RECORDS
  // ============================================================

  int get scheduledCount =>
      allRecords.where((r) => r.status?.toLowerCase() == 'scheduled').length;

  int get closedCount =>
      allRecords.where((r) => r.status?.toLowerCase() == 'closed').length;

  double get totalAmountAllTime =>
      allRecords.fold(0.0, (sum, r) => sum + (r.amount ?? 0));

  double get filteredTotalAmount =>
      filteredAllRecords.fold(0.0, (sum, r) => sum + (r.amount ?? 0));

  // ============================================================
  // ADD/EDIT MAINTENANCE RECORD
  // ============================================================

  void prepareAddRecord() {
    editingRecord.value = null;
    _clearRecordForm();
  }

  void prepareEditRecord(MaintenanceRecord record) {
    editingRecord.value = record;

    invoiceNumberController.text = record.invoiceNo ?? '';
    remarksController.text = record.remarks ?? '';
    totalAmountController.text = record.amount?.toString() ?? '';

    selectedDate.value = record.serviceDate ?? DateTime.now();
    selectedStatus.value = record.status ?? 'Scheduled';

    // Find matching maintenance type
    selectedMaintenanceType.value = genCon.mainteneceMasters
        .firstWhereOrNull((t) => t.maintenanceID == record.maintenanceID);

    // Find matching vendor
    selectedVendor.value = vendors.firstWhereOrNull(
        (v) => int.tryParse(v.vendorID ?? '') == record.vendorID);
  }

  Future<bool> saveMaintenanceRecord() async {
    if (!_validateRecordForm()) return false;

    isSubmitting.value = true;

    try {
      final company = companyService.selectedCompanyObs.value?.id ?? '';
      final dtStr =
          DateFormat('yyyy-MM-dd').format(selectedDate.value);

      final record = MaintenanceRecord(
        company: company,
        slNo: editingRecord.value?.slNo ?? 0,
        vehicleNo: selectedVehicle.value?.vehicleNo,
        dt: dtStr,
        invoiceNo: invoiceNumberController.text.trim(),
        vendorID: int.tryParse(selectedVendor.value?.vendorID ?? ''),
        vendorName: selectedVendor.value?.vendorName,
        maintenanceID: selectedMaintenanceType.value?.maintenanceID,
        maintenanceType: selectedMaintenanceType.value?.maintenanceType,
        amount: double.tryParse(totalAmountController.text),
        remarks: remarksController.text.trim().isEmpty
            ? null
            : remarksController.text.trim(),
        status: selectedStatus.value,
        image1: editingRecord.value?.image1 ?? '',
      );

      final result = await _repo.saveMaintenanceRecord(record);

      return result.fold(
        (error) {
          CustomWidget.customSnackBar(
            isError: true,
            title: 'Error',
            message: error,
          );
          return false;
        },
        (savedRecord) {
          // Update vehicle-specific list
          if (editingRecord.value != null) {
            final index = maintenanceRecords
                .indexWhere((r) => r.slNo == savedRecord.slNo);
            if (index != -1) {
              maintenanceRecords[index] = savedRecord;
            }
            // Also update all records dashboard list
            final allIdx =
                allRecords.indexWhere((r) => r.slNo == savedRecord.slNo);
            if (allIdx != -1) {
              allRecords[allIdx] = savedRecord;
            }
          } else {
            maintenanceRecords.insert(0, savedRecord);
            allRecords.insert(0, savedRecord);
          }
          filteredRecords.value = List.from(maintenanceRecords);
          _applyFilters();

          CustomWidget.customSnackBar(
            isError: false,
            title: 'Success',
            message: editingRecord.value != null
                ? 'Record updated successfully'
                : 'Record added successfully',
          );

          _clearRecordForm();
          return true;
        },
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  bool _validateRecordForm() {
    if (selectedMaintenanceType.value == null) {
      CustomWidget.customSnackBar(
        isError: true,
        title: 'Validation Error',
        message: 'Please select service type',
      );
      return false;
    }

    if (invoiceNumberController.text.trim().isEmpty) {
      CustomWidget.customSnackBar(
        isError: true,
        title: 'Validation Error',
        message: 'Please enter invoice number',
      );
      return false;
    }

    if (totalAmountController.text.trim().isEmpty ||
        double.tryParse(totalAmountController.text) == null) {
      CustomWidget.customSnackBar(
        isError: true,
        title: 'Validation Error',
        message: 'Please enter a valid amount',
      );
      return false;
    }

    return true;
  }

  void _clearRecordForm() {
    editingRecord.value = null;
    invoiceNumberController.clear();
    remarksController.clear();
    totalAmountController.clear();
    selectedDate.value = DateTime.now();
    selectedMaintenanceType.value = null;
    selectedVendor.value = null;
    selectedStatus.value = 'Scheduled';
  }

  // ============================================================
  // VIEW TOGGLES
  // ============================================================

  void toggleBulkUpload() {
    showBulkUpload.toggle();
    if (showBulkUpload.value) {
      vehicleFound.value = false;
    }
  }

  void showDashboard() {
    currentView.value = 'dashboard';
  }

  void showVehicleView() {
    currentView.value = 'vehicle';
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd MMM yyyy').format(date);
  }

  String formatAmount(double? amount) {
    if (amount == null) return '-';
    return NumberFormat.currency(symbol: 'AED ', decimalDigits: 2)
        .format(amount);
  }

  String formatNumber(int? number) {
    if (number == null) return '-';
    return NumberFormat('#,###').format(number);
  }

  Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'closed':
        return const Color(0xFF22C55E); // Green
      case 'scheduled':
        return const Color(0xFFF59E0B); // Amber
      default:
        return const Color(0xFF64748B); // Slate
    }
  }
}
