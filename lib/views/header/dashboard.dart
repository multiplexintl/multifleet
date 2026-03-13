import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multifleet/controllers/dashboard_controller.dart';
import 'package:multifleet/models/fine.dart';
import 'package:multifleet/models/maintenance.dart';
import 'package:multifleet/models/vehicle_assignment_model.dart';
import 'package:multifleet/models/vehicle_docs.dart';
import 'package:multifleet/theme/app_theme.dart';
import 'package:multifleet/widgets/dashboard_charts.dart';
import 'package:multifleet/widgets/dashboard_tables.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accent,
          onRefresh: () => controller.refresh(),
          child: LayoutBuilder(builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 900;
            final isTablet =
                constraints.maxWidth >= 600 && constraints.maxWidth < 900;
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(controller, isDesktop)),
                SliverPadding(
                  padding:
                      EdgeInsets.all(isDesktop ? AppSpacing.xl : AppSpacing.lg),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Fleet KPIs ──────────────────────────
                        _buildFleetKpis(controller, isDesktop, isTablet),
                        const SizedBox(height: AppSpacing.xl),

                        // ── Mid row: Expiry alerts + Fines ──────
                        if (isDesktop)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _buildExpirySection(controller)),
                              const SizedBox(width: AppSpacing.xl),
                              Expanded(child: _buildFinesSection(controller)),
                            ],
                          )
                        else
                          Column(
                            children: [
                              _buildExpirySection(controller),
                              const SizedBox(height: AppSpacing.xl),
                              _buildFinesSection(controller),
                            ],
                          ),
                        const SizedBox(height: AppSpacing.xl),

                        // ── Charts ──────────────────────────────
                        _buildSectionLabel('Analytics & Trends'),
                        const SizedBox(height: AppSpacing.md),
                        DashboardChartsSection(
                          controller: controller,
                          isMobile: !isDesktop && !isTablet,
                          isTablet: isTablet,
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // ── Tables ──────────────────────────────
                        _buildSectionLabel('Data Tables'),
                        const SizedBox(height: AppSpacing.md),
                        DashboardTablesSection(
                          controller: controller,
                          isMobile: !isDesktop && !isTablet,
                          isTablet: isTablet,
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // ── Recent Assignments ──────────────────
                        _buildAssignmentsSection(controller, isDesktop),
                        const SizedBox(height: AppSpacing.xl),

                        // ── Maintenance ─────────────────────────
                        _buildMaintenanceSection(controller, isDesktop),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(DashboardController controller, bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? AppSpacing.xl : AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.sidebarBg,
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fleet Dashboard', style: AppTextStyles.h3),
                Obx(() {
                  final company = controller.companyService.selectedCompany;
                  return Text(
                    company?.name ?? '',
                    style: AppTextStyles.caption,
                  );
                }),
              ],
            ),
          ),
          Obx(() {
            final loading = controller.isLoading;
            return IconButton(
              onPressed: loading ? null : () => controller.refresh(),
              icon: loading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.accent),
                    )
                  : Icon(Icons.refresh, color: AppColors.accent),
              tooltip: 'Refresh',
            );
          }),
        ],
      ),
    );
  }

  // ============================================================
  // FLEET KPI CARDS
  // ============================================================

  Widget _buildFleetKpis(
      DashboardController controller, bool isDesktop, bool isTablet) {
    return Obx(() {
      final loading = controller.isLoadingVehicles.value;

      final cards = [
        _KpiData(
          title: 'Total Vehicles',
          value: loading ? '—' : controller.totalVehicles.toString(),
          icon: Icons.directions_car,
          color: AppColors.accent,
          subtitle: 'In fleet',
          onTap: controller.goToVehicles,
        ),
        _KpiData(
          title: 'Active',
          value: loading ? '—' : controller.activeVehicles.toString(),
          icon: Icons.check_circle_outline,
          color: AppColors.success,
          subtitle: 'On the road',
          onTap: controller.goToVehicles,
        ),
        _KpiData(
          title: 'Unassigned',
          value: loading ? '—' : controller.unassignedVehicles.toString(),
          icon: Icons.person_off_outlined,
          color: AppColors.warning,
          subtitle: 'No driver',
          onTap: controller.goToAssignments,
        ),
        _KpiData(
          title: 'In Maintenance',
          value: loading ? '—' : controller.underMaintenance.toString(),
          icon: Icons.build_outlined,
          color: AppColors.error,
          subtitle: 'Under service',
          onTap: controller.goToMaintenance,
        ),
      ];

      final crossAxisCount = isDesktop ? 4 : (isTablet ? 4 : 2);

      return GridView.count(
        crossAxisCount: crossAxisCount,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: AppSpacing.lg,
        mainAxisSpacing: AppSpacing.lg,
        childAspectRatio: isDesktop ? 2.2 : (isTablet ? 2 : 1.8),
        children: cards.map((d) => _buildKpiCard(d)).toList(),
      );
    });
  }

  Widget _buildKpiCard(_KpiData d) {
    return AppCard(
      onTap: d.onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: d.color.withOpacity(0.1),
              borderRadius: AppRadius.borderMd,
            ),
            child: Icon(d.icon, color: d.color, size: 22),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(d.title,
                    style: AppTextStyles.labelSmall,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(d.value, style: AppTextStyles.h3.copyWith(color: d.color)),
                if (d.subtitle != null)
                  Text(d.subtitle!,
                      style: AppTextStyles.caption,
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (d.onTap != null)
            Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
        ],
      ),
    );
  }

  // ============================================================
  // EXPIRY ALERTS SECTION
  // ============================================================

  Widget _buildExpirySection(DashboardController controller) {
    return Obx(() {
      final loading = controller.isLoadingDocs.value;
      final expired = controller.expiredDocs;
      final week = controller.expiringThisWeek;
      final month = controller.expiringThisMonth;

      return _buildSection(
        title: 'Document Expiry Alerts',
        icon: Icons.warning_amber_rounded,
        iconColor: AppColors.error,
        onViewAll: controller.goToExpiry,
        isLoading: loading,
        child: expired.isEmpty && week.isEmpty && month.isEmpty
            ? _buildEmptyRow(Icons.verified_outlined, 'All documents are valid',
                AppColors.success)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (expired.isNotEmpty)
                    _buildAlertRow(
                      icon: Icons.cancel_outlined,
                      color: AppColors.error,
                      label: 'Expired',
                      count: expired.length,
                      vehicles: expired
                          .map((d) => d.vehicleNo ?? '')
                          .toSet()
                          .take(3)
                          .join(', '),
                    ),
                  if (week.isNotEmpty) ...[
                    if (expired.isNotEmpty)
                      Divider(height: 1, color: AppColors.divider),
                    _buildAlertRow(
                      icon: Icons.timelapse,
                      color: AppColors.warning,
                      label: 'Expiring this week',
                      count: week.length,
                      vehicles: week
                          .map((d) => d.vehicleNo ?? '')
                          .toSet()
                          .take(3)
                          .join(', '),
                    ),
                  ],
                  if (month.isNotEmpty) ...[
                    Divider(height: 1, color: AppColors.divider),
                    _buildAlertRow(
                      icon: Icons.event_outlined,
                      color: AppColors.accent,
                      label: 'Expiring this month',
                      count: month.length,
                      vehicles: month
                          .map((d) => d.vehicleNo ?? '')
                          .toSet()
                          .take(3)
                          .join(', '),
                    ),
                  ],
                  if (expired.isNotEmpty || week.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    Divider(height: 1, color: AppColors.divider),
                    const SizedBox(height: AppSpacing.sm),
                    ..._urgentDocs(expired, week)
                        .map((d) => _buildDocRow(controller, d)),
                  ],
                ],
              ),
      );
    });
  }

  List<VehicleDocument> _urgentDocs(
      List<VehicleDocument> expired, List<VehicleDocument> week) {
    return [...expired, ...week].take(3).toList();
  }

  Widget _buildAlertRow({
    required IconData icon,
    required Color color,
    required String label,
    required int count,
    required String vehicles,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: AppRadius.borderSm,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.label),
                if (vehicles.isNotEmpty)
                  Text(vehicles,
                      style: AppTextStyles.caption,
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('$count',
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w700, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildDocRow(DashboardController controller, VehicleDocument doc) {
    final color = controller.expiryColor(doc);
    final daysLeft = doc.expiryDate?.difference(DateTime.now()).inDays;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              doc.vehicleNo ?? '-',
              style: AppTextStyles.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            daysLeft == null
                ? '-'
                : daysLeft < 0
                    ? '${daysLeft.abs()}d overdue'
                    : '${daysLeft}d left',
            style: AppTextStyles.caption.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FINES SECTION
  // ============================================================

  Widget _buildFinesSection(DashboardController controller) {
    return Obx(() {
      final loading = controller.isLoadingFines.value;
      final recent = controller.recentFines;
      final topVehicles = controller.topFinedVehicles;

      return _buildSection(
        title: 'Fines Overview',
        icon: Icons.receipt_long,
        iconColor: AppColors.warning,
        onViewAll: controller.goToFines,
        isLoading: loading,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildMiniKpi(
                  'Total Fines',
                  controller.totalFines.toString(),
                  AppColors.textPrimary,
                ),
                const SizedBox(width: AppSpacing.lg),
                _buildMiniKpi(
                  'Unpaid',
                  controller.unpaidFines.length.toString(),
                  AppColors.error,
                ),
                const SizedBox(width: AppSpacing.lg),
                Flexible(
                  child: _buildMiniKpi(
                    'Unpaid Amount',
                    controller.formatCompact(controller.unpaidFineAmount),
                    AppColors.error,
                  ),
                ),
              ],
            ),
            if (topVehicles.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: AppSpacing.sm),
              Text('Top Fined Vehicles', style: AppTextStyles.labelSmall),
              const SizedBox(height: AppSpacing.sm),
              ...topVehicles.map((e) => _buildTopVehicleRow(e)),
            ],
            if (recent.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: AppSpacing.sm),
              Text('Recent Fines', style: AppTextStyles.labelSmall),
              const SizedBox(height: AppSpacing.sm),
              ...recent.map((f) => _buildFineRow(controller, f)),
            ],
            if (controller.totalFines == 0 && !loading)
              _buildEmptyRow(Icons.check_circle_outline, 'No fines recorded',
                  AppColors.success),
          ],
        ),
      );
    });
  }

  Widget _buildMiniKpi(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AppTextStyles.h4.copyWith(color: color)),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildTopVehicleRow(MapEntry<String, int> entry) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration:
                BoxDecoration(color: AppColors.warning, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
              child: Text(entry.key,
                  style: AppTextStyles.bodySmall,
                  overflow: TextOverflow.ellipsis)),
          Text('${entry.value} fine${entry.value == 1 ? '' : 's'}',
              style: AppTextStyles.caption.copyWith(color: AppColors.warning)),
        ],
      ),
    );
  }

  Widget _buildFineRow(DashboardController controller, Fine fine) {
    final color = controller.fineStatusColor(fine.status?.status);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(fine.vehicleNo ?? '-',
                style: AppTextStyles.label, overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            flex: 2,
            child: Text(fine.fineType?.fineType ?? '-',
                style: AppTextStyles.bodySmall,
                overflow: TextOverflow.ellipsis),
          ),
          Text(
            fine.amount != null
                ? 'AED ${fine.amount!.toStringAsFixed(0)}'
                : '-',
            style:
                AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              fine.status?.status ?? '-',
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RECENT ASSIGNMENTS
  // ============================================================

  Widget _buildAssignmentsSection(
      DashboardController controller, bool isDesktop) {
    return Obx(() {
      final loading = controller.isLoadingAssignments.value;
      final recent = controller.recentAssignments;

      return _buildSection(
        title: 'Recent Assignments',
        icon: Icons.swap_horiz,
        iconColor: AppColors.accent,
        onViewAll: controller.goToAssignments,
        isLoading: loading,
        child: recent.isEmpty
            ? _buildEmptyRow(
                Icons.people_outline, 'No assignments yet', AppColors.textMuted)
            : ClipRRect(
                borderRadius: AppRadius.borderMd,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 20,
                    headingRowColor: WidgetStateProperty.all(AppColors.surface),
                    headingTextStyle: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.textSecondary),
                    columns: const [
                      DataColumn(label: Text('Vehicle')),
                      DataColumn(label: Text('Employee')),
                      DataColumn(label: Text('Designation')),
                      DataColumn(label: Text('Assigned')),
                      DataColumn(label: Text('Returned')),
                      DataColumn(label: Text('Status')),
                    ],
                    rows: recent
                        .map((a) => _assignmentRow(controller, a))
                        .toList(),
                  ),
                ),
              ),
      );
    });
  }

  DataRow _assignmentRow(DashboardController controller, VehicleAssignment a) {
    final status = a.status?.status ?? '-';
    final isActive =
        status.toLowerCase() == 'active' || status.toLowerCase() == 'assigned';
    final statusColor = isActive ? AppColors.success : AppColors.textMuted;

    return DataRow(cells: [
      DataCell(Text(a.vehicleNo ?? '-', style: AppTextStyles.label)),
      DataCell(Text(a.empName ?? '-', overflow: TextOverflow.ellipsis)),
      DataCell(Text(a.designation ?? '-',
          style: AppTextStyles.bodySmall, overflow: TextOverflow.ellipsis)),
      DataCell(Text(controller.formatDate(a.assignedDate))),
      DataCell(Text((a.returnDate?.isNotEmpty ?? false)
          ? controller.formatDate(a.returnDate)
          : '—')),
      DataCell(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(status,
              style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ),
      ),
    ]);
  }

  // ============================================================
  // MAINTENANCE SECTION
  // ============================================================

  Widget _buildMaintenanceSection(
      DashboardController controller, bool isDesktop) {
    return Obx(() {
      final loading = controller.isLoadingMaintenance.value;
      final recent = controller.recentMaintenance;

      return _buildSection(
        title: 'Maintenance Overview',
        icon: Icons.build_outlined,
        iconColor: AppColors.accent,
        onViewAll: controller.goToMaintenance,
        isLoading: loading,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildMiniKpi(
                    'Scheduled',
                    controller.scheduledMaintenance.toString(),
                    AppColors.warning),
                const SizedBox(width: AppSpacing.lg),
                _buildMiniKpi('Completed',
                    controller.closedMaintenance.toString(), AppColors.success),
                const SizedBox(width: AppSpacing.lg),
                Flexible(
                  child: _buildMiniKpi(
                      'Total Spend',
                      controller
                          .formatCompact(controller.totalMaintenanceSpend),
                      AppColors.accent),
                ),
              ],
            ),
            if (recent.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: AppSpacing.sm),
              Text('Recent Records', style: AppTextStyles.labelSmall),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: AppRadius.borderMd,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 20,
                    headingRowColor: WidgetStateProperty.all(AppColors.surface),
                    headingTextStyle: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.textSecondary),
                    columns: const [
                      DataColumn(label: Text('Vehicle')),
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Service Type')),
                      DataColumn(label: Text('Vendor')),
                      DataColumn(label: Text('Amount'), numeric: true),
                      DataColumn(label: Text('Status')),
                    ],
                    rows: recent
                        .map((r) => _maintenanceRow(controller, r))
                        .toList(),
                  ),
                ),
              ),
            ],
            if (controller.maintenanceRecords.isEmpty && !loading)
              _buildEmptyRow(Icons.build_circle_outlined,
                  'No maintenance records', AppColors.textMuted),
          ],
        ),
      );
    });
  }

  DataRow _maintenanceRow(DashboardController controller, MaintenanceRecord r) {
    final color = controller.maintenanceStatusColor(r.status);
    return DataRow(cells: [
      DataCell(Text(r.vehicleNo ?? '-', style: AppTextStyles.label)),
      DataCell(Text(controller.formatDateTime(r.serviceDate))),
      DataCell(Text(r.maintenanceType ?? '-', overflow: TextOverflow.ellipsis)),
      DataCell(Text(r.vendorName ?? '-',
          style: AppTextStyles.bodySmall, overflow: TextOverflow.ellipsis)),
      DataCell(Text(controller.formatAmount(r.amount))),
      DataCell(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(r.status ?? '-',
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ),
      ),
    ]);
  }

  // ============================================================
  // SHARED HELPERS
  // ============================================================

  Widget _buildSectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: AppRadius.borderFull,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(label, style: AppTextStyles.h4),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
    required bool isLoading,
    VoidCallback? onViewAll,
  }) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: AppRadius.borderSm,
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(title,
                    style: AppTextStyles.h4, overflow: TextOverflow.ellipsis),
              ),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('View All',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.accent)),
                      const SizedBox(width: 2),
                      Icon(Icons.arrow_forward,
                          size: 14, color: AppColors.accent),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: AppSpacing.md),
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: CircularProgressIndicator(),
              ),
            )
          else
            child,
        ],
      ),
    );
  }

  Widget _buildEmptyRow(IconData icon, String message, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(message,
                style: AppTextStyles.bodySmall.copyWith(color: color),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// INTERNAL DATA CLASSES
// ============================================================

class _KpiData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final VoidCallback? onTap;

  const _KpiData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.onTap,
  });
}
