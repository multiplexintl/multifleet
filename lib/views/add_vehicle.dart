import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:multifleet/controllers/general_masters.dart';
import 'package:multifleet/controllers/loading_controller.dart';
import 'package:multifleet/models/fuel_station/fuel_station.dart';
import 'package:multifleet/models/status_master/status_master.dart';
import 'package:multifleet/theme/app_theme.dart';
import 'package:multifleet/widgets/auto_complete_field.dart';
import 'package:multifleet/widgets/loading.dart';

import '../controllers/add_edit_vehicle_controller.dart';
import '../models/city/city.dart';
import '../models/company.dart';
import '../models/doc_master.dart';
import '../models/vehicle.dart';

import '../models/vehicle_image.dart';
import '../widgets/custom_widgets.dart';
import '../widgets/multi_select_drop.dart';
import 'edit_vehicle.dart' show showTyreEditDialog;

// ============================================================
// MANDATORY FIELD CONFIG — set these to control step validation
// ============================================================
const _kRequiresBrand = true; // Step 1: Brand
const _kRequiresModel = true; // Step 1: Model
const _kRequiresVehicleType = true; // Step 1: Vehicle Type dropdown
const _kRequiresYear = true; // Step 1: Year
const _kRequiresChassisNumber = true; // Step 2: Chassis Number
const _kRequiresTrafficFileNumber = true; // Step 2: Traffic File Number
const _kRequiresCondition = true; // Step 3: Condition dropdown
const _kRequiresStatus = true; // Step 3: Status dropdown
const _kRequiresAtLeastOneDoc = false; // Step 3: at least 1 document
const _kRequiresAtLeastOneTyre = false; // Step 4: at least 1 tyre

/// Returns an error message if the step's required fields are missing, else null.
String? _validateStep(int step, AddEditVehicleController con) {
  switch (step) {
    case 0:
      if (_kRequiresBrand && con.createBrandController.text.trim().isEmpty) {
        return 'Brand is required';
      }
      if (_kRequiresModel && con.createModelController.text.trim().isEmpty) {
        return 'Model is required';
      }
      if (_kRequiresVehicleType &&
          con.selectedVehicleTypeCreate.value == null) {
        return 'Vehicle Type is required';
      }
      if (_kRequiresYear && con.yearController.text.trim().isEmpty) {
        return 'Year is required';
      }
      return null;
    case 1:
      if (_kRequiresChassisNumber &&
          con.createChassisNumberController.text.trim().isEmpty) {
        return 'Chassis Number is required';
      }
      if (_kRequiresTrafficFileNumber &&
          con.createTrafficFileNumberController.text.trim().isEmpty) {
        return 'Traffic File Number is required';
      }
      return null;
    case 2:
      if (_kRequiresCondition && con.selectedConditionCreate.value == null) {
        return 'Condition is required';
      }
      if (_kRequiresStatus && con.selectedStatusCreate.value == null) {
        return 'Status is required';
      }
      if (_kRequiresAtLeastOneDoc && con.vehicleDocuments.isEmpty) {
        return 'At least one document is required';
      }
      return null;
    case 3:
      if (_kRequiresAtLeastOneTyre && con.tyresList.isEmpty) {
        return 'At least one tyre is required';
      }
      return null;
    default:
      return null;
  }
}

/// ============================================================
/// VEHICLE NOT FOUND DIALOG
/// ============================================================

