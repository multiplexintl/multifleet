import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:multifleet/models/notification/lst_doc_expiry.dart';
import 'package:multifleet/models/notification/lst_odo_reminder.dart';
import 'package:multifleet/models/notification/lst_service_reminder.dart';
import 'package:multifleet/models/notification/lst_unpaid_fine.dart';
import 'package:multifleet/models/vehicle_maintenance/vehicle_maintenance.dart';
import 'package:multifleet/routes.dart';
import 'package:multifleet/services/company_service.dart';
import 'package:multifleet/theme/app_theme.dart';

import 'package:multifleet/views/edit_vehicle.dart';
import 'package:multifleet/views/assigned_vehicle_page.dart';
import 'package:multifleet/views/expiry_page.dart';
import 'package:multifleet/views/header/dashboard.dart';
import 'package:multifleet/views/header/reports.dart';
import 'package:multifleet/views/maintainace_page.dart';
import 'package:multifleet/views/vehicle_assignment_view.dart';
import 'package:multifleet/views/vehicles_listing.dart';

import '../controllers/home_controller.dart';
import '../models/company.dart';
import '../services/theme_service.dart';
import 'fine_page.dart';
import 'header/profile.dart';
import 'header/settings/settings.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeScreenController>();
    final isMobile = AppBreakpoints.isMobile(context);
    final isTablet = AppBreakpoints.isTablet(context);
    final isDesktop = AppBreakpoints.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      drawer: isMobile ? _buildMobileDrawer(context, controller) : null,
      endDrawer:
          !isMobile && !isDesktop ? _buildEndDrawer(context, controller) : null,
      body: Column(
        children: [
          // Header
          _buildHeader(context, controller, isMobile, isDesktop),

          // Main Content
          Expanded(
            child: Row(
              children: [
                // Sidebar (tablet & desktop)
                if (!isMobile) _buildSidebar(context, controller, isTablet),

                // Main Content Area
                Expanded(
                  child: Obx(() => AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.02, 0),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: controller.currentHeaderIndex.value > 0
                            ? _buildHeaderContent(
                                controller.currentHeaderIndex.value)
                            : _buildMainContent(
                                controller.currentSidebarIndex.value),
                      )),
                ),

                // Right Panel (tablet & desktop)
                if (!isMobile) _buildRightPanel(context, controller, isTablet),
              ],
            ),
          ),

          // Footer
          _buildFooter(context),
        ],
      ),
    );
  }

  // ==================== HEADER ====================

  Widget _buildHeader(
    BuildContext context,
    HomeScreenController controller,
    bool isMobile,
    bool isDesktop,
  ) {
    final companyService = Get.find<CompanyService>();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 20,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Menu button (mobile)
            if (isMobile)
              IconButton(
                icon: const Icon(Icons.menu_rounded, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),

            // Company Dropdown (tablet & desktop)
            if (!isMobile)
              Container(
                width: 320,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: AppRadius.borderMd,
                ),
                child: Obx(() => _buildCompanyDropdown(companyService)),
              ),

            const SizedBox(width: 16),

            // Logo
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.2),
                    borderRadius: AppRadius.borderSm,
                  ),
                  child: Icon(
                    Icons.directions_car_rounded,
                    color: AppColors.accentLight,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  isMobile ? 'MultiFleet' : 'MultiFleet',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Header Navigation (desktop)
            if (isDesktop) ...[
              _buildHeaderNav(controller),
              const SizedBox(width: 16),
              _buildUserMenu(controller),
            ],

            // Menu button (tablet)
            if (!isMobile && !isDesktop)
              IconButton(
                icon: const Icon(Icons.menu_open_rounded, color: Colors.white),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyDropdown(CompanyService companyService) {
    return DropdownButtonFormField<Company>(
      value: companyService.selectedCompanyObs.value,
      items: companyService.companyList
          .map((company) => DropdownMenuItem(
                value: company,
                child: Text(
                  company.name ?? '',
                  style: AppTextStyles.body,
                  overflow: TextOverflow.ellipsis,
                ),
              ))
          .toList(),
      onChanged: (val) => companyService.selectCompany(val!),
      decoration: InputDecoration(
        prefixIcon:
            Icon(Icons.apartment_rounded, color: AppColors.accent, size: 20),
        border: InputBorder.none,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        isDense: true,
        isCollapsed: true,
      ),
      iconSize: 25,
      dropdownColor: AppColors.cardBg,
      borderRadius: AppRadius.borderMd,
      isExpanded: true,
      icon: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Icon(Icons.keyboard_arrow_down, color: AppColors.primaryMuted),
      ),
    );
  }

  Widget _buildHeaderNav(HomeScreenController controller) {
    return Obx(() => Row(
          children: [
            _headerNavItem(
                'Dashboard', Icons.dashboard_outlined, 2, controller),
            _headerNavItem('Reports', Icons.bar_chart_outlined, 3, controller),
            _headerNavItem('Settings', Icons.settings_outlined, 4, controller),
            _headerNavItem('Profile', Icons.person_outline, 5, controller),
          ],
        ));
  }

  Widget _headerNavItem(
      String title, IconData icon, int index, HomeScreenController controller) {
    final isActive = controller.currentHeaderIndex.value == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.changeHeaderPage(index),
          borderRadius: AppRadius.borderSm,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: AppRadius.borderSm,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isActive ? AppColors.accentLight : Colors.white70,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.white70,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserMenu(HomeScreenController controller) {
    return Obx(() => PopupMenuButton<String>(
          offset: const Offset(0, 45),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
          color: AppColors.cardBg,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: AppRadius.borderSm,
            ),
            child: const Row(
              children: [
                Icon(Icons.account_circle_outlined,
                    color: Colors.white, size: 20),
                SizedBox(width: 6),
                Text(
                  'Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 18),
              ],
            ),
          ),
          itemBuilder: (context) => [
            _popupMenuItem('Profile', Icons.person_outline, () {
              controller.changeHeaderPage(5);
            }),
            _popupMenuItem('Settings', Icons.settings_outlined, () {
              controller.changeHeaderPage(4);
            }),
            const PopupMenuDivider(),
            _popupMenuItem('Logout', Icons.logout, () {
              Get.offAllNamed(RouteLinks.login);
            }, isDestructive: true),
          ],
        ));
  }

  PopupMenuItem<String> _popupMenuItem(
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return PopupMenuItem(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isDestructive ? AppColors.error : AppColors.textSecondary,
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              color: isDestructive ? AppColors.error : AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== SIDEBAR ====================

  Widget _buildSidebar(
      BuildContext context, HomeScreenController controller, bool isTablet) {
    final sidebarWidth = isTablet ? 70.0 : 240.0;

    return Obx(() => Container(
          width: sidebarWidth,
          decoration: BoxDecoration(
            color: AppColors.sidebarBg,
            border: Border(
              right: BorderSide(color: AppColors.divider, width: 1),
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  children: [
                    _sidebarItem(
                      icon: Icons.directions_car_rounded,
                      title: 'Vehicle Listing',
                      index: 0,
                      controller: controller,
                      isCompact: isTablet,
                    ),
                    _sidebarItem(
                      icon: Icons.add_circle_outline,
                      title: 'Add/Edit Vehicles',
                      index: 1,
                      controller: controller,
                      isCompact: isTablet,
                    ),
                    _sidebarItem(
                      icon: Icons.assignment_outlined,
                      title: 'Vehicle Assignment',
                      index: 2,
                      controller: controller,
                      isCompact: isTablet,
                    ),
                    _sidebarItem(
                      icon: Icons.people_outline,
                      title: 'Assigned Vehicles',
                      index: 3,
                      controller: controller,
                      isCompact: isTablet,
                    ),
                    _sidebarItem(
                      icon: Icons.receipt_long_outlined,
                      title: 'Add Fine',
                      index: 4,
                      controller: controller,
                      isCompact: isTablet,
                    ),
                    _sidebarItem(
                      icon: Icons.event_outlined,
                      title: 'Expiry Details',
                      index: 5,
                      controller: controller,
                      isCompact: isTablet,
                    ),
                    _sidebarItem(
                      icon: Icons.build_outlined,
                      title: 'Service & Maintenance',
                      index: 6,
                      controller: controller,
                      isCompact: isTablet,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget _sidebarItem({
    required IconData icon,
    required String title,
    required int index,
    required HomeScreenController controller,
    required bool isCompact,
  }) {
    return Obx(() {
      final isActive = controller.currentSidebarIndex.value == index &&
          controller.currentHeaderIndex.value == 0;

      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              controller.changeHeaderPage(0);
              controller.changeSidebarPage(index);
            },
            borderRadius: AppRadius.borderMd,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 0 : 14,
                vertical: isCompact ? 14 : 12,
              ),
              decoration: BoxDecoration(
                color: isActive ? AppColors.accent : Colors.transparent,
                borderRadius: AppRadius.borderMd,
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: isCompact
                  ? Tooltip(
                      message: title,
                      child: Icon(
                        icon,
                        color: isActive ? Colors.white : AppColors.primaryMuted,
                        size: 22,
                      ),
                    )
                  : Row(
                      children: [
                        Icon(
                          icon,
                          color:
                              isActive ? Colors.white : AppColors.primaryMuted,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: isActive
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontWeight:
                                  isActive ? FontWeight.w600 : FontWeight.w500,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      );
    });
  }

  // ==================== RIGHT PANEL ====================

  Widget _buildRightPanel(
      BuildContext context, HomeScreenController controller, bool isTablet) {
    final panelWidth = isTablet ? 220.0 : 280.0;

    return Obx(() => Container(
          width: panelWidth,
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            border: Border(
              left: BorderSide(color: AppColors.divider, width: 1),
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Section Title
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Alerts & Reminders',
                  style: AppTextStyles.h4,
                ),
              ),

              // Insurance Expiry Alert
              AppAlertCard(
                icon: Icons.verified_user_outlined,
                title: 'Insurance Expiry',
                content:
                    '${controller.expiryInsuranceVehicles} vehicles near expiry',
                color: AppColors.warning,
                onTap: () => _showDocExpiryDialog(
                    'Insurance Expiry', controller, 'insurance'),
              ),
              const SizedBox(height: 12),

              // Mulkiya Expiry Alert
              AppAlertCard(
                icon: Icons.description_outlined,
                title: 'Mulkiya Expiry',
                content:
                    '${controller.expiryMulkiyaVehicles} vehicles near expiry',
                color: AppColors.info,
                onTap: () => _showDocExpiryDialog(
                    'Mulkiya Expiry', controller, 'mulkiya'),
              ),
              const SizedBox(height: 12),

              // KM Approaching Alert
              AppAlertCard(
                icon: Icons.speed_outlined,
                title: 'ODO Reminder',
                content:
                    '${controller.kmApproachingVehicles} vehicles approaching',
                color: AppColors.error,
                onTap: () => _showOdoReminderDialog(controller),
              ),
              const SizedBox(height: 12),

              // Service Due Alert
              AppAlertCard(
                icon: Icons.build_circle_outlined,
                title: 'Service Due',
                content:
                    '${controller.serviceDueVehicles} vehicles need service',
                color: AppColors.success,
                onTap: () => _showServiceReminderDialog(controller),
              ),
              const SizedBox(height: 12),

              // Unpaid Fines Alert
              AppAlertCard(
                icon: Icons.receipt_long_outlined,
                title: 'Unpaid Fines',
                content: '${controller.unpaidFinesCount} unpaid fines',
                color: AppColors.error,
                onTap: () => _showUnpaidFinesDialog(controller),
              ),

              if (!isTablet) ...[
                const SizedBox(height: 24),
                // Today's Maintenance Section
                _buildTodayMaintenanceSection(controller),
              ],
            ],
          ),
        ));
  }

  Widget _buildTodayMaintenanceSection(HomeScreenController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderLg,
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
                child: Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.accent,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Today's Maintenance", style: AppTextStyles.label),
                  // here show the selected company name
                  Text(
                      "In ${controller.companyService.selectedCompanyObs.value?.shortName ?? ""}",
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textMuted,
                      )),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.todayScheduledMaintenance.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.check_circle_outline,
                          color: AppColors.success.withOpacity(0.5), size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'No maintenance scheduled',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: controller.todayScheduledMaintenance
                  .map((m) => _buildMaintenanceItem(m))
                  .toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMaintenanceItem(VehicleMaintenance maintenance) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withOpacity(0.1),
              borderRadius: AppRadius.borderSm,
            ),
            child: Icon(Icons.directions_car,
                size: 16, color: AppColors.primaryDark),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  maintenance.vehicleNo ?? '',
                  style: AppTextStyles.label,
                ),
                const SizedBox(height: 2),
                Text(
                  maintenance.maintenanceType ?? '',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Text(
            'AED ${maintenance.amount?.toStringAsFixed(0) ?? '0'}',
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.accent),
          ),
        ],
      ),
    );
  }

  // Dialog header builder
  Widget _dialogHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: AppRadius.borderMd,
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: AppTextStyles.h3)),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
      ],
    );
  }

  // Company section header
  Widget _companyHeader(String companyId) {
    // get the company name based on the companyId from Comapny Service
    final companyService = Get.find<CompanyService>();
    final company = companyService.getCompanyNameById(companyId);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.08),
        borderRadius: AppRadius.borderSm,
        border: Border.all(color: AppColors.accent.withOpacity(0.15)),
      ),
      child: Text(
        company,
        style: AppTextStyles.label.copyWith(color: AppColors.accent),
      ),
    );
  }

  // Doc Expiry Dialog (Insurance / Mulkiya)
  void _showDocExpiryDialog(
      String title, HomeScreenController controller, String type) {
    final grouped = controller.getDocExpiryByCompany(type);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
        child: Container(
          width: 600,
          constraints: const BoxConstraints(maxHeight: 550),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogHeader(
                title,
                type == 'insurance'
                    ? Icons.verified_user_outlined
                    : Icons.description_outlined,
                type == 'insurance' ? AppColors.warning : AppColors.info,
              ),
              const Divider(height: 24),
              if (grouped.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text('No records found',
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.textMuted)),
                )
              else
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: grouped.entries.map((entry) {
                      final docs = entry.value.cast<LstDocExpiry>();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _companyHeader(entry.key),
                          // Table header
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: AppRadius.borderSm,
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                    width: 36,
                                    child: Text('#',
                                        style: AppTextStyles.labelSmall)),
                                Expanded(
                                    flex: 2,
                                    child: Text('Vehicle',
                                        style: AppTextStyles.labelSmall)),
                                Expanded(
                                    flex: 2,
                                    child: Text('Document',
                                        style: AppTextStyles.labelSmall)),
                                Expanded(
                                    flex: 2,
                                    child: Text('Expiry Date',
                                        style: AppTextStyles.labelSmall)),
                                Expanded(
                                    child: Text('Status',
                                        style: AppTextStyles.labelSmall)),
                              ],
                            ),
                          ),
                          ...docs.asMap().entries.map((e) {
                            final idx = e.key;
                            final doc = e.value;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 12),
                              child: Row(
                                children: [
                                  SizedBox(
                                      width: 36,
                                      child: Text('${idx + 1}',
                                          style: AppTextStyles.body)),
                                  Expanded(
                                      flex: 2,
                                      child: Text(doc.vehicleNo ?? '',
                                          style: AppTextStyles.body)),
                                  Expanded(
                                      flex: 2,
                                      child: Text(doc.docDescription ?? '',
                                          style: AppTextStyles.bodySmall)),
                                  Expanded(
                                      flex: 2,
                                      child: Text(
                                          DateFormat('dd-MM-yyyy').format(
                                              DateTime.parse(
                                                  doc.expiryDate ?? '')),
                                          style: AppTextStyles.bodySmall)),
                                  Expanded(
                                    child: AppBadge.status(doc.status),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const Divider(height: 1),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                      text: 'Close',
                      isOutlined: true,
                      onPressed: () => Get.back()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ODO Reminder Dialog
  void _showOdoReminderDialog(HomeScreenController controller) {
    final grouped = controller.getOdoRemindersByCompany();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
        child: Container(
          width: 500,
          constraints: const BoxConstraints(maxHeight: 550),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogHeader(
                  'ODO Reminder', Icons.speed_outlined, AppColors.error),
              const Divider(height: 24),
              if (grouped.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text('No records found',
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.textMuted)),
                )
              else
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: grouped.entries.map((entry) {
                      final items = entry.value.cast<LstOdoReminder>();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _companyHeader(entry.key),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: AppRadius.borderSm,
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                    width: 36,
                                    child: Text('#',
                                        style: AppTextStyles.labelSmall)),
                                Expanded(
                                    flex: 2,
                                    child: Text('Vehicle',
                                        style: AppTextStyles.labelSmall)),
                                Expanded(
                                    flex: 2,
                                    child: Text('Current ODO',
                                        style: AppTextStyles.labelSmall)),
                              ],
                            ),
                          ),
                          ...items.asMap().entries.map((e) {
                            final idx = e.key;
                            final item = e.value;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 12),
                              child: Row(
                                children: [
                                  SizedBox(
                                      width: 36,
                                      child: Text('${idx + 1}',
                                          style: AppTextStyles.body)),
                                  Expanded(
                                      flex: 2,
                                      child: Text(item.vehicleNo ?? '',
                                          style: AppTextStyles.body)),
                                  Expanded(
                                      flex: 2,
                                      child: Text('${item.currentOdo ?? 0} KM',
                                          style: AppTextStyles.bodySmall)),
                                ],
                              ),
                            );
                          }),
                          const Divider(height: 1),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                      text: 'Close',
                      isOutlined: true,
                      onPressed: () => Get.back()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Service Reminder Dialog
  void _showServiceReminderDialog(HomeScreenController controller) {
    final grouped = controller.getServiceRemindersByCompany();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
        child: Container(
          width: 650,
          constraints: const BoxConstraints(maxHeight: 550),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogHeader('Service Due', Icons.build_circle_outlined,
                  AppColors.success),
              const Divider(height: 24),
              if (grouped.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text('No records found',
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.textMuted)),
                )
              else
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: grouped.entries.map((entry) {
                      final items = entry.value.cast<LstServiceReminder>();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _companyHeader(entry.key),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: AppRadius.borderSm,
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                    width: 36,
                                    child: Text('#',
                                        style: AppTextStyles.labelSmall)),
                                Expanded(
                                    flex: 2,
                                    child: Text('Vehicle',
                                        style: AppTextStyles.labelSmall)),
                                Expanded(
                                    flex: 2,
                                    child: Text('Type',
                                        style: AppTextStyles.labelSmall)),
                                Expanded(
                                    flex: 3,
                                    child: Text('Vendor',
                                        style: AppTextStyles.labelSmall)),
                                Expanded(
                                    flex: 2,
                                    child: Text('Status',
                                        style: AppTextStyles.labelSmall)),
                              ],
                            ),
                          ),
                          ...items.asMap().entries.map((e) {
                            final idx = e.key;
                            final item = e.value;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 12),
                              child: Row(
                                children: [
                                  SizedBox(
                                      width: 36,
                                      child: Text('${idx + 1}',
                                          style: AppTextStyles.body)),
                                  Expanded(
                                      flex: 2,
                                      child: Text(item.vehicleNo ?? '',
                                          style: AppTextStyles.body)),
                                  Expanded(
                                      flex: 2,
                                      child: Text(item.maintenanceType ?? '',
                                          style: AppTextStyles.bodySmall)),
                                  Expanded(
                                      flex: 3,
                                      child: Text(item.vendorName ?? '',
                                          style: AppTextStyles.bodySmall)),
                                  Expanded(
                                    flex: 2,
                                    child: AppBadge.status(item.status),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const Divider(height: 1),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                      text: 'Close',
                      isOutlined: true,
                      onPressed: () => Get.back()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Unpaid Fines Dialog
  void _showUnpaidFinesDialog(HomeScreenController controller) {
    final grouped = controller.getUnpaidFinesByCompany();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
        child: Container(
          width: 650,
          constraints: const BoxConstraints(maxHeight: 550),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogHeader(
                  'Unpaid Fines', Icons.receipt_long_outlined, AppColors.error),
              const Divider(height: 24),
              if (grouped.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text('No records found',
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.textMuted)),
                )
              else
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: grouped.entries.map((entry) {
                      final items = entry.value.cast<LstUnpaidFine>();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _companyHeader(entry.key),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: AppRadius.borderSm,
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                    width: 36,
                                    child: Text('#',
                                        style: AppTextStyles.labelSmall)),
                                Expanded(
                                    flex: 2,
                                    child: Text('Vehicle',
                                        style: AppTextStyles.labelSmall)),
                                Expanded(
                                    flex: 2,
                                    child: Text('Reason',
                                        style: AppTextStyles.labelSmall)),
                                Expanded(
                                    flex: 1,
                                    child: Text('Fine Date',
                                        style: AppTextStyles.labelSmall)),
                                Expanded(
                                    child: Text('Status',
                                        style: AppTextStyles.labelSmall)),
                              ],
                            ),
                          ),
                          ...items.asMap().entries.map((e) {
                            final idx = e.key;
                            final item = e.value;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 12),
                              child: Row(
                                children: [
                                  SizedBox(
                                      width: 36,
                                      child: Text('${idx + 1}',
                                          style: AppTextStyles.body)),
                                  Expanded(
                                      flex: 2,
                                      child: Text(item.vehicleNo ?? '',
                                          style: AppTextStyles.body)),
                                  Expanded(
                                      flex: 2,
                                      child: Text(item.reason ?? '',
                                          style: AppTextStyles.bodySmall)),
                                  Expanded(
                                      flex: 1,
                                      child: Text(
                                          DateFormat('dd-MM-yyyy').format(
                                              DateTime.parse(
                                                  item.fineDate ?? '')),
                                          style: AppTextStyles.bodySmall)),
                                  Expanded(
                                    flex: 1,
                                    child: AppBadge.status(item.status),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const Divider(height: 1),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                      text: 'Close',
                      isOutlined: true,
                      onPressed: () => Get.back()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== DRAWERS ====================

  Widget _buildMobileDrawer(
      BuildContext context, HomeScreenController controller) {
    final companyService = Get.find<CompanyService>();

    return Drawer(
      backgroundColor: AppColors.cardBg,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.2),
                        borderRadius: AppRadius.borderMd,
                      ),
                      child: Icon(
                        Icons.directions_car_rounded,
                        color: AppColors.accentLight,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'MultiFleet',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Company Dropdown
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: AppRadius.borderMd,
                  ),
                  child: Obx(() => _buildCompanyDropdown(companyService)),
                ),
              ],
            ),
          ),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                // Header Nav Items
                _drawerSection('Menu'),
                _drawerItem(Icons.dashboard_outlined, 'Dashboard', () {
                  controller.changeHeaderPage(2);
                  Get.back();
                }, controller, headerIndex: 2),
                _drawerItem(Icons.bar_chart_outlined, 'Reports', () {
                  controller.changeHeaderPage(3);
                  Get.back();
                }, controller, headerIndex: 3),
                _drawerItem(Icons.settings_outlined, 'Settings', () {
                  controller.changeHeaderPage(4);
                  Get.back();
                }, controller, headerIndex: 4),
                _drawerItem(Icons.person_outline, 'Profile', () {
                  controller.changeHeaderPage(5);
                  Get.back();
                }, controller, headerIndex: 5),

                const Divider(height: 32),

                // Sidebar Nav Items
                _drawerSection('Vehicle Management'),
                _drawerItem(Icons.directions_car_rounded, 'Vehicle Listing',
                    () {
                  controller.changeHeaderPage(0);
                  controller.changeSidebarPage(0);
                  Get.back();
                }, controller, sidebarIndex: 0),
                _drawerItem(Icons.add_circle_outline, 'Add/Edit Vehicles', () {
                  controller.changeHeaderPage(0);
                  controller.changeSidebarPage(1);
                  Get.back();
                }, controller, sidebarIndex: 1),
                _drawerItem(Icons.assignment_outlined, 'Vehicle Assignment',
                    () {
                  controller.changeHeaderPage(0);
                  controller.changeSidebarPage(2);
                  Get.back();
                }, controller, sidebarIndex: 2),
                _drawerItem(Icons.people_outline, 'Assigned Vehicles', () {
                  controller.changeHeaderPage(0);
                  controller.changeSidebarPage(3);
                  Get.back();
                }, controller, sidebarIndex: 3),
                _drawerItem(Icons.receipt_long_outlined, 'Add Fine', () {
                  controller.changeHeaderPage(0);
                  controller.changeSidebarPage(4);
                  Get.back();
                }, controller, sidebarIndex: 4),
                _drawerItem(Icons.event_outlined, 'Expiry Details', () {
                  controller.changeHeaderPage(0);
                  controller.changeSidebarPage(5);
                  Get.back();
                }, controller, sidebarIndex: 5),
                _drawerItem(Icons.build_outlined, 'Service & Maintenance', () {
                  controller.changeHeaderPage(0);
                  controller.changeSidebarPage(6);
                  Get.back();
                }, controller, sidebarIndex: 6),
              ],
            ),
          ),

          // Logout Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppButton(
              text: 'Logout',
              icon: Icons.logout,
              color: AppColors.error,
              width: double.infinity,
              onPressed: () => Get.offAllNamed(RouteLinks.login),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.overline,
      ),
    );
  }

  Widget _drawerItem(
    IconData icon,
    String title,
    VoidCallback onTap,
    HomeScreenController controller, {
    int? headerIndex,
    int? sidebarIndex,
  }) {
    return Obx(() {
      final isActive = headerIndex != null
          ? controller.currentHeaderIndex.value == headerIndex
          : sidebarIndex != null &&
              controller.currentSidebarIndex.value == sidebarIndex &&
              controller.currentHeaderIndex.value == 0;

      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            onTap: onTap,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
            tileColor: isActive ? AppColors.accent : Colors.transparent,
            leading: Icon(
              icon,
              color: isActive ? Colors.white : AppColors.primaryMuted,
              size: 22,
            ),
            title: Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.textPrimary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildEndDrawer(
      BuildContext context, HomeScreenController controller) {
    return Drawer(
      backgroundColor: AppColors.cardBg,
      width: 280,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.2),
                    borderRadius: AppRadius.borderMd,
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: AppColors.accentLight,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin User',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Administrator',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _drawerItem(Icons.dashboard_outlined, 'Dashboard', () {
                  controller.changeHeaderPage(2);
                  Get.back();
                }, controller, headerIndex: 2),
                _drawerItem(Icons.bar_chart_outlined, 'Reports', () {
                  controller.changeHeaderPage(3);
                  Get.back();
                }, controller, headerIndex: 3),
                _drawerItem(Icons.settings_outlined, 'Settings', () {
                  controller.changeHeaderPage(4);
                  Get.back();
                }, controller, headerIndex: 4),
                _drawerItem(Icons.person_outline, 'Profile', () {
                  controller.changeHeaderPage(5);
                  Get.back();
                }, controller, headerIndex: 5),
              ],
            ),
          ),

          // Logout Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppButton(
              text: 'Logout',
              icon: Icons.logout,
              color: AppColors.error,
              width: double.infinity,
              onPressed: () => Get.offAllNamed(RouteLinks.login),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== FOOTER ====================

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        border: Border(
          top: BorderSide(color: AppColors.primaryLight, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '© 2025 MultiFleet Vehicle Management System',
            style: AppTextStyles.caption.copyWith(color: Colors.white60),
          ),
          Text(
            'Version 1.0.0',
            style: AppTextStyles.caption.copyWith(color: Colors.white60),
          ),
        ],
      ),
    );
  }

  // ==================== CONTENT BUILDERS ====================

  Widget _buildMainContent(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return const VehiclesListingPage();
      case 1:
        return const AddEditVehiclePage();
      case 2:
        return const VehicleAssignmentPage();
      case 3:
        return const VehicleAssignmentsListPage();
      case 4:
        return const FinesPage();
      case 5:
        return const VehicleExpiryPage();
      case 6:
        return const MaintenancePage();
      default:
        return const SizedBox();
    }
  }

  Widget _buildHeaderContent(int pageIndex) {
    switch (pageIndex) {
      case 2:
        return const DashboardPage();
      case 3:
        return const ReportsPage();
      case 4:
        return const SettingsPage();
      case 5:
        return const ProfilePage();
      default:
        return const SizedBox();
    }
  }
}
