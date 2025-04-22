import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:multifleet/controllers/loading_controller.dart';
import 'package:multifleet/widgets/auto_complete_field.dart';
import 'package:multifleet/widgets/loading.dart';

import '../controllers/add_edit_vehicle_controller.dart';
import '../models/company.dart';
import '../models/doc_type.dart';
import '../models/vehicle.dart';
import '../models/vehicle_docs.dart';
import '../models/vehicle_image.dart';
import '../widgets/custom_widgets.dart';
import '../widgets/multi_select_drop.dart';

void showCreateVehicleDialog() {
  var con = Get.find<AddEditVehicleController>();
  Get.dialog(
    AlertDialog(
      alignment: Alignment.center,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Vehicle Not Found',
        style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'The vehicle with plate number ${con.plateNumberController.text} does not exist. Would you like to create a new vehicle or try changing the company and try again',
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    showAddVehicleBottomSheet();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800]),
                  child: const Text(
                    'Create Vehicle',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

// Add Vehicle Bottom Sheet and related methods - with updated responsiveness
void showAddVehicleBottomSheet() {
  var con = Get.find<AddEditVehicleController>();
  // Reset form state
  con.resetFormState();

  // Pre-fill plate number from search if available
  con.createPlateNumberController.text = con.plateNumberController.text;

  Get.bottomSheet(
    LoadingOverlay(
      loadingController: Get.find<LoadingController>(),
      child: GestureDetector(
        // Close keyboard when tapping outside of text fields
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Obx(() => Container(
              height: Get.height * 0.9,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _buildBottomSheetHeader(),
                  Expanded(
                    child: Stepper(
                      physics: ClampingScrollPhysics(),
                      currentStep: con.currentStep.value,
                      onStepContinue: () {
                        if (con.currentStep.value < 4) {
                          con.currentStep.value++;
                        } else {
                          _submitVehicleForm();
                        }
                      },
                      onStepCancel: () {
                        if (con.currentStep.value > 0) {
                          con.currentStep.value--;
                        } else {
                          Get.back();
                        }
                      },
                      controlsBuilder: (context, details) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: details.onStepContinue,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue[800],
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                      ),
                                      child: Text(
                                        con.currentStep.value == 4
                                            ? 'Create Vehicle'
                                            : 'Continue',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: details.onStepCancel,
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                      ),
                                      child: Text(
                                        con.currentStep.value == 0
                                            ? 'Cancel'
                                            : 'Back',
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        );
                      },
                      steps: [
                        Step(
                          title: Text('Basic Information'),
                          content: _buildBasicInfoStep(con),
                          isActive: con.currentStep.value >= 0,
                        ),
                        Step(
                          title: Text('Additional Details'),
                          content: _buildAdditionalDetailsStep(con),
                          isActive: con.currentStep.value >= 1,
                        ),
                        Step(
                          title: Text('Status & Documents'),
                          content: _buildStatusDocumentsStep(con),
                          isActive: con.currentStep.value >= 2,
                        ),
                        Step(
                          title: Text('Tyres'),
                          content: _buildTyresStep(con),
                          isActive: con.currentStep.value >= 3,
                        ),
                        Step(
                          title: Text('Images'),
                          content: _buildImagesStep(con),
                          isActive: con.currentStep.value >= 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ),
    ),
    isScrollControlled: true,
    enableDrag: false,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    isDismissible: false,
  );
}

// Submit the vehicle form data
void _submitVehicleForm() async {
  var con = Get.find<AddEditVehicleController>();

  // Create the vehicle object
  final vehicle = Vehicle(
    company: con.selectedCompany.value?.id,
    vehicleNo: con.createPlateNumberController.text,
    description: con.createDescriptionController.text,
    brand: con.createBrandController.text,
    model: con.createModelController.text,
    city: con.selectedCities,
    initialOdo: int.tryParse(con.initialOdoController.text) ?? 0,
    currentOdo: int.tryParse(con.currentOdoController.text),
    imagePath1: '',
    imagePath2: '',
    status: con.selectedStatus.value ?? 'Active',
    type: con.selectedVehicleType.value,
    traficFileNo: con.createTrafficFileNumberController.text,
    fuelStation: con.selectedFuelStation.value,
    vYear: int.tryParse(con.yearController.text),
    chassisNo: con.createChassisNumberController.text,
    condition: con.selectedCondition.value,
    documents: con.vehicleDocuments,
    tyres: con.tyresList.toList(),
  );

  // TODO: Add API call to create the vehicle
  // log('Creating vehicle: $vehicle');
  await con.createUpdateVehicle(vehicle);
}

Widget _buildBottomSheetHeader() {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 3,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Add New Vehicle',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
        ),
        Row(
          children: [
            // Add the test data button
            if (kDebugMode) // Only show in debug mode
              _buildTestDataButton(),
            SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Get.back(),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildTestDataButton() {
  return ElevatedButton.icon(
    onPressed: () {
      final con = Get.find<AddEditVehicleController>();
      con.populateTestData();
    },
    icon: Icon(Icons.science),
    label: Text('Load Test Data'),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.purple,
      foregroundColor: Colors.white,
    ),
  );
}

Widget _buildBasicInfoStep(AddEditVehicleController con) {
  return LayoutBuilder(builder: (context, constraints) {
    // Two column layout for wider screens
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => Expanded(
                    child: _buildDropdown<Company>(
                      value: con.selectedCompany.value,
                      options: con.companyService.companyList,
                      onChanged: (val) => con.selectedCompany.value = val,
                      label: 'Company',
                      icon: Icons.business,
                      displayTextBuilder: (text) => text.name!,
                    ),
                  )),
              SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                    controller: con.createPlateNumberController,
                    label: 'Plate Number',
                    icon: Icons.directions_car,
                    isRequired: true,
                    isReadOnly: true),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: buildAutocompleteTextField(
                  context: context,
                  storageKey: 'vehicle_brands',
                  controller: con.createBrandController,
                  label: 'Brand',
                  icon: Icons.branding_watermark,
                  isRequired: true,
                  initialSuggestions: con.getBrandSuggestions(),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: buildAutocompleteTextField(
                  context: context,
                  storageKey: 'vehicle_models',
                  controller: con.createModelController,
                  label: 'Model',
                  icon: Icons.model_training,
                  isRequired: true,
                  initialSuggestions: con.getModelSuggestions(),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildDropdown<String>(
                  options: con.vehicleTypes,
                  value: con.selectedVehicleType.value,
                  onChanged: (val) => con.selectedVehicleType.value = val,
                  label: 'Vehicle Type',
                  icon: Icons.category,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildDatePickerField(
                  allowPastDates: true,
                  yearOnly: true,
                  onDateSelected: (p0) {
                    // log(con.yearController.text.toString());
                  },
                  controller: con.yearController,
                  label: 'Year',
                  icon: Icons.calendar_today,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  });
}

Widget _buildAdditionalDetailsStep(AddEditVehicleController con) {
  return LayoutBuilder(builder: (context, constraints) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTextField(
                  controller: con.createChassisNumberController,
                  label: 'Chassis Number',
                  icon: Icons.format_list_numbered,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: con.createTrafficFileNumberController,
                  label: 'Traffic File Number',
                  icon: Icons.file_copy,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTextField(
                  controller: con.initialOdoController,
                  label: 'Initial Odometer',
                  icon: Icons.speed,
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildDropdown(
                  label: 'Fuel Station',
                  value: con.selectedFuelStation.value,
                  options: con.fuelStations,
                  onChanged: (value) => con.selectedFuelStation.value = value,
                  icon: Icons.local_gas_station,
                ),
              ),

              // Expanded(
              //   child: _buildTextField(
              //     controller: con.currentOdoController,
              //     label: 'Current Odometer',
              //     icon: Icons.speed,
              //     keyboardType: TextInputType.number,
              //   ),
              // ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: buildMultiSelectField(
                  label: 'Permitted Areas',
                  options: con.permittedAreas,
                  initiallySelected: [],
                  onChanged: (cities) {
                    con.selectedCities.value = cities;
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: con.createDescriptionController,
                  label: 'Remarks',
                  icon: Icons.edit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  });
}

Widget _buildStatusDocumentsStep(AddEditVehicleController con) {
  return LayoutBuilder(builder: (context, constraints) {
    // Calculate responsive values based on available width
    log("max width: ${constraints.maxWidth.toString()}");
    final bool isSmallScreen = constraints.maxWidth < 300;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vehicle condition and status section
          // isSmallScreen
          //     ? Column(
          //         children: [
          //           _buildDropdown(
          //             label: 'Vehicle Condition',
          //             value: con.selectedCondition.value,
          //             options: con.vehicleConditions,
          //             onChanged: (value) => con.selectedCondition.value = value,
          //             icon: Icons.assessment,
          //           ),
          //           SizedBox(height: 16),
          //           _buildDropdown(
          //             label: 'Status',
          //             value: con.selectedStatus.value,
          //             options: con.vehicleStatuses,
          //             onChanged: (value) => con.selectedStatus.value = value,
          //             icon: Icons.flag,
          //           ),
          //         ],
          //       )
          //     :
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Vehicle Condition',
                  value: con.selectedCondition.value,
                  options: con.vehicleConditions,
                  onChanged: (value) => con.selectedCondition.value = value,
                  icon: Icons.assessment,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildDropdown(
                  label: 'Status',
                  value: con.selectedStatus.value,
                  options: con.vehicleStatuses,
                  onChanged: (value) => con.selectedStatus.value = value,
                  icon: Icons.flag,
                ),
              ),
            ],
          ),

          SizedBox(height: 20),
          Divider(),
          SizedBox(height: 16),

          // Documents section header with add button
          isSmallScreen
              ? Column(
                  children: [
                    Text(
                      'Vehicle Documents',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showAddDocumentDialog(context, con),
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: Colors.white,
                      ),
                      label: Text('Add Document'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Vehicle Documents',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showAddDocumentDialog(context, con),
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: Colors.white,
                      ),
                      label: Text('Add Document'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ],
                ),
          SizedBox(height: 16),

          // Dynamic document list
          Obx(
            () => con.vehicleDocuments.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.description_outlined,
                              size: 48, color: Colors.grey[400]),
                          SizedBox(height: 16),
                          Text(
                            'No documents added yet',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: List.generate(
                      con.vehicleDocuments.length,
                      (index) => _buildDocumentItem(
                          con, index, constraints, isSmallScreen),
                    ),
                  ),
          ),
        ],
      ),
    );
  });
}

// Widget to display each document item
Widget _buildDocumentItem(AddEditVehicleController con, int index,
    BoxConstraints constraints, bool isSmallScreen) {
  final document = con.vehicleDocuments[index];
  final docTypeDescription = con.getDocumentTypeDescription(document.docType);

  // Text controllers for form fields
  final TextEditingController issueDateController =
      con.createDocumentIssueDateControllers[index];
  final TextEditingController expiryDateController =
      con.documentExpiryControllers[index];
  final TextEditingController issueAuthorityController =
      con.createDocumentIssueAuthorityControllers[index];
  final TextEditingController remarksController =
      con.createDocumentRemarksControllers[index];
  final TextEditingController documentTypeController =
      con.createDocumentTypesControllers[index];

  return Card(
    margin: EdgeInsets.only(bottom: 16),
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with document type description and delete button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  docTypeDescription ?? 'Document',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                onPressed: () => con.removeDocumentCreate(index),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildDocumentFieldsColumn(
              con: con,
              index: index,
              document: document,
              issueDateController: issueDateController,
              expiryDateController: expiryDateController,
              issueAuthorityController: issueAuthorityController,
              docTypeController: documentTypeController,
              remarksController: remarksController)
        ],
      ),
    ),
  );
}

// Document fields in a column layout for small screens
Widget _buildDocumentFieldsColumn({
  required AddEditVehicleController con,
  required int index,
  required VehicleDocument document,
  required TextEditingController issueDateController,
  required TextEditingController expiryDateController,
  required TextEditingController issueAuthorityController,
  required TextEditingController docTypeController,
  required TextEditingController remarksController,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Document Type Dropdown
      // _buildDropdown(
      //   label: 'Document Type',
      //   value: document.docType?.toString() ?? '',
      //   options: con.availableDocumentTypes
      //       .map((docType) => docType.docType?.toString() ?? '')
      //       .where((id) => id.isNotEmpty)
      //       .toList(),
      //   onChanged: (value) =>
      //       con.updateDocumentTypeCreate(index, int.parse(value!)),
      //   icon: Icons.file_present,
      // ),
      // SizedBox(height: 16),

      // Issue Date
      _buildDatePickerField(
        controller: issueDateController,
        label: 'Issue Date',
        icon: Icons.calendar_today,
      ),
      SizedBox(height: 16),

      // Expiry Date
      _buildDatePickerField(
        controller: expiryDateController,
        label: 'Expiry Date',
        icon: Icons.calendar_month,
      ),
      SizedBox(height: 16),
      _buildTextField(
          controller: issueAuthorityController,
          label: "Document Type",
          icon: Icons.edit_document,
          onChanged: (value) => con.updateDocumentType(index, value)),
      SizedBox(
        height: 16,
      ),

      // Issue Authority (text field)
      _buildTextField(
          controller: issueAuthorityController,
          label: "Issue Authority",
          icon: Icons.business,
          onChanged: (value) => con.updateDocumentIssueAuthority(index, value)),
      SizedBox(height: 16),

      // City Dropdown
      _buildDropdown(
        label: 'City',
        value: document.city,
        options: con.permittedAreas,
        onChanged: (value) => con.updateDocumentCity(index, value),
        icon: Icons.location_city,
      ),
      SizedBox(height: 16),
      _buildTextField(
          controller: remarksController,
          label: "Remarks",
          icon: Icons.edit,
          onChanged: (value) => con.updateDocumentRemarks(index, value)),
      SizedBox(height: 16),
    ],
  );
}

