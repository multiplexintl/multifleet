import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multifleet/controllers/dashboard_controller.dart';
import 'package:multifleet/models/maintenance.dart';
import 'package:multifleet/models/vehicle_assignment_model.dart';
import 'package:multifleet/models/vehicle_docs.dart';
import 'package:multifleet/models/fine.dart';
import 'package:multifleet/theme/app_theme.dart';

/// ============================================================
/// DASHBOARD TABLES SECTION
/// ============================================================
/// Data tables for fleet management dashboard.
/// All data comes from DashboardController's real computed lists.
/// ============================================================

class DashboardTablesSection extends StatelessWidget {
  final DashboardController controller;
  final bool isMobile;
  final bool isTablet;

  const DashboardTablesSection({
    super.key,
    required this.controller,
    required this.isMobile,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Trigger rebuild on any list change.
      controller.maintenanceRecords.length;
      controller.documents.length;
      controller.fines.length;
      controller.assignments.length;

      if (isMobile) {
        return _buildMobileLayout();
      } else if (isTablet) {
        return _buildTabletLayout();
      } else {
        return _buildDesktopLayout();
      }
    });
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _UpcomingMaintenanceTable(controller: controller),
        const SizedBox(height: 16),
        _ExpiringDocumentsTable(controller: controller),
        const SizedBox(height: 16),
        _RecentFinesTable(controller: controller),
        const SizedBox(height: 16),
        _RecentAssignmentsTable(controller: controller),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _UpcomingMaintenanceTable(controller: controller)),
            const SizedBox(width: 16),
            Expanded(child: _ExpiringDocumentsTable(controller: controller)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _RecentFinesTable(controller: controller)),
            const SizedBox(width: 16),
            Expanded(child: _RecentAssignmentsTable(controller: controller)),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _UpcomingMaintenanceTable(controller: controller)),
            const SizedBox(width: 16),
            Expanded(child: _ExpiringDocumentsTable(controller: controller)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _RecentFinesTable(controller: controller)),
            const SizedBox(width: 16),
            Expanded(child: _RecentAssignmentsTable(controller: controller)),
          ],
        ),
      ],
    );
  }
}

// ==================== TABLE CARD WRAPPER ====================

class _TableCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final String? badge;
  final Color? badgeColor;
  final VoidCallback? onViewAll;
  final Widget child;

  const _TableCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    this.badge,
    this.badgeColor,
    this.onViewAll,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.1),
                        borderRadius: AppRadius.borderMd,
                      ),
                      child: Icon(icon, size: 18, color: iconColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.h4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (badge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (badgeColor ?? AppColors.accent)
                              .withOpacity(0.1),
                          borderRadius: AppRadius.borderFull,
                        ),
                        child: Text(
                          badge!,
                          style: AppTextStyles.caption.copyWith(
                            color: badgeColor ?? AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const Spacer(),
                    if (onViewAll != null)
                      TextButton(
                        onPressed: onViewAll,
                        style: TextButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'View All',
                          style: AppTextStyles.labelSmall
                              .copyWith(color: AppColors.accent),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          child,
        ],
      ),
    );
  }
}

Widget _emptyState(IconData icon, String message) {
  return Padding(
    padding: const EdgeInsets.all(24),
    child: Center(
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppColors.success.withOpacity(0.5)),
          const SizedBox(height: 8),
          Text(
            message,
            style:
                AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    ),
  );
}

// ==================== UPCOMING MAINTENANCE TABLE ====================

class _UpcomingMaintenanceTable extends StatelessWidget {
  final DashboardController controller;

  const _UpcomingMaintenanceTable({required this.controller});

  @override
  Widget build(BuildContext context) {
    final data = controller.scheduledMaintenanceRecords;

    return _TableCard(
      title: 'Upcoming Maintenance',
      icon: Icons.build_outlined,
      iconColor: AppColors.warning,
      badge: data.isNotEmpty ? '${data.length} scheduled' : null,
      badgeColor: AppColors.warning,
      onViewAll: controller.navigateToMaintenance,
      child: data.isEmpty
          ? _emptyState(Icons.check_circle_outline, 'No scheduled maintenance')
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) =>
                  _MaintenanceRow(item: data[i], controller: controller),
            ),
    );
  }
}

class _MaintenanceRow extends StatelessWidget {
  final MaintenanceRecord item;
  final DashboardController controller;

  const _MaintenanceRow({required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => controller.navigateToVehicleDetail(item.vehicleNo),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.warning,
                borderRadius: AppRadius.borderFull,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.vehicleNo ?? '-',
                    style: AppTextStyles.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.maintenanceType ?? '-',
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.vendorName ?? '-',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  controller.formatDateTime(item.serviceDate),
                  style: AppTextStyles.caption,
                  maxLines: 1,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== EXPIRING DOCUMENTS TABLE ====================

class _ExpiringDocumentsTable extends StatelessWidget {
  final DashboardController controller;

  const _ExpiringDocumentsTable({required this.controller});

  @override
  Widget build(BuildContext context) {
    final data = controller.docsExpiringForTable;
    final expiredCount =
        data.where((d) => d.expiryDate?.isBefore(DateTime.now()) ?? false).length;

    return _TableCard(
      title: 'Expiring Documents',
      icon: Icons.description_outlined,
      iconColor: AppColors.error,
      badge: expiredCount > 0 ? '$expiredCount expired' : null,
      badgeColor: AppColors.error,
      onViewAll: controller.navigateToExpiry,
      child: data.isEmpty
          ? _emptyState(Icons.verified_outlined, 'All documents valid')
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) =>
                  _ExpiryRow(item: data[i], controller: controller),
            ),
    );
  }
}

class _ExpiryRow extends StatelessWidget {
  final VehicleDocument item;
  final DashboardController controller;

