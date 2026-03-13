import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:multifleet/models/employee.dart';
import 'package:multifleet/models/fine.dart';
import 'package:multifleet/models/fine_type/fine_type.dart';
import 'package:multifleet/theme/app_theme.dart';
import 'package:multifleet/widgets/search_vehicle.dart';

import '../controllers/fine_controller.dart';
import '../controllers/general_masters.dart';
import '../models/city/city.dart';
import '../models/status_master/status_master.dart';
import '../models/vehicle_assignment_model.dart';
import '../widgets/date_range_picker.dart';

/// ============================================================
/// FINES MANAGEMENT PAGE
/// ============================================================
/// Redesigned with MultiFleet Design System (Slate & Teal)
/// Features: List/Grouped view, Add/Edit fines, Filters
/// ============================================================

class FinesPage extends StatelessWidget {
  const FinesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FineController>();
    final isMobile = AppBreakpoints.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header
            _buildPageHeader(context, controller),
            const SizedBox(height: 20),

            // Stats Cards
            _StatsSection(controller: controller),
            const SizedBox(height: 20),

            // Filters Section
            _FiltersSection(controller: controller),
            const SizedBox(height: 16),

            // View Toggle & Results Count
            _buildViewToggleRow(controller),
            const SizedBox(height: 12),

            // Fines List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const _LoadingState();
                }

                if (controller.filteredFines.isEmpty) {
                  return _EmptyState(
                    hasFilters: controller.hasActiveFilters,
                    onClearFilters: () => controller.clearFilters(),
                    onAddFine: () => _showAddFineDialog(context, controller),
                  );
                }

                if (controller.isGroupedView.value) {
                  return _GroupedFinesView();
                }
                return _FlatFinesView(controller: controller);
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddFineDialog(context, controller),
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Fine', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context, FineController controller) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.1),
            borderRadius: AppRadius.borderMd,
          ),
          child: const Icon(
            Icons.receipt_long_outlined,
            color: AppColors.error,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Traffic Fines', style: AppTextStyles.h2),
              Text(
                'Manage and track vehicle fines',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
        AppIconButton(
          icon: Icons.refresh_rounded,
          tooltip: 'Refresh',
          onPressed: () => controller.loadFines(),
        ),
      ],
    );
  }

  Widget _buildViewToggleRow(FineController controller) {
    return Obx(() => Row(
          children: [
            Text(
              '${controller.filteredFines.length} fines',
              style: AppTextStyles.label,
            ),
            if (controller.isGroupedView.value)
              Text(
                ' • ${controller.vehiclesWithFinesCount} vehicles',
                style: AppTextStyles.bodySmall,
              ),
            const Spacer(),
            if (controller.hasActiveFilters)
              TextButton.icon(
                onPressed: () => controller.clearFilters(),
                icon: const Icon(Icons.clear_all, size: 18),
                label: const Text('Clear'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                ),
              ),
            const SizedBox(width: 8),
            // View Toggle
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: AppRadius.borderMd,
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ViewToggleButton(
                    icon: Icons.folder_outlined,
                    tooltip: 'Group by Vehicle',
                    isSelected: controller.isGroupedView.value,
                    onPressed: () {
                      if (!controller.isGroupedView.value) {
                        controller.toggleView();
                      }
                    },
                  ),
                  Container(width: 1, height: 24, color: AppColors.divider),
                  _ViewToggleButton(
                    icon: Icons.list_alt_outlined,
                    tooltip: 'Flat List',
                    isSelected: !controller.isGroupedView.value,
                    onPressed: () {
                      if (controller.isGroupedView.value) {
                        controller.toggleView();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}

class _ViewToggleButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool isSelected;
  final VoidCallback onPressed;

  const _ViewToggleButton({
    required this.icon,
    required this.tooltip,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadius.borderSm,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accent.withOpacity(0.1) : null,
            borderRadius: AppRadius.borderSm,
          ),
          child: Icon(
            icon,
            size: 20,
            color: isSelected ? AppColors.accent : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

// ==================== STATS SECTION ====================

class _StatsSection extends StatelessWidget {
  final FineController controller;

  const _StatsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;
        final cardWidth = isWide
            ? (constraints.maxWidth - 36) / 4
            : (constraints.maxWidth - 12) / 2;

        return Obx(() {
          final isFiltered = controller.hasActiveFilters;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isFiltered)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(Icons.filter_alt_outlined,
                          size: 14, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text(
                        'Showing filtered results',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _StatCard(
                    width: cardWidth,
                    icon: Icons.receipt_long_outlined,
                    iconColor: AppColors.info,
                    label: isFiltered ? 'Fines (filtered)' : 'Total Fines',
                    value: controller.totalFinesCount.value.toString(),
                  ),
                  _StatCard(
                    width: cardWidth,
                    icon: Icons.warning_amber_outlined,
                    iconColor: AppColors.error,
                    label: isFiltered ? 'Unpaid (filtered)' : 'Unpaid',
                    value: controller.unpaidFinesCount.value.toString(),
                    subtitle: controller
                        .formatAmount(controller.totalUnpaidAmount.value),
                  ),
                  _StatCard(
                    width: cardWidth,
                    icon: Icons.check_circle_outline,
                    iconColor: AppColors.success,
                    label: isFiltered ? 'Paid (filtered)' : 'Paid',
                    value: controller
                        .formatAmount(controller.totalPaidAmount.value),
                  ),
                  _StatCard(
                    width: cardWidth,
                    icon: Icons.directions_car_outlined,
                    iconColor: AppColors.accent,
                    label: isFiltered ? 'Vehicles (filtered)' : 'Vehicles',
                    value: controller.vehiclesWithFinesCount.value.toString(),
                  ),
                ],
              ),
            ],
          );
        });
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final double width;
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? subtitle;

  const _StatCard({
    required this.width,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 100,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: AppRadius.borderLg,
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: AppRadius.borderMd,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: AppTextStyles.caption),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.h4.copyWith(fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== FILTERS SECTION ====================

class _FiltersSection extends StatelessWidget {
  final FineController controller;

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
          final isWide = constraints.maxWidth >= 800;

          if (isWide) {
            return Row(
              children: [
                Expanded(flex: 3, child: _SearchField(controller: controller)),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: _StatusFilter(controller: controller)),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: _TypeFilter(controller: controller)),
                const SizedBox(width: 12),
                Expanded(
                    flex: 2, child: _DateRangeFilter(controller: controller)),
              ],
            );
          }

          return Column(
            children: [
              _SearchField(controller: controller),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _StatusFilter(controller: controller)),
                  const SizedBox(width: 12),
                  Expanded(child: _TypeFilter(controller: controller)),
                ],
              ),
              const SizedBox(height: 12),
              _DateRangeFilter(controller: controller),
            ],
          );
        },
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final FineController controller;

  const _SearchField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller.searchController,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        hintText: 'Search by plate, employee, ticket...',
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
  final FineController controller;

  const _StatusFilter({required this.controller});

  @override
  Widget build(BuildContext context) {
    var genCon = Get.find<GeneralMastersController>();
    return Obx(() => DropdownButtonFormField<StatusMaster>(
          value: controller.selectedStatusFilter.value,
          hint: Text('All Status',
              style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
          items: [
            const DropdownMenuItem(value: null, child: Text('All Status')),
            ...genCon.fineStatusMasters
                .map((status) => DropdownMenuItem<StatusMaster>(
                      value: status,
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: controller.getStatusColor(status.status),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Text(status.status ?? '', style: AppTextStyles.body),
                        ],
                      ),
                    )),
          ],
          onChanged: (val) => controller.selectedStatusFilter.value = val,
          decoration: _filterDecoration(),
          dropdownColor: AppColors.cardBg,
          borderRadius: AppRadius.borderMd,
        ));
  }
}

class _TypeFilter extends StatelessWidget {
  final FineController controller;

  const _TypeFilter({required this.controller});

  @override
  Widget build(BuildContext context) {
    var genCon = Get.find<GeneralMastersController>();
    return Obx(() => DropdownButtonFormField<FineType>(
          value: controller.selectedTypeFilter.value,
          hint: Text('All Types',
              style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
          items: [
            DropdownMenuItem(
                value: null,
                child: Text('All Types', style: AppTextStyles.body)),
            ...genCon.fineTypeMasters.map((type) => DropdownMenuItem<FineType>(
                  value: type,
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: controller.getFineTypeColor(type.fineType),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                          child: Text(type.fineType ?? '',
                              style: AppTextStyles.body)),
                    ],
                  ),
                )),
          ],
          onChanged: (val) => controller.selectedTypeFilter.value = val,
          decoration: _filterDecoration(),
          dropdownColor: AppColors.cardBg,
          borderRadius: AppRadius.borderMd,
          isExpanded: true,
        ));
  }
}

