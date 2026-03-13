import 'dart:convert';
import 'report_types.dart';

class ReportColumn {
  final String key, label;
  final ColumnDataType dataType;
  final bool isVisible, isSortable, isFilterable, isGroupable;
  final int width;
  final AggregationType aggregation;

  const ReportColumn({
    required this.key,
    required this.label,
    required this.dataType,
    this.isVisible = true,
    this.isSortable = true,
    this.isFilterable = true,
    this.isGroupable = false,
    this.width = 120,
    this.aggregation = AggregationType.none,
  });

  ReportColumn copyWith(
          {String? key,
          String? label,
          ColumnDataType? dataType,
          bool? isVisible,
          bool? isSortable,
          bool? isFilterable,
          bool? isGroupable,
          int? width,
          AggregationType? aggregation}) =>
      ReportColumn(
          key: key ?? this.key,
          label: label ?? this.label,
          dataType: dataType ?? this.dataType,
          isVisible: isVisible ?? this.isVisible,
          isSortable: isSortable ?? this.isSortable,
          isFilterable: isFilterable ?? this.isFilterable,
          isGroupable: isGroupable ?? this.isGroupable,
          width: width ?? this.width,
          aggregation: aggregation ?? this.aggregation);

  Map<String, dynamic> toJson() => {
        'key': key,
        'label': label,
        'dataType': dataType.name,
        'isVisible': isVisible,
        'isSortable': isSortable,
        'isFilterable': isFilterable,
        'isGroupable': isGroupable,
        'width': width,
        'aggregation': aggregation.name
      };
  factory ReportColumn.fromJson(Map<String, dynamic> j) => ReportColumn(
      key: j['key'],
      label: j['label'],
      dataType: ColumnDataType.values.firstWhere((e) => e.name == j['dataType'],
          orElse: () => ColumnDataType.text),
      isVisible: j['isVisible'] ?? true,
      isSortable: j['isSortable'] ?? true,
      isFilterable: j['isFilterable'] ?? true,
      isGroupable: j['isGroupable'] ?? false,
      width: j['width'] ?? 120,
      aggregation: AggregationType.values.firstWhere(
          (e) => e.name == j['aggregation'],
          orElse: () => AggregationType.none));
}

class ReportFilter {
  final String columnKey;
  final FilterOperator operator;
  final dynamic value, value2;

  const ReportFilter(
      {required this.columnKey,
      required this.operator,
      this.value,
      this.value2});

  bool apply(dynamic fieldValue) {
    if (operator == FilterOperator.isEmpty)
      return fieldValue == null || (fieldValue is String && fieldValue.isEmpty);
    if (operator == FilterOperator.isNotEmpty)
      return fieldValue != null &&
          !(fieldValue is String && fieldValue.isEmpty);
    if (fieldValue == null) return false;
    final fStr = fieldValue.toString().toLowerCase();
    final vStr = value?.toString().toLowerCase() ?? '';
    return switch (operator) {
      FilterOperator.equals => fStr == vStr,
      FilterOperator.notEquals => fStr != vStr,
      FilterOperator.contains => fStr.contains(vStr),
      FilterOperator.notContains => !fStr.contains(vStr),
      FilterOperator.startsWith => fStr.startsWith(vStr),
      FilterOperator.endsWith => fStr.endsWith(vStr),
      FilterOperator.greaterThan => _cmp(fieldValue, value) > 0,
      FilterOperator.lessThan => _cmp(fieldValue, value) < 0,
      FilterOperator.greaterOrEqual => _cmp(fieldValue, value) >= 0,
      FilterOperator.lessOrEqual => _cmp(fieldValue, value) <= 0,
      FilterOperator.between =>
        _cmp(fieldValue, value) >= 0 && _cmp(fieldValue, value2) <= 0,
      FilterOperator.inList => value is List &&
          value.map((e) => e.toString().toLowerCase()).contains(fStr),
      FilterOperator.notInList => value is! List ||
          !value.map((e) => e.toString().toLowerCase()).contains(fStr),
      _ => true,
    };
  }

  int _cmp(dynamic a, dynamic b) {
    if (a is num && b is num) return a.compareTo(b);
    final nA = num.tryParse(a.toString()), nB = num.tryParse(b.toString());
    if (nA != null && nB != null) return nA.compareTo(nB);
    return a.toString().compareTo(b.toString());
  }

