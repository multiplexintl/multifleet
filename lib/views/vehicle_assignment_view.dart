import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multifleet/controllers/general_masters.dart';
import 'package:multifleet/models/employee.dart';
import 'package:multifleet/models/status_master/status_master.dart';
import 'package:multifleet/models/vehicle.dart';
import 'package:multifleet/models/vehicle_assignment_model.dart'
    show assignmentStatusColor, VehicleAssignment;
import 'package:multifleet/theme/app_theme.dart';
import 'package:multifleet/widgets/date_picker_field.dart';
import 'package:multifleet/widgets/search_vehicle.dart';

import '../controllers/vehicle_assign_controller.dart';

/// ============================================================
/// VEHICLE ASSIGNMENT PAGE
/// ============================================================
/// Redesigned with MultiFleet Design System (Slate & Teal)
/// ============================================================

class VehicleAssignmentPage extends StatelessWidget {
  const VehicleAssignmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VehicleAssignmentController());
    final isMobile = AppBreakpoints.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Section
              _buildSearchSection(controller),
              const SizedBox(height: 20),

              // Content (Vehicle Details + Assignment Form)
              Obx(() {
                if (controller.isSearching.value) {
                  return const _LoadingState(message: 'Searching vehicle...');
                }

                if (controller.selectedVehicle.value == null) {
                  return const _EmptySearchState();
                }

                return _buildAssignmentContent(context, controller);
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== SEARCH SECTION ====================

  Widget _buildSearchSection(VehicleAssignmentController controller) {
    return SearchVehicleWidget(
      controller: controller.plateNumberController,
      heading: "Search Vehicle to Assign",
      searchText: "Search",
      clearText: "Clear",
      onSearch: () => _handleSearch(controller),
      onClear: () => controller.clearSearch(),
      onDataChanged: (plate) {
        controller.onPlateChanged(plate.code, plate.region, plate.number);
      },
    );
  }

  Future<void> _handleSearch(VehicleAssignmentController controller) async {
    await controller.searchVehicle();
  }

// ==================== ASSIGNMENT CONTENT ====================

  Widget _buildAssignmentContent(
      BuildContext context, VehicleAssignmentController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Vehicle Details
              Expanded(
                flex: 2,
                child: _VehicleDetailsCard(
                  vehicle: controller.selectedVehicle.value!,
                  controller: controller,
                ),
              ),
              const SizedBox(width: 20),
              // Right: Already Assigned Card OR Assignment Form
              Expanded(
                flex: 3,
                child: Obx(() => controller.lastVehicleAssignment.value != null
                    ? _AlreadyAssignedCard(controller: controller)
                    : _AssignmentFormCard(controller: controller)),
              ),
            ],
          );
        }

        return Column(
          children: [
            _VehicleDetailsCard(
              vehicle: controller.selectedVehicle.value!,
              controller: controller,
            ),
            const SizedBox(height: 20),
            Obx(() => controller.lastVehicleAssignment.value != null
                ? _AlreadyAssignedCard(controller: controller)
                : _AssignmentFormCard(controller: controller)),
          ],
        );
      },
    );
  }
}

// ==================== ALREADY ASSIGNED CARD ====================

class _AlreadyAssignedCard extends StatelessWidget {
  final VehicleAssignmentController controller;

