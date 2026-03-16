import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:multifleet/models/status_master/status_master.dart';
import 'package:multifleet/models/vehicle_assignment_model.dart';
import 'package:multifleet/theme/app_theme.dart';

import '../controllers/assigned_vehicle_controller.dart';
import '../widgets/date_range_picker.dart';

/// ============================================================
/// ASSIGNED VEHICLES LIST PAGE
/// ============================================================
/// Redesigned with MultiFleet Design System (Slate & Teal)
/// ============================================================

class VehicleAssignmentsListPage extends StatelessWidget {
  const VehicleAssignmentsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AssignedVehicleController());
    final isMobile = AppBreakpoints.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header
            _buildPageHeader(controller),
            const SizedBox(height: 20),

            // Filters Section
            _FiltersSection(controller: controller),
            const SizedBox(height: 16),

            // Results Count
            Obx(() => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Text(
                        '${controller.filteredAssignments.length} assignments',
                        style: AppTextStyles.label,
                      ),
                      const Spacer(),
                      if (controller.hasActiveFilters)
                        TextButton.icon(
                          onPressed: () => controller.clearFilters(),
                          icon: const Icon(Icons.clear_all, size: 18),
                          label: const Text('Clear Filters'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                )),

            // Assignments List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const _LoadingState();
                }

                if (controller.filteredAssignments.isEmpty) {
                  return _EmptyState(
                    hasFilters: controller.hasActiveFilters,
                    onClearFilters: () => controller.clearFilters(),
                  );
                }

                return _AssignmentsList(controller: controller);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageHeader(AssignedVehicleController controller) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: AppRadius.borderMd,
          ),
          child: Icon(
            Icons.people_outline,
            color: AppColors.accent,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Assigned Vehicles', style: AppTextStyles.h2),
              Text(
                'View and manage vehicle assignments',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
        // Refresh button
        AppIconButton(
          icon: Icons.refresh_rounded,
          tooltip: 'Refresh',
          onPressed: () => controller.loadAssignments(),
        ),
      ],
    );
  }
}

// ==================== FILTERS SECTION ====================

class _FiltersSection extends StatelessWidget {
  final AssignedVehicleController controller;

  const _FiltersSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: AppRadius.borderLg,
        boxShadow: AppShadows.sm,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 700;

          if (isWide) {
            return Row(
              children: [
                // Search field
                Expanded(
                  flex: 3,
                  child: _SearchField(controller: controller),
                ),
                const SizedBox(width: 12),
                // Status filter
                Expanded(
                  flex: 2,
                  child: _StatusFilter(controller: controller),
                ),
                const SizedBox(width: 12),
                // Date range
                Expanded(
                  flex: 2,
                  child: _DateRangeFilter(controller: controller),
                ),
                const SizedBox(width: 12),
                // Apply button
                ElevatedButton.icon(
                  onPressed: () => controller.applyFilters(),
                  icon: const Icon(Icons.filter_list, size: 18),
                  label: const Text('Apply'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.borderMd,
                    ),
                  ),
                ),
              ],
            );
          }

          // Mobile layout
          return Column(
            children: [
              _SearchField(controller: controller),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _StatusFilter(controller: controller)),
                  const SizedBox(width: 12),
                  Expanded(child: _DateRangeFilter(controller: controller)),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => controller.applyFilters(),
                  icon: const Icon(Icons.filter_list, size: 18),
                  label: const Text('Apply Filters'),
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
          );
        },
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final AssignedVehicleController controller;

  const _SearchField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller.searchController,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        hintText: 'Search by plate, employee, ID...',
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
        prefixIcon: Icon(Icons.search, color: AppColors.accent, size: 20),
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
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        isDense: true,
      ),
    );
  }
}

class _StatusFilter extends StatelessWidget {
  final AssignedVehicleController controller;

