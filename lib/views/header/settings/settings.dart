import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/settings_controller.dart';
import '../../../services/theme_service.dart';
import 'apprearance_settings.dart';
import 'import_export_settings.dart';
import 'simple_master_settings.dart';
import 'system_preference_settings.dart';

/// ============================================================
/// SETTINGS PAGE
/// ============================================================

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 1024;
          final isTablet =
              constraints.maxWidth >= 768 && constraints.maxWidth < 1024;

          if (isDesktop) {
            return _buildDesktopLayout(controller);
          } else if (isTablet) {
            return _buildTabletLayout(controller);
          } else {
            return _buildMobileLayout(controller);
          }
        },
      ),
    );
  }

  // ==================== DESKTOP LAYOUT ====================
  Widget _buildDesktopLayout(SettingsController controller) {
    return Row(
      children: [
        // Sidebar - Always visible on desktop
        SizedBox(
          width: 280,
          child: _SettingsSidebar(controller: controller),
        ),
        VerticalDivider(width: 1, thickness: 1),

        // Content Area
        Expanded(
          child: Column(
            children: [
              _buildHeader(controller, showMenuButton: false),
              Expanded(child: _SettingsContent(controller: controller)),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== TABLET LAYOUT ====================
  Widget _buildTabletLayout(SettingsController controller) {
    return Row(
      children: [
        // Collapsible sidebar
        Obx(() => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: controller.showSidebar.value ? 260 : 0,
              child: controller.showSidebar.value
                  ? _SettingsSidebar(controller: controller)
                  : const SizedBox.shrink(),
            )),
        if (controller.showSidebar.value)
          VerticalDivider(width: 1, thickness: 1),

        // Content Area
        Expanded(
          child: Column(
            children: [
              _buildHeader(controller, showMenuButton: true),
              Expanded(child: _SettingsContent(controller: controller)),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== MOBILE LAYOUT ====================
  Widget _buildMobileLayout(SettingsController controller) {
    return Column(
      children: [
        _buildMobileHeader(controller),
        Expanded(child: _SettingsContent(controller: controller)),
      ],
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader(SettingsController controller,
      {required bool showMenuButton}) {
    return Builder(builder: (context) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border:
              Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
        ),
        child: Row(
          children: [
            if (showMenuButton) ...[
              IconButton(
                onPressed: controller.toggleSidebar,
                icon: Obx(() => Icon(
                      controller.showSidebar.value
                          ? Icons.menu_open
                          : Icons.menu,
                    )),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Settings',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.selectedSection.value.label,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  )),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMobileHeader(SettingsController controller) {
    return Builder(builder: (context) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border:
              Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => _showSectionsBottomSheet(controller),
              icon: const Icon(Icons.menu),
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Settings',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        controller.selectedSection.value.label,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  )),
            ),
          ],
        ),
      );
    });
  }

  void _showSectionsBottomSheet(SettingsController controller) {
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _SettingsSidebar(
                controller: controller,
                scrollController: scrollController,
                onSectionTap: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================
/// SETTINGS SIDEBAR
/// ============================================================

class _SettingsSidebar extends StatelessWidget {
  final SettingsController controller;
  final ScrollController? scrollController;
  final VoidCallback? onSectionTap;

  const _SettingsSidebar({
    required this.controller,
    this.scrollController,
    this.onSectionTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => controller.searchQuery.value = v,
              decoration: InputDecoration(
                hintText: 'Search settings...',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Sections list
          Expanded(
            child: Obx(() {
              final groups = controller.filteredGroups;
              return ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final group = groups[index];
                  return _buildGroup(context, group);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildGroup(BuildContext context, SettingsGroup group) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              group.label.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
            ),
          ),

          // Section items
          ...group.sections
              .map((section) => _buildSectionItem(context, section)),
        ],
      ),
    );
  }

  Widget _buildSectionItem(BuildContext context, SettingsSection section) {
    return Obx(() {
      final isSelected = controller.selectedSection.value == section;
      final accent = ThemeService.to.accentColor;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Material(
          color: isSelected ? accent.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              controller.selectSection(section);
              onSectionTap?.call();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    controller.getIconForSection(section),
                    size: 20,
                    color: isSelected ? accent : Theme.of(context).hintColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      section.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? accent : null,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(2),
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
}

/// ============================================================
/// SETTINGS CONTENT
/// ============================================================

class _SettingsContent extends StatelessWidget {
  final SettingsController controller;

  const _SettingsContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final section = controller.selectedSection.value;

      // Return appropriate widget based on section
      switch (section) {
        case SettingsSection.appearance:
          return const AppearanceSettings();

        // Vehicle Masters
        case SettingsSection.vehicleCategories:
          return const VehicleTypesSettings();
        case SettingsSection.vehicleConditions:
          return const VehicleConditionsSettings();
        case SettingsSection.tyrePositions:
          return const TyrePositionsSettings();

        // Compliance Masters
        case SettingsSection.documentTypes:
          return const DocumentTypesSettings();
        case SettingsSection.fineCategories:
          return const FineTypesRealSettings();

        // Maintenance Masters
        case SettingsSection.serviceTypes:
          return const MaintenanceTypesSettings();
        case SettingsSection.vendors:
          return const VendorsSettings();

        // Operations Masters
        case SettingsSection.fuelStations:
          return const FuelStationsSettings();
        case SettingsSection.employees:
          return const EmployeesSettings();
        case SettingsSection.cities:
          return const CitiesSettings();

        // System
        case SettingsSection.systemPreferences:
          return const SystemPreferencesSettings();

        case SettingsSection.importExport:
          return const ImportExportSettings();

        default:
          return _buildPlaceholder(context, section);
      }
    });
  }

  Widget _buildPlaceholder(BuildContext context, SettingsSection section) {
    final accent = ThemeService.to.accentColor;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  controller.getIconForSection(section),
                  color: accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                section.label,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Placeholder content card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              children: [
                Icon(
                  controller.getIconForSection(section),
                  size: 48,
                  color: Theme.of(context).hintColor,
                ),
                const SizedBox(height: 16),
                Text(
                  '${section.label} Settings',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Content for this section will be implemented here.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