void showCreateVehicleDialog() {
  final con = Get.find<AddEditVehicleController>();

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.borderXl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                color: AppColors.warning,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Vehicle Not Found',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'The vehicle with plate number "${con.plateNumberController.text}" does not exist. Would you like to create a new vehicle?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: BorderSide(color: AppColors.divider),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.borderMd,
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      showAddVehicleDialog();
                    },
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: const Text('Create Vehicle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.borderMd,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

/// ============================================================
/// ADD VEHICLE BOTTOM SHEET
/// ============================================================

void showAddVehicleDialog() {
  final con = Get.find<AddEditVehicleController>();
  con.resetFormState();
  con.createPlateNumberController.text = con.plateNumberController.text;
  con.selectedCompanyCreate.value = con.companyService.selectedCompany;

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 700,
          maxHeight: Get.height * 0.87,
        ),
        child: LoadingOverlay(
          loadingController: Get.find<LoadingController>(),
          child: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: ClipRRect(
              borderRadius: AppRadius.borderXl,
              child: Column(
                children: [
                  _buildSheetHeader(con),
                  _buildStepIndicator(con),
                  Expanded(child: Obx(() => _buildStepContent(con))),
                  _buildBottomActions(con),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    barrierDismissible: false,
  );
}

Widget _buildSheetHeader(AddEditVehicleController con) {
  return Container(
    padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
    decoration: BoxDecoration(
      color: AppColors.cardBg,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: AppRadius.borderMd,
          ),
          child: Icon(
            Icons.add_circle_outline_rounded,
            color: AppColors.accent,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add New Vehicle',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Obx(() => Text(
                    _getStepTitle(con.currentStep.value),
                    style:
                        TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  )),
            ],
          ),
        ),
        if (kDebugMode)
          IconButton(
            onPressed: () => con.populateTestData(),
            icon: const Icon(Icons.science_rounded),
            tooltip: 'Load Test Data',
            color: Colors.purple,
          ),
        IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.close_rounded),
          color: AppColors.textMuted,
        ),
      ],
    ),
  );
}

String _getStepTitle(int step) {
  const titles = [
    'Step 1: Basic Information',
    'Step 2: Additional Details',
    'Step 3: Status & Documents',
    'Step 4: Tyres',
    'Step 5: Images',
  ];
  return titles[step];
}

Widget _buildStepIndicator(AddEditVehicleController con) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    child: Obx(() => Row(
          children: List.generate(5, (index) {
            final isActive = con.currentStep.value >= index;
            final isCurrent = con.currentStep.value == index;

            return Expanded(
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (index < con.currentStep.value) {
                        con.currentStep.value = index;
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isCurrent ? 36 : 28,
                      height: isCurrent ? 36 : 28,
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.accent : AppColors.divider,
                        shape: BoxShape.circle,
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: AppColors.accent.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: isActive && !isCurrent
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 16)
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: isActive
                                      ? Colors.white
                                      : AppColors.textMuted,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isCurrent ? 14 : 12,
                                ),
                              ),
                      ),
                    ),
                  ),
                  if (index < 4)
                    Expanded(
                      child: Container(
                        height: 3,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: con.currentStep.value > index
                              ? AppColors.accent
                              : AppColors.divider,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        )),
  );
}

Widget _buildStepContent(AddEditVehicleController con) {
  return AnimatedSwitcher(
    duration: const Duration(milliseconds: 300),
    transitionBuilder: (child, animation) {
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.05, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      );
    },
    child: SingleChildScrollView(
      key: ValueKey(con.currentStep.value),
      padding: const EdgeInsets.all(24),
      child: _getStepWidget(con),
    ),
  );
}

Widget _getStepWidget(AddEditVehicleController con) {
  switch (con.currentStep.value) {
    case 0:
      return _buildBasicInfoStep(con);
    case 1:
      return _buildAdditionalDetailsStep(con);
    case 2:
      return _buildStatusDocumentsStep(con);
    case 3:
      return _buildTyresStep(con);
    case 4:
      return _buildImagesStep(con);
    default:
      return const SizedBox();
  }
}

