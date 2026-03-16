import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/report_controller.dart';
import '../models/reports/report_config.dart';
import '../models/reports/report_data.dart';
import '../models/reports/report_types.dart' hide DateTimeRange;
import '../theme/app_theme.dart';
import '../widgets/date_range_picker.dart';

/// ============================================================
/// REPORT BUILDER PANEL
/// ============================================================

class ReportBuilderPanel extends StatelessWidget {
  const ReportBuilderPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReportController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Range
          _BuilderSection(
            title: 'Date Range',
            icon: Icons.date_range_outlined,
            child: _DateRangeSelector(),
          ),
          const SizedBox(height: 24),

          // Columns
          _BuilderSection(
            title: 'Columns',
            icon: Icons.view_column_outlined,
            trailing: Row(
              children: [
                TextButton(
                  onPressed: controller.selectAllColumns,
                  child: Text('All',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.accent)),
                ),
                TextButton(
                  onPressed: controller.clearAllColumns,
                  child: Text('None',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textMuted)),
                ),
              ],
            ),
            child: _ColumnSelector(),
          ),
          const SizedBox(height: 24),

          // Filters
          _BuilderSection(
            title: 'Filters',
            icon: Icons.filter_list,
            trailing: IconButton(
              onPressed: () => _showAddFilterDialog(context, controller),
              icon: Icon(Icons.add_circle_outline,
                  size: 20, color: AppColors.accent),
              tooltip: 'Add filter',
            ),
            child: _FilterList(),
          ),
          const SizedBox(height: 24),

          // Group & Sort
          _BuilderSection(
            title: 'Group & Sort',
            icon: Icons.sort,
            child: _GroupSortConfig(),
          ),
          const SizedBox(height: 24),

          // Chart
          _BuilderSection(
            title: 'Visualization',
            icon: Icons.bar_chart_outlined,
            child: _ChartConfig(),
          ),
          const SizedBox(height: 24),

          // Options
          _BuilderSection(
            title: 'Options',
            icon: Icons.tune_outlined,
            child: _OptionsConfig(),
          ),
        ],
      ),
    );
  }

  void _showAddFilterDialog(BuildContext context, ReportController controller) {
    String? selectedColumn;
    FilterOperator selectedOperator = FilterOperator.equals;
    final valueController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
          title: Row(
            children: [
              Icon(Icons.filter_alt_outlined, color: AppColors.accent),
              const SizedBox(width: 12),
              Text('Add Filter', style: AppTextStyles.h4),
            ],
          ),
          content: SizedBox(
            width: 350,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedColumn,
                  decoration: InputDecoration(
                    labelText: 'Column',
                    border:
                        OutlineInputBorder(borderRadius: AppRadius.borderMd),
                  ),
                  items: controller.availableColumns
                      .map((c) =>
                          DropdownMenuItem(value: c.key, child: Text(c.label)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedColumn = v),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<FilterOperator>(
                  value: selectedOperator,
                  decoration: InputDecoration(
                    labelText: 'Operator',
                    border:
                        OutlineInputBorder(borderRadius: AppRadius.borderMd),
                  ),
                  items: [
                    FilterOperator.equals,
                    FilterOperator.notEquals,
                    FilterOperator.contains,
                    FilterOperator.greaterThan,
                    FilterOperator.lessThan,
                  ]
                      .map((o) =>
                          DropdownMenuItem(value: o, child: Text(o.label)))
                      .toList(),
                  onChanged: (v) => setState(
                      () => selectedOperator = v ?? FilterOperator.equals),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: valueController,
                  decoration: InputDecoration(
                    labelText: 'Value',
                    border:
                        OutlineInputBorder(borderRadius: AppRadius.borderMd),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedColumn != null && valueController.text.isNotEmpty) {
                  controller.addFilter(ReportFilter(
                    columnKey: selectedColumn!,
                    operator: selectedOperator,
                    value: valueController.text,
                  ));
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.textOnAccent,
              ),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BuilderSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  const _BuilderSection({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: AppRadius.borderLg,
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.accent),
                const SizedBox(width: 10),
                Text(title, style: AppTextStyles.h4.copyWith(fontSize: 16)),
                const Spacer(),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.divider),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _DateRangeSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReportController>();

    final ranges = [
      ReportDateRange.today,
      ReportDateRange.thisWeek,
      ReportDateRange.thisMonth,
      ReportDateRange.lastMonth,
      ReportDateRange.thisQuarter,
      ReportDateRange.thisYear,
      ReportDateRange.last30Days,
      ReportDateRange.last90Days,
    ];

    return Obx(() {
      final currentRange = controller.currentConfig.value.dateRange;
      final isCustom = currentRange == ReportDateRange.custom;
      final customStart = controller.currentConfig.value.customStartDate;
      final customEnd = controller.currentConfig.value.customEndDate;

      String customLabel = 'Custom Range';
      if (isCustom && customStart != null && customEnd != null) {
        String fmt(DateTime d) =>
            '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
        customLabel = '${fmt(customStart)} – ${fmt(customEnd)}';
      }

      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          // "All Time" chip — clears date filter
          ChoiceChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.all_inclusive, size: 14,
                    color: currentRange == ReportDateRange.allTime
                        ? AppColors.accent
                        : AppColors.textSecondary),
                const SizedBox(width: 4),
                const Text('All Time'),
              ],
            ),
            selected: currentRange == ReportDateRange.allTime,
            onSelected: (_) => controller.setDateRange(ReportDateRange.allTime),
            selectedColor: AppColors.accent.withOpacity(0.2),
            labelStyle: TextStyle(
              color: currentRange == ReportDateRange.allTime
                  ? AppColors.accent
                  : AppColors.textSecondary,
              fontWeight: currentRange == ReportDateRange.allTime
                  ? FontWeight.w600
                  : FontWeight.w500,
              fontSize: 13,
            ),
          ),
          ...ranges.map((range) {
            final isSelected = currentRange == range;
            return ChoiceChip(
              label: Text(range.label),
              selected: isSelected,
              onSelected: (_) => controller.setDateRange(range),
              selectedColor: AppColors.accent.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.accent : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
            );
          }),
          ChoiceChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.date_range,
                  size: 14,
                  color: isCustom ? AppColors.accent : AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(customLabel),
              ],
            ),
            selected: isCustom,
            onSelected: (_) async {
              final now = DateTime.now();
              final picked = await showCustomDateRangePicker(
                context: Get.context!,
                startDate: isCustom ? customStart : now.subtract(const Duration(days: 30)),
                endDate: isCustom ? customEnd : now,
                firstDate: DateTime(2000),
                lastDate: DateTime(now.year + 5),
              );
              if (picked != null && picked.start != null && picked.end != null) {
                controller.setCustomDateRange(picked.start!, picked.end!);
              }
            },
            selectedColor: AppColors.accent.withOpacity(0.2),
            labelStyle: TextStyle(
              color: isCustom ? AppColors.accent : AppColors.textSecondary,
              fontWeight: isCustom ? FontWeight.w600 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      );
    });
  }
}

