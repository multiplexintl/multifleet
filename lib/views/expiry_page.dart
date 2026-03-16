import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:multifleet/controllers/expiry_controller.dart';

import '../theme/app_theme.dart';

/// ============================================================
/// VEHICLE EXPIRY PAGE
/// ============================================================
/// Comprehensive document expiry tracking with filtering,
/// bulk actions, calendar view, and renewal management.
/// ============================================================

class VehicleExpiryPage extends StatelessWidget {
  const VehicleExpiryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ExpiryController());

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Obx(() {
          // Show comparison view if active
          if (controller.showComparisonView.value) {
            return _ComparisonView(controller: controller);
          }

          // Show calendar view if active
          if (controller.showCalendarView.value) {
            return _CalendarViewPage(controller: controller);
          }

          // Main list view
          return _MainView(controller: controller);
        }),
      ),
    );
  }
}

/// ============================================================
/// MAIN VIEW
/// ============================================================

class _MainView extends StatelessWidget {
  final ExpiryController controller;

  const _MainView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // Header
          _buildHeader(context),

          // Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.refreshUI,
              color: AppColors.accent,
              child: CustomScrollView(
                slivers: [
                  // Stats Cards
                  SliverToBoxAdapter(
                    child: _buildStatCards(context),
                  ),

                  // Filters
                  SliverToBoxAdapter(
                    child: _buildFilters(context),
                  ),

                  // Bulk Action Bar (when selection mode active)
                  // SliverToBoxAdapter(
                  //   child: Obx(() => controller.isSelectionMode.value
                  //       ? _buildBulkActionBar(context)
                  //       : const SizedBox.shrink()),
                  // ),

                  // Results Count & Sort
                  SliverToBoxAdapter(
                    child: _buildResultsBar(context),
                  ),

                  // List Content
                  Obx(() {
                    if (controller.isLoading.value) {
                      return const SliverFillRemaining(
                        child: AppLoading(message: 'Loading documents...'),
                      );
                    }

                    if (controller.filteredExpiryItems.isEmpty) {
                      return SliverFillRemaining(
                        child: _buildEmptyState(),
                      );
                    }

                    // Grouped or List view
                    if (controller.isGroupedByVehicle.value) {
                      return _buildGroupedList();
                    }

                    return _buildItemList();
                  }),

                  // Bottom padding
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.xxl),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== HEADER ====================

  Widget _buildHeader(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Container(
      padding: AppSpacing.paddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: AppRadius.borderMd,
                ),
                child: const Icon(
                  Icons.document_scanner_outlined,
                  color: AppColors.error,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Document Expiry', style: AppTextStyles.h2),
                    const SizedBox(height: AppSpacing.xs),
                    Obx(() => Text(
                          '${controller.totalDocuments} documents',
                          style: AppTextStyles.bodySmall,
                        )),
                  ],
                ),
              ),