Widget _buildBottomActions(AddEditVehicleController con) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.cardBg,
      border: Border(top: BorderSide(color: AppColors.divider)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    child: Obx(() => Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  if (con.currentStep.value > 0) {
                    con.currentStep.value--;
                  } else {
                    Get.back();
                  }
                },
                icon: Icon(
                  con.currentStep.value == 0 ? Icons.close : Icons.arrow_back,
                  size: 20,
                ),
                label: Text(con.currentStep.value == 0 ? 'Cancel' : 'Back'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: BorderSide(color: AppColors.divider),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape:
                      RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (con.currentStep.value < 4) {
                    final error = _validateStep(con.currentStep.value, con);
                    if (error != null) {
                      CustomWidget.customSnackBar(
                        title: 'Required',
                        message: error,
                        isError: true,
                      );
                      return;
                    }
                    con.currentStep.value++;
                  } else {
                    _submitVehicleForm();
                  }
                },
                icon: Icon(
                  con.currentStep.value == 4
                      ? Icons.check_circle
                      : Icons.arrow_forward,
                  size: 20,
                ),
                label: Text(
                  con.currentStep.value == 4 ? 'Create Vehicle' : 'Continue',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: con.currentStep.value == 4
                      ? AppColors.success
                      : AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape:
                      RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
                ),
              ),
            ),
          ],
        )),
  );
}

void _submitVehicleForm() async {
  final con = Get.find<AddEditVehicleController>();

  final vehicle = Vehicle(
    company: con.selectedCompanyCreate.value?.id,
    vehicleNo: con.createPlateNumberController.text,
    description: con.createDescriptionController.text,
    brand: con.createBrandController.text,
    model: con.createModelController.text,
    cityIds:
        con.selectedCitiesCreate.map((c) => c.cityId).whereType<int>().toList(),
    initialOdo: int.tryParse(con.initialOdoController.text) ?? 0,
    currentOdo: int.tryParse(con.currentOdoController.text),
    vehicleStatusId: con.selectedStatusCreate.value?.statusId,
    vehicleTypeId: con.selectedVehicleTypeCreate.value?.statusId,
    traficFileNo: con.createTrafficFileNumberController.text,
    fuelStationId: con.selectedFuelStationCreate.value?.fuelStationId,
    vYear: int.tryParse(con.yearController.text),
    chassisNo: con.createChassisNumberController.text,
    conditionId: con.selectedConditionCreate.value?.statusId,
    documents: con.vehicleDocuments,
    tyres: con.tyresList.toList(),
  );

  await con.createUpdateVehicle(newVehicle: vehicle, isNew: true);
}

/// ============================================================
/// STEP 1: BASIC INFORMATION
/// ============================================================

Widget _buildBasicInfoStep(AddEditVehicleController con) {
  final genCon = Get.find<GeneralMastersController>();

  return _SectionCard(
    title: 'Vehicle Identity',
    icon: Icons.directions_car_outlined,
    children: [
      _ResponsiveRow(children: [
        Obx(() => _StyledDropdown<Company>(
              label: 'Company',
              value: con.selectedCompanyCreate.value,
              items: con.companyService.companyList,
              displayBuilder: (c) => c.name ?? '',
              onChanged: (val) => con.selectedCompanyCreate.value = val,
              icon: Icons.business_outlined,
              isRequired: true,
              isReadOnly: true,
            )),
        _StyledTextField(
          controller: con.createPlateNumberController,
          label: 'Plate Number',
          icon: Icons.confirmation_number_outlined,
          isRequired: true,
          readOnly: true,
        ),
      ]),
      const SizedBox(height: 16),
      Builder(
        builder: (context) => _ResponsiveRow(children: [
          buildAutocompleteTextField(
            context: context,
            storageKey: 'vehicle_brands',
            controller: con.createBrandController,
            label: 'Brand',
            icon: Icons.branding_watermark_outlined,
            isRequired: true,
            initialSuggestions: con.getBrandSuggestions(),
          ),
          buildAutocompleteTextField(
            context: context,
            storageKey: 'vehicle_models',
            controller: con.createModelController,
            label: 'Model',
            icon: Icons.model_training_outlined,
            isRequired: true,
            initialSuggestions: con.getModelSuggestions(),
          ),
        ]),
      ),
      const SizedBox(height: 16),
      _ResponsiveRow(children: [
        Obx(() => _StyledDropdown<StatusMaster>(
              label: 'Vehicle Type',
              value: con.selectedVehicleTypeCreate.value,
              items: genCon.vehicleTypeMasters,
              displayBuilder: (t) => t.status ?? '',
              onChanged: (val) => con.selectedVehicleTypeCreate.value = val,
              icon: Icons.category_outlined,
            )),
        _StyledDateField(
          controller: con.yearController,
          label: 'Year',
          icon: Icons.calendar_today_outlined,
          yearOnly: true,
          allowPastDates: true,
        ),
      ]),
    ],
  );
}

