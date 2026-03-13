import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:multifleet/controllers/general_masters.dart';
import 'package:multifleet/models/city/city.dart';
import 'package:multifleet/models/doc_master.dart';
import 'package:multifleet/models/fuel_station/fuel_station.dart';
import 'package:multifleet/models/status_master/status_master.dart';
import 'package:multifleet/models/tyre.dart';
import 'package:multifleet/widgets/search_vehicle.dart';

import '../controllers/add_edit_vehicle_controller.dart';
import '../models/vehicle.dart';
import '../models/vehicle_docs.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_widgets.dart';
import '../widgets/multi_select_drop.dart';

/// ============================================================
/// EDIT VEHICLE PAGE
/// ============================================================
/// A full-page view for searching and editing vehicle details.
/// Features:
/// - Search by license plate with multi-vehicle selection
/// - Permanent details (read-only)
/// - Changeable details (editable)
/// - Documents management with DataTable/Card responsive view
/// - Tyres management with responsive grid
/// ============================================================

class AddEditVehiclePage extends StatelessWidget {
  const AddEditVehiclePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddEditVehicleController());

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search Section
              SearchVehicleWidget(
                heading: "Search Vehicle",
                controller: controller.plateNumberController,
                onSearch: () => _handleSearch(controller),
                onClear: () => controller.clearSearch(),
                onDataChanged: (plate) {
                  controller.onPlateChanged(
                      plate.code, plate.region, plate.number);
                },
              ),

              const SizedBox(height: AppSpacing.xl),

              // Vehicle Details Section (conditional)
              Obx(() {
                if (controller.isSearching.value) {
                  return _buildLoadingState();
                } else if (controller.vehicleData.value != null) {
                  return _buildVehicleDetailsSection(controller);
                } else {
                  return _buildEmptyState();
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // STATES
  // ============================================================

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: AppRadius.borderLg,
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        children: [
          CircularProgressIndicator(color: AppColors.accent),
          const SizedBox(height: AppSpacing.lg),
          Text('Searching...', style: AppTextStyles.body),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: AppRadius.borderLg,
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.directions_car_outlined,
              size: 48,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Search for a Vehicle',
            style: AppTextStyles.h4.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Enter the license plate number above to find and edit a vehicle',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SEARCH HANDLER
  // ============================================================

  void _handleSearch(AddEditVehicleController controller) async {
    log(controller.plateNumberController.text);

    if (controller.plateNumberController.text.contains('null')) {
      CustomWidget.customSnackBar(
          title: 'Error',
          message: 'Please enter a plate number',
          isError: true);
      return;
    }

    controller.searchVehicle();
  }

  /// Show dialog when multiple vehicles are found
  void _showVehicleSelectionDialog(
    AddEditVehicleController controller,
    List<Vehicle> vehicles,
  ) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
        child: Container(
          width: 500,
          constraints: const BoxConstraints(maxHeight: 500),
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.format_list_bulleted_outlined,
                  color: AppColors.info,
                  size: 28,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Multiple Vehicles Found', style: AppTextStyles.h4),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Select the vehicle you want to edit',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: AppSpacing.lg),
              Divider(color: AppColors.divider),

              // Vehicle list
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: vehicles.length,
                  separatorBuilder: (_, __) => Divider(
                    color: AppColors.divider,
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final vehicle = vehicles[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.borderMd,
                      ),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.1),
                          borderRadius: AppRadius.borderMd,
                        ),
                        child: Icon(
                          Icons.directions_car_outlined,
                          color: AppColors.accent,
                        ),
                      ),
                      title: Text(
                        vehicle.vehicleNo ?? 'Unknown',
                        style: AppTextStyles.label,
                      ),
                      subtitle: Text(
                        '${vehicle.brand ?? ''} ${vehicle.model ?? ''}'.trim(),
                        style: AppTextStyles.bodySmall,
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: AppColors.textMuted,
                      ),
                      onTap: () {
                        Get.back();
                        controller.vehicleData.value = vehicle;
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
              // Cancel button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: BorderSide(color: AppColors.divider),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.borderMd,
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // VEHICLE DETAILS SECTION
  // ============================================================

  Widget _buildVehicleDetailsSection(AddEditVehicleController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: AppRadius.borderLg,
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Vehicle header
          _buildVehicleHeader(controller),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Permanent Details Section
                _SectionCard(
                  icon: Icons.lock_outlined,
                  title: 'Permanent Vehicle Details',
                  subtitle: 'These details cannot be modified',
                  child: _buildPermanentDetailsContent(controller),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Changeable Details Section
                _SectionCard(
                  icon: Icons.edit_outlined,
                  title: 'Editable Details',
                  child: _buildChangeableDetailsContent(controller),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Documents Section
                _buildDocumentsSection(controller),

                const SizedBox(height: AppSpacing.xl),

                // Tyres Section
                _buildTyresSection(controller),

                const SizedBox(height: AppSpacing.xxl),

                // Action Buttons
                _buildActionButtons(controller),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleHeader(AddEditVehicleController controller) {
    final vehicle = controller.vehicleData.value!;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.lg),
          topRight: Radius.circular(AppRadius.lg),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: AppRadius.borderMd,
            ),
            child: Icon(
              Icons.directions_car,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle.vehicleNo ?? 'Unknown',
                  style: AppTextStyles.h3.copyWith(color: Colors.white),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${vehicle.brand ?? ''} ${vehicle.model ?? ''} • ${vehicle.type ?? ''}'
                      .trim(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.getStatusBgColor(vehicle.status),
              borderRadius: AppRadius.borderFull,
            ),
            child: Text(
              vehicle.status ?? 'Unknown',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.getStatusColor(vehicle.status),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PERMANENT DETAILS
  // ============================================================

  Widget _buildPermanentDetailsContent(AddEditVehicleController controller) {
    final vehicle = controller.vehicleData.value!;

    String companyName = 'Unknown';
    try {
      companyName = controller.companyService.companyList
              .firstWhere((c) => c.id == vehicle.company)
              .name ??
          'Unknown';
    } catch (_) {}

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;

        return Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.lg,
          children: [
            _ReadOnlyField(
              label: 'Plate Number',
              value: vehicle.vehicleNo ?? '-',
              icon: Icons.confirmation_number_outlined,
              width: isWide ? (constraints.maxWidth - AppSpacing.lg) / 2 : null,
            ),
            _ReadOnlyField(
              label: 'Brand',
              value: vehicle.brand ?? '-',
              icon: Icons.branding_watermark_outlined,
              width: isWide ? (constraints.maxWidth - AppSpacing.lg) / 2 : null,
            ),
            _ReadOnlyField(
              label: 'Model',
              value: vehicle.model ?? '-',
              icon: Icons.model_training_outlined,
              width: isWide ? (constraints.maxWidth - AppSpacing.lg) / 2 : null,
            ),
            _ReadOnlyField(
              label: 'Type',
              value: vehicle.type ?? '-',
              icon: Icons.category_outlined,
              width: isWide ? (constraints.maxWidth - AppSpacing.lg) / 2 : null,
            ),
            _ReadOnlyField(
              label: 'Chassis Number',
              value: vehicle.chassisNo ?? '-',
              icon: Icons.tag_outlined,
              width: isWide ? (constraints.maxWidth - AppSpacing.lg) / 2 : null,
            ),
            _ReadOnlyField(
              label: 'Traffic File Number',
              value: vehicle.traficFileNo ?? '-',
              icon: Icons.folder_outlined,
              width: isWide ? (constraints.maxWidth - AppSpacing.lg) / 2 : null,
            ),
            _ReadOnlyField(
              label: 'Company',
              value: companyName,
              icon: Icons.business_outlined,
              width: isWide ? (constraints.maxWidth - AppSpacing.lg) / 2 : null,
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // CHANGEABLE DETAILS
  // ============================================================

  Widget _buildChangeableDetailsContent(AddEditVehicleController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        var genCon = Get.find<GeneralMastersController>();
        return Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.lg,
          children: [
            _StyledTextField(
              label: 'Current Odometer (KM)',
              controller: controller.currentOdoController,
              icon: Icons.speed_outlined,
              keyboardType: TextInputType.number,
              onChanged: controller.updateCurrentOdometer,
              width: isWide ? (constraints.maxWidth - AppSpacing.lg) / 2 : null,
            ),
            SizedBox(
              width: isWide ? (constraints.maxWidth - AppSpacing.lg) / 2 : null,
              child: Obx(() {
                final selected = controller.getSelectedCities();
                return MultiSelectDropDown<City>(
                  key: ValueKey(
                      controller.vehicleData.value?.vehicleNo ?? 'new'),
                  label: 'Permitted Areas',
                  options: genCon.companyCity.toList(),
                  displayBuilder: (c) => c.city ?? '',
                  initiallySelected: selected,
                  onChanged: (cities) => controller.updateVehicleCity(cities),
                );
              }),
            ),
            _StyledDropdown<StatusMaster>(
              label: 'Vehicle Condition',
              value: controller.selectedConditionCreate.value,
              items: genCon.vehicleConditionMasters,
              icon: Icons.health_and_safety_outlined,
              displayBuilder: (c) => c.status ?? '',
              onChanged: controller.updateVehicleCondition,
              width: isWide ? (constraints.maxWidth - AppSpacing.lg) / 2 : null,
            ),
            _StyledDropdown<FuelStation>(
              label: 'Fuel Station',
              value: controller.selectedFuelStationCreate.value,
              items: genCon.availableFuelStations,
              icon: Icons.local_gas_station_outlined,
              displayBuilder: (f) => f.fuelStation ?? '',
              onChanged: controller.updateFuelStation,
              width: isWide ? (constraints.maxWidth - AppSpacing.lg) / 2 : null,
            ),
            _StyledDropdown<StatusMaster>(
              label: 'Vehicle Status',
              value: controller.selectedStatusCreate.value,
              items: genCon.vehicleStatusMasters,
              icon: Icons.toggle_on_outlined,
              displayBuilder: (s) => s.status ?? '',
              onChanged: controller.updateVehicleStatus,
              width: isWide ? (constraints.maxWidth - AppSpacing.lg) / 2 : null,
            ),
            _StyledTextField(
              label: 'Description / Remarks',
              controller: controller.descriptionController,
              icon: Icons.notes_outlined,
              onChanged: controller.updateVehicleDescription,
              width: isWide ? (constraints.maxWidth - AppSpacing.lg) / 2 : null,
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // DOCUMENTS SECTION
  // ============================================================

  Widget _buildDocumentsSection(AddEditVehicleController controller) {
    return Obx(() {
      final documents = controller.vehicleData.value?.documents ?? [];

      return _SectionCard(
        icon: Icons.description_outlined,
        title: 'Vehicle Documents',
        headerExtra: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: AppRadius.borderFull,
          ),
          child: Text(
            '${documents.length}',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        trailing: _SmallButton(
          label: 'Add Document',
          icon: Icons.add_outlined,
          onPressed: () => _showAddDocumentDialog(controller),
        ),
        child: documents.isEmpty
            ? _EmptyPlaceholder(
                icon: Icons.description_outlined,
                message: 'No documents added yet',
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 700) {
                    return _buildDocumentsTable(controller, documents);
                  } else {
                    return _buildDocumentsCards(controller, documents);
                  }
                },
              ),
      );
    });
  }

  Widget _buildDocumentsTable(
    AddEditVehicleController controller,
    List<VehicleDocument> documents,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: AppRadius.borderMd,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.borderMd,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(AppColors.surface),
            dataRowMinHeight: 52,
            dataRowMaxHeight: 60,
            columnSpacing: 24,
            horizontalMargin: 16,
            headingTextStyle: AppTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
            columns: const [
              DataColumn(label: Text('Type')),
              DataColumn(label: Text('Issue Date')),
              DataColumn(label: Text('Expiry Date')),
              DataColumn(label: Text('Authority')),
              DataColumn(label: Text('City')),
              DataColumn(label: Text('Amount')),
              DataColumn(label: Text('Actions')),
            ],
            rows: documents.map((doc) {
              final docTypeName = _getDocTypeName(controller, doc.docType);
              final expiryColor = AppColors.getExpiryColor(doc.expiryDate);

              return DataRow(
                cells: [
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        borderRadius: AppRadius.borderSm,
                      ),
                      child: Text(
                        docTypeName,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  DataCell(Text(
                    doc.formatDate(doc.issueDate),
                    style: AppTextStyles.body,
                  )),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          doc.formatDate(doc.expiryDate),
                          style: AppTextStyles.body,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: expiryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(Text(
                    doc.issueAuthority ?? '-',
                    style: AppTextStyles.body,
                  )),
                  DataCell(Text(
                    doc.city ?? '-',
                    style: AppTextStyles.body,
                  )),
                  DataCell(Text(
                    doc.amount != null ? doc.amount!.toStringAsFixed(2) : '-',
                    style: AppTextStyles.body,
                  )),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () =>
                              _showEditDocumentDialog(controller, doc),
                          tooltip: 'Edit',
                          splashRadius: 20,
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: AppColors.error,
                          ),
                          onPressed: () =>
                              _showDeleteDocumentConfirmation(controller, doc),
                          tooltip: 'Delete',
                          splashRadius: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentsCards(
    AddEditVehicleController controller,
    List<VehicleDocument> documents,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: documents.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final doc = documents[index];
        final docTypeName = _getDocTypeName(controller, doc.docType);
        final expiryColor = AppColors.getExpiryColor(doc.expiryDate);

        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.borderMd,
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius: AppRadius.borderSm,
                    ),
                    child: Text(
                      docTypeName,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => _showEditDocumentDialog(controller, doc),
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: AppColors.error,
                    ),
                    onPressed: () =>
                        _showDeleteDocumentConfirmation(controller, doc),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Divider(color: AppColors.divider, height: 1),
              const SizedBox(height: AppSpacing.md),

              // Details
              _DocumentDetailRow(
                label: 'Issue Date',
                value: doc.formatDate(doc.issueDate),
              ),
              _DocumentDetailRow(
                label: 'Expiry Date',
                value: doc.formatDate(doc.expiryDate),
                trailing: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: expiryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              _DocumentDetailRow(
                label: 'Authority',
                value: doc.issueAuthority ?? '-',
              ),
              _DocumentDetailRow(
                label: 'City',
                value: doc.city ?? '-',
              ),
              _DocumentDetailRow(
                label: 'Amount',
                value: doc.amount != null ? doc.amount!.toStringAsFixed(2) : '-',
                isLast: true,
              ),
            ],
          ),
        );
      },
    );
  }

  String _getDocTypeName(AddEditVehicleController controller, int? docType) {
    var genCon = Get.find<GeneralMastersController>();

    try {
      return genCon.companyDocumentTypes
              .firstWhere((t) => t.docType == docType)
              .docDescription ??
          'Unknown';
    } catch (_) {
      return 'Unknown';
    }
  }

  // ============================================================
  // TYRES SECTION
  // ============================================================

  Widget _buildTyresSection(AddEditVehicleController controller) {
    return Obx(() {
      final allTyres = controller.vehicleData.value?.tyres ?? [];
      final displayTyres = controller.filteredTyres;
      final activeCount = controller.activeTyreCount;
      final maxTyres = controller.maxTyresAllowed;
      final showActiveOnly = controller.showActiveTyresOnly.value;
      final isListView = controller.tyreListView.value;

      return Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.divider)),
              ),
              child: Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.sm,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Title with counts
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.1),
                          borderRadius: AppRadius.borderMd,
                        ),
                        child: Icon(
                          Icons.tire_repair_outlined,
                          color: AppColors.accent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text('Vehicle Tyres', style: AppTextStyles.label),
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.1),
                          borderRadius: AppRadius.borderFull,
                        ),
                        child: Text(
                          '${allTyres.length}/$maxTyres',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: AppRadius.borderFull,
                        ),
                        child: Text(
                          '$activeCount Active',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Actions
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // View mode toggle
                      IconButton(
                        onPressed: controller.toggleTyreViewMode,
                        tooltip: isListView ? 'Grid view' : 'List view',
                        icon: Icon(
                          isListView
                              ? Icons.grid_view_outlined
                              : Icons.view_list_outlined,
                          size: 20,
                          color: AppColors.accent,
                        ),
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                        ),
                      ),
                      // Toggle filter button
                      TextButton.icon(
                        onPressed: controller.toggleTyreFilter,
                        icon: Icon(
                          showActiveOnly
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 18,
                          color: AppColors.accent,
                        ),
                        label: Text(
                          showActiveOnly ? 'Show All' : 'Active Only',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.accent,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),

                      // Add button
                      if (activeCount < maxTyres)
                        Builder(builder: (ctx) {
                          return _SmallButton(
                            label: 'Add Tyre',
                            icon: Icons.add_outlined,
                            onPressed: () {
                              final newIndex = controller.addNewTyre();
                              log("newIndex: $newIndex");
                              if (newIndex >= 0) {
                                final newTyre = controller
                                    .vehicleData.value!.tyres![newIndex];
                                showTyreEditDialog(
                                  ctx,
                                  controller,
                                  newTyre,
                                  newIndex,
                                  isNew: true,
                                );
                              }
                            },
                          );
                        }),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: displayTyres.isEmpty
                  ? _EmptyPlaceholder(
                      icon: Icons.tire_repair_outlined,
                      message: showActiveOnly
                          ? 'No active tyres found'
                          : 'No tyres added yet',
                    )
                  : isListView
                      ? ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 520),
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: displayTyres.length,
                            separatorBuilder: (_, __) =>
                                Divider(height: 1, color: AppColors.divider),
                            itemBuilder: (context, index) {
                              final tyre = displayTyres[index];
                              final actualIndex = allTyres.indexOf(tyre);
                              return _TyreListRow(
                                tyre: tyre,
                                index: actualIndex,
                                controller: controller,
                              );
                            },
                          ),
                        )
                      : ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 520),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final tyresPerRow = constraints.maxWidth > 900
                                  ? 3
                                  : constraints.maxWidth > 500
                                      ? 2
                                      : 1;

                              return GridView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: tyresPerRow,
                                  crossAxisSpacing: AppSpacing.md,
                                  mainAxisSpacing: AppSpacing.md,
                                  mainAxisExtent: 300,
                                ),
                                itemCount: displayTyres.length,
                                itemBuilder: (context, index) {
                                  final tyre = displayTyres[index];
                                  final actualIndex = allTyres.indexOf(tyre);

                                  return _CompactTyreCard(
                                    tyre: tyre,
                                    index: actualIndex,
                                    controller: controller,
                                  );
                                },
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      );
    });
  }

  // ============================================================
  // ACTION BUTTONS
  // ============================================================

  Widget _buildActionButtons(AddEditVehicleController controller) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => _saveChanges(controller),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Save Changes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.borderMd,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () => _cancelEdit(controller),
              icon: Icon(Icons.close, color: AppColors.textSecondary),
              label: Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.divider),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.borderMd,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _saveChanges(AddEditVehicleController controller) async {
    final vehicle = controller.vehicleData.value;
    if (vehicle != null) {
      await controller.createUpdateVehicle(
        newVehicle: vehicle,
        isNew: false,
      );
    }
  }

  void _cancelEdit(AddEditVehicleController controller) {
    controller.clearSearch();
  }

  // ============================================================
  // DOCUMENT DIALOGS
  // ============================================================

  void _showAddDocumentDialog(AddEditVehicleController controller) {
    var genCon = Get.find<GeneralMastersController>();

    final formKey = GlobalKey<FormState>();
    final issueDateController = TextEditingController();
    final expiryDateController = TextEditingController();
    final issueAuthorityController = TextEditingController();
    final cityController = TextEditingController();
    final amountController = TextEditingController();

    DocumentMaster? selectedDocType;
    DateTime selectedIssueDate = DateTime.now();
    DateTime selectedExpiryDate = DateTime.now().add(const Duration(days: 365));

    issueDateController.text =
        DateFormat('yyyy-MM-dd').format(selectedIssueDate);
    expiryDateController.text =
        DateFormat('yyyy-MM-dd').format(selectedExpiryDate);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
        child: Container(
          width: Get.width > 600 ? 500 : Get.width * 0.9,
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.note_add_outlined,
                          color: AppColors.accent,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text('Add New Document', style: AppTextStyles.h4),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Divider(color: AppColors.divider),
                  const SizedBox(height: AppSpacing.lg),

                  // Document Type
                  _DialogDropdown<DocumentMaster>(
                    label: 'Document Type',
                    value: selectedDocType,
                    items: genCon.companyDocumentTypes,
                    displayBuilder: (t) => t.docDescription ?? '',
                    onChanged: (value) => selectedDocType = value,
                    validator: (v) =>
                        v == null ? 'Please select document type' : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Issue Date
                  _DialogDateField(
                    label: 'Issue Date',
                    controller: issueDateController,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: Get.context!,
                        initialDate: selectedIssueDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                        builder: (context, child) =>
                            _datePickerTheme(context, child),
                      );
                      if (picked != null) {
                        selectedIssueDate = picked;
                        issueDateController.text =
                            DateFormat('yyyy-MM-dd').format(picked);
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Expiry Date
                  _DialogDateField(
                    label: 'Expiry Date',
                    controller: expiryDateController,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: Get.context!,
                        initialDate: selectedExpiryDate,
                        firstDate: DateTime.now(),
                        lastDate:
                            DateTime.now().add(const Duration(days: 365 * 5)),
                        builder: (context, child) =>
                            _datePickerTheme(context, child),
                      );
                      if (picked != null) {
                        selectedExpiryDate = picked;
                        expiryDateController.text =
                            DateFormat('yyyy-MM-dd').format(picked);
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Issue Authority
                  _DialogTextField(
                    label: 'Issuing Authority',
                    controller: issueAuthorityController,
                    hint: 'E.g., RTA, Dubai Insurance',
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // City
                  _DialogDropdown<City>(
                    label: 'City',
                    value: null,
                    items: genCon.companyCity.toList(),
                    displayBuilder: (c) => c.city ?? '',
                    onChanged: (c) => cityController.text = c?.city ?? '',
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Amount
                  _DialogTextField(
                    label: 'Amount',
                    controller: amountController,
                    hint: 'E.g., 500.00',
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: BorderSide(color: AppColors.divider),
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.borderMd,
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (formKey.currentState!.validate() &&
                                selectedDocType != null) {
                              final newDocument = VehicleDocument(
                                company: controller.vehicleData.value?.company,
                                vehicleNo:
                                    controller.vehicleData.value?.vehicleNo,
                                docType: selectedDocType?.docType,
                                issueDate: selectedIssueDate,
                                expiryDate: selectedExpiryDate,
                                issueAuthority: issueAuthorityController.text,
                                city: cityController.text,
                                amount: double.tryParse(amountController.text),
                              );

                              controller.addDocument(newDocument);
                              Get.back();
                              CustomWidget.customSnackBar(
                                isError: false,
                                title: 'Success',
                                message: 'Document added successfully',
                              );
                            }
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add Document'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
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
        ),
      ),
    );
  }

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
    final amountController = TextEditingController(
        text: document.amount != null ? document.amount.toString() : '');
    var genCon = Get.find<GeneralMastersController>();

    DocumentMaster? selectedDocType;
    try {
      selectedDocType = genCon.companyDocumentTypes
          .firstWhere((t) => t.docType == document.docType);
    } catch (_) {}

    DateTime selectedIssueDate = document.issueDate ?? DateTime.now();
    DateTime selectedExpiryDate =
        document.expiryDate ?? DateTime.now().add(const Duration(days: 365));

    issueDateController.text =
        DateFormat('yyyy-MM-dd').format(selectedIssueDate);
    expiryDateController.text =
        DateFormat('yyyy-MM-dd').format(selectedExpiryDate);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
        child: Container(
          width: Get.width > 600 ? 500 : Get.width * 0.9,
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.edit_document,
                          color: AppColors.info,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text('Edit Document', style: AppTextStyles.h4),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Divider(color: AppColors.divider),
                  const SizedBox(height: AppSpacing.lg),

                  // Document Type
                  _DialogDropdown<DocumentMaster>(
                    label: 'Document Type',
                    value: selectedDocType,
                    items: genCon.companyDocumentTypes,
                    displayBuilder: (t) => t.docDescription ?? '',
                    onChanged: (value) => selectedDocType = value,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Issue Date
                  _DialogDateField(
                    label: 'Issue Date',
                    controller: issueDateController,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: Get.context!,
                        initialDate: selectedIssueDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                        builder: (context, child) =>
                            _datePickerTheme(context, child),
                      );
                      if (picked != null) {
                        selectedIssueDate = picked;
                        issueDateController.text =
                            DateFormat('yyyy-MM-dd').format(picked);
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Expiry Date
                  _DialogDateField(
                    label: 'Expiry Date',
                    controller: expiryDateController,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: Get.context!,
                        initialDate: selectedExpiryDate,
                        firstDate: DateTime.now(),
                        lastDate:
                            DateTime.now().add(const Duration(days: 365 * 5)),
                        builder: (context, child) =>
                            _datePickerTheme(context, child),
                      );
                      if (picked != null) {
                        selectedExpiryDate = picked;
                        expiryDateController.text =
                            DateFormat('yyyy-MM-dd').format(picked);
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Issue Authority
                  _DialogTextField(
                    label: 'Issuing Authority',
                    controller: issueAuthorityController,
                    hint: 'E.g., RTA, Dubai Insurance',
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // City
                  _DialogDropdown<City>(
                    label: 'City',
                    value: genCon.companyCity
                        .firstWhereOrNull((c) => c.city == document.city),
                    items: genCon.companyCity.toList(),
                    displayBuilder: (c) => c.city ?? '',
                    onChanged: (c) => cityController.text = c?.city ?? '',
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Amount
                  _DialogTextField(
                    label: 'Amount',
                    controller: amountController,
                    hint: 'E.g., 500.00',
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: BorderSide(color: AppColors.divider),
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.borderMd,
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              final updatedDocument = document.copyWith(
                                docType: selectedDocType?.docType,
                                issueDate: selectedIssueDate,
                                expiryDate: selectedExpiryDate,
                                issueAuthority: issueAuthorityController.text,
                                city: cityController.text,
                                amount: double.tryParse(amountController.text),
                              );

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
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Update'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.info,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
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
        ),
      ),
    );
  }

  void _showDeleteDocumentConfirmation(
    AddEditVehicleController controller,
    VehicleDocument document,
  ) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                  size: 32,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Delete Document?', style: AppTextStyles.h4),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Are you sure you want to delete this document? This action cannot be undone.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: BorderSide(color: AppColors.divider),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.borderMd,
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        controller.removeDocument(document);
                        Get.back();
                        CustomWidget.customSnackBar(
                          isError: false,
                          title: 'Success',
                          message: 'Document deleted successfully',
                        );
                      },
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
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

  Widget _datePickerTheme(BuildContext context, Widget? child) {
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
  }
}

// ============================================================
// REUSABLE WIDGETS
// ============================================================

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? headerExtra;
  final Widget? trailing;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    this.subtitle,
    this.headerExtra,
    this.trailing,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              // borderRadius: AppRadius.borderLg,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.lg),
                  topRight: Radius.circular(AppRadius.lg)),
              border: Border(
                bottom: BorderSide(color: AppColors.divider),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: AppRadius.borderMd,
                  ),
                  child: Icon(icon, color: AppColors.accent, size: 20),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(title, style: AppTextStyles.label),
                          if (headerExtra != null) ...[
                            const SizedBox(width: AppSpacing.sm),
                            headerExtra!,
                          ],
                        ],
                      ),
                      if (subtitle != null)
                        Text(subtitle!, style: AppTextStyles.caption),
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final double? width;

  const _ReadOnlyField({
    required this.label,
    required this.value,
    required this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: AppRadius.borderMd,
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textMuted),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.caption),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    value,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboardType;
  final void Function(String)? onChanged;
  final double? width;

  const _StyledTextField({
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType,
    this.onChanged,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: AppTextStyles.body,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.bodySmall,
          prefixIcon: Icon(icon, size: 20, color: AppColors.accent),
          filled: true,
          fillColor: AppColors.cardBg,
          border: OutlineInputBorder(
            borderRadius: AppRadius.borderMd,
            borderSide: BorderSide(color: AppColors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.borderMd,
            borderSide: BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.borderMd,
            borderSide: BorderSide(color: AppColors.accent, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
      ),
    );
  }
}

class _StyledDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final IconData icon;
  final void Function(T?)? onChanged;
  final double? width;
  final String Function(T)? displayBuilder;

  const _StyledDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.icon,
    this.onChanged,
    this.width,
    this.displayBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: DropdownButtonFormField<T>(
        value: value,
        items: items.map((item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(
              displayBuilder != null ? displayBuilder!(item) : item.toString(),
              style: AppTextStyles.body,
            ),
          );
        }).toList(),
        selectedItemBuilder: displayBuilder == null
            ? null
            : (context) => items
                .map((item) => Text(
                      displayBuilder!(item),
                      style: AppTextStyles.body,
                      overflow: TextOverflow.ellipsis,
                    ))
                .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.bodySmall,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          prefixIcon: Icon(icon, size: 20, color: AppColors.accent),
          filled: true,
          fillColor: AppColors.cardBg,
          border: OutlineInputBorder(
            borderRadius: AppRadius.borderMd,
            borderSide: BorderSide(color: AppColors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.borderMd,
            borderSide: BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.borderMd,
            borderSide: BorderSide(color: AppColors.accent, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
        dropdownColor: AppColors.cardBg,
        isExpanded: true,
        isDense: true,
        borderRadius: AppRadius.borderLg,
        style: AppTextStyles.body,
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  const _SmallButton({
    required this.label,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderSm,
        ),
      ),
    );
  }
}

class _EmptyPlaceholder extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyPlaceholder({
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          children: [
            Icon(icon, size: 40, color: AppColors.textMuted.withOpacity(0.5)),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? trailing;
  final bool isLast;

  const _DocumentDetailRow({
    required this.label,
    required this.value,
    this.trailing,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.body),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.sm),
            trailing!,
          ],
        ],
      ),
    );
  }
}

