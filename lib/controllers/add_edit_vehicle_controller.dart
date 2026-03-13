import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:multifleet/controllers/general_masters.dart';
import 'package:multifleet/controllers/loading_controller.dart';
import 'package:multifleet/controllers/vehicle_listing_controller.dart';
import 'package:multifleet/models/fuel_station/fuel_station.dart';
import 'package:multifleet/models/status_master/status_master.dart';
import 'package:multifleet/models/vehicle.dart';
import 'package:multifleet/repo/vehicles_repo.dart';
import 'package:multifleet/services/company_service.dart';
import 'package:multifleet/widgets/custom_widgets.dart';
import 'dart:math' as math;

import '../models/city/city.dart';
import '../models/company.dart';
import '../models/doc_master.dart';
import '../models/tyre.dart';
import '../models/vehicle_docs.dart';
import '../models/vehicle_image.dart';
import '../views/add_vehicle.dart';

// GetX Controller for vehicle management
class AddEditVehicleController extends GetxController
    implements CompanyAwareController {
  var vehicleCon = Get.find<VehicleListingController>();
  var genCon = Get.find<GeneralMastersController>();
  var loadingCon = Get.find<LoadingController>();
  var companyService = Get.find<CompanyService>();
  // Text controllers for search and create vehicle
  final plateNumberController = TextEditingController();
  final createPlateNumberController = TextEditingController();
  final createBrandController = TextEditingController();
  final createModelController = TextEditingController();
  final createChassisNumberController = TextEditingController();
  final createTrafficFileNumberController = TextEditingController();
  final createCompanyController = TextEditingController();
  final createDescriptionController = TextEditingController();
  final RxList<VehicleDocument> vehicleDocuments = <VehicleDocument>[].obs;
  // Document controllers
  final RxList<TextEditingController> createDocumentIssueDateControllers =
      <TextEditingController>[].obs;
  final RxList<TextEditingController> createDocumentExpiryControllers =
      <TextEditingController>[].obs;
  final RxList<TextEditingController> createDocumentIssueAuthorityControllers =
      <TextEditingController>[].obs;
  final RxList<TextEditingController> createDocumentTypesControllers =
      <TextEditingController>[].obs;
  final RxList<TextEditingController> createDocumentRemarksControllers =
      <TextEditingController>[].obs;
  final RxList<TextEditingController> createDocumentAmountControllers =
      <TextEditingController>[].obs;
  // new tyres
  final RxList<TextEditingController> tyreBrandControllers =
      <TextEditingController>[].obs;
  final RxList<TextEditingController> tyreSizeControllers =
      <TextEditingController>[].obs;
  final RxList<TextEditingController> tyreKmControllers =
      <TextEditingController>[].obs;
  final RxList<TextEditingController> tyreRemarksControllers =
      <TextEditingController>[].obs;
  final RxList<TextEditingController> tyreInstallDateControllers =
      <TextEditingController>[].obs;
  // Images list
  final RxList<VehicleImage> vehicleImages = <VehicleImage>[].obs;

// Primary image index
  final RxInt primaryImageIndex = 0.obs;

// Image picker instance
  final ImagePicker _imagePicker = ImagePicker();
  // Check if running on web
  bool get isWeb => kIsWeb;

  // Additional text controllers that were previously in the extension
  final yearController = TextEditingController();
  final initialOdoController = TextEditingController();
  final currentOdoController = TextEditingController();
  final descriptionController = TextEditingController();
  final typeController = TextEditingController();
  final selectedPermittedAreas = <String>[].obs;
  final fuelStationController = TextEditingController();
  final insuranceExpiryController = TextEditingController();
  final mulkiyaExpiryController = TextEditingController();
  final Map<String, Map<int, TextEditingController>> tyreControllers = {};

// Controllers for document expiry dates
  final RxList<TextEditingController> documentExpiryControllers =
      <TextEditingController>[].obs;

  // Observable values for dropdowns
  final selectedCompanyCreate = Rx<Company?>(null);
  final selectedVehicleTypeCreate = Rx<StatusMaster?>(null);
  final selectedInsuranceTypeCreate = Rx<String?>(null);
  final selectedConditionCreate = Rx<StatusMaster?>(null);
  final selectedStatusCreate = Rx<StatusMaster?>(null);
  final selectedCitiesCreate = <City>[].obs;
  final selectedFuelStationCreate = Rx<FuelStation?>(null);

  // Tyre list for new vehicle
  final tyresList = <Tyre>[].obs;
  // Tyre filter/view state
  final showActiveTyresOnly = false.obs;
  final tyreListView = false.obs; // false = grid, true = compact list

  void toggleTyreViewMode() => tyreListView.value = !tyreListView.value;
  int get activeTyreCount =>
      vehicleData.value?.tyres?.where((t) => t.status == 'Active').length ?? 0;

  int maxTyresAllowed = 8;
  int tyresAllowedleft = 0;

  // Form step tracking
  final currentStep = 0.obs;

  // Observable variables
  final isSearching = false.obs;
  final vehicleData = Rx<Vehicle?>(null);

  @override
  void onInit() {
    companyService.registerController(this);
    initializeSuggestions();
    super.onInit();
  }

  @override
  void onClose() {
    // Dispose controllers
    plateNumberController.dispose();
    createPlateNumberController.dispose();
    createBrandController.dispose();
    createModelController.dispose();
    createChassisNumberController.dispose();
    createTrafficFileNumberController.dispose();
    createCompanyController.dispose();
    yearController.dispose();
    initialOdoController.dispose();
    currentOdoController.dispose();
    typeController.dispose();
    fuelStationController.dispose();
    insuranceExpiryController.dispose();
    mulkiyaExpiryController.dispose();
    // Dispose all tyre controllers
    for (var controllerMap in tyreControllers.values) {
      for (var controller in controllerMap.values) {
        controller.dispose();
      }
    }
    for (var controller in tyreBrandControllers) {
      controller.dispose();
    }
    for (var controller in tyreSizeControllers) {
      controller.dispose();
    }
    for (var controller in tyreKmControllers) {
      controller.dispose();
    }
    for (var controller in tyreRemarksControllers) {
      controller.dispose();
    }
    for (var controller in tyreInstallDateControllers) {
      controller.dispose();
    }
    companyService.unregisterController(this);
    super.onClose();
  }

  @override
  Future<void> onCompanyChanged(Company newCompany) async {
    clearSearch();
    clearAllTyreControllers();
    resetFormState();
    initializeSuggestions();
  }

// Get or create a controller for a specific tyre field
  TextEditingController getTyreFieldController(
      int tyreIndex, String fieldName, String initialValue) {
    // Initialize the map for this tyre index if it doesn't exist
    tyreControllers[fieldName] ??= {};

    // Create a new controller if it doesn't exist for this field and tyre
    if (!tyreControllers[fieldName]!.containsKey(tyreIndex)) {
      tyreControllers[fieldName]![tyreIndex] =
          TextEditingController(text: initialValue);
    } else {
      // If value changed from elsewhere, update the controller
      if (tyreControllers[fieldName]![tyreIndex]!.text != initialValue) {
        tyreControllers[fieldName]![tyreIndex]!.text = initialValue;
      }
    }

    return tyreControllers[fieldName]![tyreIndex]!;
  }

// Clear controllers for a specific tyre
  void clearTyreControllers(int tyreIndex) {
    for (var controllers in tyreControllers.values) {
      controllers.remove(tyreIndex);
    }
  }

// Clear all tyre controllers
  void clearAllTyreControllers() {
    tyreControllers.clear();
  }

  void onPlateChanged(String? letter, String? emirate, String? number) {
    // sometimes letter will be null, that time set only number without -
    if (letter == null) {
      plateNumberController.text = '$number';
    } else {
      plateNumberController.text = '$letter-$number';
    }
    log(plateNumberController.text);
  }

  Future<void> searchVehicle() async {
    try {
      isSearching.value = true;
      vehicleData.value = null;

      if (plateNumberController.text.isNotEmpty) {
        var res2 = await VehiclesRepo().getAllVehicles(
            company: '${companyService.selectedCompanyObs.value?.id}',
            query: plateNumberController.text);

        await res2.fold((error) {
          log(error);
          CustomWidget.customSnackBar(
              title: 'Error',
              message: 'Failed to search vehicle: $error',
              isError: true);
        }, (vehicles) async {
          log(vehicles.toString());

          if (vehicles.isNotEmpty) {
            // Found a vehicle, now fetch and attach its documents and tyres
            Vehicle foundVehicle = vehicles.first;
            // update changables
            currentOdoController.text = foundVehicle.initialOdo.toString();
            selectedConditionCreate.value = genCon.vehicleConditionMasters
                .firstWhereOrNull(
                    (condition) => foundVehicle.condition == condition.status);
            selectedFuelStationCreate.value = genCon.availableFuelStations
                .firstWhereOrNull((station) =>
                    foundVehicle.fuelStationId == station.fuelStationId);
            selectedStatusCreate.value = genCon.vehicleStatusMasters
                .firstWhereOrNull(
                    (status) => foundVehicle.status == status.status);
            descriptionController.text = foundVehicle.description.toString();
            update();

            // Fetch documents
            await fetchAndAttachDocumentsForVehicle(foundVehicle);

            // Fetch tyres
            await fetchAndAttachTyresForVehicle(foundVehicle);

            // Update the vehicle data with the augmented vehicle
            vehicleData.value = foundVehicle;
            log(vehicleData.value.toString());
          } else {
            showCreateVehicleDialog();
          }
        });
      } else {
        CustomWidget.customSnackBar(
            title: 'Error',
            message: 'Please enter a plate number',
            isError: true);
      }
    } catch (e) {
      log('Exception in searchVehicle: ${e.toString()}');
      CustomWidget.customSnackBar(
          title: 'Error',
          message: 'An unexpected error occurred',
          isError: true);
    } finally {
      isSearching.value = false;
    }
  }

// Updated helper function to fetch and attach documents for a single vehicle
  Future<void> fetchAndAttachDocumentsForVehicle(Vehicle vehicle) async {
    try {
      // Get vehicle number or return if null
      final vehicleNo = vehicle.vehicleNo;
      if (vehicleNo == null) return;

      // Fetch documents for this specific vehicle
      var result = await VehiclesRepo().getVehicleDocument(
          company: '${companyService.selectedCompanyObs.value?.id}',
          vehicleNo: vehicleNo);
      result.fold((error) {
        log('Error fetching vehicle documents: $error');
      }, (documents) {
        // Attach documents directly to the vehicle
        vehicle.documents = documents;
      });
    } catch (e) {
      log('Exception in fetchAndAttachDocumentsForVehicle: ${e.toString()}');
    }
  }

  // Computed getter for filtered tyres
  List<Tyre> get filteredTyres {
    final tyres = vehicleData.value?.tyres ?? [];
    if (showActiveTyresOnly.value) {
      return tyres.where((t) => t.status == 'Active').toList();
    }
    return tyres;
  }

  void toggleTyreFilter() {
    showActiveTyresOnly.value = !showActiveTyresOnly.value;
  }

// Updated helper function to fetch and attach tyres for a single vehicle
  Future<void> fetchAndAttachTyresForVehicle(Vehicle vehicle) async {
    try {
      // Get vehicle number or return if null
      final vehicleNo = vehicle.vehicleNo;
      if (vehicleNo == null) return;

      // Fetch tyres for this specific vehicle
      var result = await VehiclesRepo().getAllVehicleTyres(
          company: companyService.selectedCompanyObs.value!.id!,
          vehicleNumber: vehicleNo);

      result.fold((error) {
        log('Error fetching vehicle tyres: $error');
      }, (tyres) {
        log(tyres.toString());
        // Attach tyres directly to the vehicle
        vehicle.tyres = tyres;
        // get the number active tyres.
        // only 6 active tyre are allowed. in active tyres can be n number.
        // so calculate maxtyres allowed based on active tyres.
        tyresAllowedleft = maxTyresAllowed -
            tyres.where((tyre) => tyre.status == 'Active').length;
        update();
      });
    } catch (e) {
      log('Exception in fetchAndAttachTyresForVehicle: ${e.toString()}');
    }
  }

  // Update vehicle status
  void updateVehicleStatus(StatusMaster? status) {
    selectedStatusCreate.value = status;
    if (vehicleData.value != null) {
      vehicleData.value = vehicleData.value!.copyWith(
        vehicleStatusId: status?.statusId,
        status: status?.status,
      );
    }
  }

// Update vehicle description
  void updateVehicleDescription(String description) {
    if (vehicleData.value != null) {
      final updatedVehicle =
          vehicleData.value!.copyWith(description: description);
      vehicleData.value = updatedVehicle;
    }
  }

  // Update vehicle current odometer
  void updateCurrentOdometer(String odometer) {
    if (vehicleData.value != null) {
      final updatedVehicle =
          vehicleData.value!.copyWith(currentOdo: int.parse(odometer));
      vehicleData.value = updatedVehicle;
    }
  }

  void updateVehicleCity(List<City> cities) {
    selectedCitiesCreate.value = cities;
    if (vehicleData.value != null) {
      final updatedVehicle = vehicleData.value!.copyWith(
        cityIds: cities.map((c) => c.cityId).whereType<int>().toList(),
        cities: cities,
      );
      vehicleData.value = updatedVehicle;
    }
  }

  void updateVehicleCondition(StatusMaster? condition) {
    selectedConditionCreate.value = condition;
    if (vehicleData.value != null) {
      vehicleData.value = vehicleData.value!.copyWith(
        conditionId: condition?.statusId,
        condition: condition?.status,
      );
    }
  }

  void updateFuelStation(FuelStation? fuelStation) {
    selectedFuelStationCreate.value = fuelStation;
    if (vehicleData.value != null) {
      vehicleData.value = vehicleData.value!.copyWith(
        fuelStationId: fuelStation?.fuelStationId,
        fuelStation: fuelStation?.fuelStation,
      );
    }
  }

  // Helper method to get currently selected City objects from vehicle data.
  // Priority: user-edited selection → resolved cities → resolve from cityIds.
  List<City> getSelectedCities() {
    if (selectedCitiesCreate.isNotEmpty) {
      return selectedCitiesCreate;
    }
    if (vehicleData.value?.cities != null &&
        vehicleData.value!.cities!.isNotEmpty) {
      return vehicleData.value!.cities!;
    }
    // Fall back: resolve from cityIds against the master city list.
    final ids = vehicleData.value?.cityIds;
    if (ids != null && ids.isNotEmpty) {
      final genCon = Get.find<GeneralMastersController>();
      return genCon.companyCity.where((c) => ids.contains(c.cityId)).toList();
    }
    return [];
  }

  /// Adds a blank new tyre to the list and returns its index,
  /// or -1 if the cap is already reached.
  int addNewTyre() {
    final currentTyres = vehicleData.value?.tyres?.toList() ?? [];

    if (activeTyreCount >= maxTyresAllowed) return -1;

    Tyre newTyre = Tyre(
      company: companyService.selectedCompanyObs.value!.id!,
      tyreId: 0,
      vehicleNo: vehicleData.value!.vehicleNo!,
      position: _getNextTyrePosition(currentTyres),
      brand: '',
      size: '',
      kmUsed: 0,
      installDt: null,
      createdDt: DateTime.now(),
      deleteAllowed: true,
      status: 'Active',
      remarks: '',
      expDt: null,
    );

    currentTyres.add(newTyre);
    update();
    log(currentTyres.toString());

    final updatedVehicle = vehicleData.value?.copyWith(tyres: currentTyres);
    vehicleData.value = updatedVehicle;

    return currentTyres.length - 1;
  }

// Helper method to determine the next tyre position from the master list.
  // Always returns a non-null position: first tries a free slot, then falls
  // back to the first master entry so position is never null.
  StatusMaster? _getNextTyrePosition(List<Tyre> tyres) {
    final masterPositions = genCon.tirePositionMaster;
    if (masterPositions.isEmpty) return null;

    final takenIds =
        tyres.map((t) => t.position?.statusId).whereType<int>().toSet();

    return masterPositions.firstWhereOrNull(
          (p) => p.statusId != null && !takenIds.contains(p.statusId),
        ) ??
        masterPositions.last;
  }

  void removeTyre(int index) {
    final currentTyres = vehicleData.value?.tyres?.toList() ?? [];
    if (index >= 0 && index < currentTyres.length) {
      currentTyres.removeAt(index);

      // Update the vehicle data
      final updatedVehicle = vehicleData.value?.copyWith(tyres: currentTyres);
      vehicleData.value = updatedVehicle;
    }
  }

  void updateTyreBrand(int index, String brand) {
    final currentTyres = vehicleData.value?.tyres?.toList() ?? [];
    if (index >= 0 && index < currentTyres.length) {
      // Update tyre with new brand
      currentTyres[index] = currentTyres[index].copyWith(brand: brand);

      // Update the vehicle data
      final updatedVehicle = vehicleData.value?.copyWith(tyres: currentTyres);
      vehicleData.value = updatedVehicle;
    }
  }

  void updateTyreSize(int index, String size) {
    final currentTyres = vehicleData.value?.tyres?.toList() ?? [];
    if (index >= 0 && index < currentTyres.length) {
      // Update tyre with new size
      currentTyres[index] = currentTyres[index].copyWith(size: size);

      // Update the vehicle data
      final updatedVehicle = vehicleData.value?.copyWith(tyres: currentTyres);
      vehicleData.value = updatedVehicle;
    }
  }

  void updateTyreKm(int index, String kmStr) {
    final currentTyres = vehicleData.value?.tyres?.toList() ?? [];
    if (index >= 0 && index < currentTyres.length) {
      // Try to parse the KM value
      int? km;
      try {
        km = int.parse(kmStr);
      } catch (e) {
        log('Error parsing KM value: $e');
        return;
      }

      // Update tyre with new kmUsed
      currentTyres[index] = currentTyres[index].copyWith(kmUsed: km);

      // Update the vehicle data
      final updatedVehicle = vehicleData.value?.copyWith(tyres: currentTyres);
      vehicleData.value = updatedVehicle;
    }
  }

  void updateTyrePosition(int index, StatusMaster? position) {
    final currentTyres = vehicleData.value?.tyres?.toList() ?? [];
    if (index >= 0 && index < currentTyres.length) {
      currentTyres[index] = currentTyres[index].copyWith(position: position);
      final updatedVehicle = vehicleData.value?.copyWith(tyres: currentTyres);
      vehicleData.value = updatedVehicle;
    }
  }

  void updateTyreStatus(int index, String status) {
    final currentTyres = vehicleData.value?.tyres?.toList() ?? [];

    if (index >= 0 && index < currentTyres.length) {
      currentTyres[index] = currentTyres[index].copyWith(status: status);
      tyresAllowedleft = maxTyresAllowed -
          currentTyres.where((tyre) => tyre.status == 'Active').length;

      final updatedVehicle = vehicleData.value?.copyWith(tyres: currentTyres);
      vehicleData.value = updatedVehicle;
    }
  }

  void updateTyreInstallDate(int index, DateTime date) {
    final currentTyres = vehicleData.value?.tyres?.toList() ?? [];
    if (index >= 0 && index < currentTyres.length) {
      // Update tyre with new install date
      currentTyres[index] = currentTyres[index].copyWith(installDt: date);

      // Update the vehicle data
      final updatedVehicle = vehicleData.value?.copyWith(tyres: currentTyres);
      vehicleData.value = updatedVehicle;
    }
  }

  void updateTyreExpiryDate(int index, DateTime date) {
    final currentTyres = vehicleData.value?.tyres?.toList() ?? [];
    if (index >= 0 && index < currentTyres.length) {
      // Update tyre with new expiry date
      currentTyres[index] = currentTyres[index].copyWith(expDt: date);

      // Update the vehicle data
      final updatedVehicle = vehicleData.value?.copyWith(tyres: currentTyres);
      vehicleData.value = updatedVehicle;
    }
  }

  void updateTyreRemarks(int index, String remarks) {
    final currentTyres = vehicleData.value?.tyres?.toList() ?? [];
    if (index >= 0 && index < currentTyres.length) {
      // Update tyre with new remarks
      currentTyres[index] = currentTyres[index].copyWith(remarks: remarks);

      // Update the vehicle data
      final updatedVehicle = vehicleData.value?.copyWith(tyres: currentTyres);
      vehicleData.value = updatedVehicle;
    }
  }
// Add these methods to the AddEditVehicleController class

// Method to add a new document to the vehicle
  void addDocument(VehicleDocument newDocument) {
    if (vehicleData.value != null) {
      // Create a list of the current documents or an empty list if null
      List<VehicleDocument> currentDocs =
          vehicleData.value!.documents?.toList() ?? [];

      // Add the new document
      currentDocs.add(newDocument);

      // Update the vehicle data with the new documents list
      final updatedVehicle =
          vehicleData.value!.copyWith(documents: currentDocs);
      vehicleData.value = updatedVehicle;
    }
  }

// Method to update an existing document
  void updateDocument(
      VehicleDocument oldDocument, VehicleDocument updatedDocument) {
    if (vehicleData.value != null && vehicleData.value!.documents != null) {
      final currentDocs = vehicleData.value!.documents!.toList();

      // Find the index of the old document
      final index = currentDocs.indexWhere((doc) =>
          doc.docType == oldDocument.docType &&
          doc.issueDate == oldDocument.issueDate);

      if (index != -1) {
        // Replace the old document with the updated one
        currentDocs[index] = updatedDocument;

        // Update the vehicle data
        final updatedVehicle =
            vehicleData.value!.copyWith(documents: currentDocs);
        vehicleData.value = updatedVehicle;
      }
    }
  }

// Method to remove a document
  void removeDocument(VehicleDocument document) {
    if (vehicleData.value != null && vehicleData.value!.documents != null) {
      final currentDocs = vehicleData.value!.documents!.toList();

      // Remove the document
      currentDocs.removeWhere((doc) =>
          doc.docType == document.docType &&
          doc.issueDate == document.issueDate);

      // Update the vehicle data
      final updatedVehicle =
          vehicleData.value!.copyWith(documents: currentDocs);
      vehicleData.value = updatedVehicle;
    }
  }

// Helper method to check if a document type already exists
  bool hasDocumentOfType(int docType) {
    if (vehicleData.value != null && vehicleData.value!.documents != null) {
      return vehicleData.value!.documents!.any((doc) => doc.docType == docType);
    }
    return false;
  }

// Method to get the expiry status of a document
  String getExpiryStatus(DateTime? expiryDate) {
    if (expiryDate == null) return 'Unknown';

    final now = DateTime.now();
    final daysUntilExpiry = expiryDate.difference(now).inDays;

    if (daysUntilExpiry < 0) return 'Expired';
    if (daysUntilExpiry <= 30) return 'Expiring Soon';
    if (daysUntilExpiry <= 90) return 'Valid (< 3 months)';
    return 'Valid';
  }

// Method to get color based on expiry status
  Color getExpiryStatusColor(String status) {
    switch (status) {
      case 'Expired':
        return Colors.red;
      case 'Expiring Soon':
        return Colors.orange;
      case 'Valid (< 3 months)':
        return Colors.amber;
      case 'Valid':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

// Method to format a DateTime to a string
  String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Method to handle vehicle creation
  void createVehicle() {
    // Validate required fields
    if (validateCreateVehicleForm()) {
      // Perform vehicle creation logic
      // This would typically involve an API call or database insertion
      Get.back(); // Close the bottom sheet

      CustomWidget.customSnackBar(
        title: 'Success',
        message:
            'Vehicle ${createPlateNumberController.text} created successfully!',
        isError: false,
      );

      // Update the search with the new vehicle
      plateNumberController.text = createPlateNumberController.text;

      // Trigger search to show the newly created vehicle
      searchVehicle();
    }
  }

  // Validate create vehicle form
  bool validateCreateVehicleForm() {
    if (createPlateNumberController.text.isEmpty) {
      CustomWidget.customSnackBar(
          title: 'Error', message: 'Plate Number is required', isError: true);
      return false;
    }
    // Add more validation as needed
    return true;
  }

  void clearSearch() {
    plateNumberController.clear();
    vehicleData.value = null;
  }

// Add a new document to the list
  void addDocumentCreate(DocumentMaster docType) {
    // Create a new vehicle document from the document type
    final newDoc = VehicleDocument(
      company:
          vehicleData.value?.company, // Default company or from current context
      vehicleNo:
          vehicleData.value?.vehicleNo, // From current vehicle being edited
      docType: docType.docType,
      issueDate: DateTime.now(),
      expiryDate:
          DateTime.now().add(Duration(days: 365)), // Default 1 year validity
      issueAuthority: '',
      city: 'Dubai', // Default city
    );

    vehicleDocuments.add(newDoc);

    // Create and add controllers for the new document
    createDocumentIssueDateControllers.add(TextEditingController(
      text: newDoc.formatDate(newDoc.issueDate),
    ));

    documentExpiryControllers.add(TextEditingController(
      text: newDoc.formatDate(newDoc.expiryDate),
    ));

    createDocumentIssueAuthorityControllers.add(TextEditingController());
    createDocumentTypesControllers.add(TextEditingController());
    createDocumentRemarksControllers.add(TextEditingController());
    createDocumentAmountControllers.add(TextEditingController());
  }

// Remove document and associated controllers
  void removeDocumentCreate(int index) {
    vehicleDocuments.removeAt(index);

    // Dispose and remove controllers
    createDocumentIssueDateControllers[index].dispose();
    documentExpiryControllers[index].dispose();
    createDocumentIssueAuthorityControllers[index].dispose();
    createDocumentAmountControllers[index].dispose();

    createDocumentIssueDateControllers.removeAt(index);
    documentExpiryControllers.removeAt(index);
    createDocumentIssueAuthorityControllers.removeAt(index);
    createDocumentAmountControllers.removeAt(index);
  }

// Update document type
  void updateDocumentTypeCreate(int index, int docTypeId) {
    final currentDoc = vehicleDocuments[index];

    vehicleDocuments[index] = currentDoc.copyWith(
      docType: docTypeId,
    );
  }

// Update document issue authority
  void updateDocumentIssueAuthority(int index, String authority) {
    final currentDoc = vehicleDocuments[index];

    vehicleDocuments[index] = currentDoc.copyWith(
      issueAuthority: authority,
    );
  }

// Update document city
  void updateDocumentCity(int index, String? city) {
    if (city == null) return;

    final currentDoc = vehicleDocuments[index];

    vehicleDocuments[index] = currentDoc.copyWith(
      city: city,
    );
  }

  void updateDocumentRemarks(int index, String remarks) {
    final currentDoc = vehicleDocuments[index];

    vehicleDocuments[index] = currentDoc.copyWith(
      remarks: remarks,
    );
  }

  void updateDocumentAmount(int index, String amountText) {
    final currentDoc = vehicleDocuments[index];
    final amount = double.tryParse(amountText);
    vehicleDocuments[index] = currentDoc.copyWith(
      amount: amount,
    );
  }

// Parse date from controller text and update document
  void updateDocumentIssueDate(int index) {
    try {
      final dateText = createDocumentIssueDateControllers[index].text;
      final parts = dateText.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);

        final issueDate = DateTime(year, month, day);

        final currentDoc = vehicleDocuments[index];
        vehicleDocuments[index] = currentDoc.copyWith(
          issueDate: issueDate,
        );
      }
    } catch (e) {
      log('Error parsing issue date: $e');
    }
  }

// Parse date from controller text and update document
  void updateDocumentExpiryDate(int index) {
    try {
      final dateText = documentExpiryControllers[index].text;
      final parts = dateText.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);

        final expiryDate = DateTime(year, month, day);

        final currentDoc = vehicleDocuments[index];
        vehicleDocuments[index] = currentDoc.copyWith(
          expiryDate: expiryDate,
        );
      }
    } catch (e) {
      log('Error parsing expiry date: $e');
    }
  }

