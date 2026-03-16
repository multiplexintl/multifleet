import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:multifleet/controllers/general_masters.dart';
import 'package:multifleet/models/company.dart';
import 'package:multifleet/models/employee.dart';
import 'package:multifleet/models/fine.dart';
import 'package:multifleet/models/fine_type/fine_type.dart';
import 'package:multifleet/models/status_master/status_master.dart';
import 'package:multifleet/models/vehicle.dart';
import 'package:multifleet/repo/fine_repo.dart';
import 'package:multifleet/services/company_service.dart';
import 'package:multifleet/widgets/custom_widgets.dart';

import '../models/city/city.dart';
import '../models/vehicle_assignment_model.dart';
import '../repo/vehicles_repo.dart';

class FineController extends GetxController implements CompanyAwareController {
  final companyService = Get.find<CompanyService>();
  final genCon = Get.find<GeneralMastersController>();

  final _fineRepo = FineRepo();
  final _vehicleRepo = VehiclesRepo();

  final plateNumberController = TextEditingController();

  // ==================== STATISTICS ====================

  var totalFinesCount = 0.obs;
  var unpaidFinesCount = 0.obs;
  var totalUnpaidAmount = 0.0.obs;
  var totalPaidAmount = 0.0.obs;
  var vehiclesWithFinesCount = 0.obs;

  // ==================== VIEW STATE ====================

  /// Toggle between grouped view (by vehicle) and flat list view
  final isGroupedView = true.obs;

  /// Currently expanded vehicle in grouped view
  final expandedVehicles = <String>{}.obs;

  // ==================== LISTS ====================

  final fines = <Fine>[].obs;
  final filteredFines = <Fine>[].obs;

  /// Grouped fines by vehicle number
  final groupedFines = <String, List<Fine>>{}.obs;

  // ==================== LOADING STATES ====================

  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final isSearchingVehicle = false.obs;
  final isLoadingHistory = false.obs;

  // ==================== FILTERS ====================

  final searchController = TextEditingController();
  final selectedStatusFilter = Rx<StatusMaster?>(null);
  final selectedTypeFilter = Rx<FineType?>(null);
  final startDateFilter = Rx<DateTime?>(null);
  final endDateFilter = Rx<DateTime?>(null);

  // ==================== DROPDOWN OPTIONS ====================

  // final statusOptions = ['Paid', 'Unpaid', 'Disputed', 'Pending'].obs;
  // final fineTypeOptions =
  //     ['Traffic', 'Parking', 'Salik', 'Speeding', 'Other'].obs;
  // final emirateOptions = [
  //   'Abu Dhabi',
  //   'Dubai',
  //   'Sharjah',
  //   'Ajman',
  //   'Umm Al Quwain',
  //   'Ras Al Khaimah',
  //   'Fujairah'
  // ].obs;
  // final authorityOptions = [
  //   'Dubai Police',
  //   'Abu Dhabi Police',
  //   'Sharjah Police',
  //   'RTA',
  //   'Salik',
  //   'Other'
  // ].obs;

  // ==================== ADD/EDIT FORM ====================

  /// Selected vehicle for adding fine
  final Rx<Vehicle?> selectedVehicle = Rx<Vehicle?>(null);

  /// Vehicle assignment history
  final assignmentHistory = <VehicleAssignment>[].obs;

  /// Selected assignment (employee) for the fine
  final Rx<VehicleAssignment?> selectedAssignment =
      Rx<VehicleAssignment?>(null);

  /// Flag for external employee (not in assignment history)
  final isExternalEmployee = false.obs;

  /// Selected external employee
  final Rx<Employee?> selectedExternalEmployee = Rx<Employee?>(null);

  /// Currently editing fine (null for new fine)
  final Rx<Fine?> editingFine = Rx<Fine?>(null);

