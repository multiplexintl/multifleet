import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multifleet/models/company.dart';
import 'package:multifleet/models/employee.dart';
import 'package:multifleet/models/status_master/status_master.dart';

import 'package:multifleet/models/vehicle.dart';
import 'package:multifleet/repo/assign_repo.dart';

import 'package:multifleet/services/company_service.dart';

import '../models/vehicle_assignment_model.dart';
import '../repo/vehicles_repo.dart';
import '../widgets/custom_widgets.dart';
import 'general_masters.dart';

class VehicleAssignmentController extends GetxController
    implements CompanyAwareController {
  final companyService = Get.find<CompanyService>();
  final _vehicleRepo = VehiclesRepo();
  final genCon = Get.find<GeneralMastersController>();

  // Text controllers
  final TextEditingController plateNumberController = TextEditingController();
  final TextEditingController empNameController = TextEditingController();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();

  // Selected values
  final Rx<Vehicle?> selectedVehicle = Rx<Vehicle?>(null);
  final Rx<Employee?> selectedEmployee = Rx<Employee?>(null);
  final Rx<String?> selectedDesignation = Rx<String?>(null);
  final Rx<StatusMaster?> selectedStatus = Rx<StatusMaster?>(null);
  final Rx<VehicleAssignment?> lastVehicleAssignment =
      Rx<VehicleAssignment?>(null);

  /// Upcoming scheduled assignments for the searched vehicle (assignedDate > today).
  final RxList<VehicleAssignment> futureAssignments = <VehicleAssignment>[].obs;

  // Date and time values
  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);

  // Images
  final RxList<XFile> selectedImages = <XFile>[].obs;

  // Loading states
  final RxBool isSearching = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isTerminating = false.obs;

  @override
  Future<void> onCompanyChanged(Company newCompany) async {
    // getAllEmployees(company: newCompany);
  }

  @override
  void onInit() {
    super.onInit();
    companyService.registerController(this);
    // getAllEmployees();
  }

  void onPlateChanged(String? letter, String? emirate, String? number) {
    plateNumberController.text = "$letter-$number";
    log(plateNumberController.text);
  }

  // ==================== SEARCH ====================

  Future<void> searchVehicle() async {
    if (plateNumberController.text.isEmpty) {
      CustomWidget.customSnackBar(
        isError: false,
        title: 'Error',
        message: 'Please enter a plate number',
      );
      return;
    }

    try {
      isSearching.value = true;
      selectedVehicle.value = null;
      lastVehicleAssignment.value = null;
      futureAssignments.clear();

      // 1. Check if vehicle exists
      var vehicleRes = await _vehicleRepo.getAllVehicles(
        company: companyService.selectedCompanyObs.value?.id ?? '',
        query: plateNumberController.text,
      );

      vehicleRes.fold(
        (error) {
          log(error);
          CustomWidget.customSnackBar(
            isError: true,
            title: 'Error',
            message: error,
          );
        },
        (vehicleList) async {
          if (vehicleList.isEmpty) {
            CustomWidget.customSnackBar(
              isError: false,
              title: 'Not Found',
              message: 'No vehicle found with this plate number',
            );
            return;
          }

          // Vehicle exists
          selectedVehicle.value = vehicleList.first;

          // 2. Check for active assignments
          var assignRes = await AssignRepo().getAllAssignmets(
            company: '${companyService.selectedCompanyObs.value?.id}',
            query: plateNumberController.text,
            isActive: true,
          );

          assignRes.fold(
            (error) {
              log(error);
              // Vehicle found but no assignment - ready for new assignment
            },
            (assignments) {
              if (assignments.isNotEmpty) {
                // Vehicle is already assigned
                lastVehicleAssignment.value = assignments.first;
                log('Vehicle already assigned to: ${assignments.first.empName}');
              }
              // If empty, vehicle is available for assignment
            },
          );

          // 3. Fetch all assignments and filter for future ones (assignedDate > today)
          var allAssignRes = await AssignRepo().getAllAssignmets(
            company: '${companyService.selectedCompanyObs.value?.id}',
            query: plateNumberController.text,
            isActive: false,
          );
          allAssignRes.fold(
            (error) => log('Future assignments fetch error: $error'),
            (all) {
              final today = DateTime.now();
              final todayOnly = DateTime(today.year, today.month, today.day);
              futureAssignments.assignAll(
                all.where((a) {
                  if (a.assignedDate == null) return false;
                  try {
                    final d = DateTime.parse(a.assignedDate!);
                    final assignedDay = DateTime(d.year, d.month, d.day);
                    return assignedDay.isAfter(todayOnly);
                  } catch (_) {
                    return false;
                  }
                }).toList()
                  ..sort((a, b) => a.assignedDate!.compareTo(b.assignedDate!)),
              );
              log('Future assignments: ${futureAssignments.length}');
            },
          );
        },
      );
    } on Exception catch (e) {
      log(e.toString());
    } finally {
      isSearching.value = false;
    }
  }

  // ==================== EMPLOYEE SELECTION ====================

  Future<List<Employee>> getEmpSuggestions(String query) async {
    if (query.isEmpty) return [];

    return genCon.companyEmployees
        .where((emp) =>
            emp.isActive &&
            ((emp.empName != null &&
                    emp.empName!.toLowerCase().contains(query.toLowerCase())) ||
                (emp.empNo != null &&
                    emp.empNo!.toLowerCase().contains(query.toLowerCase()))))
        .toList();
  }

  Future<List<String>> getDesignationSuggestions(String query) async {
    if (query.isEmpty) return [];

    return genCon.designations
        .where((designation) =>
            designation.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void onEmpSelected(Employee emp) {
    empNameController.text = emp.empName ?? '';
    selectedEmployee.value = emp;
    onDesignationSelected(emp.designation ?? '');
  }

  void onDesignationSelected(String des) {
    designationController.text = des;
    selectedDesignation.value = des;
  }

  // ==================== TERMINATE & REASSIGN ====================

  /// Finds a status from the assignment master by name (case-insensitive).
  StatusMaster? _findAssignmentStatus(String name) =>
      genCon.vehicleAssignmentStatusMasters.firstWhereOrNull(
        (s) => s.status?.toLowerCase() == name.toLowerCase(),
      );

  /// Terminate current assignment and proceed with new assignment form.
  /// Sets returnDate = today, status = Returned.
  Future<void> terminateAndProceed() async {
    if (lastVehicleAssignment.value == null) return;

    isTerminating.value = true;

    try {
      final returnedStatus = _findAssignmentStatus('Returned');
      final updatedAssignment = lastVehicleAssignment.value!.copyWith(
        returnDate: formatDateOnly(DateTime.now()),
        status: returnedStatus,
        statusId: returnedStatus?.statusId,
      );

      var res = await AssignRepo().createEditAssignment(
        assignment: updatedAssignment,
        isAssign: false, // UPDATE operation
      );

      res.fold(
        (success) {
          log('Assignment terminated for reassignment');
          // Clear assignment but keep vehicle for new assignment
          lastVehicleAssignment.value = null;
          CustomWidget.customSnackBar(
            isError: false,
            title: 'Success',
            message:
                'Previous assignment terminated. You can now assign to new employee.',
          );
        },
        (error) {
          log('Terminate error: ${error.message}');
          CustomWidget.customSnackBar(
            isError: true,
            title: 'Error',
            message: 'Failed to terminate assignment: ${error.message}',
          );
        },
      );
    } catch (e) {
      log('Terminate exception: $e');
      CustomWidget.customSnackBar(
        isError: true,
        title: 'Error',
        message: 'An error occurred while terminating assignment',
      );
    } finally {
      isTerminating.value = false;
    }
  }

  /// Terminate assignment without reassigning.
  /// Sets returnDate = today, status = Terminated.
  Future<bool> terminateAssignment() async {
    if (lastVehicleAssignment.value == null) return false;

    isTerminating.value = true;

    try {
      final terminatedStatus = _findAssignmentStatus('Terminated');
      final updatedAssignment = lastVehicleAssignment.value!.copyWith(
        returnDate: formatDateOnly(DateTime.now()),
        status: terminatedStatus,
        statusId: terminatedStatus?.statusId,
      );

      var res = await AssignRepo().createEditAssignment(
        assignment: updatedAssignment,
        isAssign: false, // UPDATE operation
      );

      return res.fold(
        (success) {
          log('Assignment terminated successfully');
          clearForm();
          CustomWidget.customSnackBar(
            isError: false,
            title: 'Success',
            message: 'Assignment terminated successfully',
          );
          return true;
        },
        (error) {
          log('Terminate error: ${error.message}');
          CustomWidget.customSnackBar(
            isError: true,
            title: 'Error',
            message: 'Failed to terminate assignment: ${error.message}',
          );
          return false;
        },
      );
    } catch (e) {
      log('Terminate exception: $e');
      CustomWidget.customSnackBar(
        isError: true,
        title: 'Error',
        message: 'An error occurred while terminating assignment',
      );
      return false;
    } finally {
      isTerminating.value = false;
    }
  }

  /// Cancel - just clear UI without backend changes
  void cancelAssignment() {
    clearForm();
  }

  // ==================== IMAGES ====================

  Future<void> pickImages() async {
    if (selectedImages.length >= 6) {
      CustomWidget.customSnackBar(
        isError: false,
        title: 'Limit Reached',
        message: 'Maximum 6 images allowed',
      );
      return;
    }

    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      if (selectedImages.length + images.length > 6) {
        final int remaining = 6 - selectedImages.length;
        selectedImages.addAll(images.take(remaining));
        CustomWidget.customSnackBar(
          isError: false,
          title: 'Limit Reached',
          message:
              'Added $remaining out of ${images.length} images. Maximum 6 images allowed.',
        );
      } else {
        selectedImages.addAll(images);
      }
    }
  }

  void removeImage(int index) {
    selectedImages.removeAt(index);
  }

  // ==================== SUBMIT ====================

  Future<void> submitAssignment() async {
    if (selectedVehicle.value == null) {
      CustomWidget.customSnackBar(
        isError: true,
        title: 'Error',
        message: 'Please search and select a vehicle first',
      );
      return;
    }

    if (selectedEmployee.value == null) {
      CustomWidget.customSnackBar(
        isError: true,
        title: 'Error',
        message: 'Please select an employee',
      );
      return;
    }

    if (selectedDesignation.value == null) {
      CustomWidget.customSnackBar(
        isError: true,
        title: 'Error',
        message: 'Please select a designation',
      );
      return;
    }

    if (startDate.value == null) {
      CustomWidget.customSnackBar(
        isError: true,
        title: 'Error',
        message: 'Please select a start date',
      );
      return;
    }

    isSubmitting.value = true;

    try {
      VehicleAssignment assignment = VehicleAssignment(
        company: companyService.selectedCompanyObs.value?.id,
        vehicleNo: selectedVehicle.value!.vehicleNo,
        empNo: selectedEmployee.value!.empNo,
        assignedDate: formatDateOnly(startDate.value),
        returnDate: formatDateOnly(endDate.value),
        remarks: remarksController.text,
        status: selectedStatus.value,
        statusId: selectedStatus.value?.statusId,
        image1: selectedImages.isNotEmpty ? selectedImages[0].path : null,
        image2: selectedImages.length >= 2 ? selectedImages[1].path : null,
        image3: selectedImages.length >= 3 ? selectedImages[2].path : null,
        image4: selectedImages.length >= 4 ? selectedImages[3].path : null,
        image5: selectedImages.length >= 5 ? selectedImages[4].path : null,
        image6: selectedImages.length >= 6 ? selectedImages[5].path : null,
      );

      log(assignment.toJsonAssignUpdate().toString());

      var res = await AssignRepo()
          .createEditAssignment(assignment: assignment, isAssign: true);

      res.fold(
        (success) {
          log(success.toString());
          CustomWidget.customSnackBar(
            isError: false,
            title: 'Success',
            message: 'Vehicle assigned successfully',
          );
          clearForm();
        },
        (error) {
          log(error.toString());
          CustomWidget.customSnackBar(
            isError: true,
            title: 'Error',
            message: error.message ?? 'Failed to assign vehicle',
          );
        },
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  // ==================== CLEAR ====================

  void clearSearch() {
    plateNumberController.clear();
    selectedVehicle.value = null;
    lastVehicleAssignment.value = null;
    futureAssignments.clear();
  }

  void clearForm() {
    // plateNumberController.clear();
    empNameController.clear();
    designationController.clear();
    remarksController.clear();
    selectedVehicle.value = null;
    selectedEmployee.value = null;
    selectedDesignation.value = null;
    selectedStatus.value = null;
    lastVehicleAssignment.value = null;
    startDate.value = null;
    endDate.value = null;
    selectedImages.clear();
  }

  // ==================== FORMATTERS ====================

  String formatDateTime(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  String? formatDateOnly(DateTime? date) {
    if (date == null) return null;
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String? formatISODateTime(String? isoDateTime) {
    if (isoDateTime == null || isoDateTime.isEmpty) return 'Indefinite';
    try {
      final DateTime dateTime = DateTime.parse(isoDateTime);
      return DateFormat('dd/MM/yyyy hh:mm a').format(dateTime);
    } catch (e) {
      return null;
    }
  }
}