// Initialize controllers from existing documents during editing
  void initializeDocumentControllers() {
    // Clear any existing controllers
    for (var controller in createDocumentIssueDateControllers) {
      controller.dispose();
    }
    for (var controller in documentExpiryControllers) {
      controller.dispose();
    }
    for (var controller in createDocumentIssueAuthorityControllers) {
      controller.dispose();
    }
    for (var controller in createDocumentAmountControllers) {
      controller.dispose();
    }

    createDocumentIssueDateControllers.clear();
    documentExpiryControllers.clear();
    createDocumentIssueAuthorityControllers.clear();
    createDocumentAmountControllers.clear();

    // Create controllers for each document
    for (var doc in vehicleDocuments) {
      createDocumentIssueDateControllers.add(TextEditingController(
        text: doc.formatDate(doc.issueDate),
      ));

      documentExpiryControllers.add(TextEditingController(
        text: doc.formatDate(doc.expiryDate),
      ));

      createDocumentIssueAuthorityControllers.add(TextEditingController(
        text: doc.issueAuthority ?? '',
      ));

      createDocumentAmountControllers.add(TextEditingController(
        text: doc.amount != null ? doc.amount.toString() : '',
      ));
    }
  }

// Check if a document type is already added
  bool isDocumentTypeAlreadyAdded(DocumentMaster docType) {
    return vehicleDocuments.any((doc) => doc.docType == docType.docType);
  }

  /// Adds a new blank tyre to tyresList and returns its index, or -1 if cap reached.
  int createAddNewTyre() {
    if (tyresList.length >= maxTyresAllowed) return -1;

    final nextPosition = _getNextTyrePosition(tyresList.toList());
    final newTyre = Tyre(
      company: companyService.selectedCompanyObs.value!.id!,
      tyreId: 0,
      vehicleNo: createPlateNumberController.text,
      position: nextPosition,
      brand: '',
      size: '',
      kmUsed: 0,
      installDt: null,
      createdDt: DateTime.now(),
      deleteAllowed: true,
      status: 'Active',
      remarks: '',
      expDt: null,
    );
    tyresList.add(newTyre);

    // Keep legacy per-field controllers in sync (used by createRemoveTyre disposal)
    tyreBrandControllers.add(TextEditingController());
    tyreSizeControllers.add(TextEditingController());
    tyreKmControllers.add(TextEditingController(text: "0"));
    tyreRemarksControllers.add(TextEditingController());
    tyreInstallDateControllers.add(TextEditingController());

    return tyresList.length - 1;
  }

  void createRemoveTyre(int index) {
    if (index >= 0 && index < tyresList.length) {
      // Remove tyre from list
      tyresList.removeAt(index);

      // Dispose and remove controllers
      tyreBrandControllers[index].dispose();
      tyreSizeControllers[index].dispose();
      tyreKmControllers[index].dispose();
      tyreRemarksControllers[index].dispose();
      tyreInstallDateControllers[index].dispose();

      tyreBrandControllers.removeAt(index);
      tyreSizeControllers.removeAt(index);
      tyreKmControllers.removeAt(index);
      tyreRemarksControllers.removeAt(index);
      tyreInstallDateControllers.removeAt(index);
    }
  }

  void createUpdateTyreBrand(int index, String brand) {
    if (index >= 0 && index < tyresList.length) {
      final updatedTyre = tyresList[index].copyWith(brand: brand);
      tyresList[index] = updatedTyre;
    }
  }

  void createUpdateTyreSize(int index, String size) {
    if (index >= 0 && index < tyresList.length) {
      final updatedTyre = tyresList[index].copyWith(size: size);
      tyresList[index] = updatedTyre;
    }
  }

  void createUpdateTyrePosition(int index, StatusMaster? position) {
    if (index >= 0 && index < tyresList.length) {
      final updatedTyre = tyresList[index].copyWith(position: position);
      tyresList[index] = updatedTyre;
    }
  }

  void createUpdateTyreKm(int index, String km) {
    if (index >= 0 && index < tyresList.length) {
      int? kmUsed = int.tryParse(km);
      if (kmUsed != null) {
        final updatedTyre = tyresList[index].copyWith(kmUsed: kmUsed);
        tyresList[index] = updatedTyre;
      }
    }
  }

  void createUpdateTyreRemarks(int index, String remarks) {
    if (index >= 0 && index < tyresList.length) {
      final updatedTyre = tyresList[index].copyWith(remarks: remarks);
      tyresList[index] = updatedTyre;
    }
  }

  void createUpdateTyreInstallDate(int index, DateTime date) {
    if (index >= 0 && index < tyresList.length) {
      final updatedTyre = tyresList[index].copyWith(installDt: date);
      tyresList[index] = updatedTyre;
    }
  }

  void createUpdateTyreExpiryDate(int index, DateTime date) {
    if (index >= 0 && index < tyresList.length) {
      tyresList[index] = tyresList[index].copyWith(expDt: date);
    }
  }

  void createUpdateTyreStatus(int index, String status) {
    if (index >= 0 && index < tyresList.length) {
      tyresList[index] = tyresList[index].copyWith(status: status);
    }
  }

