import '../models/reports/report_config.dart';
import '../models/reports/report_data.dart';
import '../models/reports/report_types.dart';

/// ============================================================
/// REPORT SERVICE
/// ============================================================

class ReportService {
  ReportService._();
  static final ReportService _instance = ReportService._();
  static ReportService get instance => _instance;

  GeneratedReport generateReport({
    required ReportConfig config,
    required List<Map<String, dynamic>> rawData,
    required String companyId,
  }) {
    final stopwatch = Stopwatch()..start();

    final columns = config.columns.isNotEmpty
        ? config.columns
        : ReportColumnDefinitions.getColumnsForType(config.reportType);

    var filteredData = _applyFilters(rawData, config.filters);
    filteredData = _applyDateRangeFilter(
        filteredData, config.effectiveDateRange, config.reportType);

    if (config.sortConfig != null) {
      filteredData = _applySorting(filteredData, config.sortConfig!);
    }

    final rows =
        _createRows(filteredData, columns, config.groupBy, config.showTotals);
    final limitedRows = config.limit != null && config.limit! < rows.length
        ? rows.take(config.limit!).toList()
        : rows;

    final summary = _generateSummary(rawData, filteredData, columns, config);
    final chartData = config.chartConfig.type != ChartType.none
        ? _generateChartData(filteredData, config)
        : null;

    stopwatch.stop();

    return GeneratedReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      config: config.copyWith(columns: columns),
      columns: columns,
      rows: limitedRows,
      summary: summary,
      chartData: chartData,
      generatedAt: DateTime.now(),
      companyId: companyId,
      processingTime: stopwatch.elapsed,
    );
  }

  List<Map<String, dynamic>> _applyFilters(
      List<Map<String, dynamic>> data, List<ReportFilter> filters) {
    if (filters.isEmpty) return data;
    return data.where((row) {
      for (final filter in filters) {
        if (!filter.apply(row[filter.columnKey])) return false;
      }
      return true;
    }).toList();
  }

  List<Map<String, dynamic>> _applyDateRangeFilter(
    List<Map<String, dynamic>> data,
    DateTimeRange range,
    ReportType reportType,
  ) {
    final dateField = switch (reportType.category) {
      ReportCategory.fine => 'fineDate',
      ReportCategory.maintenance => 'serviceDate',
      ReportCategory.document => 'expiryDate',
      ReportCategory.assignment => 'assignedDate',
      _ => null,
    };
    if (dateField == null) return data;

    return data.where((row) {
      final dateValue = row[dateField];
      if (dateValue == null) return true;
      final date = dateValue is DateTime
          ? dateValue
          : DateTime.tryParse(dateValue.toString());
      return date == null || range.contains(date);
    }).toList();
  }

  List<Map<String, dynamic>> _applySorting(
      List<Map<String, dynamic>> data, SortConfig sortConfig) {
    final sortedData = List<Map<String, dynamic>>.from(data);
    sortedData.sort((a, b) {
      final valueA = a[sortConfig.columnKey];
      final valueB = b[sortConfig.columnKey];
      int cmp = 0;
      if (valueA == null && valueB == null) {
        cmp = 0;
      } else if (valueA == null) {
        cmp = 1;
      } else if (valueB == null) {
        cmp = -1;
      } else if (valueA is num && valueB is num) {
        cmp = valueA.compareTo(valueB);
      } else {
        cmp = valueA.toString().compareTo(valueB.toString());
      }
      return sortConfig.direction == SortDirection.ascending ? cmp : -cmp;
    });
    return sortedData;
  }

  List<ReportRow> _createRows(
    List<Map<String, dynamic>> data,
    List<ReportColumn> columns,
    GroupByOption groupBy,
    bool showTotals,
  ) {
    if (groupBy == GroupByOption.none) {
      return data.map((row) => ReportRow(data: row)).toList();
    }

    final groupKey = _getGroupKey(groupBy);
    final groups = <String, List<Map<String, dynamic>>>{};
    for (final row in data) {
      final key = row[groupKey]?.toString() ?? 'Unknown';
      groups.putIfAbsent(key, () => []).add(row);
    }

    final rows = <ReportRow>[];
    for (final entry in groups.entries) {
      rows.add(ReportRow(
          data: {'_groupKey': entry.key, '_groupCount': entry.value.length},
          isGroupHeader: true));
      rows.addAll(entry.value.map((r) => ReportRow(data: r, level: 1)));
      if (showTotals) {
        final subtotals = _calculateAggregations(entry.value, columns);
        rows.add(ReportRow(
            data: {'_groupKey': entry.key, ...subtotals},
            isSubtotal: true,
            level: 1));
      }
    }
    return rows;
  }

  String _getGroupKey(GroupByOption g) => switch (g) {
        GroupByOption.vehicle => 'vehicleNo',
        GroupByOption.employee => 'empNo',
        GroupByOption.status => 'status',
        GroupByOption.type => 'type',
        GroupByOption.emirate => 'emirate',
        GroupByOption.city => 'city',
        GroupByOption.brand => 'brand',
        GroupByOption.model => 'model',
        _ => 'status',
      };

  Map<String, dynamic> _calculateAggregations(
      List<Map<String, dynamic>> data, List<ReportColumn> columns) {
    final result = <String, dynamic>{};
    for (final col
        in columns.where((c) => c.aggregation != AggregationType.none)) {
      final values = data.map((r) => r[col.key]).whereType<num>().toList();
      if (values.isEmpty) continue;
      result[col.key] = switch (col.aggregation) {
        AggregationType.sum => values.reduce((a, b) => a + b),
        AggregationType.average =>
          values.reduce((a, b) => a + b) / values.length,
        AggregationType.count => values.length,
        AggregationType.min => values.reduce((a, b) => a < b ? a : b),
        AggregationType.max => values.reduce((a, b) => a > b ? a : b),
        _ => null,
      };
    }
    return result;
  }

  ReportSummary _generateSummary(
    List<Map<String, dynamic>> rawData,
    List<Map<String, dynamic>> filteredData,
    List<ReportColumn> columns,
    ReportConfig config,
  ) {
    final aggregations = _calculateAggregations(filteredData, columns);
    final statusBreakdown = <String, int>{};
    for (final row in filteredData) {
      final status = row['status']?.toString() ?? 'Unknown';
      statusBreakdown[status] = (statusBreakdown[status] ?? 0) + 1;
    }

    final highlights = <String, dynamic>{};
    switch (config.reportType.category) {
      case ReportCategory.fine:
        final amounts =
            filteredData.map((r) => r['amount']).whereType<num>().toList();
        if (amounts.isNotEmpty) {
          highlights['totalAmount'] = amounts.reduce((a, b) => a + b);
          highlights['unpaidCount'] = filteredData
              .where((r) => r['status']?.toString().toLowerCase() != 'paid')
              .length;
        }
        break;
      case ReportCategory.vehicle:
        highlights['activeCount'] = filteredData
            .where((r) => r['status']?.toString().toLowerCase() == 'active')
            .length;
        highlights['maintenanceCount'] = filteredData
            .where(
                (r) => r['status']?.toString().toLowerCase() == 'maintenance')
            .length;
        break;
      case ReportCategory.maintenance:
        final costs =
            filteredData.map((r) => r['cost']).whereType<num>().toList();
        if (costs.isNotEmpty) {
          highlights['totalCost'] = costs.reduce((a, b) => a + b);
        }
        break;
      default:
        break;
    }

    return ReportSummary(
      totalRows: rawData.length,
      filteredRows: filteredData.length,
      aggregations: aggregations,
      statusBreakdown: statusBreakdown,
      highlights: highlights,
    );
  }

  ChartData? _generateChartData(
      List<Map<String, dynamic>> data, ReportConfig config) {
    final chartConfig = config.chartConfig;
    final xKey = chartConfig.xAxisKey ??
        (config.reportType.category == ReportCategory.fine
            ? 'fineType'
            : 'status');
    final yKey = chartConfig.yAxisKey ??
        (config.reportType.category == ReportCategory.fine
            ? 'amount'
            : 'count');

    final groups = <String, double>{};
    for (final row in data) {
      final label = row[xKey]?.toString() ?? 'Unknown';
      final value = (row[yKey] as num?)?.toDouble() ?? 1.0;
      groups[label] = (groups[label] ?? 0) + value;
    }

    final sorted = groups.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final limited = sorted.take(10).toList();
    final dataPoints = limited
        .map((e) => ChartDataPoint(label: e.key, value: e.value))
        .toList();

    return ChartData(
      type: chartConfig.type,
      title: chartConfig.title,
      series: [ChartSeries(name: 'Data', data: dataPoints)],
      labels: limited.map((e) => e.key).toList(),
    );
  }
}
