import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multifleet/controllers/import_controller.dart';
import 'package:multifleet/services/theme_service.dart';

/// ============================================================
/// IMPORT / EXPORT SETTINGS
/// ============================================================

class ImportExportSettings extends StatelessWidget {
  const ImportExportSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ImportController());
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.upload_file_outlined,
            title: 'Import Fleet Data',
            subtitle:
                'Upload the Fleet Data Collection Template to import vehicles, documents, fines, assignments, and maintenance records.',
          ),
          const SizedBox(height: 24),
          _UploadCard(controller: controller),
          const SizedBox(height: 24),
          Obx(() {
            if (controller.parsedVehicleCount.value > 0) {
              return _ParsedSummaryCard(controller: controller);
            }
            return const SizedBox.shrink();
          }),
          Obx(() {
            if (controller.isImporting.value ||
                controller.summary.value != null) {
              return Column(
                children: [
                  const SizedBox(height: 24),
                  _ProgressCard(controller: controller),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
          Obx(() {
            if (controller.summary.value != null) {
              return Column(
                children: [
                  const SizedBox(height: 24),
                  _ResultsCard(controller: controller),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
          Obx(() {
            if (controller.errors.isNotEmpty) {
              return Column(
                children: [
                  const SizedBox(height: 24),
                  _ErrorsCard(controller: controller),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

// ============================================================
// SECTION HEADER
// ============================================================

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final accent = ThemeService.to.accentColor;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: accent, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// UPLOAD CARD
// ============================================================

class _UploadCard extends StatelessWidget {
  final ImportController controller;
  const _UploadCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final accent = ThemeService.to.accentColor;
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Step 1: Select Excel File',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              'Select the filled Fleet_Data_Collection_Template.xlsx file.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 20),

            // File picker button + status
            Obx(() {
              final hasFile = controller.selectedFileName.value.isNotEmpty;
              final isParsing = controller.isParsing.value;
              final isPicking = controller.isPickingFile.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: (isParsing ||
                                isPicking ||
                                controller.isImporting.value)
                            ? null
                            : controller.pickAndParseFile,
                        icon: isPicking || isParsing
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              )
                            : const Icon(Icons.upload_file_outlined),
                        label: Text(isPicking
                            ? 'Opening...'
                            : isParsing
                                ? 'Parsing...'
                                : 'Choose File'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                        ),
                      ),
                      if (hasFile) ...[
                        const SizedBox(width: 16),
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_outline,
                                  color: Colors.green, size: 18),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  controller.selectedFileName.value,
                                  style: theme.textTheme.bodyMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Status message
                  if (controller.statusMessage.value.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        controller.statusMessage.value,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: accent),
                      ),
                    ),
                  ],
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PARSED SUMMARY CARD
// ============================================================

class _ParsedSummaryCard extends StatelessWidget {
  final ImportController controller;
  const _ParsedSummaryCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = ThemeService.to.accentColor;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Step 2: Review Parsed Data',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Obx(() => Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _StatChip(
                      label: 'Employees',
                      value: controller.parsedEmployeeCount.value,
                      icon: Icons.badge_outlined,
                      color: Colors.indigo,
                    ),
                    _StatChip(
                      label: 'Vehicles',
                      value: controller.parsedVehicleCount.value,
                      icon: Icons.directions_car_outlined,
                      color: accent,
                    ),
                    _StatChip(
                      label: 'Documents',
                      value: controller.parsedDocCount.value,
                      icon: Icons.description_outlined,
                      color: Colors.blue,
                    ),
                    _StatChip(
                      label: 'Fines',
                      value: controller.parsedFineCount.value,
                      icon: Icons.receipt_long_outlined,
                      color: Colors.orange,
                    ),
                    _StatChip(
                      label: 'Assignments',
                      value: controller.parsedAssignmentCount.value,
                      icon: Icons.person_pin_circle_outlined,
                      color: Colors.green,
                    ),
                    _StatChip(
                      label: 'Maintenance',
                      value: controller.parsedMaintenanceCount.value,
                      icon: Icons.build_outlined,
                      color: Colors.purple,
                    ),
                    _StatChip(
                      label: 'Tyres',
                      value: controller.parsedTyreCount.value,
                      icon: Icons.tire_repair_outlined,
                      color: Colors.teal,
                    ),
                  ],
                )),
            const SizedBox(height: 20),
            Obx(() {
              final hasParsedErrors = controller.errors
                  .where((e) =>
                      controller.summary.value == null &&
                      e.row == 0 &&
                      e.sheet.isNotEmpty)
                  .isNotEmpty;

              return Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: controller.isImporting.value ||
                            controller.parsedVehicleCount.value == 0
                        ? null
                        : controller.startImport,
                    icon: controller.isImporting.value
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.onPrimary),
                          )
                        : const Icon(Icons.cloud_upload_outlined),
                    label: Text(controller.isImporting.value
                        ? 'Importing...'
                        : 'Start Import'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton.icon(
                    onPressed: controller.isImporting.value
                        ? null
                        : controller.resetImport,
                    icon: const Icon(Icons.refresh_outlined),
                    label: const Text('Reset'),
                  ),
                  if (hasParsedErrors) ...[
                    const SizedBox(width: 12),
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_outlined,
                            color: Colors.orange, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Parse warnings detected — see errors below',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.orange),
                        ),
                      ],
                    ),
                  ],
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PROGRESS CARD
// ============================================================

class _ProgressCard extends StatelessWidget {
  final ImportController controller;
  const _ProgressCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = ThemeService.to.accentColor;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Import Progress',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Obx(() {
              final total = controller.totalVehicles.value;
              final current = controller.currentVehicleIndex.value;
              final progress =
                  total > 0 ? current / total : 0.0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        controller.isImporting.value
                            ? 'Processing: ${controller.currentVehicleNo.value}'
                            : controller.statusMessage.value,
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        total > 0 ? '$current / $total' : '',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: controller.isImporting.value ? progress : 1.0,
                    backgroundColor: theme.dividerColor,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        controller.isImporting.value ? accent : Colors.green),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// RESULTS CARD
// ============================================================

class _ResultsCard extends StatelessWidget {
  final ImportController controller;
  const _ResultsCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final s = controller.summary.value;
      if (s == null) return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    s.skippedVehicles == 0
                        ? Icons.check_circle_outline
                        : Icons.warning_amber_outlined,
                    color: s.skippedVehicles == 0
                        ? Colors.green
                        : Colors.orange,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text('Import Results',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 16),
              _ResultRow('Employees', s.successEmployees, s.totalEmployees),
              _ResultRow('Vehicles', s.successVehicles, s.totalVehicles),
              _ResultRow('Documents', s.successDocuments, s.totalDocuments),
              _ResultRow('Tyres', s.successTyres, s.totalTyres),
              _ResultRow('Fines', s.successFines, s.totalFines),
              _ResultRow(
                  'Assignments', s.successAssignments, s.totalAssignments),
              _ResultRow(
                  'Maintenance', s.successMaintenance, s.totalMaintenance),
              if (s.skippedVehicles > 0) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${s.skippedVehicles} vehicle(s) skipped due to errors. See error report below.',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.orange),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final int success;
  final int total;

  const _ResultRow(this.label, this.success, this.total);

  @override
  Widget build(BuildContext context) {
    if (total == 0) return const SizedBox.shrink();
    final allOk = success == total;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            allOk ? Icons.check_circle_outline : Icons.error_outline,
            size: 16,
            color: allOk ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 120,
            child: Text(label,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(
            '$success / $total',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: allOk ? Colors.green : Colors.orange,
                ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ERRORS CARD
// ============================================================

class _ErrorsCard extends StatelessWidget {
  final ImportController controller;
  const _ErrorsCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = ThemeService.to.accentColor;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Obx(() => Text(
                        'Errors (${controller.errors.length})',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      )),
                ),
                // Download button
                Obx(() {
                  final hasReport = controller.errorReportPath.value.isNotEmpty ||
                      controller.summary.value != null;
                  if (!hasReport) return const SizedBox.shrink();

                  return ElevatedButton.icon(
                    onPressed: controller.isGeneratingReport.value
                        ? null
                        : controller.downloadErrorReport,
                    icon: controller.isGeneratingReport.value
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.download_outlined, size: 18),
                    label: const Text('Download Error Report'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      textStyle: const TextStyle(fontSize: 13),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 16),

            // Errors table
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: theme.dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Obx(() {
                  final errs = controller.errors;
                  return DataTable(
                    columnSpacing: 16,
                    headingRowHeight: 40,
                    dataRowMinHeight: 36,
                    dataRowMaxHeight: 56,
                    headingRowColor: WidgetStateProperty.all(
                        accent.withOpacity(0.08)),
                    columns: const [
                      DataColumn(label: Text('Vehicle No')),
                      DataColumn(label: Text('Sheet')),
                      DataColumn(label: Text('Row')),
                      DataColumn(label: Text('Field')),
                      DataColumn(label: Text('Error')),
                    ],
                    rows: errs
                        .map((e) => DataRow(cells: [
                              DataCell(Text(e.vehicleNo,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500))),
                              DataCell(Text(e.sheet,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: theme.hintColor))),
                              DataCell(Text(e.row > 0 ? '${e.row}' : '-')),
                              DataCell(Text(e.field)),
                              DataCell(
                                ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 400),
                                  child: Text(
                                    e.error,
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 12),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ]))
                        .toList(),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// STAT CHIP
// ============================================================

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$value',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
