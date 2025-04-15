import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multifleet/models/vehicle.dart';
import 'package:multifleet/repo/vehicles_repo.dart';

import '../models/tire.dart';
import '../models/vehicle_docs.dart';

class VehicleListingController extends GetxController {
  final RxList<Vehicle> originalVehicles = <Vehicle>[].obs;
  final RxList<Vehicle> filteredVehicles = <Vehicle>[].obs;
  final RxBool _isSearchVisible = true.obs;
  bool get isSearchVisible => _isSearchVisible.value;
  // Search controller
  final TextEditingController searchController = TextEditingController();

  // Filter options
  final RxString selectedVehicleType = 'All'.obs;
  final RxBool showExpiringSoon = false.obs;

  //loadings
  var isLoading = false.obs;

  @override
  void onInit() async {
    super.onInit();
    // Initialize vehicles
    await getComprehensiveVehicleData();
  }

  Future<void> getVehicles() async {
    isLoading.value = true;
    try {
      var result = await VehiclesRepo().getAllVehicles(company: 'EPIC01');
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

  // New function to get comprehensive vehicle data
  Future<void> getComprehensiveVehicleData() async {
    isLoading.value = true;
    try {
      // Get the basic vehicle details first
      await getVehicles();

      if (originalVehicles.isNotEmpty) {
        // Create a map to easily find vehicles by vehicleNo
        Map<String?, Vehicle> vehicleMap = {};
        for (var vehicle in originalVehicles) {
          if (vehicle.vehicleNo != null) {
            vehicleMap[vehicle.vehicleNo] = vehicle;
          }
        }

        // Fetch documents for each vehicle
        await fetchAndAttachDocuments(vehicleMap);

        // Fetch tires for each vehicle
        await fetchAndAttachTires(vehicleMap);

        // Update the original and filtered lists with the enhanced vehicles
        originalVehicles.value = vehicleMap.values.toList();
        filteredVehicles.value = List.from(originalVehicles);
        log(json.encode(filteredVehicles));
      }
    } on Exception catch (e) {
      log('Error getting comprehensive vehicle data: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Helper function to fetch and attach documents
  Future<void> fetchAndAttachDocuments(Map<String?, Vehicle> vehicleMap) async {
    try {
      // Assuming you have a repository method to get documents for all vehicles or by company
      var result =
          await VehiclesRepo().getAllVehicleDocument(company: 'EPIC01');

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

  // Helper function to fetch and attach tires
  Future<void> fetchAndAttachTires(Map<String?, Vehicle> vehicleMap) async {
    try {
      // Assuming you have a repository method to get tires for all vehicles or by company
      var result =
          await VehiclesRepo().getAllVehicleTires(vehicleNumber: 'EPIC01');

      result.fold((error) {
        log('Error fetching vehicle tires: $error');
      }, (tires) {
        // Group tires by vehicleNo
        Map<String?, List<Tire>> tiresByVehicle = {};

        for (var tire in tires) {
          if (tire.vehicleNo != null) {
            tiresByVehicle.putIfAbsent(tire.vehicleNo, () => []);
            tiresByVehicle[tire.vehicleNo]!.add(tire);
          }
        }

        // Attach tires to corresponding vehicles
        tiresByVehicle.forEach((vehicleNo, vehicleTires) {
          if (vehicleMap.containsKey(vehicleNo)) {
            vehicleMap[vehicleNo] =
                vehicleMap[vehicleNo]!.withTires(vehicleTires);
          }
        });
      });
    } catch (e) {
      log('Exception in fetchAndAttachTires: ${e.toString()}');
    }
  }

  void toggleSearchVisible() {
    _isSearchVisible.value = !_isSearchVisible.value;
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

  // Filter vehicles by type
  void filterByVehicleType(String type) {
    selectedVehicleType.value = type;
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
    if (selectedVehicleType.value != 'All') {
      tempVehicles = tempVehicles
          .where((vehicle) =>
              vehicle.type == selectedVehicleType.value ||
              (vehicle.type == null && selectedVehicleType.value.isEmpty))
          .toList();
    }

    // 2. Filter by expiring soon
    if (showExpiringSoon.value) {
      tempVehicles = tempVehicles.where((vehicle) {
        // Safely parse dates (handle potential null or invalid date values)
        DateTime? mulkiyaExpiry;
        DateTime? insuranceExpiry;

        try {
          // Handle different date formats or null values appropriately
          // if (vehicle.mulkiyaExpiry != null &&
          //     vehicle.mulkiyaExpiry!.isNotEmpty) {
          //   mulkiyaExpiry = DateTime.parse(vehicle.mulkiyaExpiry!);
          // }

          // if (vehicle.insuranceExpiry != null &&
          //     vehicle.insuranceExpiry!.isNotEmpty) {
          //   insuranceExpiry = DateTime.parse(vehicle.insuranceExpiry!);
          // }
        } catch (e) {
          // If date parsing fails, assume it's not expiring soon
          return false;
        }

        // Calculate days remaining if dates are valid
        final now = DateTime.now();
        final daysToMulkiya = mulkiyaExpiry != null
            ? mulkiyaExpiry.difference(now).inDays
            : 999; // Large number if no date

        final daysToInsurance = insuranceExpiry != null
            ? insuranceExpiry.difference(now).inDays
            : 999; // Large number if no date

        // Show if either is expiring within 90 days
        return daysToMulkiya <= 90 || daysToInsurance <= 90;
      }).toList();
    }

    // 3. Apply search text filter
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

  // Get unique vehicle types for filter dropdown
  List<String> getVehicleTypes() {
    // Start with "All" as the first option
    final List<String> types = ["All"];

    // Add unique vehicle types from your data
    if (originalVehicles.isNotEmpty) {
      final uniqueTypes = originalVehicles
          .map((vehicle) => vehicle.type ?? "")
          .where((type) => type.isNotEmpty)
          .toSet()
          .toList();

      types.addAll(uniqueTypes);
    }

    return types;
  }
}
