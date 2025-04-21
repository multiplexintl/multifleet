import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:multifleet/models/doc_type.dart';
import 'package:multifleet/widgets/search_vehicle.dart';

import '../controllers/add_edit_vehicle_controller.dart';
import '../models/vehicle_docs.dart';
import '../widgets/custom_widgets.dart';
import '../widgets/multi_select_drop.dart';

// Main StatelessWidget Page
class AddEditVehiclePage extends StatelessWidget {
  const AddEditVehiclePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    final controller = Get.put(AddEditVehicleController());

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search Section
                _buildSearchSection(controller),

                const SizedBox(height: 20),

                // Vehicle Details Section (if found)
                Obx(() => controller.isSearching.value
                    ? Center(
                        child: Text("Searching..."),
                      )
                    : controller.vehicleData.value != null
                        ? _buildVehicleDetailsSection(controller)
                        : Center(child: Text("Search Any Vehicle"))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSection(AddEditVehicleController controller) {
    return SearchVehicleWidget(
      controller: controller.plateNumberController,
      onSearch: () => controller.searchVehicle(),
      onClear: () => controller.clearSearch(),
      onDataChanged: (letter, emirate, number) {
        controller.onPlateChanged(letter, emirate, number);
      },
    );
  }

  Widget _buildVehicleDetailsSection(AddEditVehicleController controller) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Permanent Details Section
            _buildSectionHeader('Permanent Vehicle Details'),
            _buildPermanentDetailsSection(controller),

            const Divider(height: 32),

            // Changeable Details Section
            _buildSectionHeader('Changeable Vehicle Details'),
            _buildChangeableDetailsSection(controller),

            const Divider(height: 32),

            // Tyres Section
            _buildSectionHeader('Tyre Details'),
            _buildTyresSection(controller),

            const SizedBox(height: 50),

            // Action Buttons
            _buildActionButtons(
              onPressedSave: () {
                log(json.encode(controller.vehicleData));
              },
              onPressedCancel: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue[800],
        ),
      ),
    );
  }

  Widget _buildPermanentDetailsSection(AddEditVehicleController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = _calculateCrossAxisCount(constraints.maxWidth);

        return Obx(() => GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 9.5,
              mainAxisSpacing: 20,
              crossAxisSpacing: 25,
              children: [
                _buildReadOnlyField(
                    'Plate Number', controller.vehicleData.value!.vehicleNo),
                _buildReadOnlyField(
                    'Brand', controller.vehicleData.value!.brand),
                _buildReadOnlyField(
                    'Model', controller.vehicleData.value!.model),
                _buildReadOnlyField('Type', controller.vehicleData.value!.type),
                _buildReadOnlyField(
                    'Chassis Number', controller.vehicleData.value!.chassisNo),
                _buildReadOnlyField('Traffic File Number',
                    controller.vehicleData.value!.traficFileNo),
                _buildReadOnlyField(
                    'Company',
                    controller.companyService.companyList
                        .where((element) =>
                            element.id == controller.vehicleData.value!.company)
                        .first
                        .name),
              ],
            ));
      },
    );
  }

  Widget _buildChangeableDetailsSection(AddEditVehicleController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = _calculateCrossAxisCount(constraints.maxWidth);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic changeable details
            GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 9.5,
              mainAxisSpacing: 20,
              crossAxisSpacing: 25,
              children: [
                _buildTextFormField(
                  label: 'Current KM',
                  editingCon: controller.currentOdoController,
                  onChanged: controller.updateCurrentOdometer,
                ),
                buildMultiSelectField(
                  label: 'Permitted Areas',
                  options: controller.permittedAreas,
                  initiallySelected: controller.vehicleData.value?.city ?? [],
                  onChanged: (cities) => controller.updateVehicleCity(cities),
                ),
                _buildDropdownField(
                  label: 'Vehicle Condition',
                  options: controller.vehicleConditions,
                  onChanged: controller.updateVehicleCondition,
                  value: controller.selectedCondition.value,
                ),
                _buildDropdownField(
                  label: 'Fuel Station',
                  options: controller.fuelStations,
                  onChanged: controller.updateFuelStation,
                  value: controller.selectedFuelStation.value,
                ),
                _buildDropdownField(
                  label: 'Vehicle Status',
                  options: controller.vehicleStatuses,
                  onChanged: controller.updateVehicleStatus,
                  value: controller.selectedStatus.value,
                ),
                _buildTextFormField(
                  label: 'Description',
                  editingCon: controller.descriptionController,
                  onChanged: controller.updateVehicleDescription,
                ),
              ],
            ),

            SizedBox(height: 30),

            // Vehicle Documents Section
            _buildDocumentsSection(controller, constraints),
          ],
        );
      },
    );
  }

  Widget _buildDocumentsSection(
      AddEditVehicleController controller, BoxConstraints constraints) {
    // final docTypes = {
    //   1001: 'Insurance',
    //   1002: 'Mulkiya',
    //   1003: 'Service',
    //   1004: 'Registration',
    //   1005: 'Permit',
    //   1006: 'Other'
    // };

    // Get existing documents
    final documents = controller.vehicleData.value?.documents ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
              icon: Icon(Icons.add_circle_outline, color: Colors.white),
              label: Text('Add Document'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
              ),
              onPressed: () => _showAddDocumentDialog(controller),
            ),
          ],
        ),
        SizedBox(height: 16),

        // Existing documents list
        if (documents.isEmpty)
          Container(
            padding: EdgeInsets.symmetric(vertical: 32),
            alignment: Alignment.center,
            child: Text(
              'No documents added yet',
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          _buildDocumentsList(controller, documents, constraints),
      ],
    );
  }

  Widget _buildDocumentsList(AddEditVehicleController controller,
      List<VehicleDocument> documents, BoxConstraints constraints) {
    final isWideScreen = constraints.maxWidth > 700;

    if (isWideScreen) {
      // Table view for wide screens
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 20,
            columns: [
              DataColumn(label: Text('Type')),
              DataColumn(label: Text('Issue Date')),
              DataColumn(label: Text('Expiry Date')),
              DataColumn(label: Text('Authority')),
              DataColumn(label: Text('City')),
              DataColumn(label: Text('Actions')),
            ],
            rows: documents.map((doc) {
              final docTypeName = controller.availableDocumentTypes
                      .where((type) => type.docType == doc.docType)
                      .first
                      .docDescription ??
                  'Unknown';

              return DataRow(
                cells: [
                  DataCell(Text(docTypeName,
                      style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(doc.formatDate(doc.issueDate))),
                  DataCell(Row(
                    children: [
                      Text(doc.formatDate(doc.expiryDate)),
                      SizedBox(width: 5),
                      _buildExpiryIndicator(doc.expiryDate),
                    ],
                  )),
                  DataCell(Text(doc.issueAuthority ?? '-')),
                  DataCell(Text(doc.city ?? '-')),
                  DataCell(Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, size: 20),
                        onPressed: () =>
                            _showEditDocumentDialog(controller, doc),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: Icon(Icons.delete,
                            size: 20, color: Colors.red[400]),
                        onPressed: () =>
                            _showDeleteDocumentConfirmation(controller, doc),
                        tooltip: 'Delete',
                      ),
                    ],
                  )),
                ],
              );
            }).toList(),
          ),
        ),
      );
    } else {
      // Card view for narrower screens
      return ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: documents.length,
        separatorBuilder: (context, index) => SizedBox(height: 12),
        itemBuilder: (context, index) {
          final doc = documents[index];
          final docTypeName = controller.availableDocumentTypes
                  .where((type) => type.docType == doc.docType)
                  .first
                  .docDescription ??
              'Unknown';

          return Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Chip(
                        label: Text(docTypeName),
                        backgroundColor: _getDocumentTypeColor(doc.docType),
                        labelStyle: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, size: 20),
                            onPressed: () =>
                                _showEditDocumentDialog(controller, doc),
                            tooltip: 'Edit',
                          ),
                          IconButton(
                            icon: Icon(Icons.delete,
                                size: 20, color: Colors.red[400]),
                            onPressed: () => _showDeleteDocumentConfirmation(
                                controller, doc),
                            tooltip: 'Delete',
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  _buildDocumentDetailRow(
                      'Issue Date', doc.formatDate(doc.issueDate)),
                  SizedBox(height: 8),
                  _buildDocumentDetailRow(
                    'Expiry Date',
                    Row(
                      children: [
                        Text(doc.formatDate(doc.expiryDate)),
                        SizedBox(width: 5),
                        _buildExpiryIndicator(doc.expiryDate),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildDocumentDetailRow(
                      'Authority', doc.issueAuthority ?? '-'),
                  SizedBox(height: 8),
                  _buildDocumentDetailRow('City', doc.city ?? '-'),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildDocumentDetailRow(String label, dynamic value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          child: value is Widget ? value : Text(value.toString()),
        ),
      ],
    );
  }

  Widget _buildExpiryIndicator(DateTime? expiryDate) {
    if (expiryDate == null) return SizedBox();

    final now = DateTime.now();
    final daysUntilExpiry = expiryDate.difference(now).inDays;

    Color indicatorColor;
    String tooltip;

    if (daysUntilExpiry < 0) {
      indicatorColor = Colors.red;
      tooltip = 'Expired';
    } else if (daysUntilExpiry <= 30) {
      indicatorColor = Colors.orange;
      tooltip = 'Expiring soon';
    } else if (daysUntilExpiry <= 90) {
      indicatorColor = Colors.amber;
      tooltip = 'Expires in $daysUntilExpiry days';
    } else {
      indicatorColor = Colors.green;
      tooltip = 'Valid';
    }

    return Tooltip(
      message: tooltip,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: indicatorColor,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Color _getDocumentTypeColor(int? docType) {
    switch (docType) {
      case 1001:
        return Colors.blue[700]!; // Insurance
      case 1002:
        return Colors.green[700]!; // Mulkiya
      case 1003:
        return Colors.purple[700]!; // Service
      case 1004:
        return Colors.amber[700]!; // Registration
      case 1005:
        return Colors.teal[700]!; // Permit
      default:
        return Colors.grey[700]!; // Other
    }
  }

// Dialog to add a new document
  void _showAddDocumentDialog(AddEditVehicleController controller) {
    final formKey = GlobalKey<FormState>();
    final issueDateController = TextEditingController();
    final expiryDateController = TextEditingController();
    final issueAuthorityController = TextEditingController();
    final cityController = TextEditingController();

    DocumentType? selectedDocType;
    DateTime selectedIssueDate = DateTime.now();
    DateTime selectedExpiryDate = DateTime.now().add(Duration(days: 365));

    // Initialize the date controller values
    issueDateController.text =
        DateFormat('dd/MM/yyyy').format(selectedIssueDate);
    expiryDateController.text =
        DateFormat('dd/MM/yyyy').format(selectedExpiryDate);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: Get.width > 600 ? 600 : Get.width * 0.9,
          padding: EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Add New Document',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Document Type
                  Text('Document Type',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  _buildDropdownField<DocumentType>(
                    value: selectedDocType,
                    label: "Document Type",
                    options: controller.availableDocumentTypes,
                    onChanged: (value) {
                      if (value != null) {
                        selectedDocType = value;
                      }
                    },
                    validator: (value) =>
                        value == null ? 'Please select a document type' : null,
                    displayTextBuilder: (text) =>
                        text.docDescription.toString(),
                  ),

                  SizedBox(height: 16),

                  // Issue Date
                  Text('Issue Date',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  _buildTextFormField(
                    label: "Select Date",
                    editingCon: issueDateController,
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: Get.context!,
                        initialDate: selectedIssueDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now().add(Duration(
                            days:
                                30)), // Allow selection slightly in the future
                      );
                      if (pickedDate != null) {
                        selectedIssueDate = pickedDate;
                        issueDateController.text =
                            DateFormat('dd/MM/yyyy').format(pickedDate);
                      }
                    },
                    validator: (value) =>
                        value!.isEmpty ? 'Please select issue date' : null,
                    readOnly: true,
                  ),

                  SizedBox(height: 16),

                  // Expiry Date
                  Text('Expiry Date',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  _buildTextFormField(
                    editingCon: expiryDateController,
                    label: "Select Date",
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: Get.context!,
                        initialDate: selectedExpiryDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365 * 5)),
                      );
                      if (pickedDate != null) {
                        selectedExpiryDate = pickedDate;
                        expiryDateController.text =
                            DateFormat('dd/MM/yyyy').format(pickedDate);
                      }
                    },
                    validator: (value) =>
                        value!.isEmpty ? 'Please select expiry date' : null,
                  ),
                  SizedBox(height: 16),

                  // Issue Authority
                  Text('Issuing Authority',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  _buildTextFormField(
                    editingCon: issueAuthorityController,
                    label: 'E.g., RTA, Dubai Insurance',
                    validator: (value) => value!.isEmpty
                        ? 'Please enter issuing authority'
                        : null,
                  ),
                  SizedBox(height: 16),

                  // City
                  Text('City', style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  _buildDropdownField(
                    label: "City",
                    options: controller.permittedAreas,
                    onChanged: (city) {
                      cityController.text = city!;
                    },
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter city' : null,
                    value: null,
                  ),

                  SizedBox(height: 24),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text('Cancel'),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            // Create the new document
                            final newDocument = VehicleDocument(
                              company: controller.vehicleData.value?.company,
                              vehicleNo:
                                  controller.vehicleData.value?.vehicleNo,
                              docType: selectedDocType?.docType,
                              issueDate: selectedIssueDate,
                              expiryDate: selectedExpiryDate,
                              issueAuthority: issueAuthorityController.text,
                              city: cityController.text,
                            );
                            log(newDocument.toString());

                            // Add to the vehicle data
                            controller.addDocument(newDocument);

                            Get.back();
                            CustomWidget.customSnackBar(
                              isError: false,
                              title: 'Success',
                              message: 'Document added successfully',
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Add Document'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

// Dialog to edit an existing document
  void _showEditDocumentDialog(
    AddEditVehicleController controller,
    VehicleDocument document,
  ) {
    final formKey = GlobalKey<FormState>();
    final issueDateController = TextEditingController();
    final expiryDateController = TextEditingController();
    final issueAuthorityController =
        TextEditingController(text: document.issueAuthority);
    final cityController = TextEditingController(text: document.city);

    DocumentType? selectedDocType = controller.availableDocumentTypes
        .where((type) => type.docType == document.docType)
        .first;
    DateTime selectedIssueDate = document.issueDate ?? DateTime.now();
    DateTime selectedExpiryDate =
        document.expiryDate ?? DateTime.now().add(Duration(days: 365));

    // Initialize the date controller values
    issueDateController.text =
        DateFormat('dd/MM/yyyy').format(selectedIssueDate);
    expiryDateController.text =
        DateFormat('dd/MM/yyyy').format(selectedExpiryDate);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: Get.width > 600 ? 600 : Get.width * 0.9,
          padding: EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Edit Document',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Document Type
                  Text('Document Type',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  _buildDropdownField<DocumentType>(
                    label: "Document Type",
                    value: selectedDocType,
                    options: controller.availableDocumentTypes,
                    onChanged: (value) {
                      if (value != null) {
                        selectedDocType = value;
                      }
                    },
                    validator: (value) =>
                        value == null ? 'Please select a document type' : null,
                    displayTextBuilder: (text) => text.docDescription ?? '',
                  ),

                  SizedBox(height: 16),

                  // Issue Date
                  Text('Issue Date',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  _buildTextFormField(
                    editingCon: issueDateController,
                    readOnly: true,
                    label: "Select Date",
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: Get.context!,
                        initialDate: selectedIssueDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now().add(Duration(days: 30)),
                      );
                      if (pickedDate != null) {
                        selectedIssueDate = pickedDate;
                        issueDateController.text =
                            DateFormat('dd/MM/yyyy').format(pickedDate);
                      }
                    },
                    validator: (value) =>
                        value!.isEmpty ? 'Please select issue date' : null,
                  ),
                  SizedBox(height: 16),

                  // Expiry Date
                  Text('Expiry Date',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  _buildTextFormField(
                    editingCon: expiryDateController,
                    readOnly: true,
                    label: 'Select Date',
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: Get.context!,
                        initialDate: selectedExpiryDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365 * 5)),
                      );
                      if (pickedDate != null) {
                        selectedExpiryDate = pickedDate;
                        expiryDateController.text =
                            DateFormat('dd/MM/yyyy').format(pickedDate);
                      }
                    },
                    validator: (value) =>
                        value!.isEmpty ? 'Please select expiry date' : null,
                  ),
                  SizedBox(height: 16),

                  // Issue Authority
                  Text('Issuing Authority',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  _buildTextFormField(
                    editingCon: issueAuthorityController,
                    label: 'E.g., RTA, Dubai Insurance',
                    validator: (value) => value!.isEmpty
                        ? 'Please enter issuing authority'
                        : null,
                  ),
                  SizedBox(height: 16),

                  // City
                  Text('City', style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  _buildDropdownField(
                      label: "City",
                      options: controller.permittedAreas,
                      onChanged: (city) {
                        cityController.text = city!;
                      },
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter city' : null,
                      value: null),

                  SizedBox(height: 24),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text('Cancel'),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            // Create updated document
                            final updatedDocument = document.copyWith(
                              docType: selectedDocType?.docType,
                              issueDate: selectedIssueDate,
                              expiryDate: selectedExpiryDate,
                              issueAuthority: issueAuthorityController.text,
                              city: cityController.text,
                            );

                            // Update the document
                            controller.updateDocument(
                                document, updatedDocument);

                            Get.back();
                            CustomWidget.customSnackBar(
                              isError: false,
                              title: 'Success',
                              message: 'Document updated successfully',
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Update Document'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

// Confirmation dialog for deleting a document
  void _showDeleteDocumentConfirmation(
      AddEditVehicleController controller, VehicleDocument document) {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Document'),
        content: Text(
            'Are you sure you want to delete this document? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Remove the document
              controller.removeDocument(document);

              Get.back();
              CustomWidget.customSnackBar(
                isError: false,
                title: 'Success',
                message: 'Document deleted successfully',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildTyresSection(AddEditVehicleController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int tyresPerRow = _calculateTyresPerRow(constraints.maxWidth);

        return Obx(() {
          // Safely access tyres list, defaulting to empty list if null
          final tyres = controller.vehicleData.value?.tyres ?? [];
          final maxTyres = controller.maxTyresAllowed;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with add button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tyres (${tyres.length}/$maxTyres)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  if (tyres.length < maxTyres)
                    ElevatedButton.icon(
                      onPressed: () => controller.addNewTyre(),
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Colors.white,
                      ),
                      label: const Text('Add Tyre'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // No tyres message
              if (tyres.isEmpty)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'No tyres added yet. Click "Add Tyre" to begin.',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ),
                ),

              // Responsive tyre grid
              if (tyres.isNotEmpty)
                LayoutBuilder(
                  builder: (context, gridConstraints) {
                    // Calculate optimal height based on screen size
                    final screenHeight = MediaQuery.of(context).size.height;
                    final availableHeight =
                        screenHeight * 0.6; // Use at most 60% of screen height
                    final itemHeight = tyresPerRow > 1
                        ? (availableHeight /
                            ((tyres.length / tyresPerRow).ceil()))
                        : 380.0;

                    // Use minimum height of 300, maximum of 450
                    final actualItemHeight = itemHeight.clamp(430.0, 650.0);

                    return Container(
                      // Set a reasonable max height for the grid container
                      constraints: BoxConstraints(
                        maxHeight:
                            screenHeight * 0.7, // Limit to 70% of screen height
                      ),
                      child: ListView(
                        // This outer ListView makes it scrollable
                        shrinkWrap: true,
                        children: [
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: tyresPerRow,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,

                              // Use a calculated aspect ratio instead of fixed mainAxisExtent
                              childAspectRatio: gridConstraints.maxWidth /
                                  (tyresPerRow * actualItemHeight),
                            ),
                            itemCount: tyres.length,
                            itemBuilder: (context, index) {
                              var tyre = tyres[index];
                              return Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: SingleChildScrollView(
                                  // Add inner scrolling for each tyre card
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                'Tyre ${index + 1}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue[800],
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.delete_outline,
                                                  color: Colors.red),
                                              onPressed: () =>
                                                  controller.removeTyre(index),
                                              iconSize: 20,
                                              splashRadius: 20,
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 12),

                                        // Position dropdown
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 80,
                                              child: Text('Position: ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                            Expanded(
                                              child: DropdownButtonFormField<
                                                  String>(
                                                isDense: true,
                                                value: tyre.position,
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 8),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                                items: [
                                                  'Front Left',
                                                  'Front Right',
                                                  'Rear Left',
                                                  'Rear Right',
                                                  'Spare',
                                                  'Other'
                                                ].map((String value) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: value,
                                                    child: Text(value,
                                                        style: TextStyle(
                                                            fontSize: 14)),
                                                  );
                                                }).toList(),
                                                onChanged: (newValue) {
                                                  if (newValue != null) {
                                                    controller
                                                        .updateTyrePosition(
                                                            index, newValue);
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 10),

                                        // Brand field
                                        _buildEditableField(
                                            controller: controller,
                                            index: index,
                                            label: 'Brand',
                                            value: tyre.brand ?? '',
                                            onChanged: (newValue) {
                                              controller.updateTyreBrand(
                                                  index, newValue);
                                            }),

                                        const SizedBox(height: 10),

                                        // Size field
                                        _buildEditableField(
                                            controller: controller,
                                            index: index,
                                            label: 'Size',
                                            value: tyre.size ?? '',
                                            onChanged: (newValue) {
                                              controller.updateTyreSize(
                                                  index, newValue);
                                            }),

                                        const SizedBox(height: 10),

                                        // KM field
                                        _buildEditableField(
                                            controller: controller,
                                            index: index,
                                            label: 'KM Used',
                                            value:
                                                tyre.kmUsed?.toString() ?? '0',
                                            keyboardType: TextInputType.number,
                                            onChanged: (newValue) {
                                              controller.updateTyreKm(
                                                  index, newValue);
                                            }),

                                        const SizedBox(height: 10),

                                        // Installation Date
                                        Row(
                                          children: [
                                            const Text('Install Date: ',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Expanded(
                                              child: InkWell(
                                                onTap: () async {
                                                  final DateTime? pickedDate =
                                                      await showDatePicker(
                                                    context: context,
                                                    initialDate:
                                                        tyre.installDt ??
                                                            DateTime.now(),
                                                    firstDate: DateTime(2010),
                                                    lastDate: DateTime.now()
                                                        .add(const Duration(
                                                            days: 1)),
                                                  );
                                                  if (pickedDate != null) {
                                                    controller
                                                        .updateTyreInstallDate(
                                                            index, pickedDate);
                                                  }
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10,
                                                      vertical: 8),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.grey),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        tyre.installDt != null
                                                            ? tyre.formatDate(
                                                                tyre.installDt)
                                                            : 'Select Date',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color:
                                                              tyre.installDt !=
                                                                      null
                                                                  ? Colors.black
                                                                  : Colors.grey,
                                                        ),
                                                      ),
                                                      Icon(Icons.calendar_today,
                                                          size: 16),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 10),

                                        // Expiry Date
                                        Row(
                                          children: [
                                            const Text('Expiry Date: ',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Expanded(
                                              child: InkWell(
                                                onTap: () async {
                                                  final DateTime? pickedDate =
                                                      await showDatePicker(
                                                    context: context,
                                                    initialDate: tyre.expDt ??
                                                        DateTime.now().add(
                                                            const Duration(
                                                                days: 365)),
                                                    firstDate: DateTime.now(),
                                                    lastDate: DateTime.now()
                                                        .add(const Duration(
                                                            days: 365 * 5)),
                                                  );
                                                  if (pickedDate != null) {
                                                    controller
                                                        .updateTyreExpiryDate(
                                                            index, pickedDate);
                                                  }
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10,
                                                      vertical: 8),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.grey),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        tyre.expDt != null
                                                            ? tyre.formatDate(
                                                                tyre.expDt)
                                                            : 'Select Date',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color:
                                                              tyre.expDt != null
                                                                  ? Colors.black
                                                                  : Colors.grey,
                                                        ),
                                                      ),
                                                      Icon(Icons.calendar_today,
                                                          size: 16),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 10),

                                        // Remarks field
                                        _buildEditableField(
                                            controller: controller,
                                            index: index,
                                            label: 'Remarks',
                                            value: tyre.remarks ?? '',
                                            maxLines: 2,
                                            onChanged: (newValue) {
                                              controller.updateTyreRemarks(
                                                  index, newValue);
                                            }),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          );
        });
      },
    );
  }

// Update this method in your widget to use the controller management
  Widget _buildEditableField({
    required AddEditVehicleController controller,
    required int index,
    required String label,
    required String value,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    // Get field name from label by removing spaces and making first letter lowercase
    final fieldName = label
        .replaceAll(' ', '')
        .replaceFirst(label[0], label[0].toLowerCase());

    // Get tyre index from context - this assumes you have access to the tyre index in this scope
    // If not, you'll need to pass tyreIndex as a parameter to this method
    final tyreIndex = index; // Use the actual tyre index from your context

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
            width: 80,
            child: Text('$label: ',
                style: TextStyle(fontWeight: FontWeight.bold))),
        Expanded(
          child: TextField(
            controller:
                controller.getTyreFieldController(tyreIndex, fieldName, value),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              isDense: true,
            ),
            style: TextStyle(fontSize: 14),
            keyboardType: keyboardType,
            maxLines: maxLines,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

// Utility method to calculate tyres per row
  int _calculateTyresPerRow(double width) {
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }

  // Utility method to calculate cross-axis count
  int _calculateCrossAxisCount(double width) {
    if (width > 1200) return 3;
    if (width > 800) return 2;
    return 1;
  }

  Widget _buildActionButtons(
      {required void Function()? onPressedSave,
      required void Function()? onPressedCancel}) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: onPressedSave,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: onPressedCancel,
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800]!,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Utility Widgets for Different Field Types
  Widget _buildReadOnlyField(String label, dynamic value) {
    return ListTile(
      title: Text(label, style: const TextStyle(fontSize: 12)),
      subtitle: Text(value.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<T> options,
    required void Function(T?)? onChanged,
    String? Function(T?)? validator,
    String Function(T)? displayTextBuilder, // Optional custom display text
  }) {
    return DropdownButtonHideUnderline(
      child: DropdownButtonFormField<T>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        value: value,
        items: options.map((value) {
          return DropdownMenuItem<T>(
            value: value,
            child: Text(displayTextBuilder != null
                ? displayTextBuilder(value)
                : value.toString()),
          );
        }).toList(),
        onChanged: onChanged,
        validator: validator,
        isDense: true,
        isExpanded: true,
      ),
    );
  }

  Widget _buildTextFormField(
      {required String label,
      required TextEditingController editingCon,
      void Function(String)? onChanged,
      void Function()? onTap,
      String? Function(String?)? validator,
      bool readOnly = false}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      controller: editingCon,
      onChanged: onChanged,
      validator: validator,
      onTap: onTap,
      readOnly: readOnly,
    );
  }
}