  // Form controllers
  final ticketNoController = TextEditingController();
  final amountController = TextEditingController();
  final locationController = TextEditingController();
  final authorityController = TextEditingController();
  final reasonController = TextEditingController();
  final remarksController = TextEditingController();
  final fineDate = Rx<DateTime?>(DateTime.now());
  final selectedFineType = Rx<FineType?>(null);
  final selectedEmirate = Rx<City?>(null);
  // final selectedAuthority = Rx<String?>(null);
  final selectedStatus = Rx<StatusMaster?>(null);

  // ==================== LIFECYCLE ====================

  @override
  void onInit() {
    super.onInit();
    // Auto-filter on any filter change
    searchController.addListener(_onSearchChanged);
    ever(selectedStatusFilter, (_) => _applyFiltersInternal());
    ever(selectedTypeFilter, (_) => _applyFiltersInternal());
    ever(startDateFilter, (_) => _applyFiltersInternal());
    ever(endDateFilter, (_) => _applyFiltersInternal());
    // Register for company changes. If company is already resolved,
    // registerController immediately calls onCompanyChanged → loadFines.
    // On browser refresh, CompanyService calls onCompanyChanged once company
    // is restored — no eager load with empty company ID.
    companyService.registerController(this);
  }

  @override
  Future<void> onCompanyChanged(Company newCompany) async {
    loadFines(company: newCompany.id);
  }

