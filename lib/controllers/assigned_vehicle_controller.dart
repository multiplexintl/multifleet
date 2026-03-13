import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:multifleet/models/company.dart';
import 'package:multifleet/models/status_master/status_master.dart';
import 'package:multifleet/models/vehicle_assignment_model.dart';
import 'package:multifleet/repo/assign_repo.dart';
import 'package:multifleet/widgets/custom_widgets.dart';

import '../controllers/general_masters.dart';
import '../services/company_service.dart';

class AssignedVehicleController extends GetxController
    implements CompanyAwareController {
  var companyService = Get.find<CompanyService>();
  final genCon = Get.find<GeneralMastersController>();

  // For filters
  final searchController = TextEditingController();
  final selectedStatusFilter = ''.obs;
  final startDateFilter = Rx<DateTime?>(null);
  final endDateFilter = Rx<DateTime?>(null);

  // Loading states
  final isLoading = false.obs;
  final isUpdating = false.obs;
  final isTerminating = false.obs;

  // List of assignments
  var assignments = <VehicleAssignment>[].obs;
  var filteredAssignments = <VehicleAssignment>[].obs;

  // Status options driven from master
  List<StatusMaster> get statusOptions => genCon.vehicleAssignmentStatusMasters;

  // Edit form controllers
  final editRemarksController = TextEditingController();
  final editReturnDate = Rx<DateTime?>(null);
  final editStatus = Rx<StatusMaster?>(null);

  // Currently editing assignment
  final Rx<VehicleAssignment?> currentEditAssignment =
      Rx<VehicleAssignment?>(null);

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
    // registerController fires onCompanyChanged immediately if company is set,
    // or waits for CompanyService to restore it on browser refresh.
    companyService.registerController(this);
  }

  @override
  Future<void> onCompanyChanged(Company newCompany) async {
    loadAssignments(company: newCompany.id);
  }

  @override
  void onClose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    editRemarksController.dispose();
    super.onClose();
  }

  void _onSearchChanged() {
    _applyFiltersInternal();
  }

  // ==================== LOAD ASSIGNMENTS ====================

  Future<void> loadAssignments({String? company}) async {
    isLoading.value = true;

    try {
      var res = await AssignRepo().getAllAssignmets(
        company: company ?? companyService.selectedCompanyObs.value!.id!,
        query: '',
        isActive: false,
      );

      res.fold(
        (error) {
          log('Load assignments error: $error');
          CustomWidget.customSnackBar(
            isError: true,
            title: 'Error',
            message: error,
          );
        },
        (data) {
          assignments.value = data;
          // Sort by assigned date descending (newest first)
          assignments.sort((a, b) {
            final dateA = _parseDate(a.assignedDate);
            final dateB = _parseDate(b.assignedDate);
            if (dateA == null && dateB == null) return 0;
            if (dateA == null) return 1;
            if (dateB == null) return -1;
            return dateB.compareTo(dateA);
          });
          filteredAssignments.value = List.from(assignments);
        },
      );
    } catch (e) {
      log('Error loading assignments: $e');
      CustomWidget.customSnackBar(
        isError: true,
        title: 'Error',
        message: 'Failed to load assignments. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== FILTERS ====================

  void applyFilters() {
    _applyFiltersInternal();
    CustomWidget.customSnackBar(
      title: 'Filters Applied',
      message: '${filteredAssignments.length} assignments found',
      isError: false,
    );
  }

  void _applyFiltersInternal() {
    filteredAssignments.value = assignments.where((assignment) {
      // Text search filter
      bool matchesSearch = true;
      if (searchController.text.isNotEmpty) {
        final search = searchController.text.toLowerCase();
        matchesSearch = (assignment.vehicleNo?.toLowerCase().contains(search) ??
                false) ||
            (assignment.empName?.toLowerCase().contains(search) ?? false) ||
            (assignment.empNo?.toLowerCase().contains(search) ?? false) ||
            (assignment.designation?.toLowerCase().contains(search) ?? false);
      }

      // Status filter
      bool matchesStatus = true;
      if (selectedStatusFilter.value.isNotEmpty) {
        matchesStatus = assignment.status?.status?.toLowerCase() ==
            selectedStatusFilter.value.toLowerCase();
      }

      // Date range filter
      bool matchesDateRange = true;
      final assignedDate = _parseDate(assignment.assignedDate);

      if (startDateFilter.value != null && assignedDate != null) {
        final filterStart = DateTime(
          startDateFilter.value!.year,
          startDateFilter.value!.month,
          startDateFilter.value!.day,
        );
        final assignedDay = DateTime(
          assignedDate.year,
          assignedDate.month,
          assignedDate.day,
        );
        matchesDateRange = assignedDay.isAfter(filterStart) ||
            assignedDay.isAtSameMomentAs(filterStart);
      }

      if (endDateFilter.value != null &&
          assignedDate != null &&
          matchesDateRange) {
        final filterEnd = DateTime(
          endDateFilter.value!.year,
          endDateFilter.value!.month,
          endDateFilter.value!.day,
        );
        final assignedDay = DateTime(
          assignedDate.year,
          assignedDate.month,
          assignedDate.day,
        );
        matchesDateRange = assignedDay.isBefore(filterEnd) ||
            assignedDay.isAtSameMomentAs(filterEnd);
      }

      return matchesSearch && matchesStatus && matchesDateRange;
    }).toList();
  }

  void clearFilters() {
    searchController.clear();
    selectedStatusFilter.value = '';
    startDateFilter.value = null;
    endDateFilter.value = null;

    filteredAssignments.value = List.from(assignments);

    CustomWidget.customSnackBar(
      title: 'Filters Cleared',
      message: 'Showing all assignments',
      isError: false,
    );
  }

  bool get hasActiveFilters {
    return searchController.text.isNotEmpty ||
        selectedStatusFilter.value.isNotEmpty ||
        startDateFilter.value != null ||
        endDateFilter.value != null;
  }

  // ==================== EDIT ASSIGNMENT ====================

  void prepareEditAssignment(VehicleAssignment assignment) {
    currentEditAssignment.value = assignment;
    editRemarksController.text = assignment.remarks ?? '';
    editReturnDate.value = _parseDate(assignment.returnDate?.toString());
    editStatus.value = assignment.status;
  }

  void clearEditForm() {
    currentEditAssignment.value = null;
    editRemarksController.clear();
    editReturnDate.value = null;
    editStatus.value = null;
  }

  Future<bool> updateAssignment() async {
    if (currentEditAssignment.value == null) return false;

    isUpdating.value = true;

    try {
      final updatedAssignment = currentEditAssignment.value!.copyWith(
        returnDate: editReturnDate.value != null
            ? DateFormat('yyyy-MM-dd').format(editReturnDate.value!)
            : null,
        remarks: editRemarksController.text,
        status: editStatus.value,
        statusId: editStatus.value?.statusId,
      );

      log('Updating assignment: ${updatedAssignment.toJson()}');

      var res = await AssignRepo().createEditAssignment(
        assignment: updatedAssignment,
        isAssign: false, // This is an update
      );

      return res.fold(
        (success) {
          log('Assignment updated successfully');

          // Update local list
          final index = assignments.indexWhere(
            (a) =>
                a.vehicleNo == updatedAssignment.vehicleNo &&
                a.empNo == updatedAssignment.empNo,
          );
          if (index != -1) {
            assignments[index] = updatedAssignment;
            _applyFiltersInternal();
          }

          CustomWidget.customSnackBar(
            isError: false,
            title: 'Success',
            message: 'Assignment updated successfully',
          );
          return true;
        },
        (error) {
          log('Update error: $error');
          CustomWidget.customSnackBar(
            isError: true,
            title: 'Error',
            message: 'Failed to update assignment: $error',
          );
          return false;
        },
      );
    } catch (e) {
      log('Update exception: $e');
      CustomWidget.customSnackBar(
        isError: true,
        title: 'Error',
        message: 'An error occurred while updating',
      );
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  // ==================== TERMINATE ASSIGNMENT ====================

  Future<bool> terminateAssignment(VehicleAssignment assignment) async {
    isTerminating.value = true;

    try {
      final terminatedStatus = genCon.vehicleAssignmentStatusMasters
          .firstWhereOrNull((s) => s.status?.toLowerCase() == 'terminated');

      final updatedAssignment = assignment.copyWith(
        returnDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        status: terminatedStatus,
        statusId: terminatedStatus?.statusId,
      );

      var res = await AssignRepo().createEditAssignment(
        assignment: updatedAssignment,
        isAssign: false,
      );

      return res.fold(
        (success) {
          log('Assignment terminated successfully');
          final index = assignments.indexWhere(
            (a) =>
                a.vehicleNo == assignment.vehicleNo &&
                a.empNo == assignment.empNo,
          );
          if (index != -1) {
            assignments[index] = updatedAssignment;
            _applyFiltersInternal();
          }
          CustomWidget.customSnackBar(
            isError: false,
            title: 'Success',
            message: 'Assignment terminated successfully',
          );
          return true;
        },
        (error) {
          log('Terminate error: $error');
          CustomWidget.customSnackBar(
            isError: true,
            title: 'Error',
            message: 'Failed to terminate assignment: $error',
          );
          return false;
        },
      );
    } catch (e) {
      log('Terminate exception: $e');
      CustomWidget.customSnackBar(
        isError: true,
        title: 'Error',
        message: 'An error occurred while terminating',
      );
      return false;
    } finally {
      isTerminating.value = false;
    }
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
    return DateFormat('dd MMM yyyy').format(date);
  }

  // Get status color for badges — delegates to shared helper
  Color getStatusColor(String? status) => assignmentStatusColor(status);

  // Check if assignment can be edited (not terminated)
  bool canEdit(VehicleAssignment assignment) {
    return assignment.status?.status?.toLowerCase() != 'terminated';
  }

  // Get assignment duration text
  String getAssignmentDuration(VehicleAssignment assignment) {
    final startDate = _parseDate(assignment.assignedDate);
    if (startDate == null) return '-';

    final endDate = _parseDate(assignment.returnDate?.toString());
    final now = DateTime.now();

    if (endDate != null) {
      final days = endDate.difference(startDate).inDays;
      return '$days days';
    } else {
      final days = now.difference(startDate).inDays;
      return '$days days (ongoing)';
    }
  }
}

// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:multifleet/models/company.dart';
// import 'package:multifleet/models/vehicle_assignment.dart';
// import 'package:multifleet/repo/assign_repo.dart';
// import 'package:multifleet/widgets/custom_widgets.dart';

// import '../services/company_service.dart';

// class AssignedVehicleController extends GetxController
//     implements CompanyAwareController {
//   var companyService = Get.find<CompanyService>();
//   // For filters
//   final searchController = TextEditingController();
//   final selectedVehicleType = ''.obs;
//   final selectedStatus = ''.obs;
//   final startDateFilter = Rx<DateTime?>(null);
//   final endDateFilter = Rx<DateTime?>(null);
//   final RxBool _isFiltersVisible = true.obs;
//   bool get isFiltersVisible => _isFiltersVisible.value;

//   // Loading state
//   final isLoading = false.obs;

//   // List of assignments
//   var assignments = <VehicleAssignment>[].obs;
//   var filteredAssignments = <VehicleAssignment>[].obs;

//   // Dropdown options
//   final vehicleTypeOptions = ['Sedan', 'SUV', 'Truck', 'Van', 'Motorcycle'].obs;
//   final statusOptions = ['Active', 'Pending', 'Expired'].obs;

//   @override
//   void onInit() {
//     super.onInit();
//     companyService.registerController(this);
//     loadAssignments();
//   }

//   @override
//   Future<void> onCompanyChanged(Company newCompany) async {
//     loadAssignments(company: newCompany.id);
//   }

//   @override
//   void onClose() {
//     searchController.dispose();
//     super.onClose();
//   }

//   void toggleFiltersVisible() {
//     _isFiltersVisible.value = !_isFiltersVisible.value;
//   }

//   void loadAssignments({String? company}) async {
//     isLoading.value = true;

//     try {
//       // Normally you would fetch data from your API here
//       var res = await AssignRepo().getAllAssignmets(
//           company: company ?? companyService.selectedCompanyObs.value!.id!);

//       res.fold((l) {
//         CustomWidget.customSnackBar(
//           isError: true,
//           title: 'Error',
//           message: l,
//         );
//       }, (r) {
//         assignments.value = r;
//       });

//       // Initialize filtered assignments with all assignments
//       filteredAssignments.value = List.from(assignments);
//     } catch (e) {
//       log('Error loading assignments: $e');
//       CustomWidget.customSnackBar(
//         isError: true,
//         title: 'Error',
//         message: 'Failed to load assignments. Please try again.',
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   void applyFilters() {
//     filteredAssignments.value = assignments.where((assignment) {
//       // Text search filter
//       bool matchesSearch = true;
//       if (searchController.text.isNotEmpty) {
//         final search = searchController.text.toLowerCase();
//         matchesSearch =
//             assignment['plateNumber'].toLowerCase().contains(search) ||
//                 assignment['employeeName'].toLowerCase().contains(search) ||
//                 assignment['designation'].toLowerCase().contains(search);
//       }

//       // Vehicle type filter
//       bool matchesVehicleType = true;
//       if (selectedVehicleType.value.isNotEmpty) {
//         matchesVehicleType =
//             assignment['vehicleType'] == selectedVehicleType.value;
//       }

//       // Status filter
//       bool matchesStatus = true;
//       if (selectedStatus.value.isNotEmpty) {
//         matchesStatus = assignment['status'] == selectedStatus.value;
//       }

//       // Date range filter
//       bool matchesDateRange = true;
//       if (startDateFilter.value != null) {
//         // Normalize dates by removing time component for comparison
//         final assignmentStartDate = DateTime(
//           assignment['startDate'].year,
//           assignment['startDate'].month,
//           assignment['startDate'].day,
//         );
//         final filterStartDate = DateTime(
//           startDateFilter.value!.year,
//           startDateFilter.value!.month,
//           startDateFilter.value!.day,
//         );
//         matchesDateRange = assignmentStartDate.isAfter(filterStartDate) ||
//             assignmentStartDate.isAtSameMomentAs(filterStartDate);
//       }

//       if (endDateFilter.value != null) {
//         final assignmentEndDate = assignment['endDate'] != null
//             ? DateTime(
//                 assignment['endDate'].year,
//                 assignment['endDate'].month,
//                 assignment['endDate'].day,
//               )
//             : null;

//         final filterEndDate = DateTime(
//           endDateFilter.value!.year,
//           endDateFilter.value!.month,
//           endDateFilter.value!.day,
//         );

//         // If assignment has no end date, it's considered ongoing
//         // So it matches if its start date is before the filter end date
//         if (assignmentEndDate == null) {
//           matchesDateRange = matchesDateRange &&
//               assignment['startDate'].isBefore(filterEndDate);
//         } else {
//           matchesDateRange =
//               matchesDateRange && assignmentEndDate.isBefore(filterEndDate) ||
//                   assignmentEndDate.isAtSameMomentAs(filterEndDate);
//         }
//       }

//       return matchesSearch &&
//           matchesVehicleType &&
//           matchesStatus &&
//           matchesDateRange;
//     }).toList();

//     CustomWidget.customSnackBar(
//       title: 'Filters Applied',
//       message: '${filteredAssignments.length} assignments found',
//       isError: false,
//     );
//   }

//   void clearFilters() {
//     searchController.clear();
//     selectedVehicleType.value = '';
//     selectedStatus.value = '';
//     startDateFilter.value = null;
//     endDateFilter.value = null;

//     // Reset filtered assignments to show all
//     filteredAssignments.value = List.from(assignments);

//     CustomWidget.customSnackBar(
//       title: 'Filters Cleared',
//       message: 'Showing all assignments',
//       isError: false,
//     );
//   }

//   void viewAssignmentDetails(Map<String, dynamic> assignment) {
//     Get.dialog(
//       Dialog(
//         child: Container(
//           padding: EdgeInsets.all(20),
//           constraints: BoxConstraints(maxWidth: 500),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Assignment Details',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.close),
//                     onPressed: () => Get.back(),
//                   ),
//                 ],
//               ),
//               Divider(),
//               SizedBox(height: 10),

//               // Vehicle information
//               Text('Vehicle Information',
//                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//               SizedBox(height: 10),
//               _buildDetailRowForDialog(
//                   'Plate Number', assignment['plateNumber']),
//               _buildDetailRowForDialog('Brand & Model',
//                   '${assignment['brand']} ${assignment['model']}'),
//               _buildDetailRowForDialog(
//                   'Vehicle Type', assignment['vehicleType']),
//               _buildDetailRowForDialog(
//                   'Chassis Number', assignment['chassisNumber']),
//               _buildDetailRowForDialog(
//                   'Traffic File', assignment['trafficFileNumber']),
//               _buildDetailRowForDialog(
//                   'Policy Number', assignment['policyNumber']),
//               _buildDetailRowForDialog(
//                   'Current KM', assignment['currentKm'].toString()),

//               SizedBox(height: 20),

//               // Assignment information
//               Text('Assignment Information',
//                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//               SizedBox(height: 10),
//               _buildDetailRowForDialog('Employee', assignment['employeeName']),
//               _buildDetailRowForDialog(
//                   'Designation', assignment['designation']),
//               _buildDetailRowForDialog('Status', assignment['status']),
//               _buildDetailRowForDialog(
//                   'Start Date', _formatDate(assignment['startDate'])),
//               _buildDetailRowForDialog(
//                   'End Date',
//                   assignment['endDate'] != null
//                       ? _formatDate(assignment['endDate'])
//                       : '-'),
//               _buildDetailRowForDialog('Remarks', assignment['remarks'] ?? '-'),

//               SizedBox(height: 20),
//               Center(
//                 child: ElevatedButton(
//                   onPressed: () => Get.back(),
//                   child: Text('Close'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void editAssignment(Map<String, dynamic> assignment) {
//     log(assignment.toString());
//   }

//   Widget _buildDetailRowForDialog(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               "$label:",
//               style: TextStyle(fontWeight: FontWeight.w600),
//             ),
//           ),
//           Expanded(
//             child: Text(value),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
//   }
// }