  const _StatusFilter({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => DropdownButtonFormField<String>(
          value: controller.selectedStatusFilter.value.isEmpty
              ? null
              : controller.selectedStatusFilter.value,
          hint: Text('All Status',
              style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
          items: [
            const DropdownMenuItem(value: '', child: Text('All Status')),
            ...controller.statusOptions.map((s) => DropdownMenuItem(
                  value: s.status ?? '',
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: assignmentStatusColor(s.status),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(s.status ?? '', style: AppTextStyles.body),
                    ],
                  ),
                )),
          ],
          onChanged: (val) => controller.selectedStatusFilter.value = val ?? '',
          decoration: InputDecoration(
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
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            isDense: true,
          ),
          dropdownColor: AppColors.cardBg,
          borderRadius: AppRadius.borderMd,
        ));
  }
}

class _DateRangeFilter extends StatelessWidget {
  final AssignedVehicleController controller;

  const _DateRangeFilter({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => InkWell(
          // onTap: () => _showDateRangePicker(context),
          onTap: () async {
            final result = await showCustomDateRangePicker(
              context: context,
              startDate: controller.startDateFilter.value, // optional
              endDate: controller.endDateFilter.value, // optional
              firstDate: DateTime(2020), // optional
              lastDate: DateTime.now(), // optional
            );

            log(result.toString());

            if (result != null) {
              controller.startDateFilter.value = result.start;
              controller.endDateFilter.value = result.end;
            }
          },
          borderRadius: AppRadius.borderMd,
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.borderMd,
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.date_range_outlined,
                  color: AppColors.accent,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getDateRangeText(),
                    style: AppTextStyles.body.copyWith(
                      color: _hasDateFilter()
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_hasDateFilter())
                  GestureDetector(
                    onTap: () {
                      controller.startDateFilter.value = null;
                      controller.endDateFilter.value = null;
                    },
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                  ),
              ],
            ),
          ),
        ));
  }

  bool _hasDateFilter() {
    return controller.startDateFilter.value != null ||
        controller.endDateFilter.value != null;
  }

  String _getDateRangeText() {
    final start = controller.startDateFilter.value;
    final end = controller.endDateFilter.value;

    if (start == null && end == null) return 'Date Range';
    if (start != null && end == null) {
      return 'From ${DateFormat('dd/MM/yy').format(start)}';
    }
    if (start == null && end != null) {
      return 'Until ${DateFormat('dd/MM/yy').format(end)}';
    }
    return '${DateFormat('dd/MM').format(start!)} - ${DateFormat('dd/MM').format(end!)}';
  }
}

// ==================== ASSIGNMENTS LIST ====================

class _AssignmentsList extends StatelessWidget {
  final AssignedVehicleController controller;

  const _AssignmentsList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;

        if (isWide) {
          return _buildTable(context);
        }
        return _buildCards(context);
      },
    );
  }

  Widget _buildTable(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: AppRadius.borderLg,
        boxShadow: AppShadows.sm,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.borderLg,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: Obx(() => DataTable(
                  columnSpacing: 24,
                  headingRowHeight: 52,
                  dataRowMinHeight: 60,
                  dataRowMaxHeight: 70,
                  headingRowColor: WidgetStateProperty.all(AppColors.cardBg),
                  columns: const [
                    DataColumn(
                        label: Text('#',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Vehicle',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Employee',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Designation',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Assigned Date',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Return Date',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Status',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Actions',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: List.generate(
                    controller.filteredAssignments.length,
                    (index) {
                      final assignment = controller.filteredAssignments[index];
                      return DataRow(
                        cells: [
                          DataCell(Text('${index + 1}',
                              style: AppTextStyles.bodySmall)),
                          DataCell(
                              _VehicleCell(vehicleNo: assignment.vehicleNo)),
                          DataCell(_EmployeeCell(
                            name: assignment.empName,
                            empNo: assignment.empNo,
                          )),
                          DataCell(Text(assignment.designation ?? '-',
                              style: AppTextStyles.body)),
                          DataCell(Text(
                            controller.formatDate(assignment.assignedDate),
                            style: AppTextStyles.body,
                          )),
                          DataCell(Text(
                            controller
                                .formatDate(assignment.returnDate?.toString()),
                            style: AppTextStyles.body,
                          )),
                          DataCell(_StatusBadge(status: assignment.status)),
                          DataCell(_ActionButtons(
                            assignment: assignment,
                            controller: controller,
                          )),
                        ],
                      );
                    },
                  ),
                )),
          ),
        ),
      ),
    );
  }

  Widget _buildCards(BuildContext context) {
    return Obx(() => ListView.builder(
          itemCount: controller.filteredAssignments.length,
          itemBuilder: (context, index) {
            final assignment = controller.filteredAssignments[index];
            return _AssignmentCard(
              index: index,
              assignment: assignment,
              controller: controller,
            );
          },
        ));
  }
}