// Pick a single image with web support
  Future<void> pickSingleImage() async {
    if (vehicleImages.length >= 6) return;

    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      // Create a new vehicle image
      final newImage = VehicleImage(
        localPath: pickedFile.path, // This works for mobile
      );

      // For web, we need to read the file as bytes
      if (isWeb) {
        final bytes = await pickedFile.readAsBytes();
        newImage.webImage = bytes;
      }

      vehicleImages.add(newImage);
    }
  }

// Pick multiple images with web support
  Future<void> pickMultipleImages() async {
    if (vehicleImages.length >= 6) return;

    final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
      imageQuality: 80,
    );

    if (pickedFiles.isNotEmpty) {
      // Only add up to the maximum allowed
      int remainingSlots = 6 - vehicleImages.length;
      int filesToAdd = math.min(remainingSlots, pickedFiles.length);

      for (int i = 0; i < filesToAdd; i++) {
        // Create new vehicle image
        final newImage = VehicleImage(
          localPath: pickedFiles[i].path, // This works for mobile
        );

        // For web, we need to read the file as bytes
        if (isWeb) {
          final bytes = await pickedFiles[i].readAsBytes();
          newImage.webImage = bytes;
        }

        vehicleImages.add(newImage);
      }

      // Show toast if some images couldn't be added
      if (pickedFiles.length > remainingSlots) {
        Get.snackbar(
          'Maximum Images Reached',
          'Only added $filesToAdd out of ${pickedFiles.length} selected images',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

// Remove an image
  void removeImage(int index) {
    // Check if removing the primary image
    if (index == primaryImageIndex.value) {
      // If removing the primary image, set a new primary
      if (vehicleImages.length > 1) {
        // Set next image as primary, or the previous one if removing the last
        primaryImageIndex.value =
            index == vehicleImages.length - 1 ? index - 1 : index;
      } else {
        // If no images will be left, reset to 0
        primaryImageIndex.value = 0;
      }
    }
    // If removing an image before the primary, adjust the primary index
    else if (index < primaryImageIndex.value) {
      primaryImageIndex.value--;
    }

    vehicleImages.removeAt(index);
  }

// Set primary image
  void setPrimaryImage(int index) {
    if (index >= 0 && index < vehicleImages.length) {
      primaryImageIndex.value = index;
    }
  }

// Handle loading images from server when editing
  void loadImagesFromServer(List<String> imageUrls) {
    vehicleImages.clear();

    for (String url in imageUrls) {
      vehicleImages.add(VehicleImage(
        imageUrl: url,
        isNetworkImage: true,
      ));
    }

    primaryImageIndex.value = 0;
  }

// Reset all form fields and values
  void resetFormState() {
    // Reset text controllers
    createPlateNumberController.clear();
    createBrandController.clear();
    createModelController.clear();
    createChassisNumberController.clear();
    createTrafficFileNumberController.clear();
    createCompanyController.clear();
    yearController.clear();
    initialOdoController.clear();
    currentOdoController.clear();
    typeController.clear();
    fuelStationController.clear();
    insuranceExpiryController.clear();
    mulkiyaExpiryController.clear();
    selectedCompanyCreate.value = null;
    selectedVehicleTypeCreate.value = null;
    createDescriptionController.clear();

    // Reset dropdown values
    selectedInsuranceTypeCreate.value = null;
    selectedConditionCreate.value = null;
    selectedStatusCreate.value = null;
    selectedCitiesCreate.clear();
    selectedFuelStationCreate.value = null;

    // Reset step and tyres
    currentStep.value = 0;
    vehicleImages.clear();
    tyresList.clear();
    // reste documenmts
    vehicleDocuments.clear();
  }

  Future<void> createUpdateVehicle(
      {required Vehicle newVehicle, required bool isNew}) async {
    try {
      // Log the vehicle data for debugging

      log('Attempting to ${isNew ? 'Creating' : 'Updating'} vehicle: ${newVehicle.toString()}');

      // Start the loading indicator
      loadingCon.startLoading();

      // Call the repository method
      final res = await VehiclesRepo().createUpdateVehicle(newVehicle);

      res.fold((error) {
        // Failure case with valid response
        CustomWidget.customSnackBar(
          isError: true,
          title: 'Failed',
          message: error ??
              'Vehicle creation failed. Please verify the information and try again.',
        );
      }, (success) async {
        // Success case
        Get.back(); // Navigate back
        CustomWidget.customSnackBar(
          isError: false,
          title: 'Success',
          message: 'Vehicle ${isNew ? "Created" : "Updated"} successfully',
        );
        await searchVehicle();
      });
    } catch (e, stackTrace) {
      // Handle exceptions
      log('Exception during vehicle creation: $e');
      log('Stack trace: $stackTrace');

      // Show error message to user
      CustomWidget.customSnackBar(
        isError: true,
        title: 'Error',
        message: 'An unexpected error occurred. Please try again later.',
      );
    } finally {
      // Always stop the loading indicator, even if there's an error
      loadingCon.stopLoading();
    }
  }

  ////////// Debug

// function to populate test data
  void populateTestData() {
    // Basic Information Step
    if (companyService.companyList.isNotEmpty) {
      selectedCompanyCreate.value = companyService.selectedCompanyObs.value;
    }
    createPlateNumberController.text = createPlateNumberController.text;
    createBrandController.text = "Toyota";
    createModelController.text = "Land Cruiser";
    if (genCon.vehicleTypeMasters.isNotEmpty) {
      selectedVehicleTypeCreate.value = genCon.vehicleTypeMasters.first;
    }
    yearController.text = "2023";
    createDescriptionController.text = "Test vehicle for demo purposes";

    // Additional Details Step
    createChassisNumberController.text = "JTEBU5JR4B5046692";
    createTrafficFileNumberController.text = "TRF78945612";
    initialOdoController.text = "5000";
    currentOdoController.text = "7500";

    // Set some test permitted areas (use actual City objects from masters)
    if (genCon.companyCity.isNotEmpty) {
      selectedCitiesCreate.value = genCon.companyCity.take(2).toList();
    }

    // Set fuel station if available
    if (genCon.availableFuelStations.isNotEmpty) {
      selectedFuelStationCreate.value = genCon.availableFuelStations.first;
    }

    // Status & Documents Step
    if (genCon.vehicleConditionMasters.isNotEmpty) {
      selectedConditionCreate.value = genCon.vehicleConditionMasters.first;
    }
    if (genCon.vehicleStatusMasters.isNotEmpty) {
      selectedStatusCreate.value = genCon.vehicleStatusMasters.first;
    }

    // Add test documents if document types are available
    if (genCon.companyDocumentTypes.isNotEmpty) {
      // Add first document type
      final firstDocType = genCon.companyDocumentTypes[0];
      addDocumentCreate(firstDocType);

      // Set values for the first document
      if (createDocumentIssueDateControllers.isNotEmpty) {
        createDocumentIssueDateControllers[0].text = DateFormat('yyyy-MM-dd')
            .format(DateTime.now().subtract(Duration(days: 30)));
      }

      if (documentExpiryControllers.isNotEmpty) {
        documentExpiryControllers[0].text = DateFormat('yyyy-MM-dd')
            .format(DateTime.now().add(Duration(days: 335)));
      }

      if (createDocumentIssueAuthorityControllers.isNotEmpty) {
        createDocumentIssueAuthorityControllers[0].text = "Dubai RTA";
      }

      if (vehicleDocuments.isNotEmpty && genCon.companyCity.isNotEmpty) {
        updateDocumentCity(0, genCon.companyCity.first.city ?? '');
      }

      // Add second document type if available
      if (genCon.companyDocumentTypes.length > 1) {
        final secondDocType = genCon.companyDocumentTypes[1];
        addDocumentCreate(secondDocType);

        // Set values for the second document
        if (createDocumentIssueDateControllers.length > 1) {
          createDocumentIssueDateControllers[1].text = DateFormat('yyyy-MM-dd')
              .format(DateTime.now().subtract(Duration(days: 15)));
        }

        if (documentExpiryControllers.length > 1) {
          documentExpiryControllers[1].text = DateFormat('yyyy-MM-dd')
              .format(DateTime.now().add(Duration(days: 350)));
        }

        if (createDocumentIssueAuthorityControllers.length > 1) {
          createDocumentIssueAuthorityControllers[1].text =
              "Insurance Authority";
        }

        if (vehicleDocuments.length > 1 && genCon.companyCity.length > 1) {
          updateDocumentCity(1, genCon.companyCity[1].city ?? '');
        }
      }
    }

    // Tyres Step
    // Add first tyre
    createAddNewTyre();
    if (tyreBrandControllers.isNotEmpty) {
      tyreBrandControllers[0].text = "Bridgestone";
      createUpdateTyreBrand(0, "Bridgestone");
    }
    if (tyreSizeControllers.isNotEmpty) {
      tyreSizeControllers[0].text = "265/65R17";
      createUpdateTyreSize(0, "265/65R17");
    }
    if (tyreKmControllers.isNotEmpty) {
      tyreKmControllers[0].text = "2500";
      createUpdateTyreKm(0, "2500");
    }
    if (tyreRemarksControllers.isNotEmpty) {
      tyreRemarksControllers[0].text = "Front left tyre in good condition";
      createUpdateTyreRemarks(0, "Front left tyre in good condition");
    }
    // Helper: find a position master by name prefix
    StatusMaster? posByName(String name) => genCon.tirePositionMaster
        .firstWhereOrNull((p) => p.status?.contains(name) == true);

    if (tyresList.isNotEmpty) {
      createUpdateTyrePosition(0, posByName('Front Left'));
      createUpdateTyreInstallDate(
          0, DateTime.now().subtract(Duration(days: 60)));
    }

    // Add second tyre
    createAddNewTyre();
    if (tyreBrandControllers.length > 1) {
      tyreBrandControllers[1].text = "Michelin";
      createUpdateTyreBrand(1, "Michelin");
    }
    if (tyreSizeControllers.length > 1) {
      tyreSizeControllers[1].text = "265/65R17";
      createUpdateTyreSize(1, "265/65R17");
    }
    if (tyreKmControllers.length > 1) {
      tyreKmControllers[1].text = "3000";
      createUpdateTyreKm(1, "3000");
    }
    if (tyreRemarksControllers.length > 1) {
      tyreRemarksControllers[1].text = "Front right tyre replaced recently";
      createUpdateTyreRemarks(1, "Front right tyre replaced recently");
    }
    if (tyresList.length > 1) {
      createUpdateTyrePosition(1, posByName('Front Right'));
      createUpdateTyreInstallDate(
          1, DateTime.now().subtract(Duration(days: 30)));
    }

    // Add third tyre
    createAddNewTyre();
    if (tyreBrandControllers.length > 2) {
      tyreBrandControllers[2].text = "Goodyear";
      createUpdateTyreBrand(2, "Goodyear");
    }
    if (tyreSizeControllers.length > 2) {
      tyreSizeControllers[2].text = "265/65R17";
      createUpdateTyreSize(2, "265/65R17");
    }
    if (tyreKmControllers.length > 2) {
      tyreKmControllers[2].text = "5000";
      createUpdateTyreKm(2, "5000");
    }
    if (tyreRemarksControllers.length > 2) {
      tyreRemarksControllers[2].text = "Rear left tyre needs replacement soon";
      createUpdateTyreRemarks(2, "Rear left tyre needs replacement soon");
    }
    if (tyresList.length > 2) {
      createUpdateTyrePosition(2, posByName('Rear Left'));
      createUpdateTyreInstallDate(
          2, DateTime.now().subtract(Duration(days: 120)));
    }

    // Add fourth tyre
    createAddNewTyre();
    if (tyreBrandControllers.length > 3) {
      tyreBrandControllers[3].text = "Continental";
      createUpdateTyreBrand(3, "Continental");
    }
    if (tyreSizeControllers.length > 3) {
      tyreSizeControllers[3].text = "265/65R17";
      createUpdateTyreSize(3, "265/65R17");
    }
    if (tyreKmControllers.length > 3) {
      tyreKmControllers[3].text = "4500";
      createUpdateTyreKm(3, "4500");
    }
    if (tyreRemarksControllers.length > 3) {
      tyreRemarksControllers[3].text = "Rear right tyre in good condition";
      createUpdateTyreRemarks(3, "Rear right tyre in good condition");
    }
    if (tyresList.length > 3) {
      createUpdateTyrePosition(3, posByName('Rear Right'));
      createUpdateTyreInstallDate(
          3, DateTime.now().subtract(Duration(days: 90)));
    }

    // Images Step will be skipped as it requires actual file selection
    // But you can add some mock code here if needed for testing image selection

    // Optionally automatically advance to first step
    currentStep.value = 0;

    // Show a snackbar to indicate test data was loaded
    Get.snackbar(
      'Test Data Loaded',
      'The form has been populated with test data',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );
  }
}

extension SuggestionManager on AddEditVehicleController {
  // Initialize the suggestion lists from vehicle data
  void initializeSuggestions() {
    // Get the storage instance
    final storage = GetStorage();

    try {
      // Check if we already have suggestions stored
      List<String> existingBrands = [];
      List<String> existingModels = [];

      // Safely read from storage with proper type casting
      final storedBrands = storage.read('vehicle_brands');
      if (storedBrands != null) {
        existingBrands =
            (storedBrands as List).map((item) => item.toString()).toList();
      }

      final storedModels = storage.read('vehicle_models');
      if (storedModels != null) {
        existingModels =
            (storedModels as List).map((item) => item.toString()).toList();
      }

      // Only try to extract from originalVehicles if it's not empty
      if (vehicleCon.originalVehicles.isNotEmpty) {
        log("Original Vehicle after refresh: ${vehicleCon.originalVehicles.length} items");

        // Extract and add new unique brands from vehicles
        for (var vehicle in vehicleCon.originalVehicles) {
          if (vehicle.brand != null &&
              vehicle.brand!.isNotEmpty &&
              !existingBrands.contains(vehicle.brand)) {
            existingBrands.add(vehicle.brand!);
          }

          if (vehicle.model != null &&
              vehicle.model!.isNotEmpty &&
              !existingModels.contains(vehicle.model)) {
            existingModels.add(vehicle.model!);
          }
        }
      } else {
        log("Original vehicles list is empty or null");
      }

      // Default suggestions if both storage and originalVehicles are empty
      if (existingBrands.isEmpty) {
        existingBrands = [
          'Toyota',
          'Nissan',
          'Honda',
          'Mitsubishi',
          'Ford',
          'Chevrolet'
        ];
      }

      if (existingModels.isEmpty) {
        existingModels = [
          'Corolla',
          'Camry',
          'Sunny',
          'Patrol',
          'Land Cruiser',
          'Hiace'
        ];
      }

      // Sort the lists
      existingBrands.sort();
      existingModels.sort();

      // Save back to storage
      storage.write('vehicle_brands', existingBrands);
      storage.write('vehicle_models', existingModels);

      log("Saved ${existingBrands.length} brands and ${existingModels.length} models to storage");
    } catch (e) {
      // If anything goes wrong, at least provide some default values
      log("Error initializing suggestions: $e");

      // Default fallback values
      final defaultBrands = [
        'Toyota',
        'Nissan',
        'Honda',
        'Mitsubishi',
        'Ford',
        'Chevrolet'
      ];
      final defaultModels = [
        'Corolla',
        'Camry',
        'Sunny',
        'Patrol',
        'Land Cruiser',
        'Hiace'
      ];

      storage.write('vehicle_brands', defaultBrands);
      storage.write('vehicle_models', defaultModels);
    }
  }

  // Get brand suggestions with improved safety
  List<String> getBrandSuggestions() {
    try {
      final storage = GetStorage();
      final storedBrands = storage.read('vehicle_brands');

      if (storedBrands != null) {
        return (storedBrands as List).map((item) => item.toString()).toList();
      }
    } catch (e) {
      log("Error retrieving brand suggestions: $e");
    }

    // Default fallback if storage fails
    return ['Toyota', 'Nissan', 'Honda', 'Mitsubishi', 'Ford', 'Chevrolet'];
  }

  // Get model suggestions with improved safety
  List<String> getModelSuggestions() {
    try {
      final storage = GetStorage();
      final storedModels = storage.read('vehicle_models');

      if (storedModels != null) {
        return (storedModels as List).map((item) => item.toString()).toList();
      }
    } catch (e) {
      log("Error retrieving model suggestions: $e");
    }

    // Default fallback if storage fails
    return ['Corolla', 'Camry', 'Sunny', 'Patrol', 'Land Cruiser', 'Hiace'];
  }

  // Add a new brand suggestion
  void addBrandSuggestion(String brand) {
    if (brand.isEmpty) return;

    try {
      final storage = GetStorage();
      List<String> brands = getBrandSuggestions();

      if (!brands.contains(brand)) {
        brands.add(brand);
        brands.sort();
        storage.write('vehicle_brands', brands);
      }
    } catch (e) {
      log("Error adding brand suggestion: $e");
    }
  }

  // Add a new model suggestion
  void addModelSuggestion(String model) {
    if (model.isEmpty) return;

    try {
      final storage = GetStorage();
      List<String> models = getModelSuggestions();

      if (!models.contains(model)) {
        models.add(model);
        models.sort();
        storage.write('vehicle_models', models);
      }
    } catch (e) {
      log("Error adding model suggestion: $e");
    }
  }
}