              // Action Buttons
              if (isWide) ...[
                _buildHeaderActions(context),
              ],
            ],
          ),

          // Mobile: Action buttons below title
          if (!isWide) ...[
            const SizedBox(height: AppSpacing.md),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _buildHeaderActions(context),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderActions(BuildContext context) {
    return Obx(() => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Calendar View Toggle
            _HeaderIconButton(
              icon: controller.showCalendarView.value
                  ? Icons.view_list
                  : Icons.calendar_month,
              tooltip: controller.showCalendarView.value
                  ? 'List View'
                  : 'Calendar View',
              onPressed: controller.toggleCalendarView,
            ),
            const SizedBox(width: AppSpacing.sm),

            // Grouped View Toggle
            _HeaderIconButton(
              icon: controller.isGroupedByVehicle.value
                  ? Icons.view_list
                  : Icons.folder_outlined,
              tooltip: controller.isGroupedByVehicle.value
                  ? 'Flat List'
                  : 'Group by Vehicle',
              onPressed: controller.toggleGroupedView,
            ),
            const SizedBox(width: AppSpacing.sm),

            // Export Button
            PopupMenuButton<String>(
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.borderMd,
              ),
              tooltip: 'Export',
              onSelected: (value) {
                if (value == 'excel') {
                  controller.exportToExcel();
                } else if (value == 'csv') {
                  controller.exportToCsv();
                }
              },
              borderRadius: AppRadius.borderMd,
              color: AppColors.cardBg,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'excel',
                  child: Row(
                    children: [
                      Icon(Icons.table_chart,
                          size: 20, color: AppColors.success),
                      SizedBox(width: AppSpacing.sm),
                      Text('Export to Excel'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'csv',
                  child: Row(
                    children: [
                      Icon(Icons.description, size: 20, color: AppColors.info),
                      SizedBox(width: AppSpacing.sm),
                      Text('Export to CSV'),
                    ],
                  ),
                ),
              ],
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: AppRadius.borderMd,
                  border: Border.all(color: AppColors.accent),
                ),
                child: Icon(
                  Icons.download_outlined,
                  size: 20,
                  color: AppColors.accent,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // Refresh Button
            _HeaderIconButton(
              icon: Icons.refresh,
              tooltip: 'Refresh',
              onPressed: () => controller.refreshUI(),
            ),
          ],
        ));
  }

  // ==================== STAT CARDS ====================

  Widget _buildStatCards(BuildContext context) {
    return Padding(
      // padding: const EdgeInsets.all(AppSpacing.lg),
      padding: EdgeInsetsGeometry.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: AppSpacing.lg,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;
          final isMedium = constraints.maxWidth > 500;

          final crossAxisCount = isWide ? 5 : (isMedium ? 3 : 2);
          final childAspectRatio = isWide ? 1.3 : (isMedium ? 1.5 : 1.4);

          return Obx(() => GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: childAspectRatio,
                children: [
                  _StatCard(
                    label: 'Expired',
                    count: controller.expiredCount,
                    icon: Icons.error,
                    color: AppColors.error,
                    isActive: controller.activeQuickFilter.value ==
                        ExpiryStatus.expired,
                    onTap: () =>
                        controller.setQuickFilter(ExpiryStatus.expired),
                  ),
                  _StatCard(
                    label: 'Critical',
                    count: controller.criticalCount,
                    icon: Icons.warning_amber,
                    color: const Color(0xFFDC2626),
                    subtitle: '≤7 days',
                    isActive: controller.activeQuickFilter.value ==
                        ExpiryStatus.critical,
                    onTap: () =>
                        controller.setQuickFilter(ExpiryStatus.critical),
                  ),
                  _StatCard(
                    label: 'Warning',
                    count: controller.warningCount,
                    icon: Icons.access_time,
                    color: AppColors.warning,
                    subtitle: '8-30 days',
                    isActive: controller.activeQuickFilter.value ==
                        ExpiryStatus.warning,
                    onTap: () =>
                        controller.setQuickFilter(ExpiryStatus.warning),
                  ),
                  _StatCard(
                    label: 'Upcoming',
                    count: controller.upcomingCount,
                    icon: Icons.schedule,
                    color: AppColors.info,
                    subtitle: '31-60 days',
                    isActive: controller.activeQuickFilter.value ==
                        ExpiryStatus.upcoming,
                    onTap: () =>
                        controller.setQuickFilter(ExpiryStatus.upcoming),
                  ),
                  _StatCard(
                    label: 'Valid',
                    count: controller.validCount,
                    icon: Icons.check_circle,
                    color: AppColors.success,
                    subtitle: '>60 days',
                    isActive: controller.activeQuickFilter.value ==
                        ExpiryStatus.valid,
                    onTap: () => controller.setQuickFilter(ExpiryStatus.valid),
                  ),
                ],
              ));
        },
      ),
    );
  }

  // ==================== FILTERS ====================

  Widget _buildFilters(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            _buildSearchBar(),
            const SizedBox(height: AppSpacing.lg),

            // Filter Dropdowns
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 800) {
                  // Wide: All in one row
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: _buildDocTypeDropdown()),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: _buildStatusDropdown()),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: _buildVehicleTypeDropdown()),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: _buildTimeframeDropdown()),
                      const SizedBox(width: AppSpacing.md),
                      _buildClearFiltersButton(),
                    ],
                  );
                } else if (constraints.maxWidth > 500) {
                  // Medium: 2x2 grid
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildDocTypeDropdown()),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(child: _buildStatusDropdown()),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(child: _buildVehicleTypeDropdown()),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(child: _buildTimeframeDropdown()),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Align(
                        alignment: Alignment.centerRight,
                        child: _buildClearFiltersButton(),
                      ),
                    ],
                  );
                } else {
                  // Narrow: Stacked
                  return Column(
                    children: [
                      _buildDocTypeDropdown(),
                      const SizedBox(height: AppSpacing.md),
                      _buildStatusDropdown(),
                      const SizedBox(height: AppSpacing.md),
                      _buildVehicleTypeDropdown(),
                      const SizedBox(height: AppSpacing.md),
                      _buildTimeframeDropdown(),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        child: _buildClearFiltersButton(),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: controller.searchController,
      decoration: InputDecoration(
        hintText: 'Search vehicle, chassis, document...',
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
        prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
        suffixIcon: controller.searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () {
                  controller.searchController.clear();
                  controller.applyFilters();
                },
              )
            : const SizedBox.shrink(),
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
      style: AppTextStyles.body,
    );
  }

  Widget _buildDocTypeDropdown() {
    return Obx(() => _FilterDropdown(
          label: 'Document Type',
          value: controller.selectedDocTypeFilter.value?.toString(),
          items: [
            const DropdownMenuItem(value: null, child: Text('All Types')),
            ...controller.availableDocumentTypes.map((doc) => DropdownMenuItem(
                  value: doc.docType.toString(),
                  child: Text(doc.docDescription ?? 'Unknown'),
                )),
          ],
          onChanged: (value) {
            controller.selectedDocTypeFilter.value =
                value != null ? int.tryParse(value) : null;
            controller.applyFilters();
          },
        ));
  }

  Widget _buildStatusDropdown() {
    return Obx(() => _FilterDropdown(
          label: 'Status',
          value: controller.selectedStatusFilter.value?.name,
          items: [
            const DropdownMenuItem(value: null, child: Text('All Statuses')),
            ...ExpiryStatus.values.where((s) => s != ExpiryStatus.unknown).map(
                  (status) => DropdownMenuItem(
                    value: status.name,
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: controller.getStatusColor(status),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(controller.getStatusLabel(status)),
                      ],
                    ),
                  ),
                ),
          ],
          onChanged: (value) {
            controller.selectedStatusFilter.value = value != null
                ? ExpiryStatus.values.firstWhereOrNull((s) => s.name == value)
                : null;
            controller.activeQuickFilter.value = null; // Clear quick filter
            controller.applyFilters();
          },
        ));
  }

  Widget _buildVehicleTypeDropdown() {
    return Obx(() => _FilterDropdown(
          label: 'Vehicle Type',
          value: controller.selectedVehicleTypeFilter.value.isEmpty
              ? null
              : controller.selectedVehicleTypeFilter.value,
          items: [
            const DropdownMenuItem(value: null, child: Text('All Vehicles')),
            ...controller.vehicleTypeOptions.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                )),
          ],
          onChanged: (value) {
            controller.selectedVehicleTypeFilter.value = value ?? '';
            controller.applyFilters();
          },
        ));
  }

  Widget _buildTimeframeDropdown() {
    return Obx(() => _FilterDropdown(
          label: 'Timeframe',
          value: controller.selectedTimeframeFilter.value.isEmpty
              ? null
              : controller.selectedTimeframeFilter.value,
          items: [
            const DropdownMenuItem(value: null, child: Text('All Time')),
            ...controller.timeframeOptions.map((tf) => DropdownMenuItem(
                  value: tf,
                  child: Text(tf),
                )),
          ],
          onChanged: (value) {
            controller.selectedTimeframeFilter.value = value ?? '';
            controller.applyFilters();
          },
        ));
  }

  Widget _buildClearFiltersButton() {
    return Obx(() => controller.hasActiveFilters
        ? Padding(
            padding: const EdgeInsets.only(top: 20),
            child: TextButton.icon(
              icon: const Icon(Icons.clear_all, size: 18),
              label: const Text('Clear'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
              onPressed: controller.clearFilters,
            ),
          )
        : const SizedBox.shrink());
  }

  // ==================== RESULTS BAR ====================

  Widget _buildResultsBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Obx(() => Row(
            children: [
              // Results count
              Text(
                '${controller.filteredCount} of ${controller.totalDocuments} documents',
                style: AppTextStyles.label
                    .copyWith(color: AppColors.textSecondary),
              ),

              // Active filter indicator
              if (controller.hasActiveFilters) ...[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: AppRadius.borderFull,
                  ),
                  child: Text(
                    'Filtered',
                    style:
                        AppTextStyles.caption.copyWith(color: AppColors.accent),
                  ),
                ),
              ],

              const Spacer(),

              // Sort dropdown
              _SortButton(
                sortBy: controller.sortBy.value,
                ascending: controller.sortAscending.value,
                onSortChanged: controller.setSortBy,
              ),
            ],
          )),
    );
  }

  // ==================== EMPTY STATE ====================

  Widget _buildEmptyState() {
    return AppEmptyState(
      icon: Icons.description_outlined,
      title: 'No Documents Found',
      subtitle: controller.hasActiveFilters
          ? 'Try adjusting your filters'
          : 'No vehicle documents to display',
      action: controller.hasActiveFilters
          ? AppButton(
              text: 'Clear Filters',
              onPressed: controller.clearFilters,

              // color: AppButtonVariant.outline,
            )
          : null,
    );
  }

  // ==================== LIST VIEWS (PLACEHOLDER) ====================
  // These will be implemented in Part 2

  Widget _buildItemList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = controller.filteredExpiryItems[index];
          return _ExpiryItemCard(
            item: item,
            controller: controller,
            // isSelectionMode: controller.isSelectionMode.value,
            // isSelected: controller.isItemSelected(item),
            onTap: () => controller.selectExpiryItem(item),
            // onSelect: () => controller.toggleItemSelection(item),
          );
        },
        childCount: controller.filteredExpiryItems.length,
      ),
    );
  }

  Widget _buildGroupedList() {
    final grouped = controller.groupedByVehicle;
    final vehicleNos = grouped.keys.toList();

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final vehicleNo = vehicleNos[index];
          final items = grouped[vehicleNo]!;
          return Obx(() => _VehicleGroupCard(
                vehicleNo: vehicleNo,
                items: items,
                controller: controller,
                isExpanded: controller.expandedVehicles.contains(vehicleNo),
                onToggle: () => controller.toggleVehicleExpanded(vehicleNo),
              ));
        },
        childCount: vehicleNos.length,
      ),
    );
  }

  // ==================== DIALOGS ====================
  // void _showBulkScheduleDialog(BuildContext context) {
  //   Get.dialog(
  //     BulkScheduleDialog(controller: controller),
  //     barrierDismissible: false,
  //   );
  // }
}