// ==================== TABLE CELLS ====================

class _VehicleCell extends StatelessWidget {
  final String? vehicleNo;

  const _VehicleCell({this.vehicleNo});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primaryDark.withOpacity(0.1),
            borderRadius: AppRadius.borderSm,
          ),
          child: Icon(
            Icons.directions_car,
            size: 16,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          vehicleNo ?? '-',
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _EmployeeCell extends StatelessWidget {
  final String? name;
  final String? empNo;

  const _EmployeeCell({this.name, this.empNo});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          name ?? '-',
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
        ),
        if (empNo != null)
          Text(
            empNo!,
            style: AppTextStyles.caption,
          ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final StatusMaster? status;

  const _StatusBadge({this.status});

  @override
  Widget build(BuildContext context) {
    final color = assignmentStatusColor(status?.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppRadius.borderFull,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status?.status ?? 'Unknown',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final VehicleAssignment assignment;
  final AssignedVehicleController controller;

  const _ActionButtons({
    required this.assignment,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.visibility_outlined, size: 20),
          color: AppColors.info,
          tooltip: 'View Details',
          onPressed: () => _showViewDialog(context, assignment, controller),
        ),
        if (controller.canEdit(assignment))
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            color: AppColors.accent,
            tooltip: 'Edit',
            onPressed: () => _showEditDialog(context, assignment, controller),
          ),
      ],
    );
  }
}

// ==================== ASSIGNMENT CARD (Mobile) ====================

class _AssignmentCard extends StatelessWidget {
  final int index;
  final VehicleAssignment assignment;
  final AssignedVehicleController controller;

  const _AssignmentCard({
    required this.index,
    required this.assignment,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: AppRadius.borderLg,
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.lg),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: AppRadius.borderSm,
                  ),
                  child: Text(
                    '#${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    assignment.vehicleNo ?? '-',
                    style: AppTextStyles.label.copyWith(fontSize: 15),
                  ),
                ),
                _StatusBadge(status: assignment.status),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _CardDetailRow(
                  icon: Icons.person_outline,
                  label: 'Employee',
                  value:
                      '${assignment.empName ?? '-'} (${assignment.empNo ?? '-'})',
                ),
                _CardDetailRow(
                  icon: Icons.work_outline,
                  label: 'Designation',
                  value: assignment.designation ?? '-',
                ),
                _CardDetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Assigned',
                  value: controller.formatDate(assignment.assignedDate),
                ),
                _CardDetailRow(
                  icon: Icons.event_outlined,
                  label: 'Return',
                  value:
                      controller.formatDate(assignment.returnDate?.toString()),
                  showDivider: false,
                ),
              ],
            ),
          ),

          // Actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () =>
                      _showViewDialog(context, assignment, controller),
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('View'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.info,
                  ),
                ),
                if (controller.canEdit(assignment)) ...[
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () =>
                        _showEditDialog(context, assignment, controller),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.accent,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool showDivider;

  const _CardDetailRow({
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
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 10),
              SizedBox(
                width: 80,
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

// ==================== VIEW DIALOG ====================

void _showViewDialog(
  BuildContext context,
  VehicleAssignment assignment,
  AssignedVehicleController controller,
) {
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
      child: Container(
        width: 500,
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: AppRadius.borderXl,
        ),
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadius.xl),
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
                      Icons.assignment_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Assignment Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          assignment.vehicleNo ?? '-',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Employee Section
                    _ViewSection(
                      title: 'Employee Information',
                      icon: Icons.person_outline,
                      children: [
                        _ViewDetailRow(
                            label: 'Name', value: assignment.empName ?? '-'),
                        _ViewDetailRow(
                            label: 'Employee ID',
                            value: assignment.empNo ?? '-'),
                        _ViewDetailRow(
                            label: 'Designation',
                            value: assignment.designation ?? '-'),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Assignment Section
                    _ViewSection(
                      title: 'Assignment Details',
                      icon: Icons.event_note_outlined,
                      children: [
                        _ViewDetailRow(
                          label: 'Assigned Date',
                          value: controller
                              .formatDateTime(assignment.assignedDate),
                        ),
                        _ViewDetailRow(
                          label: 'Return Date',
                          value: controller.formatDateTime(
                              assignment.returnDate?.toString()),
                        ),
                        _ViewDetailRow(
                          label: 'Duration',
                          value: controller.getAssignmentDuration(assignment),
                        ),
                        _ViewDetailRow(
                          label: 'Status',
                          value: assignment.status?.status ?? '-',
                          valueWidget: _StatusBadge(status: assignment.status),
                        ),
                      ],
                    ),

                    if (assignment.remarks != null &&
                        assignment.remarks!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _ViewSection(
                        title: 'Remarks',
                        icon: Icons.notes_outlined,
                        children: [
                          Text(assignment.remarks!, style: AppTextStyles.body),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: BorderSide(color: AppColors.divider),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.borderMd,
                        ),
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                  if (controller.canEdit(assignment)) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Get.back();
                          _showEditDialog(context, assignment, controller);
                        },
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Edit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.borderMd,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ViewSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _ViewSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.accent),
            const SizedBox(width: 8),
            Text(title, style: AppTextStyles.label),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.textMuted.withOpacity(0.2),
            borderRadius: AppRadius.borderMd,
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _ViewDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? valueWidget;

  const _ViewDetailRow({
    required this.label,
    required this.value,
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: AppTextStyles.bodySmall),
          ),
          Spacer(),
          Expanded(
            child: valueWidget ??
                Text(
                  value,
                  style:
                      AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
                  textAlign: TextAlign.right,
                ),
          ),
        ],
      ),
    );
  }
}