  const _AlreadyAssignedCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final assignment = controller.lastVehicleAssignment.value!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: AppRadius.borderLg,
        boxShadow: AppShadows.sm,
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: AppRadius.borderMd,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.warning,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Vehicle Already Assigned', style: AppTextStyles.h4),
                    const SizedBox(height: 2),
                    Text(
                      'This vehicle is currently assigned',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Assignment Details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.borderMd,
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: [
                _AssignmentDetailRow(
                  icon: Icons.person_outline,
                  label: 'Assigned To',
                  value: assignment.empName ?? 'Unknown',
                  isHighlighted: true,
                ),
                const Divider(height: 20),
                _AssignmentDetailRow(
                  icon: Icons.badge_outlined,
                  label: 'Employee No',
                  value: assignment.empNo ?? 'N/A',
                ),
                const SizedBox(height: 8),
                _AssignmentDetailRow(
                  icon: Icons.flag_outlined,
                  label: 'Status',
                  value: assignment.status?.status ?? 'N/A',
                  statusColor: assignmentStatusColor(assignment.status?.status),
                ),
                const SizedBox(height: 8),
                _AssignmentDetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'From',
                  value:
                      controller.formatISODateTime(assignment.assignedDate) ??
                          'N/A',
                ),
                const SizedBox(height: 8),
                _AssignmentDetailRow(
                  icon: Icons.event_outlined,
                  label: 'To',
                  value: controller.formatISODateTime(assignment.returnDate) ??
                      'Indefinite',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Info text
          Text(
            'What would you like to do?',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),

          // Action Buttons
          Obx(() => Column(
                children: [
                  // Reassign Button (Primary)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: controller.isTerminating.value
                          ? null
                          : () => _handleReassign(controller),
                      icon: controller.isTerminating.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.swap_horiz_rounded, size: 20),
                      label: Text(controller.isTerminating.value
                          ? 'Processing...'
                          : 'Reassign to New Employee'),
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
                  const SizedBox(height: 12),

                  // Terminate & Cancel Row
                  Row(
                    children: [
                      // Cancel Button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: controller.isTerminating.value
                              ? null
                              : () => controller.cancelAssignment(),
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

                      // Terminate Button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: controller.isTerminating.value
                              ? null
                              : () => _showTerminateConfirmation(controller),
                          icon: const Icon(Icons.cancel_outlined, size: 18),
                          label: const Text('Terminate'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
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
              )),
        ],
      ),
    );
  }

  void _handleReassign(VehicleAssignmentController controller) {
    controller.terminateAndProceed();
  }

  void _showTerminateConfirmation(VehicleAssignmentController controller) {
    final assignment = controller.lastVehicleAssignment.value!;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: AppColors.error,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Terminate Assignment?',
                style: AppTextStyles.h3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTextStyles.body.copyWith(height: 1.5),
                  children: [
                    const TextSpan(text: 'This will end the assignment for '),
                    TextSpan(
                      text: assignment.empName ?? 'the employee',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(
                        text:
                            '. The vehicle will become available for new assignments.'),
                  ],
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
                    child: Obx(() => ElevatedButton(
                          onPressed: controller.isTerminating.value
                              ? null
                              : () async {
                                  final success =
                                      await controller.terminateAssignment();
                                  if (success) {
                                    Get.back();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.borderMd,
                            ),
                          ),
                          child: controller.isTerminating.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Terminate'),
                        )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}

// ==================== VEHICLE DETAILS CARD ====================

class _VehicleDetailsCard extends StatelessWidget {
  final Vehicle vehicle;
  final VehicleAssignmentController controller;

  const _VehicleDetailsCard({
    required this.vehicle,
    required this.controller,
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
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.lg),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: AppRadius.borderMd,
                  ),
                  child: const Icon(
                    Icons.directions_car_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.vehicleNo ?? 'Unknown',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${vehicle.brand ?? ''} ${vehicle.model ?? ''}'.trim(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                AppBadge.status(vehicle.status),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _DetailItem(
                  icon: Icons.category_outlined,
                  label: 'Type',
                  value: vehicle.type ?? 'N/A',
                ),
                _DetailItem(
                  icon: Icons.tag_outlined,
                  label: 'Chassis',
                  value: vehicle.chassisNo ?? 'N/A',
                ),
                _DetailItem(
                  icon: Icons.folder_outlined,
                  label: 'Traffic File',
                  value: vehicle.traficFileNo ?? 'N/A',
                ),
                _DetailItem(
                  icon: Icons.speed_outlined,
                  label: 'Current KM',
                  value: '${vehicle.currentOdo ?? 0} km',
                ),
                _DetailItem(
                  icon: Icons.calendar_today_outlined,
                  label: 'Year',
                  value: vehicle.vYear?.toString() ?? 'N/A',
                  showDivider: false,
                ),
              ],
            ),
          ),

          // Scheduled / Future Assignments
          Obx(() {
            final future = controller.futureAssignments;
            if (future.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(height: 1, color: AppColors.divider),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Row(
                    children: [
                      Icon(Icons.event_repeat_rounded,
                          size: 16, color: AppColors.accent),
                      const SizedBox(width: 8),
                      Text(
                        'Scheduled Assignments',
                        style: AppTextStyles.label
                            .copyWith(color: AppColors.accent),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${future.length}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ...future.map((a) => _ScheduledAssignmentRow(
                      assignment: a,
                      controller: controller,
                    )),
                const SizedBox(height: 8),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool showDivider;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.textMuted),
              const SizedBox(width: 12),
              SizedBox(
                width: 90,
                child: Text(label, style: AppTextStyles.bodySmall),
              ),
              Expanded(
                child: Text(
                  value,
                  style:
                      AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
        if (showDivider) Divider(height: 1, color: AppColors.divider),
      ],
    );
  }
}

// ==================== SCHEDULED ASSIGNMENT ROW ====================

class _ScheduledAssignmentRow extends StatelessWidget {
  final VehicleAssignment assignment;
  final VehicleAssignmentController controller;

  const _ScheduledAssignmentRow({
    required this.assignment,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = assignmentStatusColor(assignment.status?.status);
    final dateStr =
        controller.formatISODateTime(assignment.assignedDate) ?? 'N/A';
    final returnStr =
        controller.formatISODateTime(assignment.returnDate) ?? 'Indefinite';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment.empName ?? assignment.empNo ?? 'Unknown Employee',
                  style:
                      AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '$dateStr → $returnStr',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              assignment.status?.status ?? 'Scheduled',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== ASSIGNMENT FORM CARD ====================

class _AssignmentFormCard extends StatelessWidget {
  final VehicleAssignmentController controller;

  const _AssignmentFormCard({required this.controller});

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
          // Header
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
                  child: Icon(
                    Icons.person_add_outlined,
                    color: AppColors.accent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text('Employee Assignment', style: AppTextStyles.h4),
              ],
            ),
          ),
          const Divider(height: 1),

          // Form Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 500;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Employee & Designation
                    _ResponsiveFormRow(
                      isWide: isWide,
                      children: [
                        _EmployeeAutocomplete(controller: controller),
                        _DesignationField(controller: controller),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Dates
                    _ResponsiveFormRow(
                      isWide: isWide,
                      children: [
                        DatePickerField(
                          label: 'Start Date & Time',
                          value: controller.startDate,
                          isRequired: true,
                          pickTime: true,
                          onChanged: (date) =>
                              controller.startDate.value = date,
                        ),
                        DatePickerField(
                          label: 'End Date & Time',
                          value: controller.endDate,
                          pickTime: true,
                          onChanged: (date) => controller.endDate.value = date,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Status
                    _StatusDropdown(controller: controller),
                    const SizedBox(height: 16),

                    // Remarks
                    _RemarksField(controller: controller),
                    const SizedBox(height: 24),

                    // Images Section
                    _ImagesSection(controller: controller),
                    const SizedBox(height: 24),

                    // Action Buttons
                    _FormActionButtons(controller: controller),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== FORM FIELDS ====================

class _ResponsiveFormRow extends StatelessWidget {
  final bool isWide;
  final List<Widget> children;

  const _ResponsiveFormRow({required this.isWide, required this.children});

  @override
  Widget build(BuildContext context) {
    if (!isWide) {
      return Column(
        children: children
            .map((child) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
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
  }
}

class _EmployeeAutocomplete extends StatelessWidget {
  final VehicleAssignmentController controller;

  const _EmployeeAutocomplete({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: 'Employee Name', isRequired: true),
        const SizedBox(height: 8),
        Autocomplete<Employee>(
          optionsBuilder: (textEditingValue) async {
            return await controller.getEmpSuggestions(textEditingValue.text);
          },
          displayStringForOption: (emp) =>
              '${emp.empName ?? ''} (${emp.empNo ?? ''})',
          fieldViewBuilder: (context, textController, focusNode, onSubmitted) {
            return TextField(
              controller: textController,
              focusNode: focusNode,
              style: AppTextStyles.body,
              decoration: InputDecoration(
                hintText: 'Search employee by name or ID',
                hintStyle:
                    AppTextStyles.body.copyWith(color: AppColors.textMuted),
                prefixIcon:
                    Icon(Icons.search, color: AppColors.accent, size: 20),
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
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: AppRadius.borderMd,
                child: Container(
                  width: 350,
                  constraints: const BoxConstraints(maxHeight: 250),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: AppRadius.borderMd,
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: AppColors.divider),
                    itemBuilder: (context, index) {
                      final emp = options.elementAt(index);
                      return ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.accent.withOpacity(0.1),
                          child: Text(
                            (emp.empName ?? 'U')[0].toUpperCase(),
                            style: TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          emp.empName ?? 'Unknown',
                          style: AppTextStyles.body
                              .copyWith(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          '${emp.empNo ?? ''} • ${emp.designation ?? 'N/A'}',
                          style: AppTextStyles.caption,
                        ),
                        onTap: () => onSelected(emp),
                      );
                    },
                  ),
                ),
              ),
            );
          },
          onSelected: (emp) => controller.onEmpSelected(emp),
        ),
      ],
    );
  }
}

class _DesignationField extends StatelessWidget {
  final VehicleAssignmentController controller;

  const _DesignationField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: 'Designation', isRequired: true),
        const SizedBox(height: 8),
        TextField(
          controller: controller.designationController,
          readOnly: true,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: 'Auto-filled from employee',
            hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            prefixIcon:
                Icon(Icons.work_outline, color: AppColors.accent, size: 20),
            filled: true,
            fillColor: AppColors.divider.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        )
      ],
    );
  }
}


class _StatusDropdown extends StatelessWidget {
  final VehicleAssignmentController controller;

  const _StatusDropdown({required this.controller});

  @override
  Widget build(BuildContext context) {
    var genCon = Get.find<GeneralMastersController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: 'Status', isRequired: true),
        const SizedBox(height: 8),
        Obx(() => DropdownButtonFormField<StatusMaster>(
              value: controller.selectedStatus.value,
              items: genCon.vehicleAssignmentStatusMasters
                  .map((status) => DropdownMenuItem(
                        value: status,
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                color: _getStatusColor(status.status ?? ''),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Text(status.status ?? '',
                                style: AppTextStyles.body),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (val) => controller.selectedStatus.value = val,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.flag_outlined,
                    color: AppColors.accent, size: 20),
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
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              ),
              dropdownColor: AppColors.cardBg,
              borderRadius: AppRadius.borderMd,
            )),
      ],
    );
  }

  Color _getStatusColor(String status) => assignmentStatusColor(status);
}

class _RemarksField extends StatelessWidget {
  final VehicleAssignmentController controller;

  const _RemarksField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: 'Remarks'),
        const SizedBox(height: 8),
        TextField(
          controller: controller.remarksController,
          maxLines: 3,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: 'Enter any comments or notes...',
            hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(bottom: 48),
              child:
                  Icon(Icons.notes_outlined, color: AppColors.accent, size: 20),
            ),
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
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool isRequired;

  const _FieldLabel({required this.label, this.isRequired = false});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: label,
        style: AppTextStyles.label,
        children: isRequired
            ? [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.error),
                ),
              ]
            : null,
      ),
    );
  }
}