// ============================================================
// COMPACT TYRE CARD
// ============================================================

class _CompactTyreCard extends StatelessWidget {
  final Tyre tyre;
  final int index;
  final AddEditVehicleController controller;

  const _CompactTyreCard({
    required this.tyre,
    required this.index,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = tyre.status == 'Active';
    final activeCount = controller.activeTyreCount;

    return Container(
      decoration: BoxDecoration(
        color: isActive ? AppColors.cardBg : AppColors.errorLight,
        borderRadius: AppRadius.borderMd,
        border: Border.all(
          color:
              isActive ? AppColors.divider : AppColors.error.withOpacity(0.3),
        ),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primaryDark
                  : AppColors.error.withOpacity(0.8),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppRadius.md),
                topRight: Radius.circular(AppRadius.md),
              ),
            ),
            child: Row(
              children: [
                // Position badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: AppRadius.borderSm,
                  ),
                  child: Text(
                    tyre.position?.status ?? 'Tyre ${index + 1}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                // Status indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.success.withOpacity(0.2)
                        : Colors.white.withOpacity(0.2),
                    borderRadius: AppRadius.borderFull,
                  ),
                  child: Text(
                    tyre.status ?? 'Unknown',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (tyre.deleteAllowed == true) ...[
                  const SizedBox(width: AppSpacing.sm),
                  InkWell(
                    onTap: () => controller.removeTyre(index),
                    borderRadius: AppRadius.borderFull,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  // Info rows
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _CompactInfoRow(
                              label: 'Brand', value: tyre.brand ?? '-'),
                          _CompactInfoRow(
                              label: 'Size', value: tyre.size ?? '-'),
                          _CompactInfoRow(
                              label: 'KM Used', value: '${tyre.kmUsed ?? 0}'),
                          _CompactInfoRow(
                            label: 'Install',
                            value: tyre.installDt != null
                                ? tyre.formatDate(tyre.installDt)
                                : '-',
                          ),
                          _CompactInfoRow(
                            label: 'Expiry',
                            value: tyre.expDt != null
                                ? tyre.formatDate(tyre.expDt)
                                : '-',
                            valueColor: tyre.expDt != null
                                ? AppColors.getExpiryColor(tyre.expDt)
                                : null,
                          ),
                          const SizedBox(height: AppSpacing.sm),

                          // Status dropdown
                          Row(
                            children: [
                              SizedBox(
                                width: 70,
                                child: Text(
                                  'Status',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: SizedBox(
                                  height: 36,
                                  child: DropdownButtonFormField<String>(
                                    isDense: true,
                                    value: tyre.status,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.sm,
                                        vertical: 4,
                                      ),
                                      filled: true,
                                      fillColor: AppColors.surface,
                                      border: OutlineInputBorder(
                                        borderRadius: AppRadius.borderSm,
                                        borderSide: BorderSide(
                                            color: AppColors.divider),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: AppRadius.borderSm,
                                        borderSide: BorderSide(
                                            color: AppColors.divider),
                                      ),
                                    ),
                                    style: AppTextStyles.bodySmall,
                                    dropdownColor: AppColors.cardBg,
                                    items: ['Active', 'Inactive'].map((value) {
                                      final isDisabled = value == 'Active' &&
                                          tyre.status != 'Active' &&
                                          activeCount >= 6;
                                      return DropdownMenuItem(
                                        value: value,
                                        enabled: !isDisabled,
                                        child: Text(
                                          value,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isDisabled
                                                ? AppColors.textMuted
                                                : AppColors.textPrimary,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (v) => v != null
                                        ? controller.updateTyreStatus(index, v)
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Edit button
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () =>
                          showTyreEditDialog(context, controller, tyre, index),
                      icon: Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: AppColors.accent,
                      ),
                      label: Text(
                        'Edit Details',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TYRE EDIT DIALOG (shared between card and list row)
// ============================================================

void showTyreEditDialog(
  BuildContext context,
  AddEditVehicleController controller,
  Tyre tyre,
  int index, {
  bool isNew = false,
  bool isCreateMode = false,
}) {
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 620),
        child: _TyreEditDialogContent(
          controller: controller,
          tyre: tyre,
          index: index,
          isNew: isNew,
          isCreateMode: isCreateMode,
        ),
      ),
    ),
    barrierDismissible: !isNew,
  );
}

// ============================================================
// TYRE EDIT DIALOG — StatefulWidget to prevent TextField rebuild
// ============================================================

class _TyreEditDialogContent extends StatefulWidget {
  final AddEditVehicleController controller;
  final Tyre tyre;
  final int index;
  final bool isNew;

  /// When true, reads/writes tyresList (create flow) instead of vehicleData.tyres (edit flow)
  final bool isCreateMode;

  const _TyreEditDialogContent({
    required this.controller,
    required this.tyre,
    required this.index,
    this.isNew = false,
    this.isCreateMode = false,
  });

  @override
  State<_TyreEditDialogContent> createState() => _TyreEditDialogContentState();
}

class _TyreEditDialogContentState extends State<_TyreEditDialogContent> {
  late final TextEditingController _brandCtrl;
  late final TextEditingController _sizeCtrl;
  late final TextEditingController _kmCtrl;
  late final TextEditingController _remarksCtrl;

  Tyre get _currentTyre => widget.isCreateMode
      ? widget.controller.tyresList[widget.index]
      : widget.controller.vehicleData.value?.tyres?[widget.index] ??
          widget.tyre;

  @override
  void initState() {
    super.initState();
    final t = _currentTyre;
    _brandCtrl = TextEditingController(text: t.brand ?? '');
    _sizeCtrl = TextEditingController(text: t.size ?? '');
    _kmCtrl = TextEditingController(text: t.kmUsed?.toString() ?? '0');
    _remarksCtrl = TextEditingController(text: t.remarks ?? '');
  }

  @override
  void dispose() {
    _brandCtrl.dispose();
    _sizeCtrl.dispose();
    _kmCtrl.dispose();
    _remarksCtrl.dispose();
    super.dispose();
  }

  Tyre _liveTyre(AddEditVehicleController c, int i) {
    if (widget.isCreateMode) {
      return i < c.tyresList.length ? c.tyresList[i] : widget.tyre;
    }
    final tyres = c.vehicleData.value?.tyres;
    return (tyres != null && i < tyres.length) ? tyres[i] : widget.tyre;
  }

  /// Returns an error message if mandatory fields are missing, null if valid.
  String? _validateNewTyre() {
    final t = _liveTyre(widget.controller, widget.index);
    if (t.position == null) return 'Position is required';
    if (_brandCtrl.text.trim().isEmpty) return 'Brand is required';
    if (_sizeCtrl.text.trim().isEmpty) return 'Size is required';
    if (t.installDt == null) return 'Install Date is required';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final i = widget.index;
    final isNew = widget.isNew;
    final isCreate = widget.isCreateMode;
    final genCon = Get.find<GeneralMastersController>();

    // For existing saved tyres (tyreId != 0), lock Brand/Size/InstallDate unless empty
    bool fieldLocked(String? value) =>
        !isNew && widget.tyre.tyreId != 0 && (value?.isNotEmpty ?? false);

    void onBrand(String v) =>
        isCreate ? c.createUpdateTyreBrand(i, v) : c.updateTyreBrand(i, v);
    void onSize(String v) =>
        isCreate ? c.createUpdateTyreSize(i, v) : c.updateTyreSize(i, v);
    void onKm(String v) =>
        isCreate ? c.createUpdateTyreKm(i, v) : c.updateTyreKm(i, v);
    void onRemarks(String v) =>
        isCreate ? c.createUpdateTyreRemarks(i, v) : c.updateTyreRemarks(i, v);
    void onPosition(StatusMaster? v) => isCreate
        ? c.createUpdateTyrePosition(i, v)
        : c.updateTyrePosition(i, v);
    void onInstall(DateTime d) => isCreate
        ? c.createUpdateTyreInstallDate(i, d)
        : c.updateTyreInstallDate(i, d);
    void onExpiry(DateTime d) => isCreate
        ? c.createUpdateTyreExpiryDate(i, d)
        : c.updateTyreExpiryDate(i, d);
    void onStatus(String v) =>
        isCreate ? c.createUpdateTyreStatus(i, v) : c.updateTyreStatus(i, v);
    void onCancel() {
      Get.back();
      isCreate ? c.createRemoveTyre(i) : c.removeTyre(i);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header — reactive only for position label
        Obx(() {
          final currentTyre = _liveTyre(c, i);
          return Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppRadius.xl),
                topRight: Radius.circular(AppRadius.xl),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: AppRadius.borderMd,
                  ),
                  child: const Icon(Icons.tire_repair,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isNew ? 'Add New Tyre' : 'Edit Tyre',
                        style:
                            AppTextStyles.label.copyWith(color: Colors.white),
                      ),
                      Text(
                        currentTyre.position?.status ?? 'Tyre ${i + 1}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isNew)
                  InkWell(
                    onTap: () => Get.back(),
                    borderRadius: AppRadius.borderFull,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 18),
                    ),
                  ),
              ],
            ),
          );
        }),

        // Content
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                // Position — reactive
                Obx(() {
                  final currentTyre = _liveTyre(c, i);
                  return _TyreDialogDropdown<StatusMaster>(
                    label: 'Position',
                    value: currentTyre.position,
                    items: genCon.tirePositionMaster,
                    displayBuilder: (s) => s.status ?? '',
                    onChanged: onPosition,
                  );
                }),
                const SizedBox(height: AppSpacing.lg),
                // Brand — locked for existing saved tyres with a value
                _TyreDialogTextField(
                  label: 'Brand',
                  controller: _brandCtrl,
                  onChanged: onBrand,
                  readOnly: fieldLocked(widget.tyre.brand),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Size — locked for existing saved tyres with a value
                _TyreDialogTextField(
                  label: 'Size',
                  controller: _sizeCtrl,
                  onChanged: onSize,
                  readOnly: fieldLocked(widget.tyre.size),
                ),
                const SizedBox(height: AppSpacing.lg),
                // KM Used — always editable
                _TyreDialogTextField(
                  label: 'KM Used',
                  controller: _kmCtrl,
                  onChanged: onKm,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppSpacing.lg),
                // Install Date — locked for existing saved tyres with a value
                Obx(() {
                  final currentTyre = _liveTyre(c, i);
                  return _TyreDialogDateField(
                    label: 'Install Date',
                    value: currentTyre.installDt,
                    formatDate: currentTyre.formatDate,
                    firstDate: DateTime(2010),
                    lastDate: DateTime.now(),
                    onChanged:
                        fieldLocked(widget.tyre.installDt?.toIso8601String())
                            ? null
                            : onInstall,
                  );
                }),
                const SizedBox(height: AppSpacing.lg),
                // Expiry Date — always editable
                Obx(() {
                  final currentTyre = _liveTyre(c, i);
                  return _TyreDialogDateField(
                    label: 'Expiry Date',
                    value: currentTyre.expDt,
                    formatDate: currentTyre.formatDate,
                    firstDate: currentTyre.installDt ??
                        DateTime.now().subtract(const Duration(days: 1)),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                    onChanged: onExpiry,
                  );
                }),
                const SizedBox(height: AppSpacing.lg),
                // Remarks — always editable
                _TyreDialogTextField(
                  label: 'Remarks',
                  controller: _remarksCtrl,
                  onChanged: onRemarks,
                  maxLines: 2,
                ),
                const SizedBox(height: AppSpacing.lg),
                // Status — reactive
                Obx(() {
                  final currentTyre = _liveTyre(c, i);
                  final activeCount = isCreate
                      ? c.tyresList.where((t) => t.status == 'Active').length
                      : c.activeTyreCount;
                  final maxTyres = c.maxTyresAllowed;
                  return _TyreDialogDropdown(
                    label: 'Status',
                    value: currentTyre.status,
                    items: const ['Active', 'Inactive'],
                    disabledItems: currentTyre.status != 'Active' &&
                            activeCount >= maxTyres
                        ? ['Active']
                        : [],
                    onChanged: (v) => onStatus(v!),
                  );
                }),
              ],
            ),
          ),
        ),

        // Footer
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.divider)),
          ),
          child: Row(
            mainAxisAlignment:
                isNew ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
            children: [
              if (isNew)
                OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.borderMd),
                  ),
                  child: const Text('Cancel'),
                ),
              if (isNew)
                ElevatedButton(
                  onPressed: () {
                    final error = _validateNewTyre();
                    if (error != null) {
                      CustomWidget.customSnackBar(
                        title: 'Required',
                        message: error,
                        isError: true,
                      );
                      return;
                    }
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.borderMd),
                  ),
                  child: const Text('Add Tyre'),
                ),
              if (!isNew)
                OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: BorderSide(color: AppColors.divider),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.borderMd),
                  ),
                  child: const Text('Close'),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// TYRE LIST ROW (compact list view)