// ==================== EDIT DIALOG ====================

void _showEditDialog(
  BuildContext context,
  VehicleAssignment assignment,
  AssignedVehicleController controller,
) {
  controller.prepareEditAssignment(assignment);

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: AppRadius.borderXl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: AppRadius.borderMd,
                  ),
                  child: Icon(Icons.edit_outlined, color: AppColors.accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Edit Assignment', style: AppTextStyles.h4),
                      Text(
                        '${assignment.vehicleNo} • ${assignment.empName}',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    controller.clearEditForm();
                    Get.back();
                  },
                ),
              ],
            ),
            Divider(
              height: 32,
              color: AppColors.divider,
            ),

            // Return Date
            _EditFieldLabel(label: 'Return Date'),
            const SizedBox(height: 8),
            Obx(() => _EditDateField(
                  value: controller.editReturnDate.value,
                  startDate: DateTime.parse(assignment.assignedDate!),
                  onChanged: (date) => controller.editReturnDate.value = date,
                )),
            const SizedBox(height: 20),

            // Status
            _EditFieldLabel(label: 'Status'),
            const SizedBox(height: 8),
            Obx(() => DropdownButtonFormField<StatusMaster>(
                  value: controller.editStatus.value,
                  items: controller.statusOptions
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    color: assignmentStatusColor(status.status),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Text(status.status ?? '',
                                    style: AppTextStyles.body),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (val) => controller.editStatus.value = val,
                  decoration: _editInputDecoration(),
                  dropdownColor: AppColors.cardBg,
                  borderRadius: AppRadius.borderMd,
                )),
            const SizedBox(height: 20),

            // Remarks
            _EditFieldLabel(label: 'Remarks'),
            const SizedBox(height: 8),
            TextField(
              controller: controller.editRemarksController,
              maxLines: 3,
              style: AppTextStyles.body,
              decoration:
                  _editInputDecoration(hintText: 'Add notes or comments...'),
            ),
            const SizedBox(height: 24),

            // Terminate Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showTerminateConfirmationDialog(
                  context,
                  assignment,
                  controller,
                ),
                icon: const Icon(Icons.cancel_outlined, size: 18),
                label: const Text('Terminate Assignment'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.borderMd,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      controller.clearEditForm();
                      Get.back();
                    },
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
                  flex: 2,
                  child: Obx(() => ElevatedButton.icon(
                        onPressed: controller.isUpdating.value
                            ? null
                            : () async {
                                final success =
                                    await controller.updateAssignment();
                                if (success) {
                                  controller.clearEditForm();
                                  Get.back();
                                }
                              },
                        icon: controller.isUpdating.value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save_outlined, size: 18),
                        label: Text(controller.isUpdating.value
                            ? 'Saving...'
                            : 'Save Changes'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.borderMd,
                          ),
                        ),
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