// ==================== IMAGES SECTION ====================

class _ImagesSection extends StatelessWidget {
  final VehicleAssignmentController controller;

  const _ImagesSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.photo_library_outlined,
                    color: AppColors.accent, size: 20),
                const SizedBox(width: 8),
                Text('Upload Images', style: AppTextStyles.label),
                const SizedBox(width: 8),
                Obx(() => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        borderRadius: AppRadius.borderSm,
                      ),
                      child: Text(
                        '${controller.selectedImages.length}/6',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
                      ),
                    )),
              ],
            ),
            Obx(() => ElevatedButton.icon(
                  onPressed: controller.selectedImages.length >= 6
                      ? null
                      : () => controller.pickImages(),
                  icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                  label: const Text('Add'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.borderSm),
                  ),
                )),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.selectedImages.isEmpty) {
            return Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.borderMd,
                border: Border.all(
                    color: AppColors.divider, style: BorderStyle.solid),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_outlined,
                        size: 36, color: AppColors.textMuted),
                    const SizedBox(height: 8),
                    Text(
                      'No images added yet',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            );
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemCount: controller.selectedImages.length,
            itemBuilder: (context, index) => _ImageTile(
              index: index,
              onRemove: () => controller.removeImage(index),
            ),
          );
        }),
      ],
    );
  }
}