class _ColumnSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReportController>();

    return Obx(() {
      final columns = controller.availableColumns;
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: columns.map((col) {
          final isSelected = controller.selectedColumnKeys.contains(col.key);
          return FilterChip(
            label: Text(col.label),
            selected: isSelected,
            onSelected: (_) => controller.toggleColumn(col.key),
            selectedColor: AppColors.accent.withOpacity(0.2),
            checkmarkColor: AppColors.accent,
            labelStyle: TextStyle(
              fontSize: 12,
              color: isSelected ? AppColors.accent : AppColors.textSecondary,
            ),
          );
        }).toList(),
      );
    });
  }
}

class _FilterList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReportController>();

    return Obx(() {
      final filters = controller.activeFilters;
      if (filters.isEmpty) {
        return Text('No filters applied', style: AppTextStyles.bodySmall);
      }

      return Column(
        children: filters.asMap().entries.map((entry) {
          final filter = entry.value;
          final column = controller.availableColumns
              .firstWhereOrNull((c) => c.key == filter.columnKey);

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.borderMd,
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: AppRadius.borderSm,
                  ),
                  child: Text(
                    column?.label ?? filter.columnKey,
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.accent),
                  ),
                ),
                const SizedBox(width: 8),
                Text(filter.operator.symbol,
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('"${filter.value}"', style: AppTextStyles.body),
                ),
                IconButton(
                  onPressed: () => controller.removeFilter(entry.key),
                  icon: const Icon(Icons.close, size: 18),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          );
        }).toList(),
      );
    });
  }
}