/// ============================================================
/// STEP 2: ADDITIONAL DETAILS
/// ============================================================

Widget _buildAdditionalDetailsStep(AddEditVehicleController con) {
  var genCon = Get.find<GeneralMastersController>();

  return Column(
    children: [
      _SectionCard(
        title: 'Registration Details',
        icon: Icons.assignment_outlined,
        children: [
          _ResponsiveRow(children: [
            _StyledTextField(
              controller: con.createChassisNumberController,
              label: 'Chassis Number',
              icon: Icons.tag_outlined,
            ),
            _StyledTextField(
              controller: con.createTrafficFileNumberController,
              label: 'Traffic File Number',
              icon: Icons.folder_outlined,
            ),
          ]),
        ],
      ),
      const SizedBox(height: 16),
      _SectionCard(
        title: 'Usage Information',
        icon: Icons.speed_outlined,
        children: [
          _ResponsiveRow(children: [
            _StyledTextField(
              controller: con.initialOdoController,
              label: 'Initial Odometer (KM)',
              icon: Icons.speed_outlined,
              keyboardType: TextInputType.number,
            ),
            Obx(() => _StyledDropdown<FuelStation>(
                  label: 'Fuel Station',
                  value: con.selectedFuelStationCreate.value,
                  items: genCon.availableFuelStations,
                  displayBuilder: (f) => f.fuelStation ?? '',
                  onChanged: (val) => con.selectedFuelStationCreate.value = val,
                  icon: Icons.local_gas_station_outlined,
                )),
          ]),
          const SizedBox(height: 16),
          _ResponsiveRow(children: [
            Obx(() => buildMultiSelectField<City>(
                  label: 'Permitted Areas',
                  options: genCon.companyCity.toList(),
                  displayBuilder: (c) => c.city ?? '',
                  initiallySelected: con.selectedCitiesCreate.toList(),
                  onChanged: (cities) => con.updateVehicleCity(cities),
                )),
            _StyledTextField(
              controller: con.createDescriptionController,
              label: 'Remarks',
              icon: Icons.notes_outlined,
            ),
          ]),
        ],
      ),
    ],
  );
}

/// ============================================================
/// STEP 3: STATUS & DOCUMENTS
/// ============================================================

Widget _buildStatusDocumentsStep(AddEditVehicleController con) {
  var genCon = Get.find<GeneralMastersController>();

  return Column(
    children: [
      _SectionCard(
        title: 'Vehicle Status',
        icon: Icons.flag_outlined,
        children: [
          _ResponsiveRow(children: [
            Obx(() => _StyledDropdown<StatusMaster>(
                  label: 'Condition',
                  value: con.selectedConditionCreate.value,
                  items: genCon.vehicleConditionMasters,
                  displayBuilder: (c) => c.status ?? '',
                  onChanged: (val) => con.selectedConditionCreate.value = val,
                  icon: Icons.assessment_outlined,
                )),
            Obx(() => _StyledDropdown<StatusMaster>(
                  label: 'Status',
                  value: con.selectedStatusCreate.value,
                  items: genCon.vehicleStatusMasters,
                  displayBuilder: (s) => s.status ?? '',
                  onChanged: (val) => con.selectedStatusCreate.value = val,
                  icon: Icons.toggle_on_outlined,
                )),
          ]),
        ],
      ),
      const SizedBox(height: 16),
      _SectionCard(
        title: 'Vehicle Documents',
        icon: Icons.description_outlined,
        trailing: _SmallButton(
          text: 'Add Document',
          icon: Icons.add_rounded,
          onPressed: () => _showAddDocumentDialog(Get.context!, con),
          color: AppColors.accent,
        ),
        children: [
          Obx(() => con.vehicleDocuments.isEmpty
              ? _EmptyPlaceholder(
                  icon: Icons.description_outlined,
                  message: 'No documents added yet',
                )
              : Column(
                  children: List.generate(
                    con.vehicleDocuments.length,
                    (index) => _buildDocumentCard(con, index),
                  ),
                )),
        ],
      ),
    ],
  );
}