class _DateRangeFilter extends StatelessWidget {
  final FineController controller;

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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.borderMd,
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Icon(Icons.date_range_outlined,
                    color: AppColors.accent, size: 20),
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
                    child:
                        Icon(Icons.close, size: 16, color: AppColors.textMuted),
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

InputDecoration _filterDecoration() {
  return InputDecoration(
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
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    isDense: true,
  );
}

// ==================== GROUPED FINES VIEW ====================

class _GroupedFinesView extends StatelessWidget {
  // final FineController controller;

  const _GroupedFinesView();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FineController>(
      initState: (_) {},
      builder: (controller) {
        final vehicles = controller.groupedFines.keys.toList();
        return ListView.builder(
          itemCount: vehicles.length,
          itemBuilder: (context, index) {
            final vehicleNo = vehicles[index];
            final fines = controller.groupedFines[vehicleNo] ?? [];
            final isExpanded = controller.expandedVehicles.contains(vehicleNo);

            return _VehicleFinesGroup(
              vehicleNo: vehicleNo,
              fines: fines,
              isExpanded: isExpanded,
              onToggle: () => controller.toggleVehicleExpanded(vehicleNo),
              controller: controller,
            );
          },
        );
      },
    );
  }
}

class _VehicleFinesGroup extends StatelessWidget {
  final String vehicleNo;
  final List<Fine> fines;
  final bool isExpanded;
  final VoidCallback onToggle;
  final FineController controller;

  const _VehicleFinesGroup({
    required this.vehicleNo,
    required this.fines,
    required this.isExpanded,
    required this.onToggle,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final unpaidCount =
        fines.where((f) => f.status?.status?.toLowerCase() == 'unpaid').length;
    final totalAmount =
        fines.fold<double>(0, (sum, f) => sum + (f.amount ?? 0));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: AppRadius.borderLg,
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        children: [
          // Vehicle Header
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.lg),
              bottom: isExpanded ? Radius.zero : Radius.circular(AppRadius.lg),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark.withOpacity(0.1),
                      borderRadius: AppRadius.borderMd,
                    ),
                    child: Icon(
                      Icons.directions_car,
                      color: AppColors.primaryDark,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicleNo,
                          style: AppTextStyles.label.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${fines.length} fine${fines.length != 1 ? 's' : ''}',
                              style: AppTextStyles.bodySmall,
                            ),
                            if (unpaidCount > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.1),
                                  borderRadius: AppRadius.borderFull,
                                ),
                                child: Text(
                                  '$unpaidCount unpaid',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        controller.formatAmount(totalAmount),
                        style: AppTextStyles.label,
                      ),
                      Text('Total', style: AppTextStyles.caption),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),

          // Fines List (expanded)
          if (isExpanded)
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: Column(
                children: fines.map((fine) {
                  return _FineListItem(
                    fine: fine,
                    controller: controller,
                    showVehicle: false,
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

// ==================== FLAT FINES VIEW ====================

class _FlatFinesView extends StatelessWidget {
  final FineController controller;

  const _FlatFinesView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
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
        boxShadow: AppShadows.lg,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.borderLg,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: Obx(() => DataTable(
                  columnSpacing: 20,
                  headingRowHeight: 52,
                  dataRowMinHeight: 56,
                  dataRowMaxHeight: 64,
                  headingRowColor: WidgetStateProperty.all(
                      AppColors.textMuted.withOpacity(0.2)),
                  columns: const [
                    DataColumn(
                        label: Text('Ticket #',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Vehicle',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Employee',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Type',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Date',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Amount',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        numeric: true),
                    DataColumn(
                        label: Text('Status',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Actions',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: controller.filteredFines.map((fine) {
                    return DataRow(
                      cells: [
                        DataCell(Text(fine.ticketNo ?? '-',
                            style: AppTextStyles.body
                                .copyWith(fontWeight: FontWeight.w500))),
                        DataCell(Text(fine.vehicleNo ?? '-',
                            style: AppTextStyles.body)),
                        DataCell(Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(fine.empName ?? '-',
                                style: AppTextStyles.body),
                            if (fine.empNo != null)
                              Text(fine.empNo!, style: AppTextStyles.caption),
                          ],
                        )),
                        DataCell(_FineTypeBadge(type: fine.fineType?.fineType)),
                        DataCell(Text(controller.formatDate(fine.fineDate),
                            style: AppTextStyles.body)),
                        DataCell(Text(
                          controller.formatAmount(fine.amount),
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        )),
                        DataCell(_StatusBadge(status: fine.status?.status)),
                        DataCell(_ActionButtons(
                          fine: fine,
                          controller: controller,
                        )),
                      ],
                    );
                  }).toList(),
                )),
          ),
        ),
      ),
    );
  }

  Widget _buildCards(BuildContext context) {
    return Obx(() => ListView.builder(
          itemCount: controller.filteredFines.length,
          itemBuilder: (context, index) {
            final fine = controller.filteredFines[index];
            return _FineCard(fine: fine, controller: controller);
          },
        ));
  }
}

// ==================== FINE LIST ITEM (for grouped view) ====================

class _FineListItem extends StatelessWidget {
  final Fine fine;
  final FineController controller;
  final bool showVehicle;

  const _FineListItem({
    required this.fine,
    required this.controller,
    this.showVehicle = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showFineDetailsDialog(context, fine, controller),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.divider),
          ),
          color: AppColors.cardBg,
          borderRadius: AppRadius.borderSm,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _FineTypeBadge(type: fine.fineType?.fineType),
                      const SizedBox(width: 8),
                      Text(
                        '#${fine.ticketNo ?? '-'}',
                        style: AppTextStyles.bodySmall
                            .copyWith(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fine.empName ?? 'Unknown Employee',
                    style: AppTextStyles.body,
                  ),
                  Text(
                    controller.formatDate(fine.fineDate),
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  controller.formatAmount(fine.amount),
                  style: AppTextStyles.label,
                ),
                const SizedBox(height: 4),
                _StatusBadge(status: fine.status?.status),
              ],
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20),
              onSelected: (value) => _handleMenuAction(context, value),
              color: AppColors.cardBg,
              borderRadius: AppRadius.borderSm,
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'view', child: Text('View Details')),
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                if (fine.status?.status?.toLowerCase() != 'paid')
                  const PopupMenuItem(
                      value: 'paid', child: Text('Mark as Paid')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'view':
        _showFineDetailsDialog(context, fine, controller);
        break;
      case 'edit':
        _showEditFineDialog(context, fine, controller);
        break;
      case 'paid':
        _showMarkAsPaidDialog(context, fine, controller);
        break;
    }
  }
}

