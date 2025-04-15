import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multifleet/widgets/custom_widgets.dart';

// GetX Controller for maintenance management
class MaintenanceController extends GetxController {
  final plateNumberController = TextEditingController();
  final vehicleFound = false.obs;
  final vehicleData = Rx<Map<String, dynamic>?>(null);
  final maintenanceRecords = RxList<Map<String, dynamic>>([]);

  // Single maintenance form controllers
  final invoiceNumberController = TextEditingController();
  final descriptionController = TextEditingController();
  final totalAmountController = TextEditingController();
  final kilometerController = TextEditingController();
  final selectedDate = Rx<DateTime>(DateTime.now());
  final selectedGarage = Rx<String?>(null);

  // For Bulk Upload
  final showBulkUpload = false.obs;

  // Dropdown options
  final garageList = [
    'AutoPro',
    'Al Futtaim',
    'Danube Auto',
    'GT Auto Centre',
    'Express Auto'
  ];

  // @override
  // void onInit() {
  //   super.onInit();
  //   // Initialize with any default values if needed
  // }

  @override
  void onClose() {
    // Dispose controllers to prevent memory leaks
    plateNumberController.dispose();
    invoiceNumberController.dispose();
    descriptionController.dispose();
    totalAmountController.dispose();
    kilometerController.dispose();
    super.onClose();
  }

  void searchVehicle() {
    showBulkUpload.value = false;
    if (plateNumberController.text.isEmpty) {
      CustomWidget.customSnackBar(
        isError: true,
        title: 'Error',
        message: 'Please enter a plate number',
      );
      return;
    }

    // Simulate API call or database fetch
    vehicleFound.value = true;
    vehicleData.value = {
      'plateNumber': plateNumberController.text,
      'brand': 'Toyota',
      'model': 'Camry',
      'type': 'Sedan',
      'chassisNumber': 'CHASSIS-67890',
      'currentKm': 45000,
    };

    // Fetch maintenance records for this vehicle
    _fetchMaintenanceRecords();
  }

  void _fetchMaintenanceRecords() {
    // Simulate fetching maintenance records from API or database
    maintenanceRecords.value = [
      {
        'id': '1',
        'invoiceNumber': 'INV-001',
        'invoiceDate': DateTime.now().subtract(const Duration(days: 90)),
        'description': 'Regular oil change and filter replacement',
        'garage': 'AutoPro',
        'amount': 450.0,
        'kilometer': 42000,
      },
      {
        'id': '2',
        'invoiceNumber': 'INV-002',
        'invoiceDate': DateTime.now().subtract(const Duration(days: 30)),
        'description': 'Brake pad replacement and inspection',
        'garage': 'Al Futtaim',
        'amount': 850.0,
        'kilometer': 44000,
      },
    ];
  }

  void clearSearch() {
    plateNumberController.clear();
    vehicleFound.value = false;
    vehicleData.value = null;
    maintenanceRecords.clear();
  }

  void resetMaintenanceForm() {
    invoiceNumberController.clear();
    descriptionController.clear();
    totalAmountController.clear();
    kilometerController.clear();
    selectedDate.value = DateTime.now();
    selectedGarage.value = null;
  }

  void saveMaintenanceRecord() {
    // Validate form
    if (!validateMaintenanceForm()) {
      return;
    }

    // Create new maintenance record
    final newRecord = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'invoiceNumber': invoiceNumberController.text,
      'invoiceDate': selectedDate.value,
      'description': descriptionController.text,
      'garage': selectedGarage.value,
      'amount': double.parse(totalAmountController.text),
      'kilometer': int.parse(kilometerController.text),
    };

    // Add to list
    maintenanceRecords.add(newRecord);

    // Update vehicle's current kilometer reading if the new record has a higher value
    if (vehicleData.value != null &&
        int.parse(kilometerController.text) > vehicleData.value!['currentKm']) {
      vehicleData.update((val) {
        val!['currentKm'] = int.parse(kilometerController.text);
      });
    }

    // Show success message
    CustomWidget.customSnackBar(
      isError: false,
      title: 'Success',
      message: 'Maintenance record added successfully',
    );

    // Reset form
    resetMaintenanceForm();
  }

  bool validateMaintenanceForm() {
    if (invoiceNumberController.text.isEmpty) {
      CustomWidget.customSnackBar(
        isError: true,
        title: 'Error',
        message: 'Please enter an invoice number',
      );
      return false;
    }

    if (descriptionController.text.isEmpty) {
      CustomWidget.customSnackBar(
        isError: true,
        title: 'Error',
        message: 'Please enter a description',
      );
      return false;
    }

    if (selectedGarage.value == null) {
      CustomWidget.customSnackBar(
        isError: true,
        title: 'Error',
        message: 'Please select a garage',
      );
      return false;
    }

    if (totalAmountController.text.isEmpty ||
        !_isNumeric(totalAmountController.text)) {
      CustomWidget.customSnackBar(
        isError: true,
        title: 'Error',
        message: 'Please enter a valid amount',
      );
      return false;
    }

    if (kilometerController.text.isEmpty ||
        !_isNumeric(kilometerController.text)) {
      CustomWidget.customSnackBar(
        isError: true,
        title: 'Error',
        message: 'Please enter a valid kilometer reading',
      );
      return false;
    }

    return true;
  }

  bool _isNumeric(String? str) {
    if (str == null) {
      return false;
    }
    return double.tryParse(str) != null;
  }

  void toggleBulkUpload() {
    showBulkUpload.toggle();
    log(showBulkUpload.toString());
  }

  void uploadBulkMaintenanceRecords() {
    // Will be implemented later
    CustomWidget.customSnackBar(
      isError: false,
      title: 'Info',
      message: 'Bulk upload functionality will be implemented later',
    );
  }
}