class _ImageTile extends StatelessWidget {
  final int index;
  final VoidCallback onRemove;

  const _ImageTile({required this.index, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.divider),
        color: AppColors.surface,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: AppRadius.borderMd,
            child: Container(
              color: AppColors.surface,
              child: Center(
                child: Icon(Icons.image, color: AppColors.textMuted, size: 32),
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
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
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: AppRadius.borderSm,
              ),
              child: Text(
                '${index + 1}',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== ACTION BUTTONS ====================

class _FormActionButtons extends StatelessWidget {
  final VehicleAssignmentController controller;

  const _FormActionButtons({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => controller.clearForm(),
            icon: const Icon(Icons.clear_rounded, size: 20),
            label: const Text('Clear Form'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: BorderSide(color: AppColors.divider),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Obx(() => ElevatedButton.icon(
                onPressed: controller.isSubmitting.value
                    ? null
                    : () => controller.submitAssignment(),
                icon: controller.isSubmitting.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline, size: 20),
                label: Text(
                  controller.isSubmitting.value
                      ? 'Saving...'
                      : 'Assign Vehicle',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape:
                      RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
                ),
              )),
        ),
      ],
    );
  }
}

// ==================== STATE WIDGETS ====================

class _LoadingState extends StatelessWidget {
  final String message;

  const _LoadingState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(48),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(color: AppColors.accent),
            const SizedBox(height: 16),
            Text(message, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(48),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_rounded,
                size: 48,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Search for a Vehicle',
              style: AppTextStyles.h4.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter a plate number above to search and assign a vehicle',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== HELPER WIDGETS ====================

class _AssignmentDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isHighlighted;
  final Color? statusColor;

  const _AssignmentDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isHighlighted = false,
    this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 10),
        Text('$label:', style: AppTextStyles.bodySmall),
        const Spacer(),
        if (statusColor != null) ...[
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
        Text(
          value,
          style: isHighlighted
              ? AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                )
              : AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w500,
                  color: statusColor,
                ),
        ),
      ],
    );
  }
}