// ==================== FINE CARD (for mobile flat view) ====================

class _FineCard extends StatelessWidget {
  final Fine fine;
  final FineController controller;

  const _FineCard({required this.fine, required this.controller});

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
                _FineTypeBadge(type: fine.fineType?.fineType),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '#${fine.ticketNo ?? '-'}',
                    style: AppTextStyles.label,
                  ),
                ),
                _StatusBadge(status: fine.status?.status),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _CardDetailRow(
                  icon: Icons.directions_car_outlined,
                  label: 'Vehicle',
                  value: fine.vehicleNo ?? '-',
                ),
                _CardDetailRow(
                  icon: Icons.person_outline,
                  label: 'Employee',
                  value: fine.empName ?? '-',
                ),
                _CardDetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Date',
                  value: controller.formatDate(fine.fineDate),
                ),
                _CardDetailRow(
                  icon: Icons.attach_money,
                  label: 'Amount',
                  value: controller.formatAmount(fine.amount),
                  valueStyle: AppTextStyles.label.copyWith(
                    color: fine.status?.status?.toLowerCase() == 'unpaid'
                        ? AppColors.error
                        : AppColors.textPrimary,
                  ),
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
                      _showFineDetailsDialog(context, fine, controller),
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('View'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.info),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () =>
                      _showEditFineDialog(context, fine, controller),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                  style:
                      TextButton.styleFrom(foregroundColor: AppColors.accent),
                ),
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
  final TextStyle? valueStyle;
  final bool showDivider;

  const _CardDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueStyle,
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
                width: 70,
                child: Text(label, style: AppTextStyles.bodySmall),
              ),
              Expanded(
                child: Text(
                  value,
                  style: valueStyle ??
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

// ==================== BADGES ====================

class _StatusBadge extends StatelessWidget {
  final String? status;

  const _StatusBadge({this.status});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FineController>();
    final color = controller.getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppRadius.borderFull,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status ?? 'Unknown',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FineTypeBadge extends StatelessWidget {
  final String? type;

  const _FineTypeBadge({this.type});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FineController>();
    final color = controller.getFineTypeColor(type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppRadius.borderSm,
      ),
      child: Text(
        type ?? 'Other',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ==================== ACTION BUTTONS ====================

class _ActionButtons extends StatelessWidget {
  final Fine fine;
  final FineController controller;

  const _ActionButtons({required this.fine, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.visibility_outlined, size: 20),
          color: AppColors.info,
          tooltip: 'View Details',
          onPressed: () => _showFineDetailsDialog(context, fine, controller),
        ),
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: 20),
          color: AppColors.accent,
          tooltip: 'Edit',
          onPressed: () => _showEditFineDialog(context, fine, controller),
        ),
        if (fine.status?.status?.toLowerCase() != 'paid')
          IconButton(
            icon: const Icon(Icons.check_circle_outline, size: 20),
            color: AppColors.success,
            tooltip: 'Mark as Paid',
            onPressed: () => _showMarkAsPaidDialog(context, fine, controller),
          ),
      ],
    );
  }
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
          Text('Loading fines...', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback onClearFilters;
  final VoidCallback onAddFine;

  const _EmptyState({
    required this.hasFilters,
    required this.onClearFilters,
    required this.onAddFine,
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
              hasFilters ? Icons.filter_list_off : Icons.receipt_long_outlined,
              size: 48,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            hasFilters ? 'No Matching Fines' : 'No Fines Found',
            style: AppTextStyles.h4.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            hasFilters
                ? 'Try adjusting your filters'
                : 'Add a fine to get started',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (hasFilters)
            OutlinedButton.icon(
              onPressed: onClearFilters,
              icon: const Icon(Icons.clear_all, size: 18),
              label: const Text('Clear Filters'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: BorderSide(color: AppColors.divider),
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: onAddFine,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Fine'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}

// ==================== VIEW FINE DETAILS DIALOG ====================

void _showFineDetailsDialog(
  BuildContext context,
  Fine fine,
  FineController controller,
) {
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 650),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: AppRadius.borderXl,
        ),
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
                    child: const Icon(Icons.receipt_long,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Fine Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '#${fine.ticketNo ?? '-'}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(status: fine.status?.status),
                  const SizedBox(width: 8),
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
                    // Amount highlight
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: fine.status?.status?.toLowerCase() == 'unpaid'
                            ? AppColors.error.withOpacity(0.1)
                            : AppColors.textMuted.withOpacity(0.2),
                        borderRadius: AppRadius.borderMd,
                        border: Border.all(
                          color: fine.status?.status?.toLowerCase() == 'unpaid'
                              ? AppColors.error.withOpacity(0.3)
                              : AppColors.divider,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text('Fine Amount', style: AppTextStyles.caption),
                          const SizedBox(height: 4),
                          Text(
                            controller.formatAmount(fine.amount),
                            style: AppTextStyles.h2.copyWith(
                              color:
                                  fine.status?.status?.toLowerCase() == 'unpaid'
                                      ? AppColors.error
                                      : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Vehicle & Employee
                    _DetailSection(
                      title: 'Assignment',
                      icon: Icons.assignment_outlined,
                      children: [
                        _DetailRow(
                            label: 'Vehicle', value: fine.vehicleNo ?? '-'),
                        _DetailRow(
                            label: 'Employee', value: fine.empName ?? '-'),
                        _DetailRow(
                            label: 'Employee ID', value: fine.empNo ?? '-'),
                        _DetailRow(
                            label: 'Designation',
                            value: fine.designation ?? '-'),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Fine Details
                    _DetailSection(
                      title: 'Fine Information',
                      icon: Icons.info_outline,
                      children: [
                        _DetailRow(
                          label: 'Type',
                          valueWidget:
                              _FineTypeBadge(type: fine.fineType?.fineType),
                        ),
                        _DetailRow(
                          label: 'Date',
                          value: controller.formatDateTime(fine.fineDate),
                        ),
                        _DetailRow(
                            label: 'Location', value: fine.location ?? '-'),
                        _DetailRow(
                            label: 'Emirate', value: fine.emirate?.city ?? '-'),
                        _DetailRow(
                          label: 'Authority',
                          value: fine.issuingAuthority ?? '-',
                        ),
                      ],
                    ),

                    if (fine.reason != null && fine.reason!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _DetailSection(
                        title: 'Reason',
                        icon: Icons.description_outlined,
                        children: [
                          Text(fine.reason!, style: AppTextStyles.body)
                        ],
                      ),
                    ],

                    if (fine.remarks != null && fine.remarks!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _DetailSection(
                        title: 'Remarks',
                        icon: Icons.notes_outlined,
                        children: [
                          Text(fine.remarks!, style: AppTextStyles.body)
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        _showEditFineDialog(context, fine, controller);
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
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _DetailSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _DetailSection({
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;

  const _DetailRow({required this.label, this.value, this.valueWidget});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: AppTextStyles.bodySmall),
          ),
          Spacer(),
          Expanded(
            child: valueWidget ??
                Text(
                  value ?? '-',
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

// ==================== MARK AS PAID DIALOG ====================

void _showMarkAsPaidDialog(
  BuildContext context,
  Fine fine,
  FineController controller,
) {
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
      child: Container(
        width: 400,
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
                Icons.check_circle_outline,
                color: AppColors.success,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text('Mark as Paid?', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: AppTextStyles.body.copyWith(height: 1.5),
                children: [
                  const TextSpan(text: 'This will mark fine '),
                  TextSpan(
                    text: '#${fine.ticketNo}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: ' for '),
                  TextSpan(
                    text: controller.formatAmount(fine.amount),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: ' as paid.'),
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
                  child: ElevatedButton(
                    onPressed: () async {
                      Get.back();
                      final paidStatus = controller.genCon.fineStatusMasters
                          .firstWhereOrNull(
                              (s) => s.status?.toLowerCase() == 'paid');
                      if (paidStatus != null) {
                        await controller.updateFineStatus(fine, paidStatus);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.borderMd,
                      ),
                    ),
                    child: const Text('Mark Paid'),
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

// ==================== ADD FINE DIALOG ====================

void _showAddFineDialog(BuildContext context, FineController controller) {
  controller.prepareAddFine();

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
      child: Container(
        width: 700,
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: AppRadius.borderXl,
        ),
        child: Column(
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
                    child: const Icon(Icons.add_circle_outline,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Add New Fine',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      controller.clearAddFineForm();
                      Get.back();
                    },
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _AddFineForm(controller: controller),
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
                      onPressed: () {
                        controller.clearAddFineForm();
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
                          onPressed: controller.isSubmitting.value
                              ? null
                              : () async {
                                  final success = await controller.saveFine();
                                  if (success) {
                                    controller.clearAddFineForm();
                                    Get.back();
                                  }
                                },
                          icon: controller.isSubmitting.value
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save_outlined, size: 18),
                          label: Text(controller.isSubmitting.value
                              ? 'Saving...'
                              : 'Add Fine'),
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
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: false,
  );
}

class _AddFineForm extends StatelessWidget {
  final FineController controller;

  const _AddFineForm({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step 1: Search Vehicle
        _FormSection(
          number: '1',
          title: 'Search Vehicle',
          child: SearchVehicleWidget(
            controller: controller.plateNumberController,
            onSearch: () => controller.searchVehicleForFine(),
            onClear: () {
              controller.selectedVehicle.value = null;
              controller.assignmentHistory.clear();
            },
            onDataChanged: (plate) {
              controller.onPlateChanged(plate.code, plate.region, plate.number);
            },
          ),
        ),

        // Show selected vehicle
        Obx(() {
          if (controller.selectedVehicle.value != null) {
            return Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: AppRadius.borderMd,
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle,
                      color: AppColors.success, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Vehicle: ${controller.selectedVehicle.value!.vehicleNo} - ${controller.selectedVehicle.value!.brand ?? ''} ${controller.selectedVehicle.value!.model ?? ''}',
                      style: AppTextStyles.body
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      controller.selectedVehicle.value = null;
                      controller.assignmentHistory.clear();
                      controller.selectedAssignment.value = null;
                    },
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),

        const SizedBox(height: 24),

        // Step 2: Select Employee
        Obx(() {
          if (controller.selectedVehicle.value == null) {
            return const SizedBox.shrink();
          }

          return _FormSection(
            number: '2',
            title: 'Select Responsible Employee',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Assignment History
                if (controller.isLoadingHistory.value)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                  )
                else if (controller.assignmentHistory.isNotEmpty) ...[
                  Text('Assignment History', style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.divider),
                      borderRadius: AppRadius.borderMd,
                      color: AppColors.textMuted.withOpacity(0.2),
                    ),
                    child: Column(
                      children: controller.assignmentHistory.map((history) {
                        final isSelected =
                            controller.selectedAssignment.value == history;
                        return InkWell(
                          onTap: () =>
                              controller.selectAssignmentHistory(history),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.accent.withOpacity(0.1)
                                  : null,
                              border: Border(
                                bottom: BorderSide(
                                    color: AppColors.cardBg, width: 1.5),
                              ),
                            ),
                            child: Row(
                              children: [
                                Radio<VehicleAssignment>(
                                  value: history,
                                  groupValue:
                                      controller.selectedAssignment.value,
                                  onChanged: (val) {
                                    if (val != null) {
                                      controller.selectAssignmentHistory(val);
                                    }
                                  },
                                  activeColor: AppColors.accent,
                                  fillColor: MaterialStateProperty.all(
                                      AppColors.accent),
                                  backgroundColor: MaterialStateProperty.all(
                                      AppColors.cardBg),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        history.empName ?? '-',
                                        style: AppTextStyles.body.copyWith(
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        '${history.empNo ?? '-'} • ${history.designation ?? '-'}',
                                        style: AppTextStyles.caption,
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      controller
                                          .formatDate(history.assignedDate),
                                      style: AppTextStyles.bodySmall,
                                    ),
                                    Text(
                                      'to ${controller.formatDate(history.returnDate)}',
                                      style: AppTextStyles.caption,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // External Employee Option
                Obx(() => CheckboxListTile(
                      value: controller.isExternalEmployee.value,
                      onChanged: (val) =>
                          controller.toggleExternalEmployee(val ?? false),
                      title: const Text('Employee not in history (External)'),
                      subtitle: const Text(
                          'Select if the responsible employee is not listed above'),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppColors.accent,
                    )),

                // External Employee Autocomplete
                Obx(() {
                  if (!controller.isExternalEmployee.value) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _EmployeeAutocomplete(controller: controller),
                  );
                }),
              ],
            ),
          );
        }),

        const SizedBox(height: 24),

        // Step 3: Fine Details
        Obx(() {
          if (controller.selectedVehicle.value == null) {
            return const SizedBox.shrink();
          }

          return _FormSection(
            number: '3',
            title: 'Fine Details',
            child: _FineDetailsForm(controller: controller),
          );
        }),
      ],
    );
  }
}

class _FormSection extends StatelessWidget {
  final String number;
  final String title;
  final Widget child;

  const _FormSection({
    required this.number,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(title, style: AppTextStyles.h4),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}

class _EmployeeAutocomplete extends StatelessWidget {
  final FineController controller;

  const _EmployeeAutocomplete({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Autocomplete<Employee>(
      displayStringForOption: (emp) => '${emp.empName} (${emp.empNo})',
      optionsBuilder: (textEditingValue) async {
        if (textEditingValue.text.isEmpty) return [];
        return await controller.getEmployeeSuggestions(textEditingValue.text);
      },
      onSelected: (emp) => controller.selectExternalEmployee(emp),
      fieldViewBuilder: (context, textController, focusNode, onSubmitted) {
        return TextField(
          controller: textController,
          focusNode: focusNode,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: 'Search employee by name or ID...',
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
              width: 400,
              constraints: const BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: AppRadius.borderMd,
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final emp = options.elementAt(index);
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.accent.withOpacity(0.1),
                      child: Text(
                        (emp.empName ?? 'U')[0].toUpperCase(),
                        style: TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(emp.empName ?? '-', style: AppTextStyles.body),
                    subtitle:
                        Text(emp.empNo ?? '-', style: AppTextStyles.caption),
                    onTap: () => onSelected(emp),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FineDetailsForm extends StatelessWidget {
  final FineController controller;

  const _FineDetailsForm({required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 500;

        if (isWide) {
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'Ticket Number *',
                      controller: controller.ticketNoController,
                      hint: 'Enter ticket number',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      label: 'Amount (AED) *',
                      controller: controller.amountController,
                      hint: 'Enter amount',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildFineTypeDropdown()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDateTimePicker(context)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildEmirateDropdown()),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      label: 'Issuing Authority',
                      controller: controller.authorityController,
                      hint: 'Enter issuing authority',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Location',
                controller: controller.locationController,
                hint: 'Enter location where fine occurred',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Reason',
                controller: controller.reasonController,
                hint: 'Enter reason for fine',
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildStatusDropdown()),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      label: 'Remarks',
                      controller: controller.remarksController,
                      hint: 'Any additional notes',
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        // Narrow layout
        return Column(
          children: [
            _buildTextField(
              label: 'Ticket Number *',
              controller: controller.ticketNoController,
              hint: 'Enter ticket number',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Amount (AED) *',
              controller: controller.amountController,
              hint: 'Enter amount *',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildFineTypeDropdown(),
            const SizedBox(height: 16),
            _buildDateTimePicker(context),
            const SizedBox(height: 16),
            _buildEmirateDropdown(),
            const SizedBox(height: 16),
            // _buildAuthorityDropdown(),
            _buildTextField(
              label: 'Issuing Authority *',
              controller: controller.authorityController,
              hint: 'Enter issuing authority',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Location',
              controller: controller.locationController,
              hint: 'Enter location',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Reason',
              controller: controller.reasonController,
              hint: 'Enter reason',
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            _buildStatusDropdown(),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Remarks',
              controller: controller.remarksController,
              hint: 'Any notes',
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: AppTextStyles.body,
          decoration: _inputDecoration(hint),
        ),
      ],
    );
  }

  Widget _buildFineTypeDropdown() {
    final genCon = Get.find<GeneralMastersController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Fine Type *', style: AppTextStyles.label),
        const SizedBox(height: 8),
        Obx(() {
          final selected = controller.selectedFineType.value;
          final items = genCon.fineTypeMasters;
          return DropdownButtonFormField<FineType>(
            key: ValueKey('finetype_${selected?.fineTypeId}'),
            value: items.contains(selected) ? selected : null,
            hint: Text('Select type',
                style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
            items: items
                .map((type) => DropdownMenuItem<FineType>(
                      value: type,
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: controller.getFineTypeColor(type.fineType),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                              child: Text(type.fineType ?? '',
                                  style: AppTextStyles.body)),
                        ],
                      ),
                    ))
                .toList(),
            onChanged: (val) => controller.selectedFineType.value = val,
            decoration: _inputDecoration(null),
            dropdownColor: AppColors.cardBg,
            borderRadius: AppRadius.borderMd,
            isExpanded: true,
          );
        }),
      ],
    );
  }

  Widget _buildDateTimePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Fine Date & Time *', style: AppTextStyles.label),
        const SizedBox(height: 8),
        Obx(() => InkWell(
              onTap: () => _selectDateTime(context),
              borderRadius: AppRadius.borderMd,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                        controller
                            .formatDateForDisplay(controller.fineDate.value),
                        style: AppTextStyles.body.copyWith(
                          color: controller.fineDate.value != null
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: controller.fineDate.value ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.accent,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        controller.fineDate.value = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      } else {
        controller.fineDate.value = date;
      }
    }
  }

  Widget _buildEmirateDropdown() {
    final genCon = Get.find<GeneralMastersController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Emirate *', style: AppTextStyles.label),
        const SizedBox(height: 8),
        Obx(() {
          final selected = controller.selectedEmirate.value;
          final items = genCon.companyCity;
          return DropdownButtonFormField<City>(
            key: ValueKey('emirate_${selected?.city}'),
            value: items.contains(selected) ? selected : null,
            hint: Text('Select emirate',
                style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
            items: items
                .map((e) => DropdownMenuItem<City>(
                    value: e,
                    child: Text(e.city ?? '', style: AppTextStyles.body)))
                .toList(),
            onChanged: (val) => controller.selectedEmirate.value = val,
            decoration: _inputDecoration(null),
            dropdownColor: AppColors.cardBg,
            borderRadius: AppRadius.borderMd,
          );
        }),
      ],
    );
  }

  // Widget _buildAuthorityDropdown() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text('Issuing Authority', style: AppTextStyles.label),
  //       const SizedBox(height: 8),
  //       Obx(() => DropdownButtonFormField<String>(
  //             value: controller.selectedAuthority.value,
  //             hint: Text('Select authority',
  //                 style:
  //                     AppTextStyles.body.copyWith(color: AppColors.textMuted)),
  //             items: controller.authorityOptions
  //                 .map((a) => DropdownMenuItem(
  //                     value: a, child: Text(a, style: AppTextStyles.body)))
  //                 .toList(),
  //             onChanged: (val) => controller.selectedAuthority.value = val,
  //             decoration: _inputDecoration(null),
  //             dropdownColor: AppColors.cardBg,
  //             borderRadius: AppRadius.borderMd,
  //           )),
  //     ],
  //   );
  // }

  Widget _buildStatusDropdown() {
    final genCon = Get.find<GeneralMastersController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Status', style: AppTextStyles.label),
        const SizedBox(height: 8),
        Obx(() => DropdownButtonFormField<StatusMaster>(
              value: controller.selectedStatus.value,
              items: genCon.fineStatusMasters
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                color: controller.getStatusColor(s.status),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Text(s.status ?? '', style: AppTextStyles.body),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (val) => controller.selectedStatus.value = val,
              decoration: _inputDecoration(null),
              dropdownColor: AppColors.cardBg,
              borderRadius: AppRadius.borderMd,
            )),
      ],
    );
  }

  InputDecoration _inputDecoration(String? hint) {
    return InputDecoration(
      hintText: hint,
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
}

// ==================== EDIT FINE DIALOG ====================

void _showEditFineDialog(
  BuildContext context,
  Fine fine,
  FineController controller,
) {
  controller.prepareEditFine(fine);

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
      child: Container(
        width: 550,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: AppRadius.borderXl,
        ),
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
                    child: const Icon(Icons.edit_outlined,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Edit Fine',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '#${fine.ticketNo} • ${fine.vehicleNo}',
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
                child: _FineDetailsForm(controller: controller),
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
                          onPressed: controller.isSubmitting.value
                              ? null
                              : () async {
                                  final success = await controller.saveFine();
                                  if (success) {
                                    Get.back();
                                  }
                                },
                          icon: controller.isSubmitting.value
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save_outlined, size: 18),
                          label: Text(controller.isSubmitting.value
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
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: false,
  );
}

// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:multifleet/widgets/search_vehicle.dart';

// import '../controllers/fine_controller.dart';

// class VehicleFinePage extends StatelessWidget {
//   const VehicleFinePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(VehicleFineController());
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: LayoutBuilder(builder: (context, constraints) {
//           return SingleChildScrollView(
//             child: ConstrainedBox(
//               constraints: BoxConstraints(minHeight: constraints.maxHeight),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Search section
//                   _buildSearchSection(controller),
//                   SizedBox(height: 20),

//                   // Vehicle assignments section
//                   Obx(() => controller.selectedVehicle.value != null
//                       ? _buildAssignmentsSection(controller, constraints)
//                       : SizedBox()),

//                   // Fine form section
//                   Obx(() => controller.selectedAssignment.value != null
//                       ? _buildFineForm(controller, constraints)
//                       : SizedBox()),
//                 ],
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }

//   Widget _buildSearchSection(VehicleFineController controller) {
//     return SearchVehicleWidget(
//       controller: controller.plateNumberController,
//       heading: "Search and add fine",
//       onSearch: () => controller.searchVehicle(),
//       onClear: () => controller.clearSearch(),
//       onDataChanged: (letter, emirate, number) {
//         log('Letter: $letter, Emirate: $emirate, Number: $number');
//       },
//     );
//   }

//   Widget _buildAssignmentsSection(
//       VehicleFineController controller, BoxConstraints constraints) {
//     return Card(
//       elevation: 4,
//       margin: EdgeInsets.symmetric(vertical: 16),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Vehicle Assignment History',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   '${controller.selectedVehicle.value!.brand} ${controller.selectedVehicle.value!.model} (${controller.selectedVehicle.value!.vehicleNo})',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 16),
//             Obx(
//               () => controller.vehicleAssignments.isEmpty
//                   ? Center(
//                       child: Padding(
//                         padding: const EdgeInsets.all(20.0),
//                         child: Text(
//                             'No assignment history found for this vehicle'),
//                       ),
//                     )
//                   : Column(
//                       children: [
//                         // Header row
//                         constraints.maxWidth > 600
//                             ? _buildAssignmentHeaderRow()
//                             : SizedBox(),

//                         // Assignments list
//                         ListView.builder(
//                           shrinkWrap: true,
//                           physics: NeverScrollableScrollPhysics(),
//                           itemCount: controller.vehicleAssignments.length,
//                           itemBuilder: (context, index) {
//                             final assignment =
//                                 controller.vehicleAssignments[index];
//                             return Obx(() => Column(
//                                   children: [
//                                     InkWell(
//                                       onTap: () => controller
//                                           .selectAssignment(assignment),
//                                       child: Container(
//                                         padding: EdgeInsets.symmetric(
//                                             vertical: 10, horizontal: 16),
//                                         decoration: BoxDecoration(
//                                           color: controller.selectedAssignment
//                                                       .value ==
//                                                   assignment
//                                               ? Colors.blue.withOpacity(0.1)
//                                               : null,
//                                           border: Border(
//                                             bottom: BorderSide(
//                                               color: Colors.grey.shade300,
//                                               width: 1,
//                                             ),
//                                           ),
//                                         ),
//                                         child: Column(
//                                           children: [
//                                             // Assignment details
//                                             constraints.maxWidth > 600
//                                                 ? _buildAssignmentRow(
//                                                     assignment, controller)
//                                                 : _buildAssignmentTile(
//                                                     assignment, controller),

//                                             // Fines section
//                                             if (assignment['fines'] != null &&
//                                                 (assignment['fines'] as List)
//                                                     .isNotEmpty)
//                                               Obx(() => InkWell(
//                                                     onTap: () => controller
//                                                         .toggleFineDetails(
//                                                             assignment['id']),
//                                                     child: Padding(
//                                                       padding:
//                                                           const EdgeInsets.only(
//                                                               top: 8.0),
//                                                       child: Row(
//                                                         children: [
//                                                           Icon(
//                                                             controller
//                                                                     .expandedFineIds
//                                                                     .contains(
//                                                                         assignment[
//                                                                             'id'])
//                                                                 ? Icons
//                                                                     .keyboard_arrow_up
//                                                                 : Icons
//                                                                     .keyboard_arrow_down,
//                                                             size: 16,
//                                                           ),
//                                                           SizedBox(width: 4),
//                                                           Text(
//                                                             '${(assignment['fines'] as List).length} ${(assignment['fines'] as List).length == 1 ? 'Fine' : 'Fines'}',
//                                                             style: TextStyle(
//                                                               color:
//                                                                   Colors.blue,
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .w500,
//                                                               fontSize: 12,
//                                                             ),
//                                                           ),
//                                                         ],
//                                                       ),
//                                                     ),
//                                                   )),
//                                           ],
//                                         ),
//                                       ),
//                                     ),

//                                     // Fine details
//                                     if (assignment['fines'] != null &&
//                                         (assignment['fines'] as List)
//                                             .isNotEmpty &&
//                                         controller.expandedFineIds
//                                             .contains(assignment['id']))
//                                       _buildFineDetailsList(
//                                           assignment['fines'] as List,
//                                           constraints),
//                                   ],
//                                 ));
//                           },
//                         ),

//                         // Load more button
//                         Obx(() => controller.vehicleAssignments.length <
//                                 controller.totalAssignments.value
//                             ? Padding(
//                                 padding: const EdgeInsets.all(16.0),
//                                 child: ElevatedButton(
//                                   onPressed: controller.isLoadingMore.value
//                                       ? null
//                                       : () => controller.loadMoreAssignments(),
//                                   child: controller.isLoadingMore.value
//                                       ? SizedBox(
//                                           width: 20,
//                                           height: 20,
//                                           child: CircularProgressIndicator(
//                                             strokeWidth: 2,
//                                           ),
//                                         )
//                                       : Text('Load More'),
//                                 ),
//                               )
//                             : SizedBox()),
//                       ],
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

// // New widget to show fine details
//   Widget _buildFineDetailsList(List fines, BoxConstraints constraints) {
//     return Container(
//       padding: EdgeInsets.all(12),
//       color: Colors.grey.shade50,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Title
//           Padding(
//             padding: const EdgeInsets.only(bottom: 8.0),
//             child: Text(
//               'Fine History',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 14,
//               ),
//             ),
//           ),

//           // Fines list
//           ListView.builder(
//             shrinkWrap: true,
//             physics: NeverScrollableScrollPhysics(),
//             itemCount: fines.length,
//             itemBuilder: (context, index) {
//               final fine = fines[index] as Map<String, dynamic>;
//               return Container(
//                 margin: EdgeInsets.only(bottom: 8),
//                 padding: EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(4),
//                   border: Border.all(color: Colors.grey.shade200),
//                 ),
//                 child: constraints.maxWidth > 600
//                     ? _buildFineRow(fine)
//                     : _buildFineTile(fine),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFineRow(Map<String, dynamic> fine) {
//     return Row(
//       children: [
//         Expanded(
//           flex: 2,
//           child: Text(
//             DateFormat('dd MMM yyyy, hh:mm a').format(fine['fineDate']),
//             style: TextStyle(fontSize: 13),
//           ),
//         ),
//         Expanded(
//           flex: 2,
//           child: Text(
//             '${fine['fineAmount']} AED',
//             style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
//           ),
//         ),
//         Expanded(
//           flex: 2,
//           child: Text(
//             fine['fineNumber'],
//             style: TextStyle(fontSize: 13),
//           ),
//         ),
//         Expanded(
//           flex: 1,
//           child: Container(
//             padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//             decoration: BoxDecoration(
//               color: fine['paid']
//                   ? Colors.green.withOpacity(0.2)
//                   : Colors.red.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(
//               fine['paid'] ? 'Paid' : 'Unpaid',
//               style: TextStyle(
//                 fontSize: 12,
//                 color: fine['paid'] ? Colors.green : Colors.red,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildFineTile(Map<String, dynamic> fine) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               DateFormat('dd MMM yyyy').format(fine['fineDate']),
//               style: TextStyle(fontSize: 12),
//             ),
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//               decoration: BoxDecoration(
//                 color: fine['paid']
//                     ? Colors.green.withOpacity(0.2)
//                     : Colors.red.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Text(
//                 fine['paid'] ? 'Paid' : 'Unpaid',
//                 style: TextStyle(
//                   fontSize: 11,
//                   color: fine['paid'] ? Colors.green : Colors.red,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 4),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               'Amount: ${fine['fineAmount']} AED',
//               style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
//             ),
//             Text(
//               'No: ${fine['fineNumber']}',
//               style: TextStyle(fontSize: 12),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   // Widget _buildAssignmentsSection(
//   //     VehicleFineController controller, BoxConstraints constraints) {
//   //   return Card(
//   //     elevation: 4,
//   //     margin: EdgeInsets.symmetric(vertical: 16),
//   //     child: Padding(
//   //       padding: const EdgeInsets.all(16.0),
//   //       child: Column(
//   //         crossAxisAlignment: CrossAxisAlignment.start,
//   //         children: [
//   //           Row(
//   //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //             children: [
//   //               Text(
//   //                 'Vehicle Assignment History',
//   //                 style: TextStyle(
//   //                   fontSize: 18,
//   //                   fontWeight: FontWeight.bold,
//   //                 ),
//   //               ),
//   //               Text(
//   //                 '${controller.selectedVehicle.value!['brand']} ${controller.selectedVehicle.value!['model']} (${controller.selectedVehicle.value!['plateNumber']})',
//   //                 style: TextStyle(
//   //                   fontWeight: FontWeight.bold,
//   //                 ),
//   //               ),
//   //             ],
//   //           ),
//   //           SizedBox(height: 16),
//   //           Obx(
//   //             () => controller.vehicleAssignments.isEmpty
//   //                 ? Center(
//   //                     child: Padding(
//   //                       padding: const EdgeInsets.all(20.0),
//   //                       child: Text(
//   //                           'No assignment history found for this vehicle'),
//   //                     ),
//   //                   )
//   //                 : Column(
//   //                     children: [
//   //                       // Header row
//   //                       constraints.maxWidth > 600
//   //                           ? _buildAssignmentHeaderRow()
//   //                           : SizedBox(),

//   //                       // Assignments list
//   //                       ListView.builder(
//   //                         shrinkWrap: true,
//   //                         physics: NeverScrollableScrollPhysics(),
//   //                         itemCount: controller.vehicleAssignments.length,
//   //                         itemBuilder: (context, index) {
//   //                           final assignment =
//   //                               controller.vehicleAssignments[index];
//   //                           return InkWell(
//   //                             onTap: () =>
//   //                                 controller.selectAssignment(assignment),
//   //                             child: Container(
//   //                               padding: EdgeInsets.symmetric(
//   //                                   vertical: 10, horizontal: 16),
//   //                               decoration: BoxDecoration(
//   //                                 color: controller.selectedAssignment.value ==
//   //                                         assignment
//   //                                     ? Colors.blue.withOpacity(0.1)
//   //                                     : null,
//   //                                 border: Border(
//   //                                   bottom: BorderSide(
//   //                                     color: Colors.grey.shade300,
//   //                                     width: 1,
//   //                                   ),
//   //                                 ),
//   //                               ),
//   //                               child: constraints.maxWidth > 600
//   //                                   ? _buildAssignmentRow(
//   //                                       assignment, controller)
//   //                                   : _buildAssignmentTile(
//   //                                       assignment, controller),
//   //                             ),
//   //                           );
//   //                         },
//   //                       ),

//   //                       // Load more button
//   //                       Obx(() => controller.vehicleAssignments.length <
//   //                               controller.totalAssignments.value
//   //                           ? Padding(
//   //                               padding: const EdgeInsets.all(16.0),
//   //                               child: ElevatedButton(
//   //                                 onPressed: controller.isLoadingMore.value
//   //                                     ? null
//   //                                     : () => controller.loadMoreAssignments(),
//   //                                 child: controller.isLoadingMore.value
//   //                                     ? SizedBox(
//   //                                         width: 20,
//   //                                         height: 20,
//   //                                         child: CircularProgressIndicator(
//   //                                           strokeWidth: 2,
//   //                                         ),
//   //                                       )
//   //                                     : Text('Load More'),
//   //                               ),
//   //                             )
//   //                           : SizedBox()),
//   //                     ],
//   //                   ),
//   //           ),
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   // }

//   Widget _buildAssignmentHeaderRow() {
//     return Container(
//       padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade100,
//         border: Border(
//           bottom: BorderSide(
//             color: Colors.grey.shade300,
//             width: 1,
//           ),
//         ),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 2,
//             child: Text(
//               'Employee',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//           Expanded(
//             flex: 2,
//             child: Text(
//               'Designation',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//           Expanded(
//             flex: 2,
//             child: Text(
//               'Start Date',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//           Expanded(
//             flex: 2,
//             child: Text(
//               'End Date',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               'Status',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAssignmentRow(
//       Map<String, dynamic> assignment, VehicleFineController controller) {
//     return Row(
//       children: [
//         Expanded(
//           flex: 2,
//           child: Text(assignment['employeeName']),
//         ),
//         Expanded(
//           flex: 2,
//           child: Text(assignment['designation']),
//         ),
//         Expanded(
//           flex: 2,
//           child: Text(controller.formatDate(assignment['startDate'])),
//         ),
//         Expanded(
//           flex: 2,
//           child: Text(assignment['endDate'] != null
//               ? controller.formatDate(assignment['endDate'])
//               : 'Current'),
//         ),
//         Expanded(
//           child: Container(
//             padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: BoxDecoration(
//               color: _getStatusColor(assignment['status']).withOpacity(0.2),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(
//               assignment['status'],
//               style: TextStyle(
//                 color: _getStatusColor(assignment['status']),
//                 fontSize: 12,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildAssignmentTile(
//       Map<String, dynamic> assignment, VehicleFineController controller) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           assignment['employeeName'],
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         SizedBox(height: 4),
//         Row(
//           children: [
//             Expanded(
//               child: Text(assignment['designation']),
//             ),
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               decoration: BoxDecoration(
//                 color: _getStatusColor(assignment['status']).withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Text(
//                 assignment['status'],
//                 style: TextStyle(
//                   color: _getStatusColor(assignment['status']),
//                   fontSize: 12,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 4),
//         Row(
//           children: [
//             Icon(Icons.calendar_today, size: 14, color: Colors.grey),
//             SizedBox(width: 4),
//             Text(
//               'From: ${controller.formatDate(assignment['startDate'])}',
//               style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
//             ),
//           ],
//         ),
//         SizedBox(height: 2),
//         assignment['endDate'] != null
//             ? Row(
//                 children: [
//                   Icon(Icons.calendar_today, size: 14, color: Colors.grey),
//                   SizedBox(width: 4),
//                   Text(
//                     'To: ${controller.formatDate(assignment['endDate'])}',
//                     style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
//                   ),
//                 ],
//               )
//             : Row(
//                 children: [
//                   Icon(Icons.calendar_today, size: 14, color: Colors.grey),
//                   SizedBox(width: 4),
//                   Text(
//                     'To: Current',
//                     style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
//                   ),
//                 ],
//               ),
//       ],
//     );
//   }

//   Widget _buildFineForm(
//       VehicleFineController controller, BoxConstraints constraints) {
//     // Determine if we should use a single column or multi-column layout
//     final bool useWideLayout = constraints.maxWidth >= 768;

//     return Card(
//       elevation: 4,
//       margin: EdgeInsets.symmetric(vertical: 16),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Add Fine',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Adding fine for ${controller.selectedAssignment.value!['employeeName']} (${controller.selectedVehicle.value!.vehicleNo})',
//               style: TextStyle(
//                 color: Colors.grey.shade700,
//               ),
//             ),
//             SizedBox(height: 20),

//             // Form fields
//             useWideLayout
//                 ? _buildWideFormLayout(controller)
//                 : _buildNarrowFormLayout(controller),

//             SizedBox(height: 20),

//             // Action buttons
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 OutlinedButton(
//                   onPressed: () => controller.clearFineForm(),
//                   child: Text('Clear'),
//                 ),
//                 SizedBox(width: 10),
//                 Obx(() => ElevatedButton(
//                       onPressed: controller.isSubmitting.value
//                           ? null
//                           : () => controller.submitFine(),
//                       child: controller.isSubmitting.value
//                           ? SizedBox(
//                               width: 20,
//                               height: 20,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2,
//                               ),
//                             )
//                           : Text('Submit'),
//                     )),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildWideFormLayout(VehicleFineController controller) {
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
//                   // Fine amount
//                   Text('Fine Amount *'),
//                   SizedBox(height: 8),
//                   TextField(
//                     controller: controller.fineAmountController,
//                     decoration: InputDecoration(
//                       border: OutlineInputBorder(),
//                       hintText: 'Enter fine amount',
//                       prefixIcon: Icon(Icons.attach_money),
//                     ),
//                     keyboardType:
//                         TextInputType.numberWithOptions(decimal: true),
//                   ),
//                   SizedBox(height: 16),

//                   // Fine date picker
//                   Text('Fine Date & Time *'),
//                   SizedBox(height: 8),
//                   _buildDateTimePicker(
//                     context: Get.context!,
//                     initialDate: controller.fineDate.value,
//                     onDateSelected: (date) => controller.fineDate.value = date,
//                   ),
//                   SizedBox(height: 16),

//                   // Fine number
//                   Text('Fine Number *'),
//                   SizedBox(height: 8),
//                   TextField(
//                     controller: controller.fineNumberController,
//                     decoration: InputDecoration(
//                       border: OutlineInputBorder(),
//                       hintText: 'Enter fine number',
//                     ),
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
//                   // Fine location
//                   Text('Fine Location'),
//                   SizedBox(height: 8),
//                   TextField(
//                     controller: controller.fineLocationController,
//                     decoration: InputDecoration(
//                       border: OutlineInputBorder(),
//                       hintText: 'Enter location where fine occurred',
//                       prefixIcon: Icon(Icons.location_on),
//                     ),
//                   ),
//                   SizedBox(height: 16),

//                   // Traffic file number
//                   Text('Traffic File Number'),
//                   SizedBox(height: 8),
//                   TextField(
//                     controller: controller.trafficFileNumberController,
//                     decoration: InputDecoration(
//                       border: OutlineInputBorder(),
//                       hintText: 'Enter traffic file number',
//                     ),
//                   ),
//                   SizedBox(height: 16),
//                   // Traffic file number
//                   Text('Remarks'),
//                   SizedBox(height: 8),
//                   TextField(
//                     controller: controller.remarksController,
//                     decoration: InputDecoration(
//                       border: OutlineInputBorder(),
//                       hintText: 'Enter any remarks',
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildNarrowFormLayout(VehicleFineController controller) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Fine amount
//         Text('Fine Amount *'),
//         SizedBox(height: 8),
//         TextField(
//           controller: controller.fineAmountController,
//           decoration: InputDecoration(
//             border: OutlineInputBorder(),
//             hintText: 'Enter fine amount',
//             prefixIcon: Icon(Icons.attach_money),
//           ),
//           keyboardType: TextInputType.numberWithOptions(decimal: true),
//         ),
//         SizedBox(height: 16),

//         // Fine date picker
//         Text('Fine Date & Time *'),
//         SizedBox(height: 8),
//         _buildDateTimePicker(
//           context: Get.context!,
//           initialDate: controller.fineDate.value,
//           onDateSelected: (date) => controller.fineDate.value = date,
//         ),
//         SizedBox(height: 16),

//         // Fine location
//         Text('Fine Location'),
//         SizedBox(height: 8),
//         TextField(
//           controller: controller.fineLocationController,
//           decoration: InputDecoration(
//             border: OutlineInputBorder(),
//             hintText: 'Enter location where fine occurred',
//             prefixIcon: Icon(Icons.location_on),
//           ),
//         ),
//         SizedBox(height: 16),

//         // Fine number
//         Text('Fine Number *'),
//         SizedBox(height: 8),
//         TextField(
//           controller: controller.fineNumberController,
//           decoration: InputDecoration(
//             border: OutlineInputBorder(),
//             hintText: 'Enter fine number',
//           ),
//         ),
//         SizedBox(height: 16),

//         // Traffic file number
//         Text('Traffic File Number'),
//         SizedBox(height: 8),
//         TextField(
//           controller: controller.trafficFileNumberController,
//           decoration: InputDecoration(
//             border: OutlineInputBorder(),
//             hintText: 'Enter traffic file number',
//           ),
//         ),
//         SizedBox(height: 16),

//         // Traffic file number
//         Text('Remarks'),
//         SizedBox(height: 8),
//         TextField(
//           controller: controller.remarksController,
//           decoration: InputDecoration(
//             border: OutlineInputBorder(),
//             hintText: 'Enter any remarks',
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDateTimePicker({
//     required BuildContext context,
//     required DateTime? initialDate,
//     required Function(DateTime) onDateSelected,
//   }) {
//     return InkWell(
//       onTap: () async {
//         final DateTime? pickedDate = await showDatePicker(
//           context: context,
//           initialDate: initialDate ?? DateTime.now(),
//           firstDate: DateTime.now().subtract(Duration(days: 365)),
//           lastDate: DateTime.now().add(Duration(days: 365)),
//         );

//         if (pickedDate != null) {
//           final TimeOfDay? pickedTime = await showTimePicker(
//             context: context,
//             initialTime: TimeOfDay.now(),
//           );

//           if (pickedTime != null) {
//             final newDateTime = DateTime(
//               pickedDate.year,
//               pickedDate.month,
//               pickedDate.day,
//               pickedTime.hour,
//               pickedTime.minute,
//             );
//             onDateSelected(newDateTime);
//           }
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
//                   ? DateFormat('dd MMM yyyy, hh:mm a').format(initialDate)
//                   : 'Select date and time',
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

//   Color _getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'active':
//         return Colors.green;
//       case 'terminated':
//         return Colors.red;
//       case 'on leave':
//         return Colors.orange;
//       case 'pending':
//         return Colors.blue;
//       default:
//         return Colors.grey;
//     }
//   }
// }