class _GroupSortConfig extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReportController>();

    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Group By', style: AppTextStyles.label),
            const SizedBox(height: 8),
            DropdownButtonFormField<GroupByOption>(
              value: controller.currentConfig.value.groupBy,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
                filled: true,
                fillColor: AppColors.surface,
              ),
              borderRadius: AppRadius.borderMd,
              dropdownColor: AppColors.surface,
              items: GroupByOption.values
                  .map((o) => DropdownMenuItem(value: o, child: Text(o.label)))
                  .toList(),
              onChanged: (v) => controller.setGroupBy(v ?? GroupByOption.none),
            ),
            const SizedBox(height: 20),
            Text('Sort By', style: AppTextStyles.label),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: controller.currentConfig.value.sortConfig?.columnKey,
                    decoration: InputDecoration(
                      hintText: 'Select column',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      border:
                          OutlineInputBorder(borderRadius: AppRadius.borderMd),
                      filled: true,
                      fillColor: AppColors.surface,
                    ),
                    borderRadius: AppRadius.borderMd,
                    dropdownColor: AppColors.surface,
                    items: controller.availableColumns
                        .where((c) => c.isSortable)
                        .map((c) => DropdownMenuItem(
                            value: c.key, child: Text(c.label)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        controller.setSortConfig(
                          v,
                          controller
                                  .currentConfig.value.sortConfig?.direction ??
                              SortDirection.ascending,
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<SortDirection>(
                    value:
                        controller.currentConfig.value.sortConfig?.direction ??
                            SortDirection.ascending,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      border:
                          OutlineInputBorder(borderRadius: AppRadius.borderMd),
                      filled: true,
                      fillColor: AppColors.surface,
                    ),
                    borderRadius: AppRadius.borderMd,
                    dropdownColor: AppColors.surface,
                    items: SortDirection.values
                        .map((d) =>
                            DropdownMenuItem(value: d, child: Text(d.label)))
                        .toList(),
                    onChanged: (v) {
                      final key =
                          controller.currentConfig.value.sortConfig?.columnKey;
                      if (key != null && v != null) {
                        controller.setSortConfig(key, v);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}

class _ChartConfig extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReportController>();

    final chartTypes = [
      (ChartType.none, Icons.block, 'None'),
      (ChartType.bar, Icons.bar_chart, 'Bar'),
      (ChartType.pie, Icons.pie_chart, 'Pie'),
      (ChartType.donut, Icons.donut_large, 'Donut'),
      (ChartType.line, Icons.show_chart, 'Line'),
    ];

    return Obx(() => Wrap(
          spacing: 12,
          runSpacing: 12,
          children: chartTypes.map((item) {
            final isSelected =
                controller.currentConfig.value.chartConfig.type == item.$1;
            return InkWell(
              onTap: () => controller.setChartType(item.$1),
              borderRadius: AppRadius.borderMd,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accent.withOpacity(0.1)
                      : AppColors.surface,
                  borderRadius: AppRadius.borderMd,
                  border: Border.all(
                    color: isSelected ? AppColors.accent : AppColors.divider,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(item.$2,
                        color: isSelected
                            ? AppColors.accent
                            : AppColors.textSecondary,
                        size: 24),
                    const SizedBox(height: 4),
                    Text(
                      item.$3,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isSelected
                            ? AppColors.accent
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ));
  }
}

class _OptionsConfig extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReportController>();

    return Obx(() => Column(
          children: [
            _OptionSwitch(
              label: 'Show Summary',
              value: controller.currentConfig.value.showSummary,
              onChanged: (_) => controller.toggleShowSummary(),
            ),
            const SizedBox(height: 8),
            _OptionSwitch(
              label: 'Show Totals',
              value: controller.currentConfig.value.showTotals,
              onChanged: (_) => controller.toggleShowTotals(),
            ),
          ],
        ));
  }
}

class _OptionSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _OptionSwitch(
      {required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderMd,
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.body)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accent,
          ),
        ],
      ),
    );
  }
}

/// ============================================================
/// REPORT PREVIEW PANEL
/// ============================================================

class ReportPreviewPanel extends StatelessWidget {
  const ReportPreviewPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReportController>();

    return Obx(() {
      final report = controller.generatedReport.value;
      if (report == null) return _EmptyPreview(controller: controller);

      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ReportHeader(report: report),
            const SizedBox(height: 24),
            if (report.config.showSummary) ...[
              _SummaryCards(report: report),
              const SizedBox(height: 24),
            ],
            if (report.hasChart) ...[
              _ChartSection(report: report),
              const SizedBox(height: 24),
            ],
            _DataTable(report: report),
          ],
        ),
      );
    });
  }
}