  Map<String, dynamic> toJson() => {
        'columnKey': columnKey,
        'operator': operator.name,
        'value': value,
        'value2': value2
      };
  factory ReportFilter.fromJson(Map<String, dynamic> j) => ReportFilter(
      columnKey: j['columnKey'],
      operator: FilterOperator.values.firstWhere((e) => e.name == j['operator'],
          orElse: () => FilterOperator.equals),
      value: j['value'],
      value2: j['value2']);
}

class SortConfig {
  final String columnKey;
  final SortDirection direction;
  const SortConfig(
      {required this.columnKey, this.direction = SortDirection.ascending});
  Map<String, dynamic> toJson() =>
      {'columnKey': columnKey, 'direction': direction.name};
  factory SortConfig.fromJson(Map<String, dynamic> j) => SortConfig(
      columnKey: j['columnKey'],
      direction: SortDirection.values.firstWhere(
          (e) => e.name == j['direction'],
          orElse: () => SortDirection.ascending));
}

class ChartConfig {
  final ChartType type;
  final String? title, xAxisKey, yAxisKey;
  final bool showLegend, showLabels;

  const ChartConfig(
      {this.type = ChartType.none,
      this.title,
      this.xAxisKey,
      this.yAxisKey,
      this.showLegend = true,
      this.showLabels = true});
  ChartConfig copyWith(
          {ChartType? type,
          String? title,
          String? xAxisKey,
          String? yAxisKey,
          bool? showLegend,
          bool? showLabels}) =>
      ChartConfig(
          type: type ?? this.type,
          title: title ?? this.title,
          xAxisKey: xAxisKey ?? this.xAxisKey,
          yAxisKey: yAxisKey ?? this.yAxisKey,
          showLegend: showLegend ?? this.showLegend,
          showLabels: showLabels ?? this.showLabels);
  Map<String, dynamic> toJson() => {
        'type': type.name,
        'title': title,
        'xAxisKey': xAxisKey,
        'yAxisKey': yAxisKey,
        'showLegend': showLegend,
        'showLabels': showLabels
      };
  factory ChartConfig.fromJson(Map<String, dynamic> j) => ChartConfig(
      type: ChartType.values
          .firstWhere((e) => e.name == j['type'], orElse: () => ChartType.none),
      title: j['title'],
      xAxisKey: j['xAxisKey'],
      yAxisKey: j['yAxisKey'],
      showLegend: j['showLegend'] ?? true,
      showLabels: j['showLabels'] ?? true);
}

class ReportConfig {
  final ReportType reportType;
  final String? title, description;
  final List<ReportColumn> columns;
  final List<ReportFilter> filters;
  final SortConfig? sortConfig;
  final GroupByOption groupBy;
  final ReportDateRange dateRange;
  final DateTime? customStartDate, customEndDate;
  final ChartConfig chartConfig;
  final bool showSummary, showTotals;
  final int? limit;

  const ReportConfig(
      {required this.reportType,
      this.title,
      this.description,
      this.columns = const [],
      this.filters = const [],
      this.sortConfig,
      this.groupBy = GroupByOption.none,
      this.dateRange = ReportDateRange.thisMonth,
      this.customStartDate,
      this.customEndDate,
      this.chartConfig = const ChartConfig(),
      this.showSummary = true,
      this.showTotals = true,
      this.limit});

  DateTimeRange get effectiveDateRange =>
      (dateRange == ReportDateRange.custom &&
              customStartDate != null &&
              customEndDate != null)
          ? DateTimeRange(start: customStartDate!, end: customEndDate!)
          : dateRange.getRange();
  List<ReportColumn> get visibleColumns =>
      columns.where((c) => c.isVisible).toList();

