import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:multifleet/widgets/custom_widgets.dart';

import '../helpers/fake_data_service.dart';

class VehicleFineController extends GetxController {
  // Text controllers
  final TextEditingController plateNumberController =
      TextEditingController(text: 'AD 123 XYZ');
  final TextEditingController fineAmountController = TextEditingController();
  final TextEditingController fineLocationController = TextEditingController();
  final TextEditingController fineNumberController = TextEditingController();
  final TextEditingController trafficFileNumberController =
      TextEditingController();
  final TextEditingController remarksController = TextEditingController();

  // Selected values
  final Rx<Map<String, dynamic>?> selectedVehicle =
      Rx<Map<String, dynamic>?>(null);
  final Rx<Map<String, dynamic>?> selectedAssignment =
      Rx<Map<String, dynamic>?>(null);
  final Rx<DateTime?> fineDate = Rx<DateTime?>(DateTime.now());

  // Assignment data
  final RxList<Map<String, dynamic>> vehicleAssignments =
      <Map<String, dynamic>>[].obs;
  final RxInt totalAssignments = 0.obs;
  final RxInt currentPage = 1.obs;
  final int pageSize = 10;
  final RxSet<int> expandedFineIds = <int>{}.obs;

  // Loading states
  final RxBool isSearching = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isSubmitting = false.obs;

  // Search vehicle by plate number
  Future<void> searchVehicle() async {
    if (plateNumberController.text.isEmpty) return;

    isSearching.value = true;
    selectedVehicle.value = null;
    selectedAssignment.value = null;
    vehicleAssignments.clear();

    try {
      // Simulate API call or database query
      // await Future.delayed(Duration(seconds: 1));

      // final vehicle =
      //     FakeVehicleData.findVehicleByPlateNumber(plateNumberController.text);

      // if (vehicle != null) {
      //   selectedVehicle.value = vehicle;
      //   // Fetch assignments for this vehicle
      //   await loadVehicleAssignments(1, true);
      // } else {
      //   CustomWidget.customSnackBar(title:  'Not Found', 'No vehicle found with this plate number',
      //
      //
      //       );
      // }
    } finally {
      isSearching.value = false;
    }
  }

  void toggleFineDetails(int assignmentId) {
    if (expandedFineIds.contains(assignmentId)) {
      expandedFineIds.remove(assignmentId);
    } else {
      expandedFineIds.add(assignmentId);
    }
    update();
  }

  // Load vehicle assignments with pagination
  Future<void> loadVehicleAssignments(int page, bool resetPage) async {
    if (selectedVehicle.value == null) return;

    if (resetPage) {
      vehicleAssignments.clear();
      currentPage.value = 1;
    } else {
      isLoadingMore.value = true;
      currentPage.value = page;
    }

    try {
      // Simulate API call or database query
      await Future.delayed(Duration(seconds: 1));

      final assignments = FakeVehicleData.getVehicleAssignments(
          selectedVehicle.value!['plateNumber'], page, pageSize);

      vehicleAssignments.addAll(assignments.items);
      totalAssignments.value = assignments.total;
    } finally {
      isLoadingMore.value = false;
    }
  }

  // Load more assignments
  Future<void> loadMoreAssignments() async {
    if (vehicleAssignments.length < totalAssignments.value) {
      await loadVehicleAssignments(currentPage.value + 1, false);
    }
  }

  // Select an assignment
  void selectAssignment(Map<String, dynamic> assignment) {
    selectedAssignment.value = assignment;

    // Clear form fields
    fineAmountController.clear();
    fineLocationController.clear();
    fineNumberController.clear();
    trafficFileNumberController.clear();
    fineDate.value = DateTime.now();
  }

  // Clear search
  void clearSearch() {
    plateNumberController.clear();
    selectedVehicle.value = null;
    selectedAssignment.value = null;
    vehicleAssignments.clear();
    clearFineForm();
  }

  // Clear fine form
  void clearFineForm() {
    fineAmountController.clear();
    fineLocationController.clear();
    fineNumberController.clear();
    trafficFileNumberController.clear();
    fineDate.value = DateTime.now();
    selectedAssignment.value = null;
  }

  // Submit fine
  Future<void> submitFine() async {
    if (selectedVehicle.value == null) {
      CustomWidget.customSnackBar(
        isError: true,
        title: 'Error',
        message: 'Please search and select a vehicle first',
      );
      return;
    }

    if (selectedAssignment.value == null) {
      CustomWidget.customSnackBar(
        isError: true,
        title: 'Error',
        message: 'Please select an assignment first',
      );
      return;
    }

    if (fineAmountController.text.isEmpty) {
      CustomWidget.customSnackBar(
        isError: true,
        title: 'Error',
        message: 'Please enter the fine amount',
      );
      return;
    }

    // Validate fine amount is a valid number
    try {
      double.parse(fineAmountController.text);
    } catch (e) {
      CustomWidget.customSnackBar(
        isError: true,
        title: 'Error',
        message: 'Please enter a valid fine amount',
      );
      return;
    }

    if (fineDate.value == null) {
      CustomWidget.customSnackBar(
        isError: true,
        title: 'Error',
        message: 'Please select a fine date',
      );
      return;
    }

    if (fineNumberController.text.isEmpty) {
      CustomWidget.customSnackBar(
        isError: true,
        title: 'Error',
        message: 'Please enter the fine number',
      );
      return;
    }

    isSubmitting.value = true;

    try {
      // Simulate API call or database insertion
      await Future.delayed(Duration(seconds: 1));

      CustomWidget.customSnackBar(
        isError: false,
        title: 'Success',
        message: 'Fine added successfully',
      );

      // Clear form but keep selected vehicle and assignments
      clearFineForm();
    } finally {
      isSubmitting.value = false;
    }
  }

  // Format date for display
  String formatDateTime(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd MMM yyyy').format(date);
  }
}