Widget _buildDocumentCard(AddEditVehicleController con, int index) {
  var genCon = Get.find<GeneralMastersController>();

  final document = con.vehicleDocuments[index];
  final docTypeDescription =
      genCon.getDocumentTypeDescription(document.docType);

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: AppRadius.borderMd,
      border: Border.all(color: AppColors.divider),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: AppRadius.borderSm,
              ),
              child: Icon(Icons.article_outlined,
                  color: AppColors.accent, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                docTypeDescription ?? 'Document',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: AppColors.error, size: 20),
              onPressed: () => con.removeDocumentCreate(index),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const Divider(height: 24),
        _ResponsiveRow(children: [
          _StyledDateField(
            controller: con.createDocumentIssueDateControllers[index],
            label: 'Issue Date',
            icon: Icons.calendar_today_outlined,
            allowPastDates: true,
          ),
          _StyledDateField(
            controller: con.documentExpiryControllers[index],
            label: 'Expiry Date',
            icon: Icons.event_outlined,
          ),
        ]),
        const SizedBox(height: 12),
        _ResponsiveRow(children: [
          _StyledTextField(
            controller: con.createDocumentIssueAuthorityControllers[index],
            label: 'Issue Authority',
            icon: Icons.business_outlined,
            onChanged: (val) => con.updateDocumentIssueAuthority(index, val),
          ),
          _StyledDropdown<City>(
            label: 'City',
            value: genCon.companyCity
                .firstWhereOrNull((c) => c.city == document.city),
            items: genCon.companyCity.toList(),
            displayBuilder: (c) => c.city ?? '',
            onChanged: (c) => con.updateDocumentCity(index, c?.city),
            icon: Icons.location_city_outlined,
          )
        ]),
        const SizedBox(height: 12),
        _ResponsiveRow(children: [
          _StyledTextField(
            controller: con.createDocumentAmountControllers[index],
            label: 'Amount',
            icon: Icons.attach_money_outlined,
            keyboardType: TextInputType.number,
            onChanged: (val) => con.updateDocumentAmount(index, val),
          ),
          _StyledTextField(
            controller: con.createDocumentRemarksControllers[index],
            label: 'Remarks',
            icon: Icons.notes_outlined,
            onChanged: (val) => con.updateDocumentRemarks(index, val),
          ),
        ]),
      ],
    ),
  );
}

