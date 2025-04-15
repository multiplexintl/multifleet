import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:multifleet/controllers/vehicle_listing_controller.dart';
import 'package:multifleet/models/vehicle.dart';

class ExpiryDetailsController extends GetxController {
  var vehicleCon = Get.find<VehicleListingController>();
  // Filter options
  final expiryTypeOptions = ['All', 'Insurance', 'Mulkiya', 'Service'].obs;
  final selectedExpiryType = 'All'.obs;

  final timeframeOptions =
      ['All', 'This Month', 'Next Month', '3 Months', '6 Months'].obs;
  final selectedTimeframe = 'All'.obs;

  RxList<String> vehicleTypeOptions = <String>[].obs;
  final selectedVehicleType = 'All'.obs;

  // Data
  final vehiclesList = RxList<Vehicle>([]);
  final filteredVehiclesList = RxList<Vehicle>([]);
  final selectedVehicle = Rx<Vehicle?>(null);

  // For comparison view
  final showComparisonView = false.obs;
  final previousData = Rx<Vehicle?>(null);

  // Search
  final searchController = TextEditingController();
  final isSearching = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Load sample data
    vehicleTypeOptions.value = vehicleCon.getVehicleTypes();
    vehiclesList.value = vehicleCon.originalVehicles;
    // Initialize filtered list
    filteredVehiclesList.value = vehiclesList;

    // Add listeners for filtering
    ever(selectedExpiryType, (_) => applyFilters());
    ever(selectedTimeframe, (_) => applyFilters());
    ever(selectedVehicleType, (_) => applyFilters());
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void selectVehicle(Vehicle vehicle) {
    selectedVehicle.value = vehicle;
    // previousData.value = vehicle['previousRenewal'];
    showComparisonView.value = true;
  }

  void closeComparisonView() {
    showComparisonView.value = false;
    selectedVehicle.value = null;
    previousData.value = null;
  }

  void applyFilters() {
    List<Vehicle> result = List.from(vehiclesList);

    // Apply vehicle type filter
    if (selectedVehicleType.value != 'All') {
      result =
          result.where((v) => v.type == selectedVehicleType.value).toList();
    }

    // Apply timeframe filter
    if (selectedTimeframe.value != 'All') {
      DateTime now = DateTime.now();
      DateTime cutoffDate;

      switch (selectedTimeframe.value) {
        case 'This Month':
          cutoffDate = DateTime(now.year, now.month + 1, 1);
          break;
        case 'Next Month':
          cutoffDate = DateTime(now.year, now.month + 2, 1);
          break;
        case '3 Months':
          cutoffDate = DateTime(now.year, now.month + 3, 1);
          break;
        case '6 Months':
          cutoffDate = DateTime(now.year, now.month + 6, 1);
          break;
        default:
          cutoffDate = DateTime(now.year + 1, now.month, now.day);
      }

      // Filter based on expiry type - using the documents list
      if (selectedExpiryType.value == 'All') {
        // Check all document types
        result = result.where((v) {
          if (v.documents == null || v.documents!.isEmpty) return false;

          // Check if any document expires within the timeframe
          return v.documents!.any((doc) =>
              doc.expiryDate != null &&
              doc.expiryDate!.isAfter(now) &&
              doc.expiryDate!.isBefore(cutoffDate));
        }).toList();
      } else if (selectedExpiryType.value == 'Insurance') {
        // Filter insurance documents (docType 1001)
        result = result.where((v) {
          if (v.documents == null || v.documents!.isEmpty) return false;

          // Find insurance documents
          var insuranceDocs = v.documents!.where((doc) => doc.docType == 1001);
          if (insuranceDocs.isEmpty) return false;

          // Check if any insurance document expires within the timeframe
          return insuranceDocs.any((doc) =>
              doc.expiryDate != null &&
              doc.expiryDate!.isAfter(now) &&
              doc.expiryDate!.isBefore(cutoffDate));
        }).toList();
      } else if (selectedExpiryType.value == 'Mulkiya') {
        // Filter registration documents (docType 1002)
        result = result.where((v) {
          if (v.documents == null || v.documents!.isEmpty) return false;

          // Find registration documents
          var registrationDocs =
              v.documents!.where((doc) => doc.docType == 1002);
          if (registrationDocs.isEmpty) return false;

          // Check if any registration document expires within the timeframe
          return registrationDocs.any((doc) =>
              doc.expiryDate != null &&
              doc.expiryDate!.isAfter(now) &&
              doc.expiryDate!.isBefore(cutoffDate));
        }).toList();
      } else if (selectedExpiryType.value == 'Service') {
        // If you have a specific docType for service or handle it differently,
        // you would implement that logic here
        // For now, let's assume service is docType 1003
        result = result.where((v) {
          if (v.documents == null || v.documents!.isEmpty) return false;

          // Find service documents
          var serviceDocs = v.documents!.where((doc) => doc.docType == 1003);
          if (serviceDocs.isEmpty) return false;

          // Check if any service document expires within the timeframe
          return serviceDocs.any((doc) =>
              doc.expiryDate != null &&
              doc.expiryDate!.isAfter(now) &&
              doc.expiryDate!.isBefore(cutoffDate));
        }).toList();
      }
    } else {
      // If no timeframe filter, still apply expiry type filter
      if (selectedExpiryType.value == 'Insurance') {
        result = result
            .where((v) =>
                v.documents != null &&
                v.documents!.any(
                    (doc) => doc.docType == 1001 && doc.expiryDate != null))
            .toList();
      } else if (selectedExpiryType.value == 'Mulkiya') {
        result = result
            .where((v) =>
                v.documents != null &&
                v.documents!.any(
                    (doc) => doc.docType == 1002 && doc.expiryDate != null))
            .toList();
      } else if (selectedExpiryType.value == 'Service') {
        result = result
            .where((v) =>
                v.documents != null &&
                v.documents!.any(
                    (doc) => doc.docType == 1003 && doc.expiryDate != null))
            .toList();
      }
    }

    // Apply search if active
    if (isSearching.value && searchController.text.isNotEmpty) {
      final searchTerm = searchController.text.toLowerCase();
      result = result
          .where((v) =>
              (v.vehicleNo?.toLowerCase().contains(searchTerm) ?? false) ||
              (v.brand?.toLowerCase().contains(searchTerm) ?? false) ||
              (v.model?.toLowerCase().contains(searchTerm) ?? false) ||
              (v.chassisNo?.toLowerCase().contains(searchTerm) ?? false) ||
              (v.description?.toLowerCase().contains(searchTerm) ?? false))
          .toList();
    }

    filteredVehiclesList.value = result;
  }

  void search(String query) {
    isSearching.value = query.isNotEmpty;
    applyFilters();
  }

  void clearSearch() {
    searchController.clear();
    isSearching.value = false;
    applyFilters();
  }

String getExpiryStatus(DateTime? expiryDate) {
  if (expiryDate == null) return 'Unknown';
  
  final now = DateTime.now();
  final daysUntilExpiry = expiryDate.difference(now).inDays;
  
  if (daysUntilExpiry < 0) return 'Expired';
  if (daysUntilExpiry <= 30) return 'Soon';
  return 'Valid';
}

  Color getStatusColor(String status) {
    switch (status) {
      case 'Expired':
        return Colors.red;
      case 'Soon':
        return Colors.orange;
      case 'Valid':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