// Dialog to add a new document
void _showAddDocumentDialog(
  BuildContext context,
  AddEditVehicleController con,
) {
  // Use an RxInt to store just the doc type ID (safer than storing the whole object)
  final selectedDocTypeId = RxnInt(); // Nullable int - starts as null

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Add Document'),
        content: Obx(() {
          // Get available document types not already added
          // final availableTypes = con.availableDocumentTypes
          //     .where((docType) => !con.isDocumentTypeAlreadyAdded(docType))
          //     .toList();

          return DropdownButtonFormField<int>(
            decoration: InputDecoration(
              labelText: 'Select Document Type',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.file_present),
            ),
            value: selectedDocTypeId.value,
            items: con.availableDocumentTypes.map((DocumentType type) {
              return DropdownMenuItem<int>(
                value: type.docType, // Use docType (int) as the value
                child: Text(type.docDescription ?? 'Unknown'),
              );
            }).toList(),
            onChanged: (int? newValue) {
              selectedDocTypeId.value = newValue;
            },
            hint: Text('Select a document type'),
          );
        }),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Obx(() => ElevatedButton(
                onPressed: selectedDocTypeId.value == null
                    ? null
                    : () {
                        // Find the DocumentType object by its ID
                        final docType = con.availableDocumentTypes.firstWhere(
                          (type) => type.docType == selectedDocTypeId.value,
                          orElse: () => DocumentType(),
                        );

                        // Add the document
                        con.addDocumentCreate(docType);
                        Get.back();
                      },
                child: Text('Add'),
              )),
        ],
      );
    },
  );
}