void _showAddDocumentDialog(
    BuildContext context, AddEditVehicleController con) {
  final selectedDocTypeId = RxnInt();
  var genCon = Get.find<GeneralMastersController>();

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.borderXl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: AppRadius.borderMd,
                  ),
                  child: Icon(Icons.post_add_rounded, color: AppColors.accent),
                ),
                const SizedBox(width: 12),
                Text(
                  'Add Document',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Obx(() => DropdownButtonFormField<int>(
                  value: selectedDocTypeId.value,
                  decoration: InputDecoration(
                    labelText: 'Select Document Type',
                    prefixIcon: Icon(Icons.description_outlined,
                        color: AppColors.accent),
                    filled: true,
                    fillColor: AppColors.cardBg,
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.borderMd,
                      borderSide: BorderSide.none,
                    ),
                  ),
                  borderRadius: AppRadius.borderLg,
                  dropdownColor: AppColors.surface,
                  items: genCon.companyDocumentTypes.map((type) {
                    return DropdownMenuItem<int>(
                      value: type.docType,
                      child: Text(type.docDescription ?? 'Unknown'),
                    );
                  }).toList(),
                  onChanged: (val) => selectedDocTypeId.value = val,
                )),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => ElevatedButton(
                        onPressed: selectedDocTypeId.value == null
                            ? null
                            : () {
                                final docType =
                                    genCon.companyDocumentTypes.firstWhere(
                                  (type) =>
                                      type.docType == selectedDocTypeId.value,
                                  orElse: () => DocumentMaster(),
                                );
                                con.addDocumentCreate(docType);
                                Get.back();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Add'),
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

/// ============================================================
/// STEP 4: TYRES
/// ============================================================

Widget _buildTyresStep(AddEditVehicleController con) {
  return _SectionCard(
    title: 'Vehicle Tyres',
    icon: Icons.tire_repair_outlined,
    trailing: Builder(builder: (ctx) {
      return Obx(() => _SmallButton(
            text: 'Add Tyre',
            icon: Icons.add_rounded,
            color: AppColors.accent,
            onPressed: con.tyresList.length < con.maxTyresAllowed
                ? () {
                    final newIndex = con.createAddNewTyre();
                    if (newIndex >= 0) {
                      showTyreEditDialog(
                        ctx,
                        con,
                        con.tyresList[newIndex],
                        newIndex,
                        isNew: true,
                        isCreateMode: true,
                      );
                    }
                  }
                : null,
          ));
    }),
    headerExtra: Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: AppRadius.borderSm,
          ),
          child: Text(
            '${con.tyresList.length}/${con.maxTyresAllowed}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
            ),
          ),
        )),
    children: [
      Obx(() => con.tyresList.isEmpty
          ? _EmptyPlaceholder(
              icon: Icons.tire_repair_outlined,
              message: 'No tyres added yet',
            )
          : Builder(
              builder: (ctx) => ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: con.tyresList.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, index) => _CreateTyreRow(
                  con: con,
                  index: index,
                  ctx: ctx,
                ),
              ),
            )),
    ],
  );
}

/// Compact tyre row for the create flow — tapping opens the shared tyre dialog.
class _CreateTyreRow extends StatelessWidget {
  final AddEditVehicleController con;
  final int index;
  final BuildContext ctx;

  const _CreateTyreRow({
    required this.con,
    required this.index,
    required this.ctx,
  });

  @override
  Widget build(BuildContext context) {
    final tyre = con.tyresList[index];
    final isActive = (tyre.status ?? 'Active') == 'Active';
    final posLabel = tyre.position?.status ?? 'Tyre ${index + 1}';
    final brandSize = [tyre.brand, tyre.size]
        .where((s) => s != null && s.isNotEmpty)
        .join(' · ');

    return InkWell(
      onTap: () => showTyreEditDialog(
        ctx,
        con,
        tyre,
        index,
        isNew: false,
        isCreateMode: true,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Status colour bar
            Container(
              width: 3,
              height: 32,
              decoration: BoxDecoration(
                color: isActive ? AppColors.success : AppColors.error,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            // Position badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: AppRadius.borderSm,
              ),
              child: Text(
                posLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Brand · size
            Expanded(
              child: Text(
                brandSize.isNotEmpty ? brandSize : 'Tap to edit',
                style: TextStyle(
                  fontSize: 13,
                  color: brandSize.isNotEmpty
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Edit chevron
            Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
            // Delete button
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: AppColors.error, size: 18),
              onPressed: () => con.createRemoveTyre(index),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================
/// STEP 5: IMAGES
/// ============================================================

Widget _buildImagesStep(AddEditVehicleController con) {
  return _SectionCard(
    title: 'Vehicle Images',
    icon: Icons.photo_library_outlined,
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SmallButton(
          text: 'Add',
          icon: Icons.add_a_photo_outlined,
          onPressed: con.vehicleImages.length < 6
              ? () => _pickImage(Get.context!, con, false)
              : null,
          color: AppColors.accent,
        ),
        const SizedBox(width: 8),
        _SmallButton(
          text: 'Multiple',
          icon: Icons.photo_library_outlined,
          color: AppColors.success,
          onPressed: con.vehicleImages.length < 6
              ? () => _pickImage(Get.context!, con, true)
              : null,
        ),
      ],
    ),
    headerExtra: Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: AppRadius.borderSm,
          ),
          child: Text(
            '${con.vehicleImages.length}/6',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
            ),
          ),
        )),
    children: [
      Obx(() => con.vehicleImages.isEmpty
          ? _EmptyPlaceholder(
              icon: Icons.image_outlined,
              message: 'No images added yet',
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 500 ? 3 : 2;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemCount: con.vehicleImages.length,
                  itemBuilder: (context, index) => _buildImageCard(con, index),
                );
              },
            )),
    ],
  );
}