  @override
  void onClose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    plateNumberController.dispose();
    ticketNoController.dispose();
    amountController.dispose();
    locationController.dispose();
    authorityController.dispose();
    reasonController.dispose();
    remarksController.dispose();
    super.onClose();
  }

  void _onSearchChanged() {
    _applyFiltersInternal();
  }

  // ==================== LOAD FINES ====================

  Future<void> loadFines({String? company}) async {
    isLoading.value = true;

    try {
      final companyId =
          company ?? companyService.selectedCompanyObs.value?.id ?? '';
      log(companyId);
      final result =
          await _fineRepo.getFines(company: companyId, vehicleNo: '');

      result.fold(
        (error) {
          log('[FineController] Load error: $error');
          CustomWidget.customSnackBar(
            isError: true,
            title: 'Error',
            message: error,
          );
        },
        (data) {
          fines.value = data;
          // Sort by date descending (newest first)
          fines.sort((a, b) {
            final dateA = _parseDate(a.fineDate);
            final dateB = _parseDate(b.fineDate);
            if (dateA == null && dateB == null) return 0;
            if (dateA == null) return 1;
            if (dateB == null) return -1;
            return dateB.compareTo(dateA);
          });
          _applyFiltersInternal();
          _groupFinesByVehicle();
          _updateStatistics();
        },
      );
    } catch (e) {
      log('[FineController] Exception: $e');
      CustomWidget.customSnackBar(
        isError: true,
        title: 'Error',
        message: 'Failed to load fines',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void onPlateChanged(String? letter, String? emirate, String? number) {
    plateNumberController.text = "$letter-$number";
    log(plateNumberController.text);
  }

  // ==================== FILTERS ====================

  void applyFilters() {
    _applyFiltersInternal();
  }

  void _applyFiltersInternal() {
    filteredFines.value = fines.where((fine) {
      // Text search
      bool matchesSearch = true;
      if (searchController.text.isNotEmpty) {
        final query = searchController.text.toLowerCase();
        matchesSearch =
            (fine.vehicleNo?.toLowerCase().contains(query) ?? false) ||
                (fine.empName?.toLowerCase().contains(query) ?? false) ||
                (fine.empNo?.toLowerCase().contains(query) ?? false) ||
                (fine.ticketNo?.toLowerCase().contains(query) ?? false) ||
                (fine.location?.toLowerCase().contains(query) ?? false);
      }

      // Status filter
      bool matchesStatus = true;
      if (selectedStatusFilter.value != null) {
        matchesStatus = fine.status?.status?.toLowerCase() ==
            selectedStatusFilter.value?.status?.toLowerCase();
      }

      // Type filter
      bool matchesType = true;
      if (selectedTypeFilter.value != null) {
        matchesType = fine.fineType?.fineType?.toLowerCase() ==
            selectedTypeFilter.value?.fineType?.toLowerCase();
      }

      // Date range filter
      bool matchesDate = true;
      final fineDateTime = _parseDate(fine.fineDate);

      if (startDateFilter.value != null && fineDateTime != null) {
        matchesDate = fineDateTime
            .isAfter(startDateFilter.value!.subtract(const Duration(days: 1)));
      }
      if (endDateFilter.value != null && fineDateTime != null && matchesDate) {
        matchesDate = fineDateTime
            .isBefore(endDateFilter.value!.add(const Duration(days: 1)));
      }

      return matchesSearch && matchesStatus && matchesType && matchesDate;
    }).toList();

    _groupFinesByVehicle();
    _updateStatistics();
  }

  void _updateStatistics() {
    // Stats reflect the currently filtered set for better contextual UX
    final source = hasActiveFilters ? filteredFines : fines;

    totalFinesCount.value = source.length;

    unpaidFinesCount.value =
        source.where((f) => f.status?.status?.toLowerCase() == 'unpaid').length;

    totalUnpaidAmount.value = source
        .where((f) => f.status?.status?.toLowerCase() == 'unpaid')
        .fold(0.0, (sum, f) => sum + (f.amount ?? 0));

    totalPaidAmount.value = source
        .where((f) => f.status?.status?.toLowerCase() == 'paid')
        .fold(0.0, (sum, f) => sum + (f.amount ?? 0));

    vehiclesWithFinesCount.value = groupedFines.keys.length;
    update();
  }

  void clearFilters() {
    searchController.clear();
    selectedStatusFilter.value = null;
    selectedTypeFilter.value = null;
    startDateFilter.value = null;
    endDateFilter.value = null;

    filteredFines.value = List.from(fines);
    _groupFinesByVehicle();
  }

  bool get hasActiveFilters {
    return searchController.text.isNotEmpty ||
        selectedStatusFilter.value != null ||
        selectedTypeFilter.value != null ||
        startDateFilter.value != null ||
        endDateFilter.value != null;
  }

  // ==================== VIEW TOGGLE ====================

  void toggleView() {
    isGroupedView.value = !isGroupedView.value;
  }

  void _groupFinesByVehicle() {
    final grouped = <String, List<Fine>>{};

    for (final fine in filteredFines) {
      final vehicleNo = fine.vehicleNo ?? 'Unknown';
      if (!grouped.containsKey(vehicleNo)) {
        grouped[vehicleNo] = [];
      }
      grouped[vehicleNo]!.add(fine);
    }

    groupedFines.value = grouped;
  }

  void toggleVehicleExpanded(String vehicleNo) {
    if (expandedVehicles.contains(vehicleNo)) {
      expandedVehicles.remove(vehicleNo);
      update();
    } else {
      expandedVehicles.add(vehicleNo);
      update();
    }
  }

  // ==================== SEARCH VEHICLE (for adding fine) ====================

  Future<void> searchVehicleForFine() async {
    var plateNumber = plateNumberController.text;

    if (plateNumber.isEmpty) return;

    isSearchingVehicle.value = true;
    selectedVehicle.value = null;
    assignmentHistory.clear();
    selectedAssignment.value = null;
    isExternalEmployee.value = false;
    selectedExternalEmployee.value = null;

    try {
      final companyId = companyService.selectedCompanyObs.value?.id ?? '';

      // Search for vehicle
      final vehicleResult = await _vehicleRepo.getAllVehicles(
        company: companyId,
        query: plateNumber,
      );

      vehicleResult.fold(
        (error) {
          log('[FineController] Vehicle search error: $error');
          CustomWidget.customSnackBar(
            isError: true,
            title: 'Vehicle Not Found',
            message: 'No vehicle found with plate number: $plateNumber',
          );
        },
        (vehicles) {
          selectedVehicle.value = vehicles.first;
          // Load assignment history for this vehicle
          _loadAssignmentHistory(vehicles.first.vehicleNo ?? plateNumber);
        },
      );
    } catch (e) {
      log('[FineController] Search exception: $e');
      CustomWidget.customSnackBar(
        isError: true,
        title: 'Error',
        message: 'Failed to search vehicle',
      );
    } finally {
      isSearchingVehicle.value = false;
    }
  }

  Future<void> _loadAssignmentHistory(String vehicleNo) async {
    isLoadingHistory.value = true;

    try {
      final companyId = companyService.selectedCompanyObs.value?.id ?? '';

      final result = await _fineRepo.getVehicleAssignmentHistory(
        company: companyId,
        vehicleNo: vehicleNo,
      );

      result.fold(
        (error) {
          log('[FineController] History error: $error');
          // Not showing error - history might just be empty
          assignmentHistory.clear();
        },
        (history) {
          // Filter to past and current assignments only (no future scheduled)
          final today = DateTime.now();
          final todayDate = DateTime(today.year, today.month, today.day);
          final pastAndCurrent = history.where((a) {
            final assignedDate = _parseDate(a.assignedDate);
            if (assignedDate == null) return true;
            final assignedDateOnly = DateTime(
                assignedDate.year, assignedDate.month, assignedDate.day);
            return !assignedDateOnly.isAfter(todayDate);
          }).toList();

          // Sort by date descending
          pastAndCurrent.sort((a, b) {
            final dateA = _parseDate(a.assignedDate);
            final dateB = _parseDate(b.assignedDate);
            if (dateA == null && dateB == null) return 0;
            if (dateA == null) return 1;
            if (dateB == null) return -1;
            return dateB.compareTo(dateA);
          });
          assignmentHistory.value = pastAndCurrent;
        },
      );
    } catch (e) {
      log('[FineController] History exception: $e');
    } finally {
      isLoadingHistory.value = false;
    }
  }

  // ==================== EMPLOYEE AUTOCOMPLETE ====================

  Future<List<Employee>> getEmployeeSuggestions(String query) async {
    if (query.isEmpty) return [];

    try {
      return genCon.companyEmployees
          .where((emp) {
            final name = emp.empName?.toLowerCase() ?? '';
            final empNo = emp.empNo?.toLowerCase() ?? '';
            final q = query.toLowerCase();
            return name.contains(q) || empNo.contains(q);
          })
          .take(10)
          .toList();
    } catch (e) {
      return [];
    }
  }

  void selectExternalEmployee(Employee employee) {
    selectedExternalEmployee.value = employee;
    selectedAssignment.value = null;
  }

  void selectAssignmentHistory(VehicleAssignment history) {
    selectedAssignment.value = history;
    isExternalEmployee.value = false;
    selectedExternalEmployee.value = null;
  }

  void toggleExternalEmployee(bool value) {
    isExternalEmployee.value = value;
    if (value) {
      selectedAssignment.value = null;
    } else {
      selectedExternalEmployee.value = null;
    }
  }

  // ==================== ADD / EDIT FINE ====================

  /// Prepare the form for adding a new fine
  void prepareAddFine() {
    editingFine.value = null;
    _clearForm();
    selectedStatus.value = genCon.fineStatusMasters.isNotEmpty
        ? genCon.fineStatusMasters.first
        : null;
    fineDate.value = DateTime.now();
  }

  /// Prepare the form for editing an existing fine
  void prepareEditFine(Fine fine) {
    editingFine.value = fine;

    ticketNoController.text = fine.ticketNo ?? '';
    amountController.text = fine.amount?.toString() ?? '';
    locationController.text = fine.location ?? '';
    reasonController.text = fine.reason ?? '';
    remarksController.text = fine.remarks ?? '';
    fineDate.value = _parseDate(fine.fineDate);
    selectedFineType.value = genCon.fineTypeMasters.firstWhereOrNull(
          (t) => t.fineTypeId == fine.fineType?.fineTypeId,
        ) ??
        genCon.fineTypeMasters
            .firstWhereOrNull((t) => t.fineType == fine.fineType?.fineType);
    selectedEmirate.value = genCon.companyCity.firstWhereOrNull(
      (c) => c.city?.toLowerCase() == fine.emirate?.city?.toLowerCase(),
    );
    authorityController.text = fine.issuingAuthority ?? '';
    selectedStatus.value = genCon.fineStatusMasters.firstWhereOrNull(
          (m) => m.statusId == fine.status?.statusId,
        ) ??
        genCon.fineStatusMasters
            .firstWhereOrNull((m) => m.status == fine.status?.status);
    log(editingFine.toString());
  }

  /// Save fine — adds when editingFine is null (fineId=0), updates when editingFine has an ID.
  /// Uses the same API endpoint; the server distinguishes by FineID.
  Future<bool> saveFine() async {
    final isEditing = editingFine.value != null;
    log("Editing Fine: $isEditing");

    if (isEditing) {
      if (!_validateEditForm()) return false;
    } else {
      if (!_validateForm()) return false;
    }

    isSubmitting.value = true;

    try {
      final companyId = companyService.selectedCompanyObs.value?.id ?? '';

      Fine fine;

      if (isEditing) {
        fine = editingFine.value!.copyWith(
          fineType: selectedFineType.value,
          fineDate: fineDate.value != null
              ? DateFormat('yyyy-MM-dd').format(fineDate.value!)
              : null,
          amount: double.tryParse(amountController.text),
          location: locationController.text.trim(),
          ticketNo: ticketNoController.text.trim(),
          emirate: selectedEmirate.value,
          issuingAuthority: authorityController.text.trim(),
          reason: reasonController.text.trim(),
          status: selectedStatus.value,
          remarks: remarksController.text.trim(),
        );
        log("Editing Fine Is: $fine");
      } else {
        // Determine employee details from selection
        String? empNo;
        String? empName;
        String? designation;

        if (isExternalEmployee.value &&
            selectedExternalEmployee.value != null) {
          empNo = selectedExternalEmployee.value!.empNo;
          empName = selectedExternalEmployee.value!.empName;
          designation = selectedExternalEmployee.value!.designation;
        } else if (selectedAssignment.value != null) {
          empNo = selectedAssignment.value!.empNo;
          empName = selectedAssignment.value!.empName;
          designation = selectedAssignment.value!.designation;
        }

        fine = Fine(
          fineId: 0,
          company: companyId,
          vehicleNo: selectedVehicle.value?.vehicleNo,
          empNo: empNo,
          empName: empName,
          designation: designation,
          fineType: selectedFineType.value,
          fineDate: fineDate.value != null
              ? DateFormat('yyyy-MM-dd').format(fineDate.value!)
              : null,
          amount: double.tryParse(amountController.text),
          location: locationController.text.trim(),
          ticketNo: ticketNoController.text.trim(),
          emirate: selectedEmirate.value,
          issuingAuthority: authorityController.text.trim(),
          reason: reasonController.text.trim(),
          status: selectedStatus.value,
          remarks: remarksController.text.trim(),
        );
      }

      final result = await _fineRepo.addFine(fine: fine);

      return result.fold(
        (error) {
          CustomWidget.customSnackBar(
            isError: true,
            title: 'Error',
            message: error,
          );
          return false;
        },
        (savedFine) {
          if (isEditing) {
            final index = fines.indexWhere((f) => f.fineId == savedFine.fineId);
            if (index != -1) {
              fines[index] = savedFine;
            }
          } else {
            fines.insert(0, savedFine);
          }
          _applyFiltersInternal();
          _updateStatistics();

          CustomWidget.customSnackBar(
            isError: false,
            title: 'Success',
            message: isEditing
                ? 'Fine updated successfully'
                : 'Fine added successfully',
          );
          return true;
        },
      );
    } catch (e) {
      log('[FineController] Save exception: $e');
      CustomWidget.customSnackBar(
        isError: true,
        title: 'Error',
        message: 'Failed to save fine',
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ==================== QUICK STATUS UPDATE ====================

  Future<bool> updateFineStatus(Fine fine, StatusMaster newStatus) async {
    try {
      final updatedFine = fine.copyWith(status: newStatus);
      final result = await _fineRepo.addFine(fine: updatedFine);

      return result.fold(
        (error) {
          CustomWidget.customSnackBar(
            isError: true,
            title: 'Error',
            message: error,
          );
          return false;
        },
        (saved) {
          final index = fines.indexWhere((f) => f.fineId == fine.fineId);
          if (index != -1) {
            fines[index] = saved;
            _applyFiltersInternal();
          }

          CustomWidget.customSnackBar(
            isError: false,
            title: 'Success',
            message: 'Status updated to ${newStatus.status}',
          );
          return true;
        },
      );
    } catch (e) {
      log('[FineController] Status update exception: $e');
      return false;
    }
  }

  // ==================== DELETE FINE ====================

  // Future<bool> deleteFine(Fine fine) async {
  //   try {
  //     final companyId = companyService.selectedCompanyObs.value?.id ?? '';

  //     final result = await _fineRepo.deleteFine(
  //       company: companyId,
  //       fineId: fine.fineId ?? 0,
  //     );

  //     return result.fold(
  //       (error) {
  //         CustomWidget.customSnackBar(
  //           isError: true,
  //           title: 'Error',
  //           message: error,
  //         );
  //         return false;
  //       },
  //       (success) {
  //         // Remove from local list
  //         fines.removeWhere((f) => f.fineId == fine.fineId);
  //         _applyFiltersInternal();

  //         CustomWidget.customSnackBar(
  //           isError: false,
  //           title: 'Success',
  //           message: 'Fine deleted successfully',
  //         );
  //         return true;
  //       },
  //     );
  //   } catch (e) {
  //     log('[FineController] Delete exception: $e');
  //     return false;
  //   }
  // }

  // ==================== FORM VALIDATION ====================

  bool _validateForm() {
    if (selectedVehicle.value == null) {
      CustomWidget.customSnackBar(
        isError: true,
        title: 'Validation Error',
        message: 'Please search and select a vehicle',
      );
      return false;
    }

    // Validate employee selection
    if (isExternalEmployee.value) {
      if (selectedExternalEmployee.value == null) {
        CustomWidget.customSnackBar(
          isError: true,
          title: 'Validation Error',
          message: 'Please select an external employee',
        );
        return false;
      }
    } else if (selectedAssignment.value == null &&
        assignmentHistory.isNotEmpty) {
      CustomWidget.customSnackBar(
        isError: true,
        title: 'Validation Error',
        message:
            'Please select an employee from assignment history or use external employee',
      );
      return false;
    }

    return _validateEditForm();
  }

  bool _validateEditForm() {
    if (ticketNoController.text.trim().isEmpty) {
      CustomWidget.customSnackBar(
        isError: true,
        title: 'Validation Error',
        message: 'Please enter ticket number',
      );
      return false;
    }

    if (amountController.text.trim().isEmpty) {
      CustomWidget.customSnackBar(
        isError: true,
        title: 'Validation Error',
        message: 'Please enter fine amount',
      );
      return false;
    }

    if (double.tryParse(amountController.text) == null) {
      CustomWidget.customSnackBar(
        isError: true,
        title: 'Validation Error',
        message: 'Please enter a valid amount',
      );
      return false;
    }

    if (fineDate.value == null) {
      CustomWidget.customSnackBar(
        isError: true,
        title: 'Validation Error',
        message: 'Please select fine date',
      );
      return false;
    }

    if (selectedFineType.value == null) {
      CustomWidget.customSnackBar(
        isError: true,
        title: 'Validation Error',
        message: 'Please select fine type',
      );
      return false;
    }

    return true;
  }

  void _clearForm() {
    selectedVehicle.value = null;
    assignmentHistory.clear();
    selectedAssignment.value = null;
    isExternalEmployee.value = false;
    selectedExternalEmployee.value = null;
    editingFine.value = null;

    ticketNoController.clear();
    amountController.clear();
    locationController.clear();
    reasonController.clear();
    remarksController.clear();
    fineDate.value = DateTime.now();
    selectedFineType.value = null;
    selectedEmirate.value = null;
    authorityController.clear();
    selectedStatus.value = null;
  }

  void clearAddFineForm() {
    _clearForm();
  }

  // ==================== HELPERS ====================

  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  String formatDate(String? dateStr) {
    final date = _parseDate(dateStr);
    if (date == null) return '-';
    return DateFormat('dd MMM yyyy').format(date);
  }

  String formatDateTime(String? dateStr) {
    final date = _parseDate(dateStr);
    if (date == null) return '-';
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  String formatDateForDisplay(DateTime? date) {
    if (date == null) return 'Select date';
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  String formatAmount(double? amount) {
    if (amount == null) return '-';
    return NumberFormat.currency(symbol: 'AED ', decimalDigits: 2)
        .format(amount);
  }

  Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid':
        return const Color(0xFF22C55E); // Green
      case 'unpaid':
        return const Color(0xFFEF4444); // Red
      case 'disputed':
        return const Color(0xFFF59E0B); // Amber
      case 'pending':
        return const Color(0xFF3B82F6); // Blue
      default:
        return const Color(0xFF64748B); // Slate
    }
  }

  Color getFineTypeColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'traffic':
        return const Color(0xFFEF4444); // Red
      case 'parking':
        return const Color(0xFF3B82F6); // Blue
      case 'salik':
        return const Color(0xFF8B5CF6); // Purple
      case 'speeding':
        return const Color(0xFFF97316); // Orange
      default:
        return const Color(0xFF64748B); // Slate
    }
  }
}

// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:multifleet/models/vehicle.dart';
// import 'package:multifleet/repo/fine_repo.dart';
// import 'package:multifleet/widgets/custom_widgets.dart';

// import '../helpers/fake_data_service.dart';

// class VehicleFineController extends GetxController {
//   // Text controllers
//   final TextEditingController plateNumberController =
//       TextEditingController(text: 'A-0123');
//   final TextEditingController fineAmountController = TextEditingController();
//   final TextEditingController fineLocationController = TextEditingController();
//   final TextEditingController fineNumberController = TextEditingController();
//   final TextEditingController trafficFileNumberController =
//       TextEditingController();
//   final TextEditingController remarksController = TextEditingController();

//   // Selected values
//   final Rxn<Vehicle> selectedVehicle = Rxn<Vehicle>(null);
//   final Rx<Map<String, dynamic>?> selectedAssignment =
//       Rx<Map<String, dynamic>?>(null);
//   final Rx<DateTime?> fineDate = Rx<DateTime?>(DateTime.now());

//   // Assignment data
//   final RxList<Map<String, dynamic>> vehicleAssignments =
//       <Map<String, dynamic>>[].obs;
//   final RxInt totalAssignments = 0.obs;
//   final RxInt currentPage = 1.obs;
//   final int pageSize = 10;
//   final RxSet<int> expandedFineIds = <int>{}.obs;

//   // Loading states
//   final RxBool isSearching = false.obs;
//   final RxBool isLoadingMore = false.obs;
//   final RxBool isSubmitting = false.obs;

//   // Search vehicle by plate number
//   Future<void> searchVehicle() async {
//     if (plateNumberController.text.isEmpty) return;

//     isSearching.value = true;
//     selectedVehicle.value = null;
//     selectedAssignment.value = null;
//     vehicleAssignments.clear();

//     try {
//       var res = FineRepo().getFines(company: company)

//     } finally {
//       isSearching.value = false;
//     }
//   }

//   void toggleFineDetails(int assignmentId) {
//     if (expandedFineIds.contains(assignmentId)) {
//       expandedFineIds.remove(assignmentId);
//     } else {
//       expandedFineIds.add(assignmentId);
//     }
//     update();
//   }

//   // Load vehicle assignments with pagination
//   Future<void> loadVehicleAssignments(int page, bool resetPage) async {
//     if (selectedVehicle.value == null) return;

//     if (resetPage) {
//       vehicleAssignments.clear();
//       currentPage.value = 1;
//     } else {
//       isLoadingMore.value = true;
//       currentPage.value = page;
//     }

//     try {
//       // Simulate API call or database query
//       await Future.delayed(Duration(seconds: 1));

//       final assignments = FakeVehicleData.getVehicleAssignments(
//           selectedVehicle.value!.vehicleNo!, page, pageSize);

//       vehicleAssignments.addAll(assignments.items);
//       totalAssignments.value = assignments.total;
//     } finally {
//       isLoadingMore.value = false;
//     }
//   }

//   // Load more assignments
//   Future<void> loadMoreAssignments() async {
//     if (vehicleAssignments.length < totalAssignments.value) {
//       await loadVehicleAssignments(currentPage.value + 1, false);
//     }
//   }

//   // Select an assignment
//   void selectAssignment(Map<String, dynamic> assignment) {
//     selectedAssignment.value = assignment;

//     // Clear form fields
//     fineAmountController.clear();
//     fineLocationController.clear();
//     fineNumberController.clear();
//     trafficFileNumberController.clear();
//     fineDate.value = DateTime.now();
//   }

//   // Clear search
//   void clearSearch() {
//     plateNumberController.clear();
//     selectedVehicle.value = null;
//     selectedAssignment.value = null;
//     vehicleAssignments.clear();
//     clearFineForm();
//   }

//   // Clear fine form
//   void clearFineForm() {
//     fineAmountController.clear();
//     fineLocationController.clear();
//     fineNumberController.clear();
//     trafficFileNumberController.clear();
//     fineDate.value = DateTime.now();
//     selectedAssignment.value = null;
//   }

//   // Submit fine
//   Future<void> submitFine() async {
//     if (selectedVehicle.value == null) {
//       CustomWidget.customSnackBar(
//         isError: true,
//         title: 'Error',
//         message: 'Please search and select a vehicle first',
//       );
//       return;
//     }

//     if (selectedAssignment.value == null) {
//       CustomWidget.customSnackBar(
//         isError: true,
//         title: 'Error',
//         message: 'Please select an assignment first',
//       );
//       return;
//     }

//     if (fineAmountController.text.isEmpty) {
//       CustomWidget.customSnackBar(
//         isError: true,
//         title: 'Error',
//         message: 'Please enter the fine amount',
//       );
//       return;
//     }

//     // Validate fine amount is a valid number
//     try {
//       double.parse(fineAmountController.text);
//     } catch (e) {
//       CustomWidget.customSnackBar(
//         isError: true,
//         title: 'Error',
//         message: 'Please enter a valid fine amount',
//       );
//       return;
//     }

//     if (fineDate.value == null) {
//       CustomWidget.customSnackBar(
//         isError: true,
//         title: 'Error',
//         message: 'Please select a fine date',
//       );
//       return;
//     }

//     if (fineNumberController.text.isEmpty) {
//       CustomWidget.customSnackBar(
//         isError: true,
//         title: 'Error',
//         message: 'Please enter the fine number',
//       );
//       return;
//     }

//     isSubmitting.value = true;

//     try {
//       // Simulate API call or database insertion
//       await Future.delayed(Duration(seconds: 1));

//       CustomWidget.customSnackBar(
//         isError: false,
//         title: 'Success',
//         message: 'Fine added successfully',
//       );

//       // Clear form but keep selected vehicle and assignments
//       clearFineForm();
//     } finally {
//       isSubmitting.value = false;
//     }
//   }

//   // Format date for display
//   String formatDateTime(DateTime? date) {
//     if (date == null) return '';
//     return DateFormat('dd MMM yyyy, hh:mm a').format(date);
//   }

//   String formatDate(DateTime? date) {
//     if (date == null) return '';
//     return DateFormat('dd MMM yyyy').format(date);
//   }
// }
