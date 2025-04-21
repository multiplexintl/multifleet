import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:multifleet/controllers/loading_controller.dart';
import 'package:multifleet/controllers/vehicle_listing_controller.dart';
import 'package:multifleet/models/vehicle.dart';
import 'package:multifleet/repo/vehicles_repo.dart';
import 'package:multifleet/services/company_service.dart';
import 'package:multifleet/widgets/custom_widgets.dart';
import 'dart:math' as math;

import '../models/company.dart';
import '../models/doc_type.dart';
import '../models/tyre.dart';
import '../models/vehicle_docs.dart';
import '../models/vehicle_image.dart';
import '../views/add_vehicle.dart';

// GetX Controller for vehicle management
class AddEditVehicleController extends GetxController
    implements CompanyAwareController {
  var vehicleCon = Get.find<VehicleListingController>();
  var loadingCon = Get.find<LoadingController>();
  var companyService = Get.find<CompanyService>();
  // Text controllers for search and create vehicle
  final plateNumberController = TextEditingController(text: "D-25502");
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

  // Available document types from API
  final RxList<DocumentType> availableDocumentTypes = <DocumentType>[].obs;

// Selected vehicle documents

// Controllers for document expiry dates
  final RxList<TextEditingController> documentExpiryControllers =
      <TextEditingController>[].obs;

  // Observable values for dropdowns
  final selectedCompany = Rx<Company?>(null);
  final selectedVehicleType = Rx<String?>(null);
  final selectedInsuranceType = Rx<String?>(null);
  final selectedCondition = Rx<String?>(null);
  final selectedStatus = Rx<String?>(null);
  final selectedCities = <String>[].obs;
  final selectedFuelStation = Rx<String?>(null);

  // Tyre list for new vehicle
  final tyresList = <Tyre>[].obs;

  final List<String> insuranceTypes = ['Comprehensive', 'Third Party', 'None'];
  final List<String> vehicleConditions = ['Excellent', 'Good', 'Fair', 'Poor'];
  final List<String> vehicleStatuses = [
    'Active',
    'Inactive',
    'Under Maintenance',
    'Sold'
  ];
  final List<String> permittedAreas = [
    'Dubai',
    'Abu Dhabi',
    'Sharjah',
    'Ajman',
    'Fujairah',
    'Ras Al Khaimah',
    'Umm Al Quwain'
  ];
  final List<String> fuelStations = [
    'ADNOC',
    'ENOC',
    'EMARAT',
    'Caltex',
    'Other'
  ];

  final vehicleTypes = ['Del Van', 'Pickup', 'Car', 'Staff Bus'];

  // Constants
  final int maxTyresAllowed = 6;

  // Form step tracking
  final currentStep = 0.obs;

  // Observable variables
  final isSearching = false.obs;
  final vehicleData = Rx<Vehicle?>(null);

  @override
  void onInit() {
    companyService.registerController(this);
    loadDocumentTypes();
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
  void onCompanyChanged(Company newCompany) {
    loadDocumentTypes();
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
    plateNumberController.text = "$letter-$number";
    log(plateNumberController.text);
  }

  Future<void> searchVehicle() async {
    try {
      isSearching.value = true;

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
            selectedCondition.value = foundVehicle.condition;
            selectedFuelStation.value = foundVehicle.fuelStation;
            selectedStatus.value = foundVehicle.status;
            descriptionController.text = foundVehicle.description.toString();
            update();

            // Fetch documents
            await fetchAndAttachDocumentsForVehicle(foundVehicle);

            // Fetch tyres
            await fetchAndAttachTyresForVehicle(foundVehicle);

            // Update the vehicle data with the augmented vehicle
            vehicleData.value = foundVehicle;
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

// Updated helper function to fetch and attach tyres for a single vehicle
  Future<void> fetchAndAttachTyresForVehicle(Vehicle vehicle) async {
    try {
      // Get vehicle number or return if null
      final vehicleNo = vehicle.vehicleNo;
      if (vehicleNo == null) return;

      // Fetch tyres for this specific vehicle
      var result =
          await VehiclesRepo().getAllVehicleTyres(vehicleNumber: vehicleNo);

      result.fold((error) {
        log('Error fetching vehicle tyres: $error');
      }, (tyres) {
        // Attach tyres directly to the vehicle
        vehicle.tyres = tyres;
      });
    } catch (e) {
      log('Exception in fetchAndAttachTyresForVehicle: ${e.toString()}');
    }
  }

  // Update vehicle status
  void updateVehicleStatus(String? status) {
    if (vehicleData.value != null) {
      final updatedVehicle = vehicleData.value!.copyWith(status: status);
      vehicleData.value = updatedVehicle;
      selectedStatus.value = status;
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

  void updateVehicleCity(List<String> cities) {
    if (vehicleData.value != null) {
      final updatedVehicle = vehicleData.value!.copyWith(city: cities);
      vehicleData.value = updatedVehicle;
    }
  }

// Update vehicle condition (assuming this is stored somewhere in your model or via custom attribute)
  void updateVehicleCondition(String? condition) {
    selectedCondition.value = condition;
    if (vehicleData.value != null) {
      final updatedVehicle = vehicleData.value!.copyWith(condition: condition);
      vehicleData.value = updatedVehicle;
    }
  }

// Update fuel station preference (assuming this is stored somewhere in your model or via custom attribute)
  void updateFuelStation(String? fuelStation) {
    selectedFuelStation.value = fuelStation;
    if (vehicleData.value != null) {
      final updatedVehicle =
          vehicleData.value!.copyWith(fuelStation: fuelStation);
      vehicleData.value = updatedVehicle;
    }
  }

  // Helper method to get currently selected areas from vehicle data
  List<String> getSelectedPermittedAreas() {
    // If we have values in the controller's observable, use those
    if (selectedPermittedAreas.isNotEmpty) {
      return selectedPermittedAreas;
    }

    // Otherwise, try to parse from the vehicle's city field
    if (vehicleData.value != null &&
        vehicleData.value!.city != null &&
        vehicleData.value!.city!.isNotEmpty) {
      // Split by delimiter if using the joined string approach
      return vehicleData.value!.city!;
    }

    // Default to empty list
    return [];
  }

  void addNewTyre() {
    final currentTyres = vehicleData.value?.tyres?.toList() ?? [];

    // Only add if below the maximum
    if (currentTyres.length < maxTyresAllowed) {
      // Create a new tyre with basic properties
      // Use vehicle number from the current vehicle if available
      Tyre newTyre = Tyre(
        vehicleNo: vehicleData.value?.vehicleNo,
        position: _getNextTyrePosition(currentTyres),
        brand: '',
        size: '',
        kmUsed: 0,
        installDt: DateTime.now(),
        createdDt: DateTime.now(),
      );

      currentTyres.add(newTyre);

      // Update the vehicle data
      final updatedVehicle = vehicleData.value?.copyWith(tyres: currentTyres);
      vehicleData.value = updatedVehicle;
    }
  }

// Helper method to determine the next tyre position
  String _getNextTyrePosition(List<Tyre> tyres) {
    final positions = [
      'Front Left',
      'Front Right',
      'Rear Left',
      'Rear Right',
      'Spare'
    ]; // Removed 'Other' from this list

    // Find positions that are already taken
    final takenPositions = tyres.map((t) => t.position).toList();

    // Find the first position that's not taken
    for (String position in positions) {
      if (!takenPositions.contains(position)) {
        return position;
      }
    }

    // If all standard positions are taken, return 'Other'
    return 'Other';
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

  void updateTyrePosition(int index, String position) {
    final currentTyres = vehicleData.value?.tyres?.toList() ?? [];
    if (index >= 0 && index < currentTyres.length) {
      // Update tyre with new position
      currentTyres[index] = currentTyres[index].copyWith(position: position);

      // Update the vehicle data
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
    // vehicleFound.value = false;
    vehicleData.value = null;
  }

  // Load document types from API
  void loadDocumentTypes() async {
    try {
      // Replace with your API call
      final response = await VehiclesRepo().getAllVehicleDocumentMaster(
          company: '${companyService.selectedCompanyObs.value?.id}');

      response.fold((error) {
        log(error);
      }, (docs) {
        availableDocumentTypes.value = docs;
        log(availableDocumentTypes.toString());
      });
    } catch (e) {
      log('Error loading document types: $e');
    }
  }

// Get document type description for display
  String? getDocumentTypeDescription(int? docTypeId) {
    if (docTypeId == null) return null;

    final docType = availableDocumentTypes.firstWhere(
      (doc) => doc.docType == docTypeId,
      orElse: () => DocumentType(),
    );

    return docType.docDescription;
  }

// Add a new document to the list
  void addDocumentCreate(DocumentType docType) {
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
  }

// Remove document and associated controllers
  void removeDocumentCreate(int index) {
    vehicleDocuments.removeAt(index);

    // Dispose and remove controllers
    createDocumentIssueDateControllers[index].dispose();
    documentExpiryControllers[index].dispose();
    createDocumentIssueAuthorityControllers[index].dispose();

    createDocumentIssueDateControllers.removeAt(index);
    documentExpiryControllers.removeAt(index);
    createDocumentIssueAuthorityControllers.removeAt(index);
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

    createDocumentIssueDateControllers.clear();
    documentExpiryControllers.clear();
    createDocumentIssueAuthorityControllers.clear();

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
    }
  }

// Check if a document type is already added
  bool isDocumentTypeAlreadyAdded(DocumentType docType) {
    return vehicleDocuments.any((doc) => doc.docType == docType.docType);
  }

  void createAddNewTyre() {
    if (tyresList.length < maxTyresAllowed) {
      // Create the new tyre
      final newTyre = Tyre(
        vehicleNo: createPlateNumberController.text,
        installDt: DateTime.now(),
        createdDt: DateTime.now(),
        kmUsed: 0,
      );
      tyresList.add(newTyre);

      // Create controllers for the new tyre
      tyreBrandControllers.add(TextEditingController());
      tyreSizeControllers.add(TextEditingController());
      tyreKmControllers.add(TextEditingController(text: "0"));
      tyreRemarksControllers.add(TextEditingController());
      tyreInstallDateControllers.add(TextEditingController(
          text: DateFormat('yyyy-MM-dd').format(DateTime.now())));
    }
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

  void createUpdateTyrePosition(int index, String position) {
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
    selectedCompany.value = null;
    selectedVehicleType.value = null;
    createDescriptionController.clear();

    // Reset dropdown values
    selectedInsuranceType.value = null;
    selectedCondition.value = null;
    selectedStatus.value = 'Active'; // Default to Active
    selectedCities.clear();
    selectedFuelStation.value = null;

    // Reset step and tyres
    currentStep.value = 0;
    vehicleImages.clear();
    tyresList.clear();
  }

  Future<void> createUpdateVehicle(Vehicle newVehicle) async {
    try {
      // Log the vehicle data for debugging
      log('Attempting to create/update vehicle: ${newVehicle.toString()}');

      // Start the loading indicator
      loadingCon.startLoading();

      // Call the repository method
      final res = await VehiclesRepo().createUpdateVehicle(newVehicle);
      log('API response: $res');

      // Handle the result
      if (res) {
        // Success case
        Get.back(); // Navigate back
        CustomWidget.customSnackBar(
          isError: false,
          title: 'Success',
          message: 'Vehicle created successfully',
        );
        await searchVehicle();
      } else {
        // Failure case with valid response
        CustomWidget.customSnackBar(
          isError: true,
          title: 'Failed',
          message:
              'Vehicle creation failed. Please verify the information and try again.',
        );
      }
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

// Add this function to your AddEditVehicleController class
  void populateTestData() {
    // Basic Information Step
    if (companyService.companyList.isNotEmpty) {
      selectedCompany.value = companyService.selectedCompanyObs.value;
    }
    createPlateNumberController.text = "D-25502";
    createBrandController.text = "Toyota";
    createModelController.text = "Land Cruiser";
    if (vehicleTypes.isNotEmpty) {
      selectedVehicleType.value = vehicleTypes.first;
    }
    yearController.text = "2023";
    createDescriptionController.text = "Test vehicle for demo purposes";

    // Additional Details Step
    createChassisNumberController.text = "JTEBU5JR4B5046692";
    createTrafficFileNumberController.text = "TRF78945612";
    initialOdoController.text = "5000";
    currentOdoController.text = "7500";

    // Set some test permitted areas
    if (permittedAreas.isNotEmpty) {
      selectedCities.value = permittedAreas.take(2).toList();
    }

    // Set fuel station if available
    if (fuelStations.isNotEmpty) {
      selectedFuelStation.value = fuelStations.first;
    }

    // Status & Documents Step
    if (vehicleConditions.isNotEmpty) {
      selectedCondition.value = vehicleConditions.first;
    }
    if (vehicleStatuses.isNotEmpty) {
      selectedStatus.value = vehicleStatuses.first;
    }

    // Add test documents if document types are available
    if (availableDocumentTypes.isNotEmpty) {
      // Add first document type
      final firstDocType = availableDocumentTypes[0];
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

      if (vehicleDocuments.isNotEmpty && permittedAreas.isNotEmpty) {
        updateDocumentCity(0, permittedAreas[0]);
      }

      // Add second document type if available
      if (availableDocumentTypes.length > 1) {
        final secondDocType = availableDocumentTypes[1];
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

        if (vehicleDocuments.length > 1 && permittedAreas.length > 1) {
          updateDocumentCity(1, permittedAreas[1]);
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
    if (tyresList.isNotEmpty) {
      createUpdateTyrePosition(0, "Front Left");
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
      createUpdateTyrePosition(1, "Front Right");
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
      createUpdateTyrePosition(2, "Rear Left");
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
      createUpdateTyrePosition(3, "Rear Right");
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