  ReportConfig copyWith(
          {ReportType? reportType,
          String? title,
          String? description,
          List<ReportColumn>? columns,
          List<ReportFilter>? filters,
          SortConfig? sortConfig,
          GroupByOption? groupBy,
          ReportDateRange? dateRange,
          DateTime? customStartDate,
          DateTime? customEndDate,
          ChartConfig? chartConfig,
          bool? showSummary,
          bool? showTotals,
          int? limit}) =>
      ReportConfig(
          reportType: reportType ?? this.reportType,
          title: title ?? this.title,
          description: description ?? this.description,
          columns: columns ?? this.columns,
          filters: filters ?? this.filters,
          sortConfig: sortConfig ?? this.sortConfig,
          groupBy: groupBy ?? this.groupBy,
          dateRange: dateRange ?? this.dateRange,
          customStartDate: customStartDate ?? this.customStartDate,
          customEndDate: customEndDate ?? this.customEndDate,
          chartConfig: chartConfig ?? this.chartConfig,
          showSummary: showSummary ?? this.showSummary,
          showTotals: showTotals ?? this.showTotals,
          limit: limit ?? this.limit);

  Map<String, dynamic> toJson() => {
        'reportType': reportType.name,
        'title': title,
        'description': description,
        'columns': columns.map((c) => c.toJson()).toList(),
        'filters': filters.map((f) => f.toJson()).toList(),
        'sortConfig': sortConfig?.toJson(),
        'groupBy': groupBy.name,
        'dateRange': dateRange.name,
        'customStartDate': customStartDate?.toIso8601String(),
        'customEndDate': customEndDate?.toIso8601String(),
        'chartConfig': chartConfig.toJson(),
        'showSummary': showSummary,
        'showTotals': showTotals,
        'limit': limit
      };
  factory ReportConfig.fromJson(Map<String, dynamic> j) => ReportConfig(
      reportType: ReportType.values.firstWhere((e) => e.name == j['reportType'],
          orElse: () => ReportType.custom),
      title: j['title'],
      description: j['description'],
      columns: (j['columns'] as List?)
              ?.map((e) => ReportColumn.fromJson(e))
              .toList() ??
          [],
      filters: (j['filters'] as List?)
              ?.map((e) => ReportFilter.fromJson(e))
              .toList() ??
          [],
      sortConfig:
          j['sortConfig'] != null ? SortConfig.fromJson(j['sortConfig']) : null,
      groupBy: GroupByOption.values.firstWhere((e) => e.name == j['groupBy'],
          orElse: () => GroupByOption.none),
      dateRange: ReportDateRange.values.firstWhere((e) => e.name == j['dateRange'],
          orElse: () => ReportDateRange.thisMonth),
      customStartDate: j['customStartDate'] != null
          ? DateTime.parse(j['customStartDate'])
          : null,
      customEndDate: j['customEndDate'] != null
          ? DateTime.parse(j['customEndDate'])
          : null,
      chartConfig: j['chartConfig'] != null
          ? ChartConfig.fromJson(j['chartConfig'])
          : const ChartConfig(),
      showSummary: j['showSummary'] ?? true,
      showTotals: j['showTotals'] ?? true,
      limit: j['limit']);
  String toJsonString() => jsonEncode(toJson());
}

class ReportPreset {
  final String id, userId, name;
  final String? description;
  final ReportConfig config;
  final DateTime createdAt, updatedAt;
  final bool isFavorite, isDefault;

  const ReportPreset(
      {required this.id,
      required this.userId,
      required this.name,
      this.description,
      required this.config,
      required this.createdAt,
      required this.updatedAt,
      this.isFavorite = false,
      this.isDefault = false});

  ReportPreset copyWith(
          {String? id,
          String? userId,
          String? name,
          String? description,
          ReportConfig? config,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isFavorite,
          bool? isDefault}) =>
      ReportPreset(
          id: id ?? this.id,
          userId: userId ?? this.userId,
          name: name ?? this.name,
          description: description ?? this.description,
          config: config ?? this.config,
          createdAt: createdAt ?? this.createdAt,
          updatedAt: updatedAt ?? this.updatedAt,
          isFavorite: isFavorite ?? this.isFavorite,
          isDefault: isDefault ?? this.isDefault);

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'name': name,
        'description': description,
        'config': config.toJson(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'isFavorite': isFavorite,
        'isDefault': isDefault
      };
  factory ReportPreset.fromJson(Map<String, dynamic> j) => ReportPreset(
      id: j['id'],
      userId: j['userId'],
      name: j['name'],
      description: j['description'],
      config: ReportConfig.fromJson(j['config']),
      createdAt: DateTime.parse(j['createdAt']),
      updatedAt: DateTime.parse(j['updatedAt']),
      isFavorite: j['isFavorite'] ?? false,
      isDefault: j['isDefault'] ?? false);
}
