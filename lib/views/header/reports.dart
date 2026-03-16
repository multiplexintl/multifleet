import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multifleet/theme/app_theme.dart';

import '../../controllers/report_controller.dart';
import '../../models/reports/report_types.dart';
import '../../widgets/report_widgets.dart';

/// ============================================================
/// REPORTS PAGE
/// ============================================================
/// Main reports page with sidebar, builder, and preview
/// ============================================================

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final controller = Get.put(ReportController());

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: AppColors.accent,
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isTablet =
                constraints.maxWidth >= 768 && constraints.maxWidth < 1200;
            final isMobile = constraints.maxWidth < 768;

            if (isMobile) {
              return _buildMobileLayout(controller);
            } else if (isTablet) {
              return _buildTabletLayout(controller);
            } else {
              return _buildDesktopLayout(controller);
            }
          },
        );
      }),
    );
  }

  // ==================== DESKTOP LAYOUT ====================

  Widget _buildDesktopLayout(ReportController controller) {
    return Row(
      children: [
        // Sidebar - Presets & Categories
        Obx(() => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: controller.showPresetPanel.value ? 280 : 0,
              child: controller.showPresetPanel.value
                  ? const ReportSidebar()
                  : const SizedBox.shrink(),
            )),

        // Divider
        if (controller.showPresetPanel.value)
          Container(width: 1, color: AppColors.divider),

        // Main Content
        Expanded(
          child: Column(
            children: [
              // Header
              _buildHeader(controller),

              // Content
              Expanded(
                child: Obx(() {
                  return controller.selectedTab.value == 0
                      ? const ReportBuilderPanel()
                      : const ReportPreviewPanel();
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== TABLET LAYOUT ====================

  Widget _buildTabletLayout(ReportController controller) {
    return Column(
      children: [
        // Header
        _buildHeader(controller),

        // Content with optional sidebar drawer
        Expanded(
          child: Row(
            children: [
              // Collapsible sidebar
              Obx(() => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: controller.showPresetPanel.value ? 260 : 0,
                    child: controller.showPresetPanel.value
                        ? const ReportSidebar()
                        : const SizedBox.shrink(),
                  )),

              if (controller.showPresetPanel.value)
                Container(width: 1, color: AppColors.divider),

              // Main content
              Expanded(
                child: Obx(() {
                  return controller.selectedTab.value == 0
                      ? const ReportBuilderPanel()
                      : const ReportPreviewPanel();
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== MOBILE LAYOUT ====================

  Widget _buildMobileLayout(ReportController controller) {
    return Column(
      children: [
        // Mobile Header
        _buildMobileHeader(controller),

        // Tabs
        _buildMobileTabs(controller),

        // Content
        Expanded(
          child: Obx(() {
            return controller.selectedTab.value == 0
                ? const ReportBuilderPanel()
                : const ReportPreviewPanel();
          }),
        ),
      ],
    );
  }

  // ==================== HEADER ====================

  Widget _buildHeader(ReportController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Row(
        children: [
          // Toggle sidebar button
          IconButton(
            onPressed: controller.togglePresetPanel,
            icon: Obx(() => Icon(
                  controller.showPresetPanel.value
                      ? Icons.menu_open
                      : Icons.menu,
                  color: AppColors.textSecondary,
                )),
            tooltip: 'Toggle presets panel',
          ),
          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reports',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(() => Text(
                      controller.currentConfig.value.reportType.label,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    )),
              ],
            ),
          ),

          // Tabs
          _buildDesktopTabs(controller),

          const SizedBox(width: 24),

          // Actions
          _buildHeaderActions(controller),
        ],
      ),
    );
  }

  Widget _buildDesktopTabs(ReportController controller) {
    return Obx(() => Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTab(
                label: 'Builder',
                icon: Icons.construction_outlined,
                isSelected: controller.selectedTab.value == 0,
                onTap: () => controller.setSelectedTab(0),
              ),
              const SizedBox(width: 4),
              _buildTab(
                label: 'Preview',
                icon: Icons.visibility_outlined,
                isSelected: controller.selectedTab.value == 1,
                onTap: () => controller.setSelectedTab(1),
                badge: controller.hasReportData ? null : null,
              ),
            ],
          ),
        ));
  }

  Widget _buildTab({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    String? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cardBg : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.accent : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderActions(ReportController controller) {
    return Row(
      children: [
        // Generate Report Button
        Obx(() => ElevatedButton.icon(
              onPressed: controller.isGenerating.value
                  ? null
                  : controller.generateReport,
              icon: controller.isGenerating.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.play_arrow, size: 20),
              label: Text(
                controller.isGenerating.value ? 'Generating...' : 'Generate',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            )),

        const SizedBox(width: 12),

        // Export dropdown
        Obx(() => PopupMenuButton<ExportFormat>(
              enabled:
                  controller.hasReportData && !controller.isExporting.value,
              onSelected: controller.exportReport,
              offset: const Offset(0, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              borderRadius: AppRadius.borderLg,
              color: AppColors.cardBg,
              itemBuilder: (context) => ExportFormat.values
                  .where((f) => f != ExportFormat.csv) // Only PDF and Excel
                  .map((format) => PopupMenuItem(
                        value: format,
                        child: Row(
                          children: [
                            Icon(
                              format == ExportFormat.pdf
                                  ? Icons.picture_as_pdf
                                  : Icons.table_chart,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 12),
                            Text(format.label),
                          ],
                        ),
                      ))
                  .toList(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: controller.hasReportData
                      ? AppColors.textPrimary
                      : AppColors.divider,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.download,
                      size: 18,
                      color: controller.hasReportData
                          ? Colors.white
                          : AppColors.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Export',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: controller.hasReportData
                            ? Colors.white
                            : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 18,
                      color: controller.hasReportData
                          ? Colors.white
                          : AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            )),

        const SizedBox(width: 12),

        // Save Preset Button
        IconButton(
          onPressed: () => _showSavePresetDialog(Get.context!, controller),
          icon: const Icon(Icons.bookmark_add_outlined),
          tooltip: 'Save as preset',
          style: IconButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Reset Button
        IconButton(
          onPressed: controller.reset,
          icon: const Icon(Icons.refresh),
          tooltip: 'Reset',
          style: IconButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== MOBILE HEADER ====================

  Widget _buildMobileHeader(ReportController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Menu button for presets
              IconButton(
                onPressed: () =>
                    _showPresetsBottomSheet(Get.context!, controller),
                icon: const Icon(Icons.menu),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surface,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reports',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Obx(() => Text(
                          controller.currentConfig.value.reportType.label,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        )),
                  ],
                ),
              ),
              // Generate button
              Obx(() => IconButton(
                    onPressed: controller.isGenerating.value
                        ? null
                        : controller.generateReport,
                    icon: controller.isGenerating.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.play_arrow),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileTabs(ReportController controller) {
    return Container(
      color: AppColors.cardBg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Obx(() => Row(
            children: [
              Expanded(
                child: _buildMobileTab(
                  label: 'Builder',
                  isSelected: controller.selectedTab.value == 0,
                  onTap: () => controller.setSelectedTab(0),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMobileTab(
                  label: 'Preview',
                  isSelected: controller.selectedTab.value == 1,
                  onTap: () => controller.setSelectedTab(1),
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildMobileTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  // ==================== DIALOGS ====================

  void _showSavePresetDialog(
      BuildContext context, ReportController controller) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    bool isFavorite = false;
    bool isDefault = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.bookmark_add, color: AppColors.accent),
              SizedBox(width: 12),
              Text('Save Preset'),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Preset Name',
                    hintText: 'e.g., Monthly Fine Report',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'Brief description of this preset',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  value: isFavorite,
                  onChanged: (v) => setState(() => isFavorite = v ?? false),
                  title: const Text('Add to favorites'),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  value: isDefault,
                  onChanged: (v) => setState(() => isDefault = v ?? false),
                  title: const Text('Set as default for this report type'),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  return;
                }
                controller.saveAsPreset(
                  name: nameController.text.trim(),
                  description: descController.text.trim().isEmpty
                      ? null
                      : descController.text.trim(),
                  isFavorite: isFavorite,
                  isDefault: isDefault,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPresetsBottomSheet(
      BuildContext context, ReportController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Report Presets',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ReportSidebar(scrollController: scrollController),
            ),
          ],
        ),
      ),
    );
  }
}