// ============================================================

class _TyreListRow extends StatelessWidget {
  final Tyre tyre;
  final int index;
  final AddEditVehicleController controller;

  const _TyreListRow({
    required this.tyre,
    required this.index,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = tyre.status == 'Active';
    final hasExpiry = tyre.expDt != null;
    final expiryColor =
        hasExpiry ? AppColors.getExpiryColor(tyre.expDt) : AppColors.textMuted;

    return InkWell(
      onTap: () => showTyreEditDialog(context, controller, tyre, index),
      borderRadius: AppRadius.borderSm,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            // Status colour bar
            Container(
              width: 3,
              height: 36,
              decoration: BoxDecoration(
                color: isActive ? AppColors.success : AppColors.error,
                borderRadius: AppRadius.borderFull,
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Position badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primaryDark.withOpacity(0.08)
                    : AppColors.error.withOpacity(0.08),
                borderRadius: AppRadius.borderSm,
              ),
              child: Text(
                tyre.position?.status ?? '#${index + 1}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: isActive ? AppColors.primaryDark : AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Brand · size
            Expanded(
              flex: 3,
              child: Text(
                [tyre.brand, tyre.size]
                    .where((s) => s != null && s.isNotEmpty)
                    .join(' · '),
                style: AppTextStyles.body,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // KM
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Icon(Icons.speed_outlined,
                      size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    '${tyre.kmUsed ?? 0} km',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Expiry
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Icon(Icons.event_outlined, size: 14, color: expiryColor),
                  const SizedBox(width: 4),
                  Text(
                    hasExpiry ? tyre.formatDate(tyre.expDt) : '—',
                    style: AppTextStyles.bodySmall.copyWith(color: expiryColor),
                  ),
                ],
              ),
            ),

            // Status chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.success.withOpacity(0.12)
                    : AppColors.error.withOpacity(0.12),
                borderRadius: AppRadius.borderFull,
              ),
              child: Text(
                tyre.status ?? '',
                style: AppTextStyles.caption.copyWith(
                  color: isActive ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // Edit icon
            Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _CompactInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _CompactInfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w500,
                color: valueColor ?? AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TYRE DIALOG WIDGETS
// ============================================================

class _TyreDialogTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final void Function(String) onChanged;
  final TextInputType keyboardType;
  final int maxLines;
  final bool readOnly;

  const _TyreDialogTextField({
    required this.label,
    required this.controller,
    required this.onChanged,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: AppTextStyles.label,
          ),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            onChanged: readOnly ? null : onChanged,
            readOnly: readOnly,
            style: AppTextStyles.body.copyWith(
              color: readOnly ? AppColors.textMuted : AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: readOnly
                  ? AppColors.surface.withOpacity(0.5)
                  : AppColors.surface,
              suffixIcon: readOnly
                  ? Icon(Icons.lock_outline,
                      size: 14, color: AppColors.textMuted)
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              border: OutlineInputBorder(
                borderRadius: AppRadius.borderMd,
                borderSide: BorderSide(color: AppColors.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.borderMd,
                borderSide: BorderSide(color: AppColors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.borderMd,
                borderSide: BorderSide(
                  color: readOnly ? AppColors.divider : AppColors.accent,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TyreDialogDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final void Function(T?) onChanged;
  final List<T> disabledItems;
  final String Function(T)? displayBuilder;

  const _TyreDialogDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.disabledItems = const <Never>[],
    this.displayBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: AppTextStyles.label,
          ),
        ),
        Expanded(
          child: DropdownButtonFormField<T>(
            isDense: true,
            value: value,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              border: OutlineInputBorder(
                borderRadius: AppRadius.borderMd,
                borderSide: BorderSide(color: AppColors.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.borderMd,
                borderSide: BorderSide(color: AppColors.divider),
              ),
            ),
            style: AppTextStyles.body,
            dropdownColor: AppColors.cardBg,
            items: items.map((item) {
              final isDisabled = disabledItems.contains(item);
              return DropdownMenuItem<T>(
                value: item,
                enabled: !isDisabled,
                child: Text(
                  displayBuilder != null
                      ? displayBuilder!(item)
                      : item.toString(),
                  style: AppTextStyles.body.copyWith(
                    color: isDisabled
                        ? AppColors.textMuted
                        : AppColors.textPrimary,
                  ),
                ),
              );
            }).toList(),
            // selectedItemBuilder: displayBuilder == null
            //     ? null
            //     : (context) => items
            //         .map((item) => Text(
            //               displayBuilder!(item),
            //               style: AppTextStyles.body,
            //               overflow: TextOverflow.ellipsis,
            //             ))
            //         .toList(),
            // items: items.map((item) {
            //   final isDisabled = disabledItems.contains(item);
            //   return DropdownMenuItem(
            //     value: item,
            //     enabled: !isDisabled,
            //     child: Text(
            //       item,
            //       style: TextStyle(
            //         color: isDisabled
            //             ? AppColors.textMuted
            //             : AppColors.textPrimary,
            //       ),
            //     ),
            //   );
            // }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _TyreDialogDateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final String Function(DateTime?) formatDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final void Function(DateTime)? onChanged;

  const _TyreDialogDateField({
    required this.label,
    required this.value,
    required this.formatDate,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
  });

  bool get _readOnly => onChanged == null;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: AppTextStyles.label,
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: _readOnly
                ? null
                : () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: value ?? DateTime.now(),
                      firstDate: firstDate,
                      lastDate: lastDate,
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
                    if (picked != null) {
                      onChanged!(picked);
                    }
                  },
            borderRadius: AppRadius.borderMd,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: _readOnly
                    ? AppColors.surface.withOpacity(0.5)
                    : AppColors.surface,
                borderRadius: AppRadius.borderMd,
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    value != null
                        ? formatDate(value)
                        : (_readOnly ? '—' : 'Select Date'),
                    style: AppTextStyles.body.copyWith(
                      color: value != null
                          ? (_readOnly
                              ? AppColors.textMuted
                              : AppColors.textPrimary)
                          : AppColors.textMuted,
                    ),
                  ),
                  Icon(
                    _readOnly
                        ? Icons.lock_outline
                        : Icons.calendar_today_outlined,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// DIALOG WIDGETS
// ============================================================

class _DialogTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType keyboardType;

  const _DialogTextField({
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: BorderSide(color: AppColors.accent, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ],
    );
  }
}

class _DialogDateField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final VoidCallback onTap;

  const _DialogDateField({
    required this.label,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            suffixIcon: Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: AppColors.textMuted,
            ),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: BorderSide(color: AppColors.accent, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ],
    );
  }
}

class _DialogDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final void Function(T?)? onChanged;
  final String Function(T)? displayBuilder;
  final String? Function(T?)? validator;

  const _DialogDropdown({
    required this.label,
    required this.value,
    required this.items,
    this.onChanged,
    this.displayBuilder,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<T>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                displayBuilder?.call(item) ?? item.toString(),
                style: AppTextStyles.body,
              ),
            );
          }).toList(),
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: BorderSide(color: AppColors.accent, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
          dropdownColor: AppColors.cardBg,
          isExpanded: true,
        ),
      ],
    );
  }
}