class _EmptyPreview extends StatelessWidget {
  final ReportController controller;
  const _EmptyPreview({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assessment_outlined, size: 80, color: AppColors.divider),
          const SizedBox(height: 24),
          Text('No Report Generated',
              style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text('Configure your report and click Generate',
              style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: controller.generateReport,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Generate Report'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.textOnAccent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportHeader extends StatelessWidget {
  final GeneratedReport report;
  const _ReportHeader({required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: AppRadius.borderLg,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report.title,
                    style:
                        AppTextStyles.h2.copyWith(color: AppColors.textOnDark)),
                const SizedBox(height: 8),
                Text(
                  'Generated on ${_formatDate(report.generatedAt)} • ${report.processingTime.inMilliseconds}ms',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textOnDark.withOpacity(0.8)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: AppRadius.borderMd,
            ),
            child: Column(
              children: [
                Text('${report.dataRowCount}',
                    style:
                        AppTextStyles.h1.copyWith(color: AppColors.textOnDark)),
                Text('Records',
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textOnDark.withOpacity(0.8))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

class _SummaryCards extends StatelessWidget {
  final GeneratedReport report;
  const _SummaryCards({required this.report});

  @override
  Widget build(BuildContext context) {
    final highlights = report.summary.highlights;
    if (highlights.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: highlights.entries
          .take(4)
          .map((e) => _SummaryCard(
                label: _formatLabel(e.key),
                value: _formatValue(e.value),
                icon: _getIcon(e.key),
              ))
          .toList(),
    );
  }

  String _formatLabel(String k) =>
      k.replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m[0]}').trim();
  String _formatValue(dynamic v) =>
      v is double ? v.toStringAsFixed(2) : v.toString();
  IconData _getIcon(String k) {
    if (k.contains('amount') || k.contains('cost') || k.contains('Cost')) {
      return Icons.attach_money;
    }
    if (k.contains('count') || k.contains('Count')) return Icons.numbers;
    return Icons.analytics;
  }
}

class _SummaryCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _SummaryCard(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
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
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: AppRadius.borderMd,
            ),
            child: Icon(icon, color: AppColors.accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: AppTextStyles.h4),
                Text(label, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartSection extends StatelessWidget {
  final GeneratedReport report;
  const _ChartSection({required this.report});

  @override
  Widget build(BuildContext context) {
    final chartData = report.chartData!;

    return Container(
      height: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: AppRadius.borderLg,
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (chartData.title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(chartData.title!, style: AppTextStyles.h4),
            ),
          Expanded(child: _buildChart(chartData)),
        ],
      ),
    );
  }

  Widget _buildChart(ChartData data) {
    final dataPoints = data.singleSeriesData;
    if (dataPoints.isEmpty) return const Center(child: Text('No data'));

    final colors = [
      AppColors.accent,
      AppColors.info,
      AppColors.warning,
      AppColors.error,
      const Color(0xFF8B5CF6),
      AppColors.success
    ];

    switch (data.type) {
      case ChartType.pie:
      case ChartType.donut:
        return Row(
          children: [
            Expanded(
              child: PieChart(PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: data.type == ChartType.donut ? 50 : 0,
                sections: dataPoints
                    .asMap()
                    .entries
                    .map((e) => PieChartSectionData(
                          value: e.value.value,
                          title: '',
                          color: colors[e.key % colors.length],
                          radius: 80,
                        ))
                    .toList(),
              )),
            ),
            const SizedBox(width: 24),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: dataPoints
                  .asMap()
                  .entries
                  .take(6)
                  .map((e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                    color: colors[e.key % colors.length],
                                    borderRadius: AppRadius.borderSm)),
                            const SizedBox(width: 8),
                            Text(
                                '${e.value.label}: ${e.value.value.toStringAsFixed(0)}',
                                style: AppTextStyles.bodySmall),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ],
        );

      case ChartType.bar:
      case ChartType.horizontalBar:
        final maxY =
            dataPoints.map((d) => d.value).reduce((a, b) => a > b ? a : b) *
                1.1;
        return BarChart(BarChartData(
          maxY: maxY,
          barGroups: dataPoints
              .asMap()
              .entries
              .map((e) => BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                          toY: e.value.value,
                          color: AppColors.accent,
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4)))
                    ],
                  ))
              .toList(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    getTitlesWidget: (v, _) => Text(_formatAxis(v),
                        style:
                            AppTextStyles.bodySmall.copyWith(fontSize: 10)))),
            bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (v, _) {
                      final idx = v.toInt();
                      if (idx >= 0 && idx < dataPoints.length) {
                        final lbl = dataPoints[idx].label;
                        return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                                lbl.length > 8
                                    ? '${lbl.substring(0, 8)}...'
                                    : lbl,
                                style: AppTextStyles.bodySmall
                                    .copyWith(fontSize: 10)));
                      }
                      return const Text('');
                    })),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxY / 5,
              getDrawingHorizontalLine: (_) =>
                  FlLine(color: AppColors.divider, strokeWidth: 1)),
          borderData: FlBorderData(show: false),
        ));

      case ChartType.line:
      case ChartType.area:
        final maxY =
            dataPoints.map((d) => d.value).reduce((a, b) => a > b ? a : b) *
                1.1;
        return LineChart(LineChartData(
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: dataPoints
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value.value))
                  .toList(),
              isCurved: true,
              color: AppColors.accent,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                  show: true, color: AppColors.accent.withOpacity(0.1)),
            )
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    getTitlesWidget: (v, _) => Text(_formatAxis(v),
                        style:
                            AppTextStyles.bodySmall.copyWith(fontSize: 10)))),
            bottomTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
        ));

      default:
        return const Center(child: Text('Chart not available'));
    }
  }

  String _formatAxis(double v) =>
      v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}K' : v.toStringAsFixed(0);
}