Widget _buildImageCard(AddEditVehicleController con, int index) {
  final image = con.vehicleImages[index];
  final isPrimary = index == con.primaryImageIndex.value;

  return Container(
    decoration: BoxDecoration(
      borderRadius: AppRadius.borderMd,
      border: Border.all(
        color: isPrimary ? AppColors.accent : AppColors.divider,
        width: isPrimary ? 2 : 1,
      ),
    ),
    child: ClipRRect(
      borderRadius: AppRadius.borderMd,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildImageWidget(image),
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: () => con.removeImage(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
          Positioned(
            bottom: 6,
            left: 6,
            child: isPrimary
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: AppRadius.borderSm,
                    ),
                    child: const Text(
                      'Main',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: () => con.setPrimaryImage(index),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: AppRadius.borderSm,
                      ),
                      child: const Icon(Icons.star_border,
                          color: Colors.white, size: 16),
                    ),
                  ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildImageWidget(VehicleImage image) {
  if (image.isNetworkImage &&
      image.imageUrl != null &&
      image.imageUrl!.isNotEmpty) {
    return Image.network(
      image.imageUrl!,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: progress.expectedTotalBytes != null
                ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                : null,
            strokeWidth: 2,
            color: AppColors.accent,
          ),
        );
      },
      errorBuilder: (_, __, ___) => _imagePlaceholder(),
    );
  } else if (image.webImage != null) {
    return Image.memory(
      image.webImage!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _imagePlaceholder(),
    );
  }
  return _imagePlaceholder();
}

Widget _imagePlaceholder() {
  return Container(
    color: AppColors.surface,
    child: Center(
      child: Icon(Icons.image_not_supported_outlined,
          color: AppColors.textMuted, size: 32),
    ),
  );
}

Future<void> _pickImage(
    BuildContext context, AddEditVehicleController con, bool multiple) async {
  try {
    if (multiple) {
      await con.pickMultipleImages();
    } else {
      await con.pickSingleImage();
    }
  } catch (e) {
    CustomWidget.customSnackBar(
      isError: true,
      title: "Error",
      message: 'Failed to pick image: ${e.toString()}',
    );
  }
}