/// ============================================================
/// REUSABLE WIDGETS
/// ============================================================

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadius.borderMd,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: AppRadius.borderMd,
            border: Border.all(
              color: AppColors.accent,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.accent,
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final bool isActive;
  final VoidCallback onTap;

  const _StatCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
    this.subtitle,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderLg,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isActive ? color.withOpacity(0.15) : AppColors.cardBg,
            borderRadius: AppRadius.borderLg,
            border: Border.all(
              color: isActive ? color : AppColors.divider,
              width: isActive ? 2 : 1,
            ),
            boxShadow: isActive ? [] : AppShadows.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: AppRadius.borderMd,
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  if (isActive)
                    Icon(Icons.check_circle, color: color, size: 16),
                ],
              ),
              const Spacer(),
              Text(
                count.toString(),
                style: AppTextStyles.h2.copyWith(
                  color: isActive ? color : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: AppTextStyles.caption,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<DropdownMenuItem<String?>> items;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<String?>(
          value: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
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
              borderSide: BorderSide(color: AppColors.accent),
            ),
          ),
          dropdownColor: AppColors.cardBg,
          borderRadius: AppRadius.borderMd,
          style: AppTextStyles.body,
          icon: Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
          isExpanded: true,
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _SortButton extends StatelessWidget {
  final String sortBy;
  final bool ascending;
  final ValueChanged<String> onSortChanged;

  const _SortButton({
    required this.sortBy,
    required this.ascending,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onSortChanged,
      itemBuilder: (context) => [
        _buildSortItem('expiry', 'Expiry Date'),
        _buildSortItem('vehicle', 'Vehicle'),
        _buildSortItem('docType', 'Document Type'),
      ],
      borderRadius: AppRadius.borderMd,
      color: AppColors.cardBg,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: AppRadius.borderMd,
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              ascending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              _getSortLabel(),
              style: AppTextStyles.labelSmall,
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  String _getSortLabel() {
    switch (sortBy) {
      case 'expiry':
        return 'Expiry Date';
      case 'vehicle':
        return 'Vehicle';
      case 'docType':
        return 'Doc Type';
      default:
        return 'Sort';
    }
  }

  PopupMenuItem<String> _buildSortItem(String value, String label) {
    final isSelected = sortBy == value;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          if (isSelected)
            Icon(
              ascending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 16,
              color: AppColors.accent,
            )
          else
            const SizedBox(width: 16),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.accent : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================
/// PLACEHOLDER WIDGETS (To be implemented in later parts)
/// ============================================================

// class _ExpiryItemCard extends StatelessWidget {
//   final ExpiryItem item;
//   final ExpiryController controller;
//   final bool isSelectionMode;
//   final bool isSelected;
//   final VoidCallback onTap;
//   final VoidCallback onSelect;

//   const _ExpiryItemCard({
//     required this.item,
//     required this.controller,
//     required this.isSelectionMode,
//     required this.isSelected,
//     required this.onTap,
//     required this.onSelect,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // Placeholder - Will be fully implemented in Part 2
//     return Padding(
//       padding: const EdgeInsets.symmetric(
//         horizontal: AppSpacing.lg,
//         vertical: AppSpacing.xs,
//       ),
//       child: AppCard(
//         onTap: isSelectionMode ? onSelect : onTap,
//         child: Row(
//           children: [
//             if (isSelectionMode) ...[
//               Checkbox(
//                 value: isSelected,
//                 onChanged: (_) => onSelect(),
//                 activeColor: AppColors.accent,
//               ),
//               const SizedBox(width: AppSpacing.sm),
//             ],
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(item.vehicleNo, style: AppTextStyles.label),
//                   Text(
//                     item.documentTypeName ?? 'Document',
//                     style: AppTextStyles.bodySmall,
//                   ),
//                 ],
//               ),
//             ),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 AppStatusBadge(
//                   label: controller.getStatusLabel(item.status),
//                   color: controller.getStatusColor(item.status),
//                 ),
//                 const SizedBox(height: AppSpacing.xs),
//                 Text(
//                   controller.formatDaysRemaining(item.daysUntilExpiry),
//                   style: AppTextStyles.caption,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _VehicleGroupCard extends StatelessWidget {
//   final String vehicleNo;
//   final List<ExpiryItem> items;
//   final ExpiryController controller;
//   final bool isExpanded;
//   final VoidCallback onToggle;

//   const _VehicleGroupCard({
//     required this.vehicleNo,
//     required this.items,
//     required this.controller,
//     required this.isExpanded,
//     required this.onToggle,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // Placeholder - Will be fully implemented in Part 2
//     return Padding(
//       padding: const EdgeInsets.symmetric(
//         horizontal: AppSpacing.lg,
//         vertical: AppSpacing.xs,
//       ),
//       child: AppCard(
//         onTap: onToggle,
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: Text(vehicleNo, style: AppTextStyles.label),
//                 ),
//                 Text(
//                   '${items.length} documents',
//                   style: AppTextStyles.bodySmall,
//                 ),
//                 Icon(
//                   isExpanded ? Icons.expand_less : Icons.expand_more,
//                   color: AppColors.textMuted,
//                 ),
//               ],
//             ),
//             if (isExpanded) ...[
//               const Divider(height: AppSpacing.lg),
//               ...items.map((item) => Padding(
//                     padding: const EdgeInsets.only(bottom: AppSpacing.sm),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             item.documentTypeName ?? 'Document',
//                             style: AppTextStyles.body,
//                           ),
//                         ),
//                         AppStatusBadge(
//                           label: controller.getStatusLabel(item.status),
//                           color: controller.getStatusColor(item.status),
//                         ),
//                       ],
//                     ),
//                   )),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _CalendarViewPage extends StatelessWidget {
//   final ExpiryController controller;

//   const _CalendarViewPage({required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     // Placeholder - Will be implemented in Part 4
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Text('Calendar View - Part 4'),
//           const SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: controller.toggleCalendarView,
//             child: const Text('Back to List'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// ============================================================
// PART 2: LIST VIEW, ITEM CARDS, GROUPED VIEW
// ============================================================
// Add these widgets to your expiry_page.dart file,
// replacing the placeholder versions from Part 1
// ============================================================

/// ============================================================
/// EXPIRY ITEM CARD
/// ============================================================
/// Individual document expiry card with full details

class _ExpiryItemCard extends StatelessWidget {
  final ExpiryItem item;
  final ExpiryController controller;
  // final bool isSelectionMode;
  // final bool isSelected;
  final VoidCallback onTap;
  // final VoidCallback onSelect;

  const _ExpiryItemCard({
    required this.item,
    required this.controller,
    // required this.isSelectionMode,
    // required this.isSelected,
    required this.onTap,
    // required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = controller.getStatusColor(item.status);
    final statusBgColor = controller.getStatusBgColor(item.status);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,

          // onTap: isSelectionMode ? onSelect : onTap,
          // onLongPress: isSelectionMode
          //     ? null
          //     : () {
          //         controller.toggleSelectionMode();
          //         controller.toggleItemSelection(item);
          //       },
          borderRadius: AppRadius.borderLg,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: AppRadius.borderLg,
              border: Border.all(
                color: AppColors.divider,
                width: 1,
              ),
              boxShadow: AppShadows.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Vehicle Info + Status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Selection Checkbox
                    // if (isSelectionMode) ...[
                    //   Transform.scale(
                    //     scale: 1.1,
                    //     child: Checkbox(
                    //       value: isSelected,
                    //       onChanged: (_) => onSelect(),
                    //       activeColor: AppColors.accent,
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(4),
                    //       ),
                    //     ),
                    //   ),
                    //   const SizedBox(width: AppSpacing.sm),
                    // ],

                    // Status Indicator Line
                    Container(
                      width: 4,
                      height: 50,
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: AppRadius.borderFull,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),

                    // Vehicle Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Vehicle Number
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: AppSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryDark,
                                  borderRadius: AppRadius.borderSm,
                                ),
                                child: Text(
                                  item.vehicleNo,
                                  style: AppTextStyles.label.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),

                              // Vehicle Type Badge
                              if (item.vehicle.type != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: AppSpacing.xs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: AppRadius.borderSm,
                                    border:
                                        Border.all(color: AppColors.divider),
                                  ),
                                  child: Text(
                                    item.vehicle.type!,
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),

                          // Vehicle Name
                          if (item.vehicleName.isNotEmpty)
                            Text(
                              item.vehicleName,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Status Badge
                    _StatusBadge(
                      status: item.status,
                      controller: controller,
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // Divider
                Divider(color: AppColors.divider, height: 1),

                const SizedBox(height: AppSpacing.md),

                // Bottom Row: Document Info + Expiry
                Row(
                  children: [
                    // Document Type Icon
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: AppRadius.borderMd,
                      ),
                      child: Icon(
                        _getDocTypeIcon(item.docType),
                        color: statusColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),

                    // Document Type Name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.documentTypeName ?? 'Document',
                            style: AppTextStyles.label,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Expires: ${controller.formatDate(item.expiryDate)}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Days Remaining
                    _DaysRemainingChip(
                      days: item.daysUntilExpiry,
                      status: item.status,
                      controller: controller,
                    ),
                  ],
                ),

                // Quick Actions (visible on hover/focus for desktop)
                _buildQuickActions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    // Only show if not in selection mode and item needs attention
    // if (isSelectionMode) return const SizedBox.shrink();

    final needsAction = item.status == ExpiryStatus.expired ||
        item.status == ExpiryStatus.critical ||
        item.status == ExpiryStatus.warning;

    if (!needsAction) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Renew Button
          TextButton.icon(
            icon: Icon(
              Icons.refresh,
              size: 16,
              color: AppColors.accent,
            ),
            label: Text(
              'Renew',
              style: AppTextStyles.buttonSmall.copyWith(
                color: AppColors.accent,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.borderMd,
              ),
            ),
            onPressed: onTap,
          ),
        ],
      ),
    );
  }

  IconData _getDocTypeIcon(int docType) {
    // Map common document types to icons
    // Adjust based on your actual document type IDs
    switch (docType) {
      case 1001: // Insurance
        return Icons.security;
      case 1002: // Mulkiya/Registration
        return Icons.assignment;
      case 1003: // Service
        return Icons.build;
      case 1004: // Permit
        return Icons.badge;
      case 1005: // Fitness
        return Icons.health_and_safety;
      default:
        return Icons.description;
    }
  }
}

/// ============================================================
/// STATUS BADGE
/// ============================================================

class _StatusBadge extends StatelessWidget {
  final ExpiryStatus status;
  final ExpiryController controller;

  const _StatusBadge({
    required this.status,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final color = controller.getStatusColor(status);
    final bgColor = controller.getStatusBgColor(status);
    final icon = controller.getStatusIcon(status);
    final label = controller.getStatusLabel(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.borderFull,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================
/// DAYS REMAINING CHIP
/// ============================================================

class _DaysRemainingChip extends StatelessWidget {
  final int days;
  final ExpiryStatus status;
  final ExpiryController controller;

  const _DaysRemainingChip({
    required this.days,
    required this.status,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final color = controller.getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppRadius.borderMd,
      ),
      child: Text(
        controller.formatDaysRemaining(days),
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// ============================================================
/// VEHICLE GROUP CARD (GROUPED VIEW)
/// ============================================================

class _VehicleGroupCard extends StatelessWidget {
  final String vehicleNo;
  final List<ExpiryItem> items;
  final ExpiryController controller;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _VehicleGroupCard({
    required this.vehicleNo,
    required this.items,
    required this.controller,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    // Get the vehicle from first item
    final vehicle = items.first.vehicle;

    // Calculate summary stats
    final expiredCount =
        items.where((i) => i.status == ExpiryStatus.expired).length;
    final criticalCount =
        items.where((i) => i.status == ExpiryStatus.critical).length;
    final warningCount =
        items.where((i) => i.status == ExpiryStatus.warning).length;

    // Determine worst status for header color
    final worstStatus = _getWorstStatus();
    final headerColor = controller.getStatusColor(worstStatus);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: AppRadius.borderLg,
          border: Border.all(
            color:
                isExpanded ? headerColor.withOpacity(0.5) : AppColors.divider,
          ),
          boxShadow: AppShadows.sm,
        ),
        child: Column(
          children: [
            // Header (Always visible)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onToggle,
                borderRadius: isExpanded
                    ? const BorderRadius.vertical(
                        top: Radius.circular(AppRadius.lg))
                    : AppRadius.borderLg,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: isExpanded
                        ? headerColor.withOpacity(0.05)
                        : Colors.transparent,
                    borderRadius: isExpanded
                        ? const BorderRadius.vertical(
                            top: Radius.circular(AppRadius.lg))
                        : AppRadius.borderLg,
                  ),
                  child: Row(
                    children: [
                      // Status Indicator
                      Container(
                        width: 4,
                        height: 40,
                        decoration: BoxDecoration(
                          color: headerColor,
                          borderRadius: AppRadius.borderFull,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),

                      // Vehicle Icon
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark.withOpacity(0.1),
                          borderRadius: AppRadius.borderMd,
                        ),
                        child: Icon(
                          _getVehicleIcon(vehicle.type),
                          color: AppColors.primaryDark,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),

                      // Vehicle Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  vehicleNo,
                                  style: AppTextStyles.h4,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                if (vehicle.type != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: AppRadius.borderSm,
                                    ),
                                    child: Text(
                                      vehicle.type!,
                                      style: AppTextStyles.caption,
                                    ),
                                  ),
                              ],
                            ),
                            if (vehicle.brand != null || vehicle.model != null)
                              Text(
                                '${vehicle.brand ?? ''} ${vehicle.model ?? ''}'
                                    .trim(),
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Status Summary Pills
                      _buildStatusSummary(
                          expiredCount, criticalCount, warningCount),

                      const SizedBox(width: AppSpacing.md),

                      // Document Count
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppRadius.borderFull,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.description_outlined,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              '${items.length}',
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: AppSpacing.sm),

                      // Expand Icon
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Expanded Content
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: _buildExpandedContent(),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSummary(int expired, int critical, int warning) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (expired > 0)
          _MiniStatusPill(
            count: expired,
            color: controller.getStatusColor(ExpiryStatus.expired),
            icon: Icons.error,
          ),
        if (critical > 0) ...[
          const SizedBox(width: AppSpacing.xs),
          _MiniStatusPill(
            count: critical,
            color: controller.getStatusColor(ExpiryStatus.critical),
            icon: Icons.warning_amber,
          ),
        ],
        if (warning > 0) ...[
          const SizedBox(width: AppSpacing.xs),
          _MiniStatusPill(
            count: warning,
            color: controller.getStatusColor(ExpiryStatus.warning),
            icon: Icons.access_time,
          ),
        ],
      ],
    );
  }

  Widget _buildExpandedContent() {
    // Sort items by days until expiry (most urgent first)
    final sortedItems = List<ExpiryItem>.from(items)
      ..sort((a, b) => a.daysUntilExpiry.compareTo(b.daysUntilExpiry));

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Column(
        children: [
          // Document List
          ...sortedItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == sortedItems.length - 1;

            return _GroupDocumentRow(
              item: item,
              controller: controller,
              isLast: isLast,
              onTap: () => controller.selectExpiryItem(item),
            );
          }),

          // Action Footer
          // _buildGroupActions(),
        ],
      ),
    );
  }

  // Widget _buildGroupActions() {
  //   final needsAction = items.any((i) =>
  //       i.status == ExpiryStatus.expired ||
  //       i.status == ExpiryStatus.critical ||
  //       i.status == ExpiryStatus.warning);

  //   if (!needsAction) return const SizedBox.shrink();

  //   return Container(
  //     padding: const EdgeInsets.all(AppSpacing.md),
  //     decoration: BoxDecoration(
  //       color: AppColors.surface,
  //       borderRadius: const BorderRadius.vertical(
  //         bottom: Radius.circular(AppRadius.lg),
  //       ),
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.end,
  //       children: [
  //         TextButton.icon(
  //           icon: const Icon(Icons.checklist, size: 16),
  //           label: const Text('Select All'),
  //           style: TextButton.styleFrom(
  //             foregroundColor: AppColors.textSecondary,
  //           ),
  //           onPressed: () {
  //             controller.isSelectionMode.value = true;
  //             for (final item in items) {
  //               if (!controller.selectedItems.contains(item)) {
  //                 controller.selectedItems.add(item);
  //               }
  //             }
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }

  ExpiryStatus _getWorstStatus() {
    if (items.any((i) => i.status == ExpiryStatus.expired)) {
      return ExpiryStatus.expired;
    }
    if (items.any((i) => i.status == ExpiryStatus.critical)) {
      return ExpiryStatus.critical;
    }
    if (items.any((i) => i.status == ExpiryStatus.warning)) {
      return ExpiryStatus.warning;
    }
    if (items.any((i) => i.status == ExpiryStatus.upcoming)) {
      return ExpiryStatus.upcoming;
    }
    return ExpiryStatus.valid;
  }

  IconData _getVehicleIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'truck':
      case 'lorry':
        return Icons.local_shipping;
      case 'bus':
        return Icons.directions_bus;
      case 'van':
        return Icons.airport_shuttle;
      case 'motorcycle':
      case 'bike':
        return Icons.two_wheeler;
      case 'sedan':
      case 'car':
        return Icons.directions_car;
      case 'suv':
        return Icons.directions_car_filled;
      default:
        return Icons.directions_car;
    }
  }
}

/// ============================================================
/// MINI STATUS PILL (For group summary)
/// ============================================================

class _MiniStatusPill extends StatelessWidget {
  final int count;
  final Color color;
  final IconData icon;

  const _MiniStatusPill({
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppRadius.borderFull,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 2),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================
/// GROUP DOCUMENT ROW (Inside expanded group)
/// ============================================================

class _GroupDocumentRow extends StatelessWidget {
  final ExpiryItem item;
  final ExpiryController controller;
  final bool isLast;
  final VoidCallback onTap;

  const _GroupDocumentRow({
    required this.item,
    required this.controller,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = controller.getStatusColor(item.status);
    final statusBgColor = controller.getStatusBgColor(item.status);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : Border(
                    bottom:
                        BorderSide(color: AppColors.divider.withOpacity(0.5))),
          ),
          child: Row(
            children: [
              // Document Icon
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: AppRadius.borderSm,
                ),
                child: Icon(
                  _getDocIcon(item.docType),
                  color: statusColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Document Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.documentTypeName ?? 'Document',
                      style: AppTextStyles.label,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Expires: ${controller.formatDate(item.expiryDate)}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),

              // Status
              _StatusBadge(
                status: item.status,
                controller: controller,
              ),
              const SizedBox(width: AppSpacing.md),

              // Days Chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: AppRadius.borderSm,
                ),
                child: Text(
                  _formatDaysShort(item.daysUntilExpiry),
                  style: AppTextStyles.caption.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              // Arrow
              Icon(
                Icons.chevron_right,
                color: AppColors.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDaysShort(int days) {
    if (days < 0) return '${days.abs()}d ago';
    if (days == 0) return 'Today';
    return '${days}d';
  }

  IconData _getDocIcon(int docType) {
    switch (docType) {
      case 1001:
        return Icons.security;
      case 1002:
        return Icons.assignment;
      case 1003:
        return Icons.build;
      default:
        return Icons.description;
    }
  }
}

// ============================================================
// PART 3: COMPARISON VIEW, RENEWAL HISTORY, RENEWAL FORM
// ============================================================
// Add these widgets to your expiry_page.dart file,
// replacing the placeholder _ComparisonView from Part 1
// ============================================================

/// ============================================================
/// COMPARISON VIEW (DETAIL VIEW)
/// ============================================================
/// Shows document details, renewal history, and renewal form

class _ComparisonView extends StatelessWidget {
  final ExpiryController controller;

  const _ComparisonView({required this.controller});

  @override
  Widget build(BuildContext context) {
    final item = controller.selectedExpiryItem.value;
    if (item == null) return const SizedBox.shrink();

    return Column(
      children: [
        // Header
        _buildHeader(context, item),

        // Content
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;

              if (isWide) {
                // Desktop: Side by side
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: Document Details + History
                    Expanded(
                      flex: 5,
                      child: _buildLeftPanel(context, item),
                    ),

                    // Divider
                    Container(
                      width: 1,
                      color: AppColors.divider,
                    ),

                    // Right: Renewal Form
                    Expanded(
                      flex: 4,
                      child: _buildRenewalForm(context, item),
                    ),
                  ],
                );
              } else {
                // Mobile: Tabbed or scrollable
                return _buildMobileLayout(context, item);
              }
            },
          ),
        ),
      ],
    );
  }

  // ==================== HEADER ====================

  Widget _buildHeader(BuildContext context, ExpiryItem item) {
    final statusColor = controller.getStatusColor(item.status);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        children: [
          // Back Button
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: controller.closeComparisonView,
            tooltip: 'Back to list',
          ),
          const SizedBox(width: AppSpacing.md),

          // Status Indicator
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: AppRadius.borderFull,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Vehicle Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark,
                        borderRadius: AppRadius.borderSm,
                      ),
                      child: Text(
                        item.vehicleNo,
                        style: AppTextStyles.label.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),

                    // Document Type
                    Text(
                      item.documentTypeName ?? 'Document',
                      style: AppTextStyles.h3,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${item.vehicleName} • ${item.vehicle.type ?? 'Vehicle'}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Status Badge
          _StatusBadge(
            status: item.status,
            controller: controller,
          ),
        ],
      ),
    );
  }

  // ==================== LEFT PANEL ====================

  Widget _buildLeftPanel(BuildContext context, ExpiryItem item) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Document Details
          _buildCurrentDocumentSection(item),
          const SizedBox(height: AppSpacing.xl),

          // Renewal History
          _buildRenewalHistorySection(item),
        ],
      ),
    );
  }

  // ==================== CURRENT DOCUMENT SECTION ====================

  Widget _buildCurrentDocumentSection(ExpiryItem item) {
    final statusColor = controller.getStatusColor(item.status);
    final statusBgColor = controller.getStatusBgColor(item.status);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: AppRadius.borderMd,
                ),
                child: Icon(
                  Icons.description,
                  color: AppColors.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text('Current Document', style: AppTextStyles.h4),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Expiry Alert Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: AppRadius.borderLg,
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    controller.getStatusIcon(item.status),
                    color: statusColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.formatDaysRemaining(item.daysUntilExpiry),
                        style: AppTextStyles.h3.copyWith(color: statusColor),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Expires on ${controller.formatDate(item.expiryDate)}',
                        style: AppTextStyles.body.copyWith(
                          color: statusColor.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Document Details Grid
          _buildDetailsGrid(item),
        ],
      ),
    );
  }

  Widget _buildDetailsGrid(ExpiryItem item) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _DetailItem(
                icon: Icons.directions_car,
                label: 'Vehicle',
                value: item.vehicleNo,
              ),
            ),
            Expanded(
              child: _DetailItem(
                icon: Icons.category,
                label: 'Type',
                value: item.vehicle.type ?? '-',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _DetailItem(
                icon: Icons.confirmation_number,
                label: 'Chassis No',
                value: item.vehicle.chassisNo ?? '-',
              ),
            ),
            Expanded(
              child: _DetailItem(
                icon: Icons.description,
                label: 'Document',
                value: item.documentTypeName ?? '-',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _DetailItem(
                icon: Icons.calendar_today,
                label: 'Issue Date',
                value: item.document.issueDate != null
                    ? controller.formatDate(item.document.issueDate)
                    : '-',
              ),
            ),
            Expanded(
              child: _DetailItem(
                icon: Icons.event_busy,
                label: 'Expiry Date',
                value: controller.formatDate(item.expiryDate),
                valueColor: controller.getStatusColor(item.status),
              ),
            ),
          ],
        ),

        // Document Number (if available)
        if (item.document.documentNo != null) ...[
          const SizedBox(height: AppSpacing.md),
          _DetailItem(
            icon: Icons.tag,
            label: 'Document Number',
            value: item.document.documentNo!,
          ),
        ],

        // Amount (if available)
        if (item.document.amount != null) ...[
          const SizedBox(height: AppSpacing.md),
          _DetailItem(
            icon: Icons.attach_money,
            label: 'Amount',
            value: item.document.amount!.toStringAsFixed(2),
          ),
        ],
      ],
    );
  }

  // ==================== RENEWAL HISTORY SECTION ====================

  Widget _buildRenewalHistorySection(ExpiryItem item) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: AppRadius.borderMd,
                ),
                child: Icon(
                  Icons.history,
                  color: AppColors.info,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text('Renewal History', style: AppTextStyles.h4),
              const Spacer(),
              Obx(() => controller.isLoadingHistory.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : TextButton.icon(
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Refresh'),
                      onPressed: () => controller.loadRenewalHistory(item),
                    )),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // History List
          Obx(() {
            if (controller.isLoadingHistory.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (controller.renewalHistory.isEmpty) {
              return _buildEmptyHistory();
            }

            return Column(
              children: controller.renewalHistory.asMap().entries.map((entry) {
                final index = entry.key;
                final history = entry.value;
                final isFirst = index == 0;
                final isLast = index == controller.renewalHistory.length - 1;

                return _RenewalHistoryItem(
                  history: history,
                  controller: controller,
                  isFirst: isFirst,
                  isLast: isLast,
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Icon(
            Icons.history,
            size: 48,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No Renewal History',
            style: AppTextStyles.label.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'This document has not been renewed yet',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  // ==================== RENEWAL FORM ====================

  Widget _buildRenewalForm(BuildContext context, ExpiryItem item) {
    return Container(
      color: AppColors.surface,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: _RenewalForm(
          item: item,
          controller: controller,
        ),
      ),
    );
  }

  // ==================== MOBILE LAYOUT ====================

  Widget _buildMobileLayout(BuildContext context, ExpiryItem item) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Tab Bar
          Container(
            color: AppColors.cardBg,
            child: TabBar(
              labelColor: AppColors.accent,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.accent,
              tabs: const [
                Tab(text: 'Details & History'),
                Tab(text: 'Renew Document'),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              children: [
                // Tab 1: Details + History
                _buildLeftPanel(context, item),

                // Tab 2: Renewal Form
                _buildRenewalForm(context, item),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================
/// DETAIL ITEM WIDGET
/// ============================================================

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderMd,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.label.copyWith(
                    color: valueColor ?? AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================
/// RENEWAL HISTORY ITEM
/// ============================================================

class _RenewalHistoryItem extends StatelessWidget {
  final RenewalHistoryItem history;
  final ExpiryController controller;
  final bool isFirst;
  final bool isLast;

  const _RenewalHistoryItem({
    required this.history,
    required this.controller,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Top Line
                if (!isFirst)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.divider,
                    ),
                  ),

                // Dot
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isFirst ? AppColors.accent : AppColors.divider,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isFirst ? AppColors.accent : AppColors.textMuted,
                      width: 2,
                    ),
                  ),
                ),

                // Bottom Line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.divider,
                    ),
                  ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(
                bottom: AppSpacing.md,
              ),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isFirst
                    ? AppColors.accent.withOpacity(0.05)
                    : AppColors.surface,
                borderRadius: AppRadius.borderMd,
                border: Border.all(
                  color: isFirst
                      ? AppColors.accent.withOpacity(0.2)
                      : AppColors.divider,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    children: [
                      // Date Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: isFirst
                              ? AppColors.accent
                              : AppColors.primaryLight,
                          borderRadius: AppRadius.borderSm,
                        ),
                        child: Text(
                          controller.formatDate(history.renewalDate),
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),

                      // Cost
                      if (history.cost != null && history.cost! > 0)
                        Text(
                          controller.formatCurrency(history.cost),
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Expiry Change
                  Row(
                    children: [
                      Expanded(
                        child: _ExpiryChangeItem(
                          label: 'Previous Expiry',
                          date: history.previousExpiryDate,
                          controller: controller,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm),
                        child: Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: AppColors.textMuted,
                        ),
                      ),
                      Expanded(
                        child: _ExpiryChangeItem(
                          label: 'New Expiry',
                          date: history.newExpiryDate,
                          controller: controller,
                          isNew: true,
                        ),
                      ),
                    ],
                  ),

                  // Additional Details
                  if (history.provider != null ||
                      history.policyNumber != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Divider(color: AppColors.divider, height: 1),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.lg,
                      runSpacing: AppSpacing.sm,
                      children: [
                        if (history.provider != null)
                          _InfoChip(
                            icon: Icons.business,
                            label: history.provider!,
                          ),
                        if (history.policyNumber != null)
                          _InfoChip(
                            icon: Icons.tag,
                            label: history.policyNumber!,
                          ),
                        if (history.renewedBy != null)
                          _InfoChip(
                            icon: Icons.person,
                            label: history.renewedBy!,
                          ),
                      ],
                    ),
                  ],

                  // Remarks
                  if (history.remarks != null &&
                      history.remarks!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: AppRadius.borderSm,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.notes,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              history.remarks!,
                              style: AppTextStyles.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Document Link
                  if (history.documentUrl != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    TextButton.icon(
                      icon: const Icon(Icons.attach_file, size: 16),
                      label: const Text('View Document'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.accent,
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () {
                        // Open document URL
                        // launchUrl(Uri.parse(history.documentUrl!));
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================
/// EXPIRY CHANGE ITEM
/// ============================================================

class _ExpiryChangeItem extends StatelessWidget {
  final String label;
  final DateTime? date;
  final ExpiryController controller;
  final bool isNew;

  const _ExpiryChangeItem({
    required this.label,
    required this.date,
    required this.controller,
    this.isNew = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: 2),
        Text(
          date != null ? controller.formatDate(date) : '-',
          style: AppTextStyles.label.copyWith(
            color: isNew ? AppColors.success : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// ============================================================
/// INFO CHIP
/// ============================================================

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }
}

/// ============================================================
/// RENEWAL FORM
/// ============================================================

class _RenewalForm extends StatelessWidget {
  final ExpiryItem item;
  final ExpiryController controller;

  const _RenewalForm({
    required this.item,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.renewalFormKey,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: AppRadius.borderMd,
                  ),
                  child: Icon(
                    Icons.autorenew,
                    color: AppColors.success,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text('Renew Document', style: AppTextStyles.h4),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Current Expiry Info
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: AppRadius.borderMd,
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.warning,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Expiry',
                          style: AppTextStyles.caption,
                        ),
                        Text(
                          controller.formatDate(item.expiryDate),
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // New Expiry Date
            _FormDateField(
              label: 'New Expiry Date *',
              hint: 'Select new expiry date',
              value: controller.newExpiryDate,
              icon: Icons.event,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
              onChanged: (date) => controller.newExpiryDate.value = date,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Renewal Date
            _FormDateField(
              label: 'Renewal Date *',
              hint: 'Select renewal date',
              value: controller.renewalDate,
              icon: Icons.calendar_today,
              firstDate: DateTime.now().subtract(const Duration(days: 30)),
              lastDate: DateTime.now(),
              onChanged: (date) => controller.renewalDate.value = date,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Cost
            _FormTextField(
              label: 'Renewal Cost',
              hint: 'Enter amount',
              controller: controller.renewalCostController,
              icon: Icons.payments,
              keyboardType: TextInputType.number,
              prefix: Text(
                controller.companyService.selectedCompanyObs.value?.currency ??
                    'AED ',
                style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Provider
            _FormTextField(
              label: 'Provider / Company',
              hint: 'e.g., Emirates Insurance',
              controller: controller.renewalProviderController,
              icon: Icons.business,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Policy Number
            _FormTextField(
              label: 'Policy / Reference Number',
              hint: 'Enter reference number',
              controller: controller.renewalPolicyController,
              icon: Icons.tag,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Remarks
            _FormTextField(
              label: 'Remarks',
              hint: 'Add any notes...',
              controller: controller.renewalRemarksController,
              icon: Icons.notes,
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Document Upload
            _buildDocumentUpload(context),
            const SizedBox(height: AppSpacing.xxl),

            // Submit Button
            Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: controller.isSubmitting.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_circle),
                    label: Text(
                      controller.isSubmitting.value
                          ? 'Submitting...'
                          : 'Submit Renewal',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.borderMd,
                      ),
                      elevation: 0,
                    ),
                    onPressed: controller.isSubmitting.value
                        ? null
                        : () => controller.submitRenewal(item),
                  ),
                )),
            const SizedBox(height: AppSpacing.md),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: BorderSide(color: AppColors.divider),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.borderMd,
                  ),
                ),
                onPressed: controller.closeComparisonView,
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentUpload(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Document',
          style: AppTextStyles.label,
        ),
        const SizedBox(height: AppSpacing.sm),
        Obx(() {
          final hasFile = controller.renewalDocumentName.value.isNotEmpty;

          return Container(
            decoration: BoxDecoration(
              color: hasFile
                  ? AppColors.success.withOpacity(0.05)
                  : AppColors.surface,
              borderRadius: AppRadius.borderLg,
              border: Border.all(
                color: hasFile
                    ? AppColors.success.withOpacity(0.3)
                    : AppColors.divider,
                style: hasFile ? BorderStyle.solid : BorderStyle.none,
              ),
            ),
            child: hasFile ? _buildFilePreview() : _buildUploadArea(context),
          );
        }),
      ],
    );
  }

  Widget _buildUploadArea(BuildContext context) {
    return InkWell(
      onTap: () => _pickDocument(context),
      borderRadius: AppRadius.borderLg,
      child: DashedBorder(
        color: AppColors.divider,
        strokeWidth: 1.5,
        gap: 6,
        borderRadius: AppRadius.borderLg,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_upload_outlined,
                  color: AppColors.accent,
                  size: 32,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Click to upload document',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'PDF, JPG, PNG up to 10MB',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilePreview() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: AppRadius.borderMd,
            ),
            child: Icon(
              _getFileIcon(controller.renewalDocumentName.value),
              color: AppColors.success,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.renewalDocumentName.value,
                  style: AppTextStyles.label,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Ready to upload',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              color: AppColors.error,
              size: 20,
            ),
            onPressed: () {
              controller.setRenewalDocument(null);
            },
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'doc':
      case 'docx':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  void _pickDocument(BuildContext context) async {
    // For web:
    // import 'package:file_picker/file_picker.dart';
    //
    // final result = await FilePicker.platform.pickFiles(
    //   type: FileType.custom,
    //   allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    //   withData: true,
    // );
    //
    // if (result != null && result.files.isNotEmpty) {
    //   final file = result.files.first;
    //   controller.setRenewalDocument(
    //     null,
    //     bytes: file.bytes,
    //     name: file.name,
    //   );
    // }

    // For mobile:
    // import 'package:image_picker/image_picker.dart';
    // or use file_picker package

    // Placeholder - Show dialog
    Get.dialog(
      AlertDialog(
        title: const Text('File Upload'),
        content: const Text(
          'Integrate file_picker or image_picker package\n'
          'to enable document upload functionality.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// ============================================================
/// FORM TEXT FIELD
/// ============================================================

class _FormTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final Widget? prefix;

  const _FormTextField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
            prefix: prefix,
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

/// ============================================================
/// FORM DATE FIELD
/// ============================================================

class _FormDateField extends StatelessWidget {
  final String label;
  final String hint;
  final Rx<DateTime?> value;
  final IconData icon;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime?> onChanged;

  const _FormDateField({
    required this.label,
    required this.hint,
    required this.value,
    required this.icon,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.sm),
        Obx(() => InkWell(
              onTap: () => _selectDate(context),
              borderRadius: AppRadius.borderMd,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.borderMd,
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    Icon(icon, color: AppColors.textMuted, size: 20),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        value.value != null
                            ? DateFormat('dd MMM yyyy').format(value.value!)
                            : hint,
                        style: AppTextStyles.body.copyWith(
                          color: value.value != null
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.calendar_today,
                      color: AppColors.textMuted,
                      size: 18,
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  void _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: value.value ?? DateTime.now(),
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
      onChanged(picked);
    }
  }
}

/// ============================================================
/// DASHED BORDER (Custom painter for upload area)
/// ============================================================

class DashedBorder extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double strokeWidth;
  final double gap;
  final BorderRadius borderRadius;

  const DashedBorder({
    super.key,
    required this.child,
    this.color,
    this.strokeWidth = 1,
    this.gap = 5,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: color ?? AppColors.textMuted,
        strokeWidth: strokeWidth,
        gap: gap,
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final BorderRadius borderRadius;

  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();
    final rrect = RRect.fromRectAndCorners(
      Rect.fromLTWH(0, 0, size.width, size.height),
      topLeft: borderRadius.topLeft,
      topRight: borderRadius.topRight,
      bottomLeft: borderRadius.bottomLeft,
      bottomRight: borderRadius.bottomRight,
    );
    path.addRRect(rrect);

    final dashPath = Path();
    final pathMetrics = path.computeMetrics();

    for (final metric in pathMetrics) {
      double distance = 0;
      bool draw = true;
      while (distance < metric.length) {
        final length = draw ? gap : gap;
        if (draw) {
          dashPath.addPath(
            metric.extractPath(distance, distance + length),
            Offset.zero,
          );
        }
        distance += length;
        draw = !draw;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CalendarViewPage extends StatelessWidget {
  final ExpiryController controller;

  const _CalendarViewPage({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        _buildHeader(context),

        // Content
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;

              if (isWide) {
                // Desktop: Calendar + List side by side
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Calendar
                    Expanded(
                      flex: 5,
                      child: _buildCalendarSection(context),
                    ),

                    // Divider
                    Container(width: 1, color: AppColors.divider),

                    // Selected Date Items
                    Expanded(
                      flex: 4,
                      child: _buildSelectedDateItems(context),
                    ),
                  ],
                );
              } else {
                // Mobile: Stacked
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildCalendarSection(context),
                      _buildSelectedDateItems(context),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  // ==================== HEADER ====================

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        children: [
          // Back Button
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: controller.toggleCalendarView,
            tooltip: 'Back to list',
          ),
          const SizedBox(width: AppSpacing.md),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Expiry Calendar', style: AppTextStyles.h2),
                const SizedBox(height: AppSpacing.xs),
                Obx(() => Text(
                      'Viewing ${DateFormat('MMMM yyyy').format(controller.focusedMonth.value)}',
                      style: AppTextStyles.bodySmall,
                    )),
              ],
            ),
          ),

          // Legend
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LegendItem(color: AppColors.error, label: 'Expired'),
        const SizedBox(width: AppSpacing.md),
        _LegendItem(color: AppColors.warning, label: 'Warning'),
        const SizedBox(width: AppSpacing.md),
        _LegendItem(color: AppColors.success, label: 'Valid'),
      ],
    );
  }

  // ==================== CALENDAR SECTION ====================

  Widget _buildCalendarSection(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: AppCard(
        child: Column(
          children: [
            // Month Navigation
            _buildMonthNavigation(),
            const SizedBox(height: AppSpacing.lg),

            // Calendar Grid
            _buildCalendarGrid(context),
            const SizedBox(height: AppSpacing.lg),

            // Month Summary
            _buildMonthSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthNavigation() {
    return Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                final current = controller.focusedMonth.value;
                controller.setFocusedMonth(
                  DateTime(current.year, current.month - 1, 1),
                );
              },
            ),
            GestureDetector(
              onTap: () => _showMonthPicker(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('MMMM yyyy')
                        .format(controller.focusedMonth.value),
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(Icons.arrow_drop_down, color: AppColors.textMuted),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                final current = controller.focusedMonth.value;
                controller.setFocusedMonth(
                  DateTime(current.year, current.month + 1, 1),
                );
              },
            ),
          ],
        ));
  }

  void _showMonthPicker() {
    Get.dialog(
      _MonthYearPickerDialog(
        initialDate: controller.focusedMonth.value,
        onDateSelected: (date) {
          controller.setFocusedMonth(date);
          Get.back();
        },
      ),
    );
  }

  Widget _buildCalendarGrid(BuildContext context) {
    return GetBuilder<ExpiryController>(
      builder: (controller) {
        final focusedMonth = controller.focusedMonth.value;
        final firstDayOfMonth =
            DateTime(focusedMonth.year, focusedMonth.month, 1);
        final lastDayOfMonth =
            DateTime(focusedMonth.year, focusedMonth.month + 1, 0);

        // Get the weekday of the first day (0 = Sunday in our grid)
        int startWeekday = firstDayOfMonth.weekday % 7;

        // Calculate total cells needed
        final totalDays = lastDayOfMonth.day;
        final totalCells = ((startWeekday + totalDays) / 7).ceil() * 7;

        return Column(
          children: [
            // Weekday Headers
            Row(
              children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                  .map((day) => Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Calendar Days Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: totalCells,
              itemBuilder: (context, index) {
                final dayOffset = index - startWeekday;

                if (dayOffset < 0 || dayOffset >= totalDays) {
                  // Empty cell
                  return const SizedBox.shrink();
                }

                final date = DateTime(
                    focusedMonth.year, focusedMonth.month, dayOffset + 1);
                final events = controller.getEventsForDay(date);
                final isSelected = controller.selectedCalendarDate.value !=
                        null &&
                    _isSameDay(date, controller.selectedCalendarDate.value!);
                final isToday = _isSameDay(date, DateTime.now());

                return _CalendarDayCell(
                  date: date,
                  events: events,
                  isSelected: isSelected,
                  isToday: isToday,
                  controller: controller,
                  onTap: () => controller.selectCalendarDate(date),
                );
              },
            ),
          ],
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildMonthSummary() {
    return Obx(() {
      final focusedMonth = controller.focusedMonth.value;

      // Count events in this month
      int expiredCount = 0;
      int criticalCount = 0;
      int warningCount = 0;
      int upcomingCount = 0;

      controller.calendarEvents.forEach((date, event) {
        if (date.year == focusedMonth.year &&
            date.month == focusedMonth.month) {
          for (final item in event.items) {
            switch (item.status) {
              case ExpiryStatus.expired:
                expiredCount++;
                break;
              case ExpiryStatus.critical:
                criticalCount++;
                break;
              case ExpiryStatus.warning:
                warningCount++;
                break;
              case ExpiryStatus.upcoming:
                upcomingCount++;
                break;
              default:
                break;
            }
          }
        }
      });

      final totalThisMonth =
          expiredCount + criticalCount + warningCount + upcomingCount;

      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.borderMd,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _SummaryItem(
              label: 'Total',
              count: totalThisMonth,
              color: AppColors.textPrimary,
            ),
            _SummaryItem(
              label: 'Expired',
              count: expiredCount,
              color: AppColors.error,
            ),
            _SummaryItem(
              label: 'Critical',
              count: criticalCount,
              color: const Color(0xFFDC2626),
            ),
            _SummaryItem(
              label: 'Warning',
              count: warningCount,
              color: AppColors.warning,
            ),
          ],
        ),
      );
    });
  }

  // ==================== SELECTED DATE ITEMS ====================

  Widget _buildSelectedDateItems(BuildContext context) {
    return Obx(() {
      final selectedDate = controller.selectedCalendarDate.value;

      if (selectedDate == null) {
        return _buildNoDateSelected();
      }

      final items = controller.getEventsForDay(selectedDate);

      if (items.isEmpty) {
        return _buildNoEventsForDate(selectedDate);
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            margin: const EdgeInsets.only(top: AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              border: Border(
                bottom: BorderSide(color: AppColors.divider),
                top: BorderSide(color: AppColors.divider),
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
                    Icons.event,
                    color: AppColors.accent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, d MMMM yyyy').format(selectedDate),
                        style: AppTextStyles.h4,
                      ),
                      Text(
                        '${items.length} document${items.length == 1 ? '' : 's'} expiring',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: controller.clearCalendarSelection,
                  tooltip: 'Clear selection',
                ),
              ],
            ),
          ),

          // Items List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _CalendarEventCard(
                  item: item,
                  controller: controller,
                  onTap: () {
                    // controller.toggleCalendarView();
                    controller.selectExpiryItem(item);
                  },
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildNoDateSelected() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.touch_app,
              size: 64,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Select a Date',
              style: AppTextStyles.h4.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Tap on a date to see expiring documents',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoEventsForDate(DateTime date) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              size: 64,
              color: AppColors.success,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No Expirations',
              style: AppTextStyles.h4.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'No documents expire on ${DateFormat('d MMMM yyyy').format(date)}',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================
/// CALENDAR DAY CELL
/// ============================================================

class _CalendarDayCell extends StatelessWidget {
  final DateTime date;
  final List<ExpiryItem> events;
  final bool isSelected;
  final bool isToday;
  final ExpiryController controller;
  final VoidCallback onTap;

  const _CalendarDayCell({
    required this.date,
    required this.events,
    required this.isSelected,
    required this.isToday,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasEvents = events.isNotEmpty;
    final worstStatus = _getWorstStatus();
    final statusColor =
        worstStatus != null ? controller.getStatusColor(worstStatus) : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderMd,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.accent.withOpacity(0.15)
                : isToday
                    ? AppColors.surface
                    : null,
            borderRadius: AppRadius.borderMd,
            border: Border.all(
              color: isSelected
                  ? AppColors.accent
                  : isToday
                      ? AppColors.accent.withOpacity(0.5)
                      : Colors.transparent,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Date Number
              Text(
                '${date.day}',
                style: AppTextStyles.label.copyWith(
                  color: isSelected
                      ? AppColors.accent
                      : isToday
                          ? AppColors.accent
                          : AppColors.textPrimary,
                  fontWeight: isToday || isSelected
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),

              // Event Indicator
              if (hasEvents)
                Positioned(
                  bottom: 4,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (events.length > 1) ...[
                        const SizedBox(width: 2),
                        Text(
                          '+${events.length - 1}',
                          style: TextStyle(
                            fontSize: 8,
                            color: statusColor,
                            fontWeight: FontWeight.bold,
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

  ExpiryStatus? _getWorstStatus() {
    if (events.isEmpty) return null;

    if (events.any((e) => e.status == ExpiryStatus.expired)) {
      return ExpiryStatus.expired;
    }
    if (events.any((e) => e.status == ExpiryStatus.critical)) {
      return ExpiryStatus.critical;
    }
    if (events.any((e) => e.status == ExpiryStatus.warning)) {
      return ExpiryStatus.warning;
    }
    if (events.any((e) => e.status == ExpiryStatus.upcoming)) {
      return ExpiryStatus.upcoming;
    }
    return ExpiryStatus.valid;
  }
}

/// ============================================================
/// CALENDAR EVENT CARD
/// ============================================================

class _CalendarEventCard extends StatelessWidget {
  final ExpiryItem item;
  final ExpiryController controller;
  final VoidCallback onTap;

  const _CalendarEventCard({
    required this.item,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = controller.getStatusColor(item.status);
    final statusBgColor = controller.getStatusBgColor(item.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.borderMd,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: AppRadius.borderMd,
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                // Status Indicator
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: AppRadius.borderFull,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // Document Icon
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: AppRadius.borderSm,
                  ),
                  child: Icon(
                    Icons.description,
                    color: statusColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.vehicleNo,
                        style: AppTextStyles.label,
                      ),
                      Text(
                        item.documentTypeName ?? 'Document',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: AppRadius.borderSm,
                  ),
                  child: Text(
                    controller.getStatusLabel(item.status),
                    style: AppTextStyles.caption.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(width: AppSpacing.sm),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ============================================================
/// MONTH YEAR PICKER DIALOG
/// ============================================================

class _MonthYearPickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateSelected;

  const _MonthYearPickerDialog({
    required this.initialDate,
    required this.onDateSelected,
  });

  @override
  State<_MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends State<_MonthYearPickerDialog> {
  late int selectedYear;
  late int selectedMonth;

  @override
  void initState() {
    super.initState();
    selectedYear = widget.initialDate.year;
    selectedMonth = widget.initialDate.month;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text('Select Month', style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.lg),

            // Year Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => setState(() => selectedYear--),
                ),
                Text(
                  '$selectedYear',
                  style: AppTextStyles.h4,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => setState(() => selectedYear++),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Month Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final month = index + 1;
                final isSelected = month == selectedMonth;

                return InkWell(
                  onTap: () => setState(() => selectedMonth = month),
                  borderRadius: AppRadius.borderSm,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.accent : null,
                      borderRadius: AppRadius.borderSm,
                      border: Border.all(
                        color:
                            isSelected ? AppColors.accent : AppColors.divider,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      DateFormat('MMM').format(DateTime(2000, month)),
                      style: AppTextStyles.labelSmall.copyWith(
                        color:
                            isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: AppSpacing.sm),
                ElevatedButton(
                  onPressed: () {
                    widget.onDateSelected(
                        DateTime(selectedYear, selectedMonth, 1));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Select'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================
/// LEGEND ITEM
/// ============================================================

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.caption,
        ),
      ],
    );
  }
}

/// ============================================================
/// SUMMARY ITEM
/// ============================================================

class _SummaryItem extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: AppTextStyles.h3.copyWith(color: color),
        ),
        Text(
          label,
          style: AppTextStyles.caption,
        ),
      ],
    );
  }
}
