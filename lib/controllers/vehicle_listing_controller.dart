import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multifleet/models/company.dart';
import 'package:multifleet/models/status_master/status_master.dart';
import 'package:multifleet/models/vehicle.dart';
import 'package:multifleet/repo/vehicles_repo.dart';
import 'package:multifleet/services/company_service.dart';

class VehicleListingController extends GetxController
    implements CompanyAwareController {
  final RxList<Vehicle> originalVehicles = <Vehicle>[].obs;
  final RxList<Vehicle> filteredVehicles = <Vehicle>[].obs;
  final Rx<Vehicle> selectedVehicle = Vehicle().obs;

  final RxBool _isSearchVisible = true.obs;
  bool get isSearchVisible => _isSearchVisible.value;
  // Search controller
  final TextEditingController searchController = TextEditingController();
  final companyService = Get.find<CompanyService>();

  // Filter options
  final selectedVehicleType = Rx<StatusMaster?>(null);

  final selectedVehicleStatus = Rx<StatusMaster?>(null);

  final RxBool showExpiringSoon = false.obs;

  //loadings
  var isLoading = false.obs;
  var dialogueLoading = false.obs;

  @override
  void onInit() async {
    super.onInit();
    // Register this controller with the company service
    companyService.registerController(this);
    // Initial data load happens when company service calls onCompanyChanged
    // or can be explicitly triggered if needed
    if (companyService.selectedCompany != null) {
      await getComprehensiveVehicleData();
    }
  }

  @override
  void onClose() {
    // Unregister this controller when it's closed
    companyService.unregisterController(this);
    searchController.dispose();
    super.onClose();
  }

  @override
  Future<void> onCompanyChanged(Company newCompany) async {
    originalVehicles.clear();
    filteredVehicles.clear();

    // Reload data with the new company
    getComprehensiveVehicleData();
  }

  // New function to get comprehensive vehicle data
  Future<void> getComprehensiveVehicleData() async {
    isLoading.value = true;
    try {
      // Get the basic vehicle details first
      await getVehicles();

      if (originalVehicles.isNotEmpty) {
        filteredVehicles.value = List.from(originalVehicles);
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
        originalVehicles.value = vehicles;
        filteredVehicles.value = List.from(originalVehicles);
      });
    } on Exception catch (e) {
      log(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

// fetch and attach documents and tyre for all vehcles in vehilcle map
  Future<void> fetchAndAttachDocumentsAndTyres(Vehicle vehicle) async {
    dialogueLoading.value = true;
    selectedVehicle.value = vehicle;
    try {
      // Fetch documents
      await fetchAndAttachDocuments(selectedVehicle.value);
      log("Docs Attached: ${json.encode(selectedVehicle.value)}");

      // Fetch tyres
      await fetchAndAttachTyres(selectedVehicle.value);
      log("Tyres Attached: ${json.encode(selectedVehicle.value)}");
    } catch (e) {
      log('Exception in fetchAndAttachDocumentsAndTyres: ${e.toString()}');
    } finally {
      dialogueLoading.value = false;
    }
  }

  // Helper function to fetch and attach documents
  Future<void> fetchAndAttachDocuments(Vehicle vehicle) async {
    try {
      // Assuming you have a repository method to get documents for all vehicles or by company
      var result = await VehiclesRepo().getVehicleDocument(
          company: '${companyService.selectedCompanyObs.value?.id}',
          vehicleNo: vehicle.vehicleNo!);

      result.fold((error) {
        log('Error fetching vehicle documents: $error');
      }, (documents) {
        selectedVehicle.value.documents = documents;
      });
    } catch (e) {
      log('Exception in fetchAndAttachDocuments: ${e.toString()}');
    }
  }

  // Helper function to fetch and attach tyres
  Future<void> fetchAndAttachTyres(Vehicle vehicle) async {
    log("vehicleMap");
    try {
      // Assuming you have a repository method to get tyres for all vehicles or by company
      var result = await VehiclesRepo().getAllVehicleTyres(
          company: companyService.selectedCompanyObs.value!.id!,
          vehicleNumber: vehicle.vehicleNo!);
      log(result.toString());

      result.fold((error) {
        log('Error fetching vehicle tyres: $error');
      }, (tyres) {
        selectedVehicle.value.tyres = tyres;
      });
    } catch (e) {
      log('Exception in fetchAndAttachTyres: ${e.toString()}');
    }
  }

  void toggleSearchVisible() {
    _isSearchVisible.value = !_isSearchVisible.value;
  }

  // Clear all filters
  void clearFilters() {
    selectedVehicleType.value = null;
    selectedVehicleStatus.value = null;
    showExpiringSoon.value = false;
    searchController.clear();
    filteredVehicles.value = List.from(originalVehicles);
    update();
  }

  // Search method
  void searchVehicles(String query) {
    if (query.isEmpty) {
      filteredVehicles.value = List.from(originalVehicles);
    } else {
      filteredVehicles.value = originalVehicles.where((vehicle) {
        final queryLower = query.toLowerCase();
        return vehicle.brand.toString().toLowerCase().contains(queryLower) ||
            vehicle.model.toString().toLowerCase().contains(queryLower) ||
            vehicle.vehicleNo.toString().toLowerCase().contains(queryLower) ||
            vehicle.chassisNo.toString().toLowerCase().contains(queryLower) ||
            vehicle.traficFileNo.toString().toLowerCase().contains(queryLower);
      }).toList();
      update();
    }
    applyFilters();
  }

  // Toggle expiring soon filter
  void toggleExpiringSoonFilter(bool value) {
    showExpiringSoon.value = value;
    applyFilters();
  }

  // Apply all filters
  void applyFilters() {
    List<Vehicle> tempVehicles = List.from(originalVehicles);

    // Apply all filters sequentially

    // 1. Filter by vehicle type
    if (selectedVehicleType.value?.status != null) {
      tempVehicles = tempVehicles
          .where((vehicle) =>
              vehicle.type == selectedVehicleType.value?.status ||
              (vehicle.type == null && selectedVehicleType.value == null))
          .toList();
    }

    // 2. Filter by status (null means "All")
    if (selectedVehicleStatus.value != null) {
      tempVehicles = tempVehicles
          .where((vehicle) =>
              vehicle.status == selectedVehicleStatus.value?.status)
          .toList();
    }

    // 3. Filter by expiring soon (checks vehicle documents)
    if (showExpiringSoon.value) {
      final now = DateTime.now();
      tempVehicles = tempVehicles.where((vehicle) {
        final docs = vehicle.documents;
        if (docs == null || docs.isEmpty) return false;

        return docs.any((doc) {
          if (doc.expiryDate == null) return false;
          final daysUntilExpiry = doc.expiryDate!.difference(now).inDays;
          return daysUntilExpiry <= 90;
        });
      }).toList();
    }

    // 4. Apply search text filter
    if (searchController.text.isNotEmpty) {
      final queryLower = searchController.text.toLowerCase().trim();

      tempVehicles = tempVehicles.where((vehicle) {
        // Safely handle null values for all fields
        final brand = vehicle.brand?.toString().toLowerCase() ?? '';
        final model = vehicle.model?.toString().toLowerCase() ?? '';
        final vehicleNo = vehicle.vehicleNo?.toString().toLowerCase() ?? '';
        final chassisNo = vehicle.chassisNo?.toString().toLowerCase() ?? '';
        final trafficFileNo =
            vehicle.traficFileNo?.toString().toLowerCase() ?? '';

        // Check if any field contains the search query
        return brand.contains(queryLower) ||
            model.contains(queryLower) ||
            vehicleNo.contains(queryLower) ||
            chassisNo.contains(queryLower) ||
            trafficFileNo.contains(queryLower);
      }).toList();
    }

    // Update the filtered vehicles list
    filteredVehicles.value = tempVehicles;

    // No results case
    if (filteredVehicles.isEmpty && originalVehicles.isNotEmpty) {
      // You could set a flag here to show a "No results" message
      // noResultsFound.value = true;
    } else {
      // noResultsFound.value = false;
    }

    // Notify listeners that the UI should update
    update();
  }

  Future<Vehicle?> getVehicleByNo(String vehicleNo) async {
    Vehicle? vehicle;

    // Check if the vehicles data is already loaded
    if (originalVehicles.isNotEmpty) {
      // Try to find the vehicle by its number
      try {
        vehicle = originalVehicles.firstWhere(
          (element) => element.vehicleNo == vehicleNo,
        );
      } catch (e) {
        // Vehicle not found in the list
        vehicle = null;
      }
    } else {
      // If no vehicles are loaded, get the comprehensive data first
      await getComprehensiveVehicleData();

      // Now try to find the vehicle after data is loaded
      if (originalVehicles.isNotEmpty) {
        try {
          vehicle = originalVehicles.firstWhere(
            (element) => element.vehicleNo == vehicleNo,
          );
        } catch (e) {
          // Vehicle not found after loading data
          vehicle = null;
        }
      }
    }

    return vehicle;
  }
}