/// ============================================================
/// REUSABLE WIDGETS
/// ============================================================

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final Widget? trailing;
  final Widget? headerExtra;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
    this.trailing,
    this.headerExtra,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: AppRadius.borderLg,
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: AppRadius.borderSm,
                  ),
                  child: Icon(icon, color: AppColors.accent, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (headerExtra != null) ...[
                        const SizedBox(width: 8),
                        headerExtra!,
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponsiveRow extends StatelessWidget {
  final List<Widget> children;

  const _ResponsiveRow({required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 500) {
          return Column(
            children: children
                .map((child) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: child,
                    ))
                .toList(),
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children.asMap().entries.map((entry) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: entry.key < children.length - 1 ? 12 : 0,
                ),
                child: entry.value,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _EmptyPlaceholder extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyPlaceholder({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 48, color: AppColors.textMuted.withOpacity(0.5)),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;

  const _SmallButton({
    required this.text,
    required this.icon,
    this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(text, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderSm),
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final bool isRequired;
  final bool readOnly;
  final TextInputType keyboardType;
  final Function(String)? onChanged;

  const _StyledTextField({
    required this.controller,
    required this.label,
    this.icon,
    this.isRequired = false,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        labelStyle: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        prefixIcon:
            icon != null ? Icon(icon, color: AppColors.accent, size: 20) : null,
        filled: true,
        fillColor:
            readOnly ? AppColors.divider.withOpacity(0.3) : AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(color: AppColors.accent, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}

class _StyledDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) displayBuilder;
  final Function(T?) onChanged;
  final IconData? icon;
  final bool isRequired;
  final bool isReadOnly;

  const _StyledDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.displayBuilder,
    required this.onChanged,
    this.icon,
    this.isRequired = false,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(displayBuilder(item),
                    style: const TextStyle(fontSize: 14)),
              ))
          .toList(),
      onChanged: isReadOnly ? null : onChanged,
      isDense: true,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        labelStyle: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        prefixIcon:
            icon != null ? Icon(icon, color: AppColors.accent, size: 20) : null,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(color: AppColors.accent, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      dropdownColor: AppColors.cardBg,
      borderRadius: AppRadius.borderMd,
    );
  }
}

class _StyledDateField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool allowPastDates;
  final bool yearOnly;
  final Function(DateTime?)? onDateSelected;

  const _StyledDateField({
    required this.controller,
    required this.label,
    required this.icon,
    this.allowPastDates = false,
    this.yearOnly = false,
    this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: () async {
        if (yearOnly) {
          await _showYearPicker(controller, allowPastDates, onDateSelected);
        } else {
          await _showFullDatePicker(controller, allowPastDates, onDateSelected);
        }
      },
      style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.accent, size: 20),
        suffixIcon: Icon(Icons.calendar_today_outlined,
            color: AppColors.textMuted, size: 18),
        hintText: yearOnly ? 'YYYY' : 'YYYY-MM-DD',
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(color: AppColors.accent, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}

Future<void> _showFullDatePicker(
  TextEditingController controller,
  bool allowPastDates,
  Function(DateTime?)? onDateSelected,
) async {
  DateTime initialDate = DateTime.now();
  if (controller.text.isNotEmpty) {
    try {
      initialDate = DateFormat('yyyy-MM-dd').parse(controller.text);
    } catch (_) {}
  }

  final DateTime? pickedDate = await showDatePicker(
    context: Get.context!,
    initialDate: initialDate,
    firstDate: allowPastDates
        ? DateTime.now().subtract(const Duration(days: 365 * 10))
        : DateTime.now(),
    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.accent,
            onPrimary: Colors.white,
            surface: AppColors.cardBg,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      );
    },
  );

  if (pickedDate != null) {
    controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    onDateSelected?.call(pickedDate);
  }
}

Future<void> _showYearPicker(
  TextEditingController controller,
  bool allowPastDates,
  Function(DateTime?)? onDateSelected,
) async {
  int initialYear = DateTime.now().year;
  if (controller.text.isNotEmpty) {
    try {
      initialYear = int.parse(controller.text);
    } catch (_) {}
  }

  int minYear = allowPastDates ? DateTime.now().year - 25 : DateTime.now().year;
  int maxYear = DateTime.now().year + 1;
  initialYear = initialYear.clamp(minYear, maxYear);

  final int? selectedYear = await showDialog<int>(
    context: Get.context!,
    builder: (context) => _YearPickerDialog(
      initialYear: initialYear,
      minYear: minYear,
      maxYear: maxYear,
    ),
  );

  if (selectedYear != null) {
    controller.text = selectedYear.toString();
    onDateSelected?.call(DateTime(selectedYear, 1, 1));
  }
}

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
  State<_YearPickerDialog> createState() => _YearPickerDialogState();
}

class _YearPickerDialogState extends State<_YearPickerDialog> {
  late int selectedYear;
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    selectedYear = widget.initialYear;
    scrollController = ScrollController(
      initialScrollOffset: (widget.initialYear - widget.minYear) * 52.0,
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Year',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: ListView.builder(
                controller: scrollController,
                itemCount: widget.maxYear - widget.minYear + 1,
                itemBuilder: (context, index) {
                  final year = widget.minYear + index;
                  final isSelected = year == selectedYear;

                  return GestureDetector(
                    onTap: () => setState(() => selectedYear = year),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accent.withOpacity(0.1)
                            : null,
                        borderRadius: AppRadius.borderSm,
                      ),
                      child: Text(
                        year.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(selectedYear),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('OK'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