Widget _buildTyresStep(AddEditVehicleController con) {
  return LayoutBuilder(builder: (context, constraints) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => Text(
                    'Tyres (${con.tyresList.length}/${con.maxTyresAllowed})',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
              ElevatedButton.icon(
                onPressed: con.tyresList.length < con.maxTyresAllowed
                    ? () => con.createAddNewTyre()
                    : null,
                icon: Icon(
                  Icons.add_circle_outline,
                  color: Colors.white,
                ),
                label: Text('Add Tyre'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Obx(
            () => con.tyresList.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.tire_repair,
                              size: 48, color: Colors.grey[400]),
                          SizedBox(height: 16),
                          Text(
                            'No tyres added yet',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    //   crossAxisSpacing: 20,
                    //   mainAxisSpacing: 20,
                    //   childAspectRatio: aspectRatio,
                    //   crossAxisCount: crossAxisCount,
                    // ),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: con.tyresList.length,
                    itemBuilder: (context, index) {
                      return _buildTyreCard(index, con, constraints);
                    },
                  ),
          ),
        ],
      ),
    );
  });
}

Widget _buildTyreCard(
    int index, AddEditVehicleController con, BoxConstraints constraints) {
  // Get the tyre data for this card
  final tyre = con.tyresList[index];

  // Use the persistent controllers from the controller class
  final brandController = con.tyreBrandControllers[index];
  final sizeController = con.tyreSizeControllers[index];
  final kmController = con.tyreKmControllers[index];
  final remarksController = con.tyreRemarksControllers[index];
  final installDateController = con.tyreInstallDateControllers[index];

  return Card(
    margin: EdgeInsets.only(bottom: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tyre ${index + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Row(
                children: [
                  // Position dropdown
                  SizedBox(
                    width: 140,
                    child: DropdownButtonFormField<String>(
                      value: tyre.position,
                      decoration: InputDecoration(
                        labelText: 'Position',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: [
                        'Front Left',
                        'Front Right',
                        'Rear Left',
                        'Rear Right',
                        'Spare',
                        'Other'
                      ].map((position) {
                        return DropdownMenuItem<String>(
                          value: position,
                          child: Text(position, style: TextStyle(fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          con.createUpdateTyrePosition(index, value);
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => con.createRemoveTyre(index),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // First column
              Expanded(
                child: Column(
                  children: [
                    _buildTextField(
                        controller: brandController,
                        label: 'Brand',
                        onChanged: (value) {
                          // log(value);
                          con.createUpdateTyreBrand(index, value);
                        }),
                    SizedBox(height: 12),
                    _buildTextField(
                      controller: kmController,
                      label: 'KM Used',
                      onChanged: (value) =>
                          con.createUpdateTyreKm(index, value),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16),

              Expanded(
                child: Column(
                  children: [
                    TextField(
                      controller: sizeController,
                      decoration: InputDecoration(
                        labelText: 'Size',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) =>
                          con.createUpdateTyreSize(index, value),
                    ),
                    SizedBox(height: 12),
                    _buildDatePickerField(
                      controller: installDateController,
                      label: 'Installation Date',
                      icon: Icons.calendar_today,
                      allowPastDates: true,
                      onDateSelected: (date) {
                        if (date != null) {
                          con.createUpdateTyreInstallDate(index, date);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          TextField(
            controller: remarksController,
            decoration: InputDecoration(
              labelText: 'Remarks',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            maxLines: 2,
            onChanged: (value) => con.createUpdateTyreRemarks(index, value),
          ),
        ],
      ),
    ),
  );
}

Widget _buildImagesStep(AddEditVehicleController con) {
  return LayoutBuilder(builder: (context, constraints) {
    // Calculate responsive values based on available width
    final bool isSmallScreen = constraints.maxWidth < 600;
    final double imageSize = isSmallScreen
        ? (constraints.maxWidth / 2) - 24
        : (constraints.maxWidth / 3) - 24;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and add button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => Text(
                    'Vehicle Images (${con.vehicleImages.length}/6)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  )),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: con.vehicleImages.length < 6
                        ? () => _pickImage(context, con, false)
                        : null,
                    icon: Icon(
                      Icons.add_a_photo,
                      color: Colors.white,
                    ),
                    label: Text('Add Image'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: con.vehicleImages.length < 6
                        ? () => _pickImage(context, con, true)
                        : null,
                    icon: Icon(
                      Icons.photo_library,
                      color: Colors.white,
                    ),
                    label: Text('Multiple'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),

          // Images grid view
          Obx(
            () => con.vehicleImages.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.image_not_supported_outlined,
                              size: 48, color: Colors.grey[400]),
                          SizedBox(height: 16),
                          Text(
                            'No images added yet',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  )
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isSmallScreen ? 2 : 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1,
                    ),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: con.vehicleImages.length,
                    itemBuilder: (context, index) {
                      return _buildImageItem(con, index, imageSize);
                    },
                  ),
          ),
        ],
      ),
    );
  });
}

Widget _buildImageItem(AddEditVehicleController con, int index, double size) {
  final image = con.vehicleImages[index];

  return Stack(
    children: [
      // Image display with border
      Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: _buildImageWidget(image),
        ),
      ),

      // Delete button overlay
      Positioned(
        top: 5,
        right: 5,
        child: GestureDetector(
          onTap: () => con.removeImage(index),
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.close,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      ),

      // Main/Primary image indicator
      if (index == con.primaryImageIndex.value)
        Positioned(
          bottom: 5,
          left: 5,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Main',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

      // Set as primary image button
      if (index != con.primaryImageIndex.value)
        Positioned(
          bottom: 5,
          left: 5,
          child: GestureDetector(
            onTap: () => con.setPrimaryImage(index),
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.star_border,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
    ],
  );
}

// Helper method to build the appropriate image widget based on the source
Widget _buildImageWidget(VehicleImage image) {
  // For network images (from server)
  if (image.isNetworkImage &&
      image.imageUrl != null &&
      image.imageUrl!.isNotEmpty) {
    return Image.network(
      image.imageUrl!,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Icon(
            Icons.broken_image,
            color: Colors.grey[400],
            size: 40,
          ),
        );
      },
    );
  }
  // For locally picked images
  else if (image.webImage != null) {
    return Image.memory(
      image.webImage!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Icon(
            Icons.broken_image,
            color: Colors.grey[400],
            size: 40,
          ),
        );
      },
    );
  }
  // Fallback for any issues
  else {
    return Center(
      child: Icon(
        Icons.image_not_supported,
        color: Colors.grey[400],
        size: 40,
      ),
    );
  }
}

// Image picker function for single or multiple images
Future<void> _pickImage(
    BuildContext context, AddEditVehicleController con, bool multiple) async {
  try {
    if (multiple) {
      await con.pickMultipleImages();
    } else {
      await con.pickSingleImage();
    }
  } catch (e) {
    // Show error dialog
    CustomWidget.customSnackBar(
        isError: true,
        title: "Error!!",
        message: 'Failed to pick image: ${e.toString()}');
  }
}

Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  IconData? icon,
  bool isRequired = false,
  bool isReadOnly = false,
  TextInputType keyboardType = TextInputType.text,
  void Function(String)? onChanged,
}) {
  return TextField(
    controller: controller,
    keyboardType: keyboardType,
    onChanged: onChanged,
    readOnly: isReadOnly,
    decoration: InputDecoration(
      labelText: isRequired ? '$label *' : label,
      prefixIcon: icon != null ? Icon(icon) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}

Widget _buildDropdown<T>({
  required String label,
  required T? value,
  required List<T> options,
  required void Function(T?) onChanged,
  required IconData icon,
  String Function(T)? displayTextBuilder, // Optional custom display text
}) {
  return DropdownButtonFormField<T>(
    value: value,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    items: options.map((option) {
      return DropdownMenuItem<T>(
        value: option,
        child: Text(displayTextBuilder != null
            ? displayTextBuilder(option)
            : option.toString()),
      );
    }).toList(),
    onChanged: onChanged,
    isDense: true,
    isExpanded: true,
  );
}

Widget _buildDatePickerField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  bool allowPastDates = false,
  Function(DateTime?)? onDateSelected,
  bool yearOnly = false, // Added parameter to control year-only mode
}) {
  return TextField(
    controller: controller,
    readOnly: true,
    onTap: () async {
      if (yearOnly) {
        // Year-only picker logic
        await _showYearPicker(controller, allowPastDates, onDateSelected);
      } else {
        // Full date picker logic
        await _showFullDatePicker(controller, allowPastDates, onDateSelected);
      }
    },
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: Icon(yearOnly ? Icons.calendar_month : Icons.calendar_today),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      // Add hint text to indicate format
      hintText: yearOnly ? 'YYYY' : 'YYYY-MM-DD',
    ),
  );
}

// Helper function for full date picker
Future<void> _showFullDatePicker(
  TextEditingController controller,
  bool allowPastDates,
  Function(DateTime?)? onDateSelected,
) async {
  // Try to parse existing date or use current date
  DateTime initialDate = DateTime.now();
  if (controller.text.isNotEmpty) {
    try {
      initialDate = DateFormat('yyyy-MM-dd').parse(controller.text);
    } catch (e) {
      // Ignore parsing errors, use current date
    }
  }

  final DateTime? pickedDate = await showDatePicker(
    context: Get.context!,
    initialDate: initialDate,
    // If past dates are allowed, start from 10 years ago, otherwise from today
    firstDate: allowPastDates
        ? DateTime.now().subtract(Duration(days: 365 * 10))
        : DateTime.now(),
    lastDate: DateTime.now().add(Duration(days: 365 * 5)),
  );

  if (pickedDate != null) {
    controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    // Call the callback if provided
    if (onDateSelected != null) {
      onDateSelected(pickedDate);
    }
  }
}

// Helper function for year-only picker
Future<void> _showYearPicker(
  TextEditingController controller,
  bool allowPastDates,
  Function(DateTime?)? onDateSelected,
) async {
  // Get the initial year (current or from controller)
  int initialYear = DateTime.now().year;
  if (controller.text.isNotEmpty) {
    try {
      initialYear = int.parse(controller.text);
    } catch (e) {
      // If parsing fails, use current year
    }
  }

  // Calculate min and max years
  int minYear = allowPastDates ? DateTime.now().year - 25 : DateTime.now().year;
  int maxYear = DateTime.now().year + 1;

  // Ensure initial year is within range
  initialYear = initialYear.clamp(minYear, maxYear);
  // Show the custom year picker
  final int? selectedYear = await showDialog<int>(
    context: Get.context!,
    builder: (BuildContext context) {
      return _YearPickerDialog(
        initialYear: initialYear,
        minYear: minYear,
        maxYear: maxYear,
      );
    },
  );

  if (selectedYear != null) {
    // Update the controller with just the year
    controller.text = selectedYear.toString();

    // Create a DateTime object for the callback (Jan 1 of selected year)
    final selectedDate = DateTime(selectedYear, 1, 1);

    // Call the callback if provided
    if (onDateSelected != null) {
      onDateSelected(selectedDate);
    }
  }
}

// Custom year picker dialog
class _YearPickerDialog extends StatefulWidget {
  final int initialYear;
  final int minYear;
  final int maxYear;

  const _YearPickerDialog({
    required this.initialYear,
    required this.minYear,
    required this.maxYear,
  });

  @override
  _YearPickerDialogState createState() => _YearPickerDialogState();
}

class _YearPickerDialogState extends State<_YearPickerDialog> {
  late int selectedYear;
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    selectedYear = widget.initialYear;

    // Initialize scroll controller to start at the initial year
    scrollController = ScrollController(
      initialScrollOffset: (widget.initialYear - widget.minYear) *
          56.0, // Approximate item height
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Year'),
      content: SizedBox(
        width: 300,
        height: 300,
        child: ListView.builder(
          controller: scrollController,
          itemCount: widget.maxYear - widget.minYear + 1,
          itemBuilder: (context, index) {
            final year = widget.minYear + index;
            return ListTile(
              title: Text(
                year.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: year == selectedYear
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: year == selectedYear
                      ? Theme.of(context).primaryColor
                      : null,
                ),
              ),
              onTap: () {
                setState(() {
                  selectedYear = year;
                });
              },
              selected: year == selectedYear,
              selectedTileColor:
                  Theme.of(context).primaryColor.withOpacity(0.1),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(selectedYear),
          child: Text('OK'),
        ),
      ],
    );
  }
}
