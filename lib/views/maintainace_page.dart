import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:multifleet/controllers/general_masters.dart';
import 'package:multifleet/models/maintenance_master.dart';
import 'package:multifleet/models/vendor.dart';
import 'package:multifleet/theme/app_theme.dart';
import 'package:multifleet/widgets/search_vehicle.dart';

import '../controllers/maintenance_controller.dart';
import '../models/maintenance.dart';

class MaintenancePage extends StatelessWidget {
  const MaintenancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MaintenanceController>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accent,
          onRefresh: () => controller.refresh(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 800;
              final isTablet =
                  constraints.maxWidth >= 600 && constraints.maxWidth < 800;
              log('isDesktop: $isDesktop, isTablet: $isTablet',
                  name: 'MaintenancePage');

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildHeader(controller, isDesktop),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.all(
                        isDesktop ? AppSpacing.xl : AppSpacing.lg),
                    sliver: SliverToBoxAdapter(
                      child: Obx(() {
                        if (controller.currentView.value == 'vehicle' &&
                            controller.vehicleFound.value) {
                          return _buildVehicleView(
                              controller, isDesktop, isTablet);
                        }
                        return _buildDashboardView(
                            controller, isDesktop, isTablet);
                      }),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(MaintenanceController controller, bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? AppSpacing.xl : AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.sidebarBg,
        boxShadow: AppShadows.sm,
      ),
      child: Obx(() {
        if (controller.currentView.value == 'vehicle') {
          // Vehicle view header — back button + vehicle plate
          return Row(
            children: [
              AppButton(
                text: 'Back',
                icon: Icons.arrow_back,
                isOutlined: true,
                onPressed: () => controller.clearSearch(),
              ),
              const SizedBox(width: AppSpacing.md),
              Icon(Icons.directions_car,
                  color: AppColors.accent, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                controller.selectedVehicle.value?.vehicleNo ?? '',
                style: AppTextStyles.h4,
              ),
              const Spacer(),
              AppButton(
                text: 'Add Record',
                icon: Icons.add,
                onPressed: () {
                  controller.prepareAddRecord();
                  AddMaintenanceRecordDialog.show(controller);
                },
              ),
            ],
          );
        }

        // Dashboard header — search + compact bulk upload icon
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: SearchVehicleWidget(
                    controller: controller.plateNumberController,
                    heading: 'Search Vehicle for Service Records',
                    onTapTextField: () =>
                        controller.showBulkUpload.value = false,
                    onSearch: () => controller.searchVehicle(),
                    onClear: () => controller.clearSearch(),
                    onDataChanged: (plate) {
                      controller.plateNumberController.text =
                          "${plate.code}-${plate.number}";
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Compact bulk upload button
                Tooltip(
                  message: 'Bulk Upload Records',
                  child: InkWell(
                    onTap: () => controller.toggleBulkUpload(),
                    borderRadius: AppRadius.borderMd,
                    child: Obx(() => Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: controller.showBulkUpload.value
                                ? AppColors.accent.withOpacity(0.15)
                                : AppColors.cardBg,
                            borderRadius: AppRadius.borderMd,
                            border: Border.all(
                              color: controller.showBulkUpload.value
                                  ? AppColors.accent
                                  : AppColors.divider,
                            ),
                          ),
                          child: Icon(
                            Icons.upload_file,
                            color: controller.showBulkUpload.value
                                ? AppColors.accent
                                : AppColors.textMuted,
                            size: 22,
                          ),
                        )),
                  ),
                ),
              ],
            ),
            // Bulk upload panel — only when toggled
            Obx(() {
              if (!controller.showBulkUpload.value) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: _buildBulkUploadPanel(controller),
              );
            }),
          ],
        );
      }),
    );
  }

  Widget _buildBulkUploadPanel(MaintenanceController controller) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_upload_outlined,
              color: AppColors.textMuted, size: 32),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bulk Upload Maintenance Records',
                    style: AppTextStyles.label),
                const SizedBox(height: 2),
                Text('Upload an Excel or CSV file with multiple records',
                    style: AppTextStyles.caption),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          AppButton(
            text: 'Browse Files',
            icon: Icons.folder_open,
            isOutlined: true,
            onPressed: () {
              // TODO: file picker
            },
          ),
          const SizedBox(width: AppSpacing.sm),
          TextButton(
            onPressed: () {
              // TODO: Download template
            },
            child: Text('Template',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DASHBOARD VIEW
  // ============================================================

  Widget _buildDashboardView(
    MaintenanceController controller,
    bool isDesktop,
    bool isTablet,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatsSection(controller, isDesktop, isTablet),
        const SizedBox(height: AppSpacing.xl),
        _buildRecordsSection(controller, isDesktop),
      ],
    );
  }

  // ============================================================
  // STATS CARDS
  // ============================================================

  Widget _buildStatsSection(
    MaintenanceController controller,
    bool isDesktop,
    bool isTablet,
  ) {
    return Obx(() {
      if (controller.isLoading.value && controller.allRecords.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: CircularProgressIndicator(),
          ),
        );
      }

      final crossAxisCount = isDesktop ? 3 : (isTablet ? 3 : 2);

      return GridView.count(
        crossAxisCount: crossAxisCount,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: AppSpacing.lg,
        mainAxisSpacing: AppSpacing.lg,
        childAspectRatio: isDesktop ? 2.6 : 1.5,
        children: [
          _buildStatCard(
            title: 'Scheduled',
            value: controller.scheduledCount.toString(),
            icon: Icons.schedule,
            color: AppColors.warning,
            subtitle: 'Pending services',
            onTap: () => controller.setQuickFilter('Scheduled'),
          ),
          _buildStatCard(
            title: 'Completed',
            value: controller.closedCount.toString(),
            icon: Icons.check_circle_outline,
            color: AppColors.success,
            subtitle: 'Closed records',
            onTap: () => controller.setQuickFilter('Closed'),
          ),
          _buildStatCard(
            title: 'Total Spend',
            value: _formatCompactCurrency(controller.totalAmountAllTime),
            icon: Icons.account_balance_wallet_outlined,
            color: AppColors.accent,
            subtitle: 'All time',
            onTap: null,
          ),
        ],
      );
    });
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: AppRadius.borderMd,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: AppTextStyles.labelSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(value,
                    style: AppTextStyles.h3.copyWith(color: color)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.caption),
                ],
              ],
            ),
          ),
          if (onTap != null)
            Icon(Icons.chevron_right,
                color: AppColors.textMuted, size: 20),
        ],
      ),
    );
  }

  String _formatCompactCurrency(double amount) {
    if (amount >= 1000000) {
      return 'AED ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return 'AED ${(amount / 1000).toStringAsFixed(1)}K';
    }
    return 'AED ${amount.toStringAsFixed(0)}';
  }

  // ============================================================
  // RECORDS SECTION — filter panel + table
  // ============================================================

  Widget _buildRecordsSection(
    MaintenanceController controller,
    bool isDesktop,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title row
        Row(
          children: [
            Text('Maintenance Records', style: AppTextStyles.h4),
            const Spacer(),
            // Filter toggle button
            Obx(() => TextButton.icon(
                  onPressed: () =>
                      controller.showFilters.toggle(),
                  icon: Icon(
                    controller.showFilters.value
                        ? Icons.filter_list_off
                        : Icons.filter_list,
                    size: 18,
                  ),
                  label: Text(controller.showFilters.value
                      ? 'Hide Filters'
                      : 'Filters'),
                  style: TextButton.styleFrom(
                    foregroundColor: controller.hasActiveFilters
                        ? AppColors.accent
                        : AppColors.textMuted,
                  ),
                )),
            Obx(() {
              if (controller.hasActiveFilters) {
                return TextButton.icon(
                  onPressed: () => controller.clearFilters(),
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear'),
                  style: TextButton.styleFrom(
                      foregroundColor: AppColors.error),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),

        // Status chips
        const SizedBox(height: AppSpacing.md),
        _buildStatusChips(controller),

        // Collapsible filter panel
        Obx(() {
          if (!controller.showFilters.value) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: _buildFilterPanel(controller, isDesktop),
          );
        }),

        const SizedBox(height: AppSpacing.lg),

        // Records table
        _buildAllRecordsTable(controller, isDesktop),
      ],
    );
  }

  Widget _buildStatusChips(MaintenanceController controller) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Obx(() => Row(
            children: controller.filterOptions.map((filter) {
              final isSelected = controller.selectedFilter.value == filter;
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: AppChip(
                  label: filter,
                  isSelected: isSelected,
                  icon: _getFilterIcon(filter),
                  onTap: () => controller.setQuickFilter(filter),
                ),
              );
            }).toList(),
          )),
    );
  }

  IconData _getFilterIcon(String filter) {
    switch (filter) {
      case 'All':
        return Icons.list;
      case 'Scheduled':
        return Icons.schedule;
      case 'Closed':
        return Icons.check_circle;
      default:
        return Icons.filter_list;
    }
  }

  // ============================================================
  // FILTER PANEL
  // ============================================================

  Widget _buildFilterPanel(
      MaintenanceController controller, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filter Records', style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.md),
          isDesktop
              ? Row(
                  children: [
                    Expanded(child: _buildSearchField(controller)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                        child: _buildServiceTypeFilter(controller)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: _buildVendorFilter(controller)),
                  ],
                )
              : Column(
                  children: [
                    _buildSearchField(controller),
                    const SizedBox(height: AppSpacing.md),
                    _buildServiceTypeFilter(controller),
                    const SizedBox(height: AppSpacing.md),
                    _buildVendorFilter(controller),
                  ],
                ),
          const SizedBox(height: AppSpacing.md),
          isDesktop
              ? Row(
                  children: [
                    Expanded(
                        child: _buildDateField(
                            controller, isStart: true)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                        child: _buildDateField(
                            controller, isStart: false)),
                    const Spacer(),
                    const Spacer(),
                  ],
                )
              : Column(
                  children: [
                    _buildDateField(controller, isStart: true),
                    const SizedBox(height: AppSpacing.md),
                    _buildDateField(controller, isStart: false),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildSearchField(MaintenanceController controller) {
    return AppTextField(
      controller: controller.searchController,
      labelText: 'Search',
      hintText: 'Vehicle, invoice, vendor...',
      prefixIcon: Icons.search,
    );
  }

  Widget _buildServiceTypeFilter(MaintenanceController controller) {
    final genCon = Get.find<GeneralMastersController>();
    return Obx(() {
      final selected = genCon.mainteneceMasters.firstWhereOrNull(
          (m) => m.maintenanceID == controller.selectedServiceType.value);
      return AppDropdown<MaintenanceMaster>(
        value: selected,
        items: genCon.mainteneceMasters,
        labelText: 'Service Type',
        hintText: 'All types',
        prefixIcon: Icons.build,
        displayBuilder: (item) => item.maintenanceType ?? '',
        onChanged: (v) {
          controller.selectedServiceType.value = v?.maintenanceID;
          controller.applyFilters();
        },
      );
    });
  }

  Widget _buildVendorFilter(MaintenanceController controller) {
    return Obx(() {
      final selected = controller.vendors.firstWhereOrNull(
          (v) => v.vendorID == controller.selectedVendorFilter.value);
      return AppDropdown<Vendor>(
        value: selected,
        items: controller.vendors,
        labelText: 'Vendor / Garage',
        hintText: 'All vendors',
        prefixIcon: Icons.store,
        displayBuilder: (item) => item.vendorName ?? '',
        onChanged: (v) {
          controller.selectedVendorFilter.value = v?.vendorID;
          controller.applyFilters();
        },
      );
    });
  }

  Widget _buildDateField(MaintenanceController controller,
      {required bool isStart}) {
    return Obx(() {
      final date =
          isStart ? controller.startDateFilter.value : controller.endDateFilter.value;
      return AppTextField(
        controller: TextEditingController(
          text: date != null ? DateFormat('dd MMM yyyy').format(date) : '',
        ),
        labelText: isStart ? 'From Date' : 'To Date',
        hintText: 'Select date',
        prefixIcon: Icons.calendar_today,
        readOnly: true,
        suffixIcon: date != null
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  if (isStart) {
                    controller.startDateFilter.value = null;
                  } else {
                    controller.endDateFilter.value = null;
                  }
                  controller.applyFilters();
                },
              )
            : null,
        onTap: () async {
          final picked = await showDatePicker(
            context: Get.context!,
            initialDate: date ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            builder: (ctx, child) => Theme(
              data: Theme.of(ctx).copyWith(
                colorScheme:
                    ColorScheme.light(primary: AppColors.accent),
              ),
              child: child!,
            ),
          );
          if (picked != null) {
            if (isStart) {
              controller.startDateFilter.value = picked;
            } else {
              controller.endDateFilter.value = picked;
            }
            controller.applyFilters();
          }
        },
      );
    });
  }

  // ============================================================
  // ALL RECORDS TABLE (Dashboard)
  // ============================================================

  Widget _buildAllRecordsTable(
    MaintenanceController controller,
    bool isDesktop,
  ) {
    return Obx(() {
      if (controller.isLoading.value && controller.allRecords.isEmpty) {
        return const AppLoading(message: 'Loading records...');
      }

      final records = controller.filteredAllRecords;

      if (records.isEmpty) {
        return AppEmptyState(
          icon: Icons.build_circle_outlined,
          title: 'No maintenance records',
          subtitle: controller.hasActiveFilters
              ? 'No records match your filters'
              : 'Search for a vehicle above to add maintenance records',
          action: controller.hasActiveFilters
              ? AppButton(
                  text: 'Clear Filters',
                  onPressed: () => controller.clearFilters(),
                )
              : null,
        );
      }

      // Filtered spend summary
      final filteredSpend = controller.filteredTotalAmount;
      final showSummary = controller.hasActiveFilters;

      return Column(
        children: [
          if (showSummary)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.08),
                  borderRadius: AppRadius.borderMd,
                  border:
                      Border.all(color: AppColors.accent.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: AppColors.accent, size: 16),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '${records.length} record${records.length == 1 ? '' : 's'} — Total: ${_formatCompactCurrency(filteredSpend)}',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.accent),
                    ),
                  ],
                ),
              ),
            ),
          AppCard(
            padding: EdgeInsets.zero,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 20,
                headingRowColor:
                    WidgetStateProperty.all(AppColors.surface),
                headingTextStyle: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                columns: const [
                  DataColumn(label: Text('Vehicle')),
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Service Type')),
                  DataColumn(label: Text('Vendor/Garage')),
                  DataColumn(label: Text('Invoice')),
                  DataColumn(label: Text('Amount'), numeric: true),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('')),
                ],
                rows: records.map((record) {
                  final statusColor =
                      controller.getStatusColor(record.status);
                  return DataRow(cells: [
                    DataCell(Text(record.vehicleNo ?? '-',
                        style: AppTextStyles.label)),
                    DataCell(
                        Text(controller.formatDate(record.serviceDate))),
                    DataCell(Text(record.maintenanceType ?? '-')),
                    DataCell(Text(record.vendorName ?? '-')),
                    DataCell(Text(record.invoiceNo ?? '-')),
                    DataCell(
                        Text(controller.formatAmount(record.amount))),
                    DataCell(_buildStatusBadge(
                        record.status ?? '-', statusColor)),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        tooltip: 'Edit',
                        onPressed: () =>
                            _editFromDashboard(controller, record),
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildStatusBadge(String label, Color color) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600),
      ),
    );
  }

  void _editFromDashboard(
      MaintenanceController controller, MaintenanceRecord record) async {
    if (record.vehicleNo == null) return;
    if (controller.selectedVehicle.value?.vehicleNo == record.vehicleNo) {
      controller.prepareEditRecord(record);
      AddMaintenanceRecordDialog.show(controller);
      return;
    }
    controller.plateNumberController.text = record.vehicleNo!;
    await controller.searchVehicle();
    if (controller.vehicleFound.value) {
      controller.prepareEditRecord(record);
      AddMaintenanceRecordDialog.show(controller);
    }
  }

  // ============================================================
  // VEHICLE VIEW
  // ============================================================

  Widget _buildVehicleView(
    MaintenanceController controller,
    bool isDesktop,
    bool isTablet,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildVehicleInfoCard(controller),
        const SizedBox(height: AppSpacing.xl),
        Text('Service History', style: AppTextStyles.h4),
        const SizedBox(height: AppSpacing.lg),
        _buildServiceTimeline(controller),
      ],
    );
  }

  Widget _buildVehicleInfoCard(MaintenanceController controller) {
    final vehicle = controller.selectedVehicle.value;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: AppRadius.borderMd,
                ),
                child: Icon(Icons.directions_car,
                    color: AppColors.accent, size: 28),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vehicle?.vehicleNo ?? '-',
                        style: AppTextStyles.h3),
                    Text(
                      '${vehicle?.brand ?? ''} ${vehicle?.model ?? ''}'
                          .trim(),
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              // Mini stats from loaded records
              Obx(() {
                final records = controller.maintenanceRecords;
                final total = records.fold<double>(
                    0, (s, r) => s + (r.amount ?? 0));
                return Row(
                  children: [
                    _buildMiniStat(
                        records.length.toString(), 'Records'),
                    const SizedBox(width: AppSpacing.xl),
                    _buildMiniStat(
                        _formatCompactCurrency(total), 'Total Spend'),
                  ],
                );
              }),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.md),
          Obx(() {
            final records = controller.maintenanceRecords;
            if (records.isEmpty) return const SizedBox.shrink();
            final last = records.first; // sorted desc
            return Wrap(
              spacing: AppSpacing.xl,
              runSpacing: AppSpacing.sm,
              children: [
                _buildInfoChip('Current KM',
                    vehicle?.currentOdo?.toString() ?? '-', Icons.speed),
                _buildInfoChip('Type', vehicle?.type ?? '-',
                    Icons.category),
                _buildInfoChip(
                    'Last Service',
                    controller.formatDate(last.serviceDate),
                    Icons.history),
                _buildInfoChip('Last Type',
                    last.maintenanceType ?? '-', Icons.build),
                _buildInfoChip('Last Vendor',
                    last.vendorName ?? '-', Icons.store),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(value,
            style: AppTextStyles.h4.copyWith(color: AppColors.accent)),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildInfoChip(String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text('$label: ', style: AppTextStyles.caption),
        Text(value, style: AppTextStyles.label),
      ],
    );
  }

  // ============================================================
  // SERVICE TIMELINE (Vehicle view)
  // ============================================================

  Widget _buildServiceTimeline(MaintenanceController controller) {
    return Obx(() {
      if (controller.isLoadingRecords.value) {
        return const AppLoading(message: 'Loading service history...');
      }

      final records = controller.filteredRecords;

      if (records.isEmpty) {
        return AppEmptyState(
          icon: Icons.history,
          title: 'No service records',
          subtitle: 'Add the first maintenance record using the button above',
        );
      }

      return Column(
        children: List.generate(records.length, (index) {
          final record = records[index];
          final isLast = index == records.length - 1;
          return _buildTimelineItem(controller, record, isLast);
        }),
      );
    });
  }

  Widget _buildTimelineItem(
    MaintenanceController controller,
    MaintenanceRecord record,
    bool isLast,
  ) {
    final statusColor = controller.getStatusColor(record.status);
    final date = record.serviceDate;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: date column
          SizedBox(
            width: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 6),
                Text(
                  date != null ? DateFormat('dd MMM').format(date) : '-',
                  style: AppTextStyles.label,
                ),
                Text(
                  date != null ? DateFormat('yyyy').format(date) : '',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // Center: timeline line + dot
          Column(
            children: [
              const SizedBox(height: 6),
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: AppColors.cardBg, width: 2),
                  boxShadow: [
                    BoxShadow(
                        color: statusColor.withOpacity(0.3),
                        blurRadius: 4,
                        spreadRadius: 1)
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.divider,
                  ),
                ),
            ],
          ),

          const SizedBox(width: AppSpacing.md),

          // Right: service card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            record.maintenanceType ?? 'Service',
                            style: AppTextStyles.label,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _buildStatusBadge(
                            record.status ?? '-', statusColor),
                        const SizedBox(width: AppSpacing.sm),
                        // Edit button
                        InkWell(
                          onTap: () {
                            controller.prepareEditRecord(record);
                            AddMaintenanceRecordDialog.show(controller);
                          },
                          borderRadius: AppRadius.borderSm,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(Icons.edit_outlined,
                                size: 16,
                                color: AppColors.textMuted),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Details row
                    Wrap(
                      spacing: AppSpacing.lg,
                      runSpacing: AppSpacing.xs,
                      children: [
                        if (record.vendorName != null)
                          _buildDetailChip(
                              Icons.store, record.vendorName!),
                        if (record.invoiceNo != null)
                          _buildDetailChip(
                              Icons.receipt, record.invoiceNo!),
                        if (record.amount != null)
                          _buildDetailChip(
                            Icons.attach_money,
                            controller.formatAmount(record.amount),
                            highlight: true,
                          ),
                      ],
                    ),

                    // Remarks
                    if (record.remarks != null &&
                        record.remarks!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.notes,
                              size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              record.remarks!,
                              style: AppTextStyles.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String value,
      {bool highlight = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            size: 13,
            color:
                highlight ? AppColors.accent : AppColors.textMuted),
        const SizedBox(width: 3),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            color: highlight ? AppColors.accent : null,
            fontWeight:
                highlight ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

/// ============================================================
/// ADD/EDIT MAINTENANCE RECORD DIALOG
/// ============================================================

class AddMaintenanceRecordDialog extends StatelessWidget {
  final MaintenanceController controller;

  const AddMaintenanceRecordDialog({
    super.key,
    required this.controller,
  });

  static Future<bool?> show(MaintenanceController controller) {
    return Get.dialog<bool>(
      AddMaintenanceRecordDialog(controller: controller),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = controller.editingRecord.value != null;
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 800 ? 680.0 : screenWidth * 0.95;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
      child: Container(
        width: dialogWidth,
        constraints: const BoxConstraints(maxHeight: 620),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(isEditing),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: _buildForm(context),
              ),
            ),
            _buildActions(isEditing),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isEditing) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.lg),
          topRight: Radius.circular(AppRadius.lg),
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
            child: Icon(
              isEditing ? Icons.edit : Icons.add_circle,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Edit Service Record' : 'Add Service Record',
                  style: AppTextStyles.h4,
                ),
                Text(
                  'Vehicle: ${controller.selectedVehicle.value?.vehicleNo ?? '-'}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRow(context, [
          Expanded(child: _buildServiceTypeDropdown()),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: _buildVendorDropdown()),
        ]),
        const SizedBox(height: AppSpacing.lg),
        _buildRow(context, [
          Expanded(child: _buildInvoiceField()),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: _buildDatePicker(context)),
        ]),
        const SizedBox(height: AppSpacing.lg),
        _buildRow(context, [
          Expanded(child: _buildAmountField()),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: _buildStatusDropdown()),
        ]),
        const SizedBox(height: AppSpacing.lg),
        _buildRemarksField(),
      ],
    );
  }

  Widget _buildRow(BuildContext context, List<Widget> children) {
    final isNarrow = MediaQuery.of(context).size.width < 500;
    if (isNarrow) {
      return Column(
        children: children.map((c) {
          if (c is SizedBox) return const SizedBox(height: AppSpacing.md);
          return SizedBox(width: double.infinity, child: c);
        }).toList(),
      );
    }
    return Row(children: children);
  }

  Widget _buildServiceTypeDropdown() {
    final genCon = Get.find<GeneralMastersController>();
    return Obx(() => AppDropdown<MaintenanceMaster>(
          value: controller.selectedMaintenanceType.value,
          items: genCon.mainteneceMasters,
          labelText: 'Service Type *',
          hintText: 'Select service type',
          prefixIcon: Icons.build,
          displayBuilder: (item) => item.maintenanceType ?? '',
          onChanged: (v) => controller.selectedMaintenanceType.value = v,
        ));
  }

  Widget _buildVendorDropdown() {
    return Obx(() => AppDropdown<Vendor>(
          value: controller.selectedVendor.value,
          items: controller.vendors,
          labelText: 'Vendor / Garage',
          hintText: 'Select vendor',
          prefixIcon: Icons.store,
          displayBuilder: (item) => item.vendorName ?? '',
          onChanged: (v) => controller.selectedVendor.value = v,
        ));
  }

  Widget _buildInvoiceField() {
    return AppTextField(
      controller: controller.invoiceNumberController,
      labelText: 'Invoice Number *',
      hintText: 'e.g. INV-001',
      prefixIcon: Icons.receipt,
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Obx(() => AppTextField(
          controller: TextEditingController(
            text: DateFormat('dd MMM yyyy')
                .format(controller.selectedDate.value),
          ),
          labelText: 'Service Date *',
          prefixIcon: Icons.calendar_today,
          readOnly: true,
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: controller.selectedDate.value,
              firstDate: DateTime(2000),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              builder: (ctx, child) => Theme(
                data: Theme.of(ctx).copyWith(
                  colorScheme:
                      ColorScheme.light(primary: AppColors.accent),
                ),
                child: child!,
              ),
            );
            if (picked != null) controller.selectedDate.value = picked;
          },
        ));
  }

  Widget _buildAmountField() {
    return AppTextField(
      controller: controller.totalAmountController,
      labelText: 'Amount (AED) *',
      hintText: '0.00',
      prefixIcon: Icons.attach_money,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }

  Widget _buildStatusDropdown() {
    return Obx(() => AppDropdown<String>(
          value: controller.selectedStatus.value,
          items: controller.statusOptions,
          labelText: 'Status *',
          hintText: 'Select status',
          prefixIcon: Icons.flag,
          displayBuilder: (item) => item,
          onChanged: (v) {
            if (v != null) controller.selectedStatus.value = v;
          },
        ));
  }

  Widget _buildRemarksField() {
    return AppTextField(
      controller: controller.remarksController,
      labelText: 'Remarks',
      hintText: 'Service details, parts replaced, notes...',
      prefixIcon: Icons.description,
      maxLines: 3,
    );
  }

  Widget _buildActions(bool isEditing) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AppButton(
            text: 'Cancel',
            isOutlined: true,
            onPressed: () => Get.back(result: false),
          ),
          const SizedBox(width: AppSpacing.md),
          Obx(() => AppButton(
                text: isEditing ? 'Update' : 'Save',
                icon: isEditing ? Icons.save : Icons.check,
                isLoading: controller.isSubmitting.value,
                onPressed: controller.isSubmitting.value
                    ? null
                    : () async {
                        final success =
                            await controller.saveMaintenanceRecord();
                        if (success) Get.back(result: true);
                      },
              )),
        ],
      ),
    );
  }
}

/// ============================================================
/// SHARED WIDGETS
/// ============================================================

class AppStatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSmall;

  const AppStatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 10,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: isSmall ? 10 : 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class MaintenanceInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? valueColor;

  const MaintenanceInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: AppColors.textMuted),
            const SizedBox(width: AppSpacing.sm),
          ],
          SizedBox(
            width: 120,
            child: Text(label, style: AppTextStyles.bodySmall),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