class _DataTable extends StatefulWidget {
  final GeneratedReport report;
  const _DataTable({required this.report});

  @override
  State<_DataTable> createState() => _DataTableState();
}

class _DataTableState extends State<_DataTable> {
  final _scrollV = ScrollController();
  final _scrollH = ScrollController();

  @override
  void dispose() {
    _scrollV.dispose();
    _scrollH.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleCols = widget.report.columns.where((c) => c.isVisible).toList();
    final rows = widget.report.rows;

    final scrollControllerH = _scrollH;
    final scrollControllerV = _scrollV;

    final tableWidget = DataTable(
      headingRowColor: WidgetStateProperty.all(
        AppColors.accent.withOpacity(0.1),
      ),
      dataRowMinHeight: 44,
      dataRowMaxHeight: 52,
      horizontalMargin: 16,
      columnSpacing: 24,
      columns: visibleCols
          .map((col) => DataColumn(
                label: Text(
                  col.label,
                  style: AppTextStyles.label.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ))
          .toList(),
      rows: rows.map((row) {
        return DataRow(
          color: row.isGroupHeader
              ? WidgetStateProperty.all(AppColors.accent.withOpacity(0.05))
              : row.isSubtotal
                  ? WidgetStateProperty.all(AppColors.surface)
                  : null,
          cells: visibleCols
              .map((col) => DataCell(
                    Text(
                      row.getFormattedValue(col.key, col),
                      style: row.isGroupHeader || row.isSubtotal
                          ? AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)
                          : AppTextStyles.body,
                    ),
                  ))
              .toList(),
        );
      }).toList(),
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: AppRadius.borderLg,
        boxShadow: AppShadows.sm,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with record count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text('Data', style: AppTextStyles.h4),
                const Spacer(),
                Text(
                  '${rows.where((r) => !r.isGroupHeader && !r.isSubtotal).length} records',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.divider),
          // Scrollable table: horizontal scroll wraps vertical scroll
          SizedBox(
            height: 480,
            child: SingleChildScrollView(
              controller: scrollControllerH,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: (visibleCols.fold<int>(0, (sum, c) => sum + c.width) + 100).toDouble(),
                child: Scrollbar(
                  controller: scrollControllerV,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: scrollControllerV,
                    scrollDirection: Axis.vertical,
                    child: tableWidget,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


}

/// ============================================================
/// REPORT SIDEBAR
/// ============================================================

class ReportSidebar extends StatelessWidget {
  final ScrollController? scrollController;
  const ReportSidebar({super.key, this.scrollController});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReportController>();

    return Container(
      color: AppColors.cardBg,
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader(title: 'Categories'),
          const SizedBox(height: 8),
          ...ReportCategory.values.map((cat) => _CategoryTile(category: cat)),
          const SizedBox(height: 24),
          Obx(() =>
              _SectionHeader(title: controller.selectedCategory.value.label)),
          const SizedBox(height: 8),
          Obx(() {
            final types = controller.categoryReportTypes;
            return Column(
                children: types.map((t) => _ReportTypeTile(type: t)).toList());
          }),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Favorites'),
          const SizedBox(height: 8),
          Obx(() {
            final favorites = controller.favoritePresets;
            if (favorites.isEmpty) {
              return _EmptyState(message: 'No favorites yet');
            }
            return Column(
                children:
                    favorites.map((p) => _PresetTile(preset: p)).toList());
          }),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Recent'),
          const SizedBox(height: 8),
          Obx(() {
            final recent = controller.recentReports;
            if (recent.isEmpty) {
              return _EmptyState(message: 'No recent reports');
            }
            return Column(
                children:
                    recent.take(5).map((c) => _RecentTile(config: c)).toList());
          }),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Templates'),
          const SizedBox(height: 8),
          Obx(() {
            final presets = controller.builtInPresets;
            return Column(
                children: presets
                    .take(6)
                    .map((p) => _PresetTile(preset: p, isBuiltIn: true))
                    .toList());
          }),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: AppTextStyles.labelSmall.copyWith(
        color: AppColors.textMuted,
        letterSpacing: 0.5,
        fontSize: 11,
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final ReportCategory category;
  const _CategoryTile({required this.category});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReportController>();

    return Obx(() {
      final isSelected = controller.selectedCategory.value == category;
      return InkWell(
        onTap: () => controller.setCategory(category),
        borderRadius: AppRadius.borderMd,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accent.withOpacity(0.1) : null,
            borderRadius: AppRadius.borderMd,
          ),
          child: Row(
            children: [
              Icon(
                _getCategoryIcon(category),
                size: 18,
                color: isSelected ? AppColors.accent : AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  category.label,
                  style: AppTextStyles.label.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color:
                        isSelected ? AppColors.accent : AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.sidebarBg,
                  borderRadius: AppRadius.borderSm,
                ),
                child: Text(
                  '${ReportType.forCategory(category).length}',
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  IconData _getCategoryIcon(ReportCategory cat) => switch (cat) {
        ReportCategory.vehicle => Icons.directions_car_outlined,
        ReportCategory.document => Icons.description_outlined,
        ReportCategory.fine => Icons.receipt_long_outlined,
        ReportCategory.maintenance => Icons.build_outlined,
        ReportCategory.assignment => Icons.assignment_ind_outlined,
        ReportCategory.financial => Icons.attach_money,
        ReportCategory.operational => Icons.speed_outlined,
        ReportCategory.tyre => Icons.tire_repair_outlined,
      };
}

class _ReportTypeTile extends StatelessWidget {
  final ReportType type;
  const _ReportTypeTile({required this.type});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReportController>();

    return Obx(() {
      final isSelected = controller.selectedReportType.value == type;
      return InkWell(
        onTap: () => controller.setReportType(type),
        borderRadius: AppRadius.borderMd,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.accent.withOpacity(0.1)
                : AppColors.surface,
            borderRadius: AppRadius.borderMd,
            border: isSelected
                ? Border.all(color: AppColors.accent.withOpacity(0.3))
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                type.label,
                style: AppTextStyles.label.copyWith(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.accent : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                type.description,
                style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _PresetTile extends StatelessWidget {
  final ReportPreset preset;
  final bool isBuiltIn;
  const _PresetTile({required this.preset, this.isBuiltIn = false});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReportController>();

    return InkWell(
      onTap: () => controller.loadPreset(preset),
      borderRadius: AppRadius.borderMd,
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.borderMd,
        ),
        child: Row(
          children: [
            Icon(
              isBuiltIn ? Icons.auto_awesome : Icons.bookmark,
              size: 16,
              color:
                  preset.isFavorite ? AppColors.warning : AppColors.textMuted,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                preset.name,
                style: AppTextStyles.label.copyWith(fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!isBuiltIn)
              InkWell(
                onTap: () => controller.togglePresetFavorite(preset.id),
                child: Icon(
                  preset.isFavorite ? Icons.star : Icons.star_border,
                  size: 16,
                  color:
                      preset.isFavorite ? AppColors.warning : AppColors.divider,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RecentTile extends StatelessWidget {
  final ReportConfig config;
  const _RecentTile({required this.config});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReportController>();

    return InkWell(
      onTap: () {
        controller.currentConfig.value = config;
        controller.setReportType(config.reportType);
      },
      borderRadius: AppRadius.borderMd,
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.borderMd,
        ),
        child: Row(
          children: [
            Icon(Icons.history, size: 16, color: AppColors.textMuted),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                config.title ?? config.reportType.label,
                style: AppTextStyles.body.copyWith(fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        message,
        style: AppTextStyles.bodySmall,
        textAlign: TextAlign.center,
      ),
    );
  }
}