  const _ExpiryRow({required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isExpired = item.expiryDate?.isBefore(now) ?? false;
    final daysLeft = item.expiryDate?.difference(now).inDays;
    final color = controller.expiryColor(item);

    return InkWell(
      onTap: () => controller.navigateToVehicleDetail(item.vehicleNo),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: AppRadius.borderSm,
              ),
              child: Icon(
                isExpired ? Icons.error_outline : Icons.schedule,
                size: 16,
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.vehicleNo ?? '-',
                    style: AppTextStyles.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.status ?? '-',
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: AppRadius.borderSm,
                    ),
                    child: Text(
                      isExpired
                          ? 'Expired'
                          : daysLeft == 0
                              ? 'Today'
                              : '${daysLeft}d left',
                      style: AppTextStyles.caption.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.expiryDate != null
                        ? controller.formatDateTime(item.expiryDate)
                        : '-',
                    style: AppTextStyles.caption,
                    maxLines: 1,
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

// ==================== RECENT FINES TABLE ====================

class _RecentFinesTable extends StatelessWidget {
  final DashboardController controller;

  const _RecentFinesTable({required this.controller});

  @override
  Widget build(BuildContext context) {
    final data = controller.recentFines;
    final unpaidCount = controller.unpaidFines.length;

    return _TableCard(
      title: 'Recent Fines',
      icon: Icons.receipt_long_outlined,
      iconColor: AppColors.error,
      badge: unpaidCount > 0 ? '$unpaidCount unpaid' : null,
      badgeColor: AppColors.error,
      onViewAll: controller.navigateToFines,
      child: data.isEmpty
          ? _emptyState(Icons.thumb_up_outlined, 'No recent fines')
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) =>
                  _FineRow(item: data[i], controller: controller),
            ),
    );
  }
}

class _FineRow extends StatelessWidget {
  final Fine item;
  final DashboardController controller;

  const _FineRow({required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    final statusStr = item.status?.status ?? '-';
    final statusColor = controller.getStatusColor(statusStr);
    final typeStr = item.fineType?.fineType ?? '-';

    return InkWell(
      onTap: () => controller.navigateToFineDetail(item.fineId),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 70,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: _fineTypeColor(typeStr).withOpacity(0.1),
                borderRadius: AppRadius.borderSm,
              ),
              child: Text(
                typeStr,
                style: AppTextStyles.caption.copyWith(
                  color: _fineTypeColor(typeStr),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.vehicleNo ?? '-',
                    style: AppTextStyles.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.empName?.isNotEmpty == true
                        ? item.empName!
                        : (item.ticketNo ?? '-'),
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.amount != null
                      ? 'AED ${item.amount!.toStringAsFixed(0)}'
                      : '-',
                  style: AppTextStyles.label.copyWith(
                    color: statusStr.toLowerCase() == 'unpaid'
                        ? AppColors.error
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: AppRadius.borderSm,
                  ),
                  child: Text(
                    statusStr,
                    style: AppTextStyles.caption.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _fineTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'traffic':
        return AppColors.error;
      case 'parking':
        return AppColors.info;
      case 'salik':
        return const Color(0xFF8B5CF6);
      case 'speeding':
        return const Color(0xFFF97316);
      default:
        return AppColors.textSecondary;
    }
  }
}

// ==================== RECENT ASSIGNMENTS TABLE ====================

class _RecentAssignmentsTable extends StatelessWidget {
  final DashboardController controller;

  const _RecentAssignmentsTable({required this.controller});

  @override
  Widget build(BuildContext context) {
    final data = controller.recentAssignments;
    final activeCount = data
        .where((a) => a.status?.status?.toLowerCase() == 'assigned')
        .length;

    return _TableCard(
      title: 'Recent Assignments',
      icon: Icons.assignment_ind_outlined,
      iconColor: AppColors.accent,
      badge: activeCount > 0 ? '$activeCount active' : null,
      badgeColor: AppColors.success,
      onViewAll: controller.goToAssignments,
      child: data.isEmpty
          ? _emptyState(Icons.hourglass_empty, 'No recent assignments')
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) =>
                  _AssignmentRow(item: data[i], controller: controller),
            ),
    );
  }
}

class _AssignmentRow extends StatelessWidget {
  final VehicleAssignment item;
  final DashboardController controller;

  const _AssignmentRow({required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    final statusStr = item.status?.status ?? '-';
    final isAssigned = statusStr.toLowerCase() == 'assigned';

    return InkWell(
      onTap: () => controller.navigateToVehicleDetail(item.vehicleNo),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _initials(item.empName),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.empName ?? '-',
                          style: AppTextStyles.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isAssigned) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: AppRadius.borderSm,
                          ),
                          child: Text(
                            'ACTIVE',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.empNo ?? '-',
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.vehicleNo ?? '-',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.accent),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  controller.getTimeAgo(item.assignedDate),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}
