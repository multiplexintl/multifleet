import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multifleet/widgets/custom_widgets.dart';

import '../widgets/custom_snackbar.dart';

class AssignedVehicleController extends GetxController {
  // For filters
  final searchController = TextEditingController();
  final selectedVehicleType = ''.obs;
  final selectedStatus = ''.obs;
  final startDateFilter = Rx<DateTime?>(null);
  final endDateFilter = Rx<DateTime?>(null);
  final RxBool _isFiltersVisible = true.obs;
  bool get isFiltersVisible => _isFiltersVisible.value;

  // Loading state
  final isLoading = false.obs;

  // List of assignments
  final assignments = <Map<String, dynamic>>[].obs;
  final filteredAssignments = <Map<String, dynamic>>[].obs;

  // Dropdown options
  final vehicleTypeOptions = ['Sedan', 'SUV', 'Truck', 'Van', 'Motorcycle'].obs;
  final statusOptions = ['Active', 'Pending', 'Expired'].obs;

  @override
  void onInit() {
    super.onInit();
    loadAssignments();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void toggleFiltersVisible() {
    _isFiltersVisible.value = !_isFiltersVisible.value;
  }

  void loadAssignments() async {
    isLoading.value = true;

    try {
      // Simulate API call delay
      await Future.delayed(Duration(seconds: 1));

      // Normally you would fetch data from your API here
      // For now, we'll use dummy data
      assignments.value = [
        {
          'id': '1',
          'plateNumber': 'ABC 123',
          'vehicleType': 'Sedan',
          'brand': 'Toyota',
          'model': 'Camry',
          'employeeName': 'John Smith',
          'designation': 'Sales Manager',
          'startDate': DateTime.now().subtract(Duration(days: 30)),
          'endDate': DateTime.now().add(Duration(days: 30)),
          'status': 'Active',
          'remarks': 'Daily use for client visits',
          'chassisNumber': 'CH123456789',
          'trafficFileNumber': 'TF12345',
          'policyNumber': 'POL987654',
          'currentKm': 25000,
          'mulkiyaExpiry': DateTime.now().add(Duration(days: 180)),
          'insuranceExpiry': DateTime.now().add(Duration(days: 240)),
        },
        {
          'id': '2',
          'plateNumber': 'XYZ 789',
          'vehicleType': 'SUV',
          'brand': 'Nissan',
          'model': 'Patrol',
          'employeeName': 'Sarah Johnson',
          'designation': 'Operations Director',
          'startDate': DateTime.now().subtract(Duration(days: 60)),
          'endDate': null,
          'status': 'Active',
          'remarks': 'Long-term assignment',
          'chassisNumber': 'CH987654321',
          'trafficFileNumber': 'TF67890',
          'policyNumber': 'POL123456',
          'currentKm': 15000,
          'mulkiyaExpiry': DateTime.now().add(Duration(days: 120)),
          'insuranceExpiry': DateTime.now().add(Duration(days: 90)),
        },
        {
          'id': '3',
          'plateNumber': 'DEF 456',
          'vehicleType': 'Van',
          'brand': 'Ford',
          'model': 'Transit',
          'employeeName': 'Mike Anderson',
          'designation': 'Logistics Coordinator',
          'startDate': DateTime.now().subtract(Duration(days: 15)),
          'endDate': DateTime.now().subtract(Duration(days: 5)),
          'status': 'Expired',
          'remarks': 'Short-term project delivery',
          'chassisNumber': 'CH456789123',
          'trafficFileNumber': 'TF45678',
          'policyNumber': 'POL567890',
          'currentKm': 42000,
          'mulkiyaExpiry': DateTime.now().add(Duration(days: 210)),
          'insuranceExpiry': DateTime.now().add(Duration(days: 180)),
        },
        {
          'id': '4',
          'plateNumber': 'GHI 789',
          'vehicleType': 'Sedan',
          'brand': 'Honda',
          'model': 'Accord',
          'employeeName': 'Lisa Chen',
          'designation': 'HR Manager',
          'startDate': DateTime.now().add(Duration(days: 5)),
          'endDate': DateTime.now().add(Duration(days: 90)),
          'status': 'Pending',
          'remarks': 'Scheduled assignment',
          'chassisNumber': 'CH789123456',
          'trafficFileNumber': 'TF89012',
          'policyNumber': 'POL890123',
          'currentKm': 8000,
          'mulkiyaExpiry': DateTime.now().add(Duration(days: 300)),
          'insuranceExpiry': DateTime.now().add(Duration(days: 270)),
        },
      ];

      // Initialize filtered assignments with all assignments
      filteredAssignments.value = List.from(assignments);
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

  void applyFilters() {
    filteredAssignments.value = assignments.where((assignment) {
      // Text search filter
      bool matchesSearch = true;
      if (searchController.text.isNotEmpty) {
        final search = searchController.text.toLowerCase();
        matchesSearch =
            assignment['plateNumber'].toLowerCase().contains(search) ||
                assignment['employeeName'].toLowerCase().contains(search) ||
                assignment['designation'].toLowerCase().contains(search);
      }

      // Vehicle type filter
      bool matchesVehicleType = true;
      if (selectedVehicleType.value.isNotEmpty) {
        matchesVehicleType =
            assignment['vehicleType'] == selectedVehicleType.value;
      }

      // Status filter
      bool matchesStatus = true;
      if (selectedStatus.value.isNotEmpty) {
        matchesStatus = assignment['status'] == selectedStatus.value;
      }

      // Date range filter
      bool matchesDateRange = true;
      if (startDateFilter.value != null) {
        // Normalize dates by removing time component for comparison
        final assignmentStartDate = DateTime(
          assignment['startDate'].year,
          assignment['startDate'].month,
          assignment['startDate'].day,
        );
        final filterStartDate = DateTime(
          startDateFilter.value!.year,
          startDateFilter.value!.month,
          startDateFilter.value!.day,
        );
        matchesDateRange = assignmentStartDate.isAfter(filterStartDate) ||
            assignmentStartDate.isAtSameMomentAs(filterStartDate);
      }

      if (endDateFilter.value != null) {
        final assignmentEndDate = assignment['endDate'] != null
            ? DateTime(
                assignment['endDate'].year,
                assignment['endDate'].month,
                assignment['endDate'].day,
              )
            : null;

        final filterEndDate = DateTime(
          endDateFilter.value!.year,
          endDateFilter.value!.month,
          endDateFilter.value!.day,
        );

        // If assignment has no end date, it's considered ongoing
        // So it matches if its start date is before the filter end date
        if (assignmentEndDate == null) {
          matchesDateRange = matchesDateRange &&
              assignment['startDate'].isBefore(filterEndDate);
        } else {
          matchesDateRange =
              matchesDateRange && assignmentEndDate.isBefore(filterEndDate) ||
                  assignmentEndDate.isAtSameMomentAs(filterEndDate);
        }
      }

      return matchesSearch &&
          matchesVehicleType &&
          matchesStatus &&
          matchesDateRange;
    }).toList();

    CustomWidget.customSnackBar(
      title: 'Filters Applied',
      message: '${filteredAssignments.length} assignments found',
      isError: false,
    );
  }

  void clearFilters() {
    searchController.clear();
    selectedVehicleType.value = '';
    selectedStatus.value = '';
    startDateFilter.value = null;
    endDateFilter.value = null;

    // Reset filtered assignments to show all
    filteredAssignments.value = List.from(assignments);

    CustomWidget.customSnackBar(
      title: 'Filters Cleared',
      message: 'Showing all assignments',
      isError: false,
    );
  }

  void viewAssignmentDetails(Map<String, dynamic> assignment) {
    Get.dialog(
      Dialog(
        child: Container(
          padding: EdgeInsets.all(20),
          constraints: BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Assignment Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              Divider(),
              SizedBox(height: 10),

              // Vehicle information
              Text('Vehicle Information',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 10),
              _buildDetailRowForDialog(
                  'Plate Number', assignment['plateNumber']),
              _buildDetailRowForDialog('Brand & Model',
                  '${assignment['brand']} ${assignment['model']}'),
              _buildDetailRowForDialog(
                  'Vehicle Type', assignment['vehicleType']),
              _buildDetailRowForDialog(
                  'Chassis Number', assignment['chassisNumber']),
              _buildDetailRowForDialog(
                  'Traffic File', assignment['trafficFileNumber']),
              _buildDetailRowForDialog(
                  'Policy Number', assignment['policyNumber']),
              _buildDetailRowForDialog(
                  'Current KM', assignment['currentKm'].toString()),

              SizedBox(height: 20),

              // Assignment information
              Text('Assignment Information',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 10),
              _buildDetailRowForDialog('Employee', assignment['employeeName']),
              _buildDetailRowForDialog(
                  'Designation', assignment['designation']),
              _buildDetailRowForDialog('Status', assignment['status']),
              _buildDetailRowForDialog(
                  'Start Date', _formatDate(assignment['startDate'])),
              _buildDetailRowForDialog(
                  'End Date',
                  assignment['endDate'] != null
                      ? _formatDate(assignment['endDate'])
                      : '-'),
              _buildDetailRowForDialog('Remarks', assignment['remarks'] ?? '-'),

              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  child: Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void editAssignment(Map<String, dynamic> assignment) {
    // Navigate to the assignment edit page with the selected assignment
    Get.toNamed('/vehicle-assignment/edit', arguments: assignment);
    // In a real app, you would pass the ID to the edit page
    // Get.toNamed('/vehicle-assignment/edit/${assignment['id']}');
  }

  Widget _buildDetailRowForDialog(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label + ":",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