class _EditFieldLabel extends StatelessWidget {
  final String label;

  const _EditFieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label, style: AppTextStyles.label);
  }
}

class _EditDateField extends StatelessWidget {
  final DateTime? value;
  final DateTime? startDate;
  final Function(DateTime?) onChanged;

  const _EditDateField(
      {required this.value, required this.onChanged, required this.startDate});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AssignedVehicleController>();

    return InkWell(
      onTap: () => _selectDate(context),
      borderRadius: AppRadius.borderMd,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.borderMd,
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                color: AppColors.accent, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                controller.formatDateForDisplay(value),
                style: AppTextStyles.body.copyWith(
                  color: value != null
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
                ),
              ),
            ),
            if (value != null)
              GestureDetector(
                onTap: () => onChanged(null),
                child: Icon(Icons.close, size: 18, color: AppColors.textMuted),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: value,
      firstDate: startDate ?? DateTime.now().subtract(Duration(days: 60)),
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

    if (picked != null) {
      onChanged(picked);
    }
  }
}

InputDecoration _editInputDecoration({String? hintText}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
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
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  );
}

// ==================== TERMINATE CONFIRMATION DIALOG ====================

void _showTerminateConfirmationDialog(
  BuildContext context,
  VehicleAssignment assignment,
  AssignedVehicleController controller,
) {
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: AppRadius.borderXl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Warning Icon
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

            // Title
            Text(
              'Terminate Assignment?',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Description
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: AppTextStyles.body.copyWith(height: 1.5),
                children: [
                  const TextSpan(text: 'This will end the assignment of '),
                  TextSpan(
                    text: assignment.vehicleNo ?? 'the vehicle',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: ' to '),
                  TextSpan(
                    text: assignment.empName ?? 'the employee',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: '. This action cannot be undone.'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
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
                                final success = await controller
                                    .terminateAssignment(assignment);
                                if (success) {
                                  Get.back(); // Close confirmation
                                  Get.back(); // Close edit dialog
                                  controller.clearEditForm();
                                  _showSuccessDialog(
                                    title: 'Assignment Terminated',
                                    message:
                                        'The vehicle is now available for new assignments.',
                                  );
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

// ==================== SUCCESS DIALOG ====================

void _showSuccessDialog({
  required String title,
  required String message,
}) {
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: AppRadius.borderXl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(title, style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(
              message,
              style:
                  AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.borderMd,
                  ),
                ),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ==================== EMPTY & LOADING STATES ====================

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.accent),
          const SizedBox(height: 16),
          Text(
            'Loading assignments...',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback onClearFilters;

  const _EmptyState({
    required this.hasFilters,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasFilters ? Icons.filter_list_off : Icons.assignment_outlined,
              size: 48,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            hasFilters ? 'No Matching Assignments' : 'No Assignments Found',
            style: AppTextStyles.h4.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            hasFilters
                ? 'Try adjusting your filters to find assignments'
                : 'Vehicle assignments will appear here',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
          if (hasFilters) ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onClearFilters,
              icon: const Icon(Icons.clear_all, size: 18),
              label: const Text('Clear Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.borderMd,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';

// import '../controllers/assigned_vehicle_controller.dart';

// class VehicleAssignmentsListPage extends StatelessWidget {
//   const VehicleAssignmentsListPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(AssignedVehicleController());

//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: LayoutBuilder(builder: (context, constraints) {
//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Filters section
//               _buildFiltersSection(context, controller, constraints),
//               SizedBox(height: 20),

//               // Results count
//               Obx(() => Text(
//                     '${controller.filteredAssignments.length} assignments found',
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   )),
//               SizedBox(height: 10),

//               // Results list
//               Expanded(
//                 child: Obx(() => controller.isLoading.value
//                     ? Center(child: CircularProgressIndicator())
//                     : _buildAssignmentsList(controller, constraints)),
//               ),
//             ],
//           );
//         }),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // Navigate to assignment creation page
//           // Get.find<HomeScreenController>().changePage(2);
//         },
//         tooltip: 'New Assignment',
//         child: Icon(Icons.add),
//       ),
//     );
//   }

//   Widget _buildFiltersSection(BuildContext context,
//       AssignedVehicleController controller, BoxConstraints constraints) {
//     final bool useWideLayout = constraints.maxWidth >= 768;

//     return Card(
//       elevation: 4,
//       child: AnimatedContainer(
//         duration: Duration(milliseconds: 300),
//         child: Obx(
//           () => Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               InkWell(
//                 onTap: () => controller.toggleFiltersVisible(),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Filter Assignments',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Icon(
//                         controller.isFiltersVisible
//                             ? Icons.expand_less
//                             : Icons.expand_more,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               if (controller.isFiltersVisible)
//                 Padding(
//                   padding: const EdgeInsets.only(
//                       left: 16.0, right: 16.0, bottom: 16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       SizedBox(height: 8),
//                       useWideLayout
//                           ? _buildWideFilterLayout(context, controller)
//                           : _buildNarrowFilterLayout(context, controller),
//                       SizedBox(height: 16),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           OutlinedButton(
//                             onPressed: () => controller.clearFilters(),
//                             child: Text('Clear Filters'),
//                           ),
//                           SizedBox(width: 10),
//                           ElevatedButton(
//                             onPressed: () => controller.applyFilters(),
//                             child: Text('Apply Filters'),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               if (!controller.isFiltersVisible)
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   child: Text(
//                     "Selected Filters : ${controller.selectedVehicleType.value} ${controller.selectedStatus.value} ${controller.startDateFilter.value != null ? "From ${DateFormat('dd MMM yyyy').format(controller.startDateFilter.value!)}" : ''}  ${controller.endDateFilter.value != null ? "Till ${DateFormat('dd MMM yyyy').format(controller.endDateFilter.value!)}" : ''} ${controller.searchController.text}",
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                 )
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildWideFilterLayout(
//       BuildContext context, AssignedVehicleController controller) {
//     return Column(
//       children: [
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Left column
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Vehicle Type dropdown
//                   Text('Vehicle Type'),
//                   SizedBox(height: 8),
//                   _buildVehicleTypeDropdown(controller),
//                   SizedBox(height: 16),

//                   // Start date picker
//                   Text('From Date'),
//                   SizedBox(height: 8),
//                   _buildDatePicker(
//                     context: context,
//                     initialDate: controller.startDateFilter.value,
//                     onDateSelected: (date) =>
//                         controller.startDateFilter.value = date,
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(width: 20),
//             // Right column
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Status dropdown
//                   Text('Status'),
//                   SizedBox(height: 8),
//                   _buildStatusDropdown(controller),
//                   SizedBox(height: 16),

//                   // End date picker
//                   Text('To Date'),
//                   SizedBox(height: 8),
//                   _buildDatePicker(
//                     context: context,
//                     initialDate: controller.endDateFilter.value,
//                     onDateSelected: (date) =>
//                         controller.endDateFilter.value = date,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 16),
//         // Search field (full width)
//         TextField(
//           controller: controller.searchController,
//           decoration: InputDecoration(
//             border: OutlineInputBorder(),
//             hintText: 'Search by plate number, employee or designation',
//             prefixIcon: Icon(Icons.search),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildNarrowFilterLayout(
//       BuildContext context, AssignedVehicleController controller) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Search field
//         TextField(
//           controller: controller.searchController,
//           decoration: InputDecoration(
//             border: OutlineInputBorder(),
//             hintText: 'Search by plate number, employee or designation',
//             prefixIcon: Icon(Icons.search),
//           ),
//         ),
//         SizedBox(height: 16),

//         // Vehicle Type dropdown
//         Text('Vehicle Type'),
//         SizedBox(height: 8),
//         _buildVehicleTypeDropdown(controller),
//         SizedBox(height: 16),

//         // Status dropdown
//         Text('Status'),
//         SizedBox(height: 8),
//         _buildStatusDropdown(controller),
//         SizedBox(height: 16),

//         // Start date picker
//         Text('From Date'),
//         SizedBox(height: 8),
//         _buildDatePicker(
//           context: context,
//           initialDate: controller.startDateFilter.value,
//           onDateSelected: (date) => controller.startDateFilter.value = date,
//         ),
//         SizedBox(height: 16),

//         // End date picker
//         Text('To Date'),
//         SizedBox(height: 8),
//         _buildDatePicker(
//           context: context,
//           initialDate: controller.endDateFilter.value,
//           onDateSelected: (date) => controller.endDateFilter.value = date,
//         ),
//       ],
//     );
//   }

//   Widget _buildVehicleTypeDropdown(AssignedVehicleController controller) {
//     return Obx(() => DropdownButtonFormField<String>(
//           decoration: InputDecoration(
//             border: OutlineInputBorder(),
//             contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//           ),
//           value: controller.selectedVehicleType.value.isEmpty
//               ? null
//               : controller.selectedVehicleType.value,
//           hint: Text('All Types'),
//           items: controller.vehicleTypeOptions
//               .map((type) => DropdownMenuItem(
//                     value: type,
//                     child: Text(type),
//                   ))
//               .toList(),
//           onChanged: (value) =>
//               controller.selectedVehicleType.value = value ?? '',
//         ));
//   }

//   Widget _buildStatusDropdown(AssignedVehicleController controller) {
//     return Obx(() => DropdownButtonFormField<String>(
//           decoration: InputDecoration(
//             border: OutlineInputBorder(),
//             contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//           ),
//           value: controller.selectedStatus.value.isEmpty
//               ? null
//               : controller.selectedStatus.value,
//           hint: Text('All Statuses'),
//           items: controller.statusOptions
//               .map((status) => DropdownMenuItem(
//                     value: status,
//                     child: Text(status),
//                   ))
//               .toList(),
//           onChanged: (value) => controller.selectedStatus.value = value ?? '',
//         ));
//   }

//   Widget _buildDatePicker({
//     required BuildContext context,
//     required DateTime? initialDate,
//     required Function(DateTime?) onDateSelected,
//   }) {
//     return InkWell(
//       onTap: () async {
//         final DateTime? pickedDate = await showDatePicker(
//           context: context,
//           initialDate: initialDate ?? DateTime.now(),
//           firstDate: DateTime.now().subtract(Duration(days: 365)),
//           lastDate: DateTime.now().add(Duration(days: 365 * 5)),
//         );

//         if (pickedDate != null) {
//           onDateSelected(pickedDate);
//         }
//       },
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey),
//           borderRadius: BorderRadius.circular(4),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               initialDate != null
//                   ? DateFormat('dd MMM yyyy').format(initialDate)
//                   : 'Select date',
//               style: TextStyle(
//                 color: initialDate != null ? Colors.black : Colors.grey,
//               ),
//             ),
//             Icon(Icons.calendar_today),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAssignmentsList(
//       AssignedVehicleController controller, BoxConstraints constraints) {
//     if (controller.filteredAssignments.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.car_rental, size: 64, color: Colors.grey),
//             SizedBox(height: 16),
//             Text(
//               'No vehicle assignments found',
//               style: TextStyle(fontSize: 18, color: Colors.grey),
//             ),
//           ],
//         ),
//       );
//     }

//     final bool isWideScreen = constraints.maxWidth >= 768;

//     if (isWideScreen) {
//       return _buildAssignmentsTable(controller);
//     } else {
//       return _buildAssignmentsCards(controller);
//     }
//   }

//   Widget _buildAssignmentsTable(AssignedVehicleController controller) {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: SingleChildScrollView(
//         child: DataTable(
//           columnSpacing: 20,
//           headingRowHeight: 50,
//           dataRowHeight: 60,
//           columns: [
//             DataColumn(
//                 label:
//                     Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
//             DataColumn(
//                 label: Text('Plate No',
//                     style: TextStyle(fontWeight: FontWeight.bold))),
//             DataColumn(
//                 label: Text('Vehicle Type',
//                     style: TextStyle(fontWeight: FontWeight.bold))),
//             DataColumn(
//                 label: Text('Employee',
//                     style: TextStyle(fontWeight: FontWeight.bold))),
//             DataColumn(
//                 label: Text('Designation',
//                     style: TextStyle(fontWeight: FontWeight.bold))),
//             DataColumn(
//                 label: Text('Start Date',
//                     style: TextStyle(fontWeight: FontWeight.bold))),
//             DataColumn(
//                 label: Text('End Date',
//                     style: TextStyle(fontWeight: FontWeight.bold))),
//             DataColumn(
//                 label: Text('Status',
//                     style: TextStyle(fontWeight: FontWeight.bold))),
//             DataColumn(
//                 label: Text('Actions',
//                     style: TextStyle(fontWeight: FontWeight.bold))),
//           ],
//           rows: List.generate(
//             controller.filteredAssignments.length,
//             (index) {
//               final item = controller.filteredAssignments[index];
//               return DataRow(
//                 cells: [
//                   DataCell(Text('${index + 1}')),
//                   DataCell(Text(item['plateNumber'])),
//                   DataCell(Text(item['vehicleType'])),
//                   DataCell(Text(item['employeeName'])),
//                   DataCell(Text(item['designation'])),
//                   DataCell(Text(
//                       DateFormat('dd MMM yyyy').format(item['startDate']))),
//                   DataCell(Text(item['endDate'] != null
//                       ? DateFormat('dd MMM yyyy').format(item['endDate'])
//                       : '-')),
//                   DataCell(_buildStatusChip(item['status'])),
//                   DataCell(Row(
//                     children: [
//                       IconButton(
//                         icon: Icon(Icons.visibility, color: Colors.blue),
//                         onPressed: () => controller.viewAssignmentDetails(item),
//                         tooltip: 'View Details',
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.edit, color: Colors.amber),
//                         onPressed: () => controller.editAssignment(item),
//                         tooltip: 'Edit',
//                       ),
//                     ],
//                   )),
//                 ],
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildAssignmentsCards(AssignedVehicleController controller) {
//     return ListView.builder(
//       itemCount: controller.filteredAssignments.length,
//       itemBuilder: (context, index) {
//         final item = controller.filteredAssignments[index];
//         return Card(
//           margin: EdgeInsets.only(bottom: 12),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Text(
//                         '#${index + 1} - ${item['plateNumber']}',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ),
//                     _buildStatusChip(item['status']),
//                   ],
//                 ),
//                 Divider(),
//                 _buildDetailRow('Vehicle Type', item['vehicleType']),
//                 _buildDetailRow('Assigned To', item['employeeName']),
//                 _buildDetailRow('Designation', item['designation']),
//                 _buildDetailRow('Start Date',
//                     DateFormat('dd MMM yyyy').format(item['startDate'])),
//                 _buildDetailRow(
//                     'End Date',
//                     item['endDate'] != null
//                         ? DateFormat('dd MMM yyyy').format(item['endDate'])
//                         : '-'),
//                 if (item['remarks'] != null && item['remarks'].isNotEmpty)
//                   _buildDetailRow('Remarks', item['remarks']),
//                 SizedBox(height: 8),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     TextButton.icon(
//                       icon: Icon(Icons.visibility),
//                       label: Text('View'),
//                       onPressed: () => controller.viewAssignmentDetails(item),
//                     ),
//                     SizedBox(width: 8),
//                     TextButton.icon(
//                       icon: Icon(Icons.edit),
//                       label: Text('Edit'),
//                       onPressed: () => controller.editAssignment(item),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildStatusChip(String status) {
//     Color chipColor;
//     switch (status.toLowerCase()) {
//       case 'active':
//         chipColor = Colors.green;
//         break;
//       case 'pending':
//         chipColor = Colors.orange;
//         break;
//       case 'expired':
//         chipColor = Colors.red;
//         break;
//       default:
//         chipColor = Colors.blue;
//     }

//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: chipColor.withOpacity(0.2),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: chipColor),
//       ),
//       child: Text(
//         status,
//         style: TextStyle(color: chipColor, fontWeight: FontWeight.bold),
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 100,
//             child: Text(
//               "$label:",
//               style: TextStyle(fontWeight: FontWeight.w600),
//             ),
//           ),
//           Expanded(
//             child: Text(value),
//           ),
//         ],
//       ),
//     );
//   }
// }
