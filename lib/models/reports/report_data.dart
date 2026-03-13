import 'report_config.dart';
import 'report_types.dart';

/// ============================================================
/// REPORT DATA STRUCTURES (Updated)
/// ============================================================
/// Updated to match ReportRepository field names and add Tyre columns.
/// ============================================================

class ReportRow {
  final Map<String, dynamic> data;
  final bool isGroupHeader, isSubtotal;
  final int level;

  const ReportRow({
    required this.data,
    this.isGroupHeader = false,
    this.isSubtotal = false,
    this.level = 0,
  });

  dynamic getValue(String key) => data[key];

  String getFormattedValue(String key, ReportColumn col) {
    final v = data[key];
    if (v == null) return '-';
    return switch (col.dataType) {
      ColumnDataType.currency =>
        'AED ${(v is num ? v.toStringAsFixed(2) : v.toString())}',
      ColumnDataType.percentage =>
        '${(v is num ? v.toStringAsFixed(1) : v.toString())}%',
      ColumnDataType.number => v is num
          ? v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 2)
          : v.toString(),
      ColumnDataType.date => v is DateTime
          ? '${v.day.toString().padLeft(2, '0')}/${v.month.toString().padLeft(2, '0')}/${v.year}'
          : v.toString(),
      ColumnDataType.dateTime => v is DateTime
          ? '${v.day.toString().padLeft(2, '0')}/${v.month.toString().padLeft(2, '0')}/${v.year} ${v.hour.toString().padLeft(2, '0')}:${v.minute.toString().padLeft(2, '0')}'
          : v.toString(),
      ColumnDataType.boolean => v == true ? 'Yes' : 'No',
      ColumnDataType.status => v.toString(),
      ColumnDataType.list => v is List ? v.join(', ') : v.toString(),
      _ => v.toString(),
    };
  }
}

class ReportSummary {
  final int totalRows, filteredRows;
  final Map<String, dynamic> aggregations;
  final Map<String, int> statusBreakdown;
  final Map<String, dynamic> highlights;

  const ReportSummary({
    required this.totalRows,
    required this.filteredRows,
    this.aggregations = const {},
    this.statusBreakdown = const {},
    this.highlights = const {},
  });
}

class ChartDataPoint {
  final String label;
  final double value;
  final String? category, color;
  const ChartDataPoint({
    required this.label,
    required this.value,
    this.category,
    this.color,
  });
}

class ChartSeries {
  final String name;
  final List<ChartDataPoint> data;
  final String? color;
  const ChartSeries({required this.name, required this.data, this.color});
}

class ChartData {
  final ChartType type;
  final String? title;
  final List<ChartSeries> series;
  final List<String> labels;

  const ChartData({
    required this.type,
    this.title,
    required this.series,
    required this.labels,
  });

  List<ChartDataPoint> get singleSeriesData =>
      series.isNotEmpty ? series.first.data : [];
}

class GeneratedReport {
  final String id;
  final ReportConfig config;
  final List<ReportColumn> columns;
  final List<ReportRow> rows;
  final ReportSummary summary;
  final ChartData? chartData;
  final DateTime generatedAt;
  final String? companyId;
  final Duration processingTime;

  const GeneratedReport({
    required this.id,
    required this.config,
    required this.columns,
    required this.rows,
    required this.summary,
    this.chartData,
    required this.generatedAt,
    this.companyId,
    this.processingTime = Duration.zero,
  });

  String get title => config.title ?? config.reportType.label;
  int get dataRowCount =>
      rows.where((r) => !r.isGroupHeader && !r.isSubtotal).length;
  bool get hasData => rows.isNotEmpty;
  bool get hasChart =>
      chartData != null && config.chartConfig.type != ChartType.none;
}

// ============================================================
// COLUMN DEFINITIONS
// ============================================================

class ReportColumnDefinitions {
  ReportColumnDefinitions._();

  // ==================== VEHICLE COLUMNS ====================
  static const vehicleColumns = [
    ReportColumn(
      key: 'vehicleNo',
      label: 'Vehicle No',
      dataType: ColumnDataType.text,
      width: 100,
      isGroupable: true,
    ),
    ReportColumn(
      key: 'description',
      label: 'Description',
      dataType: ColumnDataType.text,
      width: 150,
    ),
    ReportColumn(
      key: 'brand',
      label: 'Brand',
      dataType: ColumnDataType.text,
      width: 100,
      isGroupable: true,
    ),
    ReportColumn(
      key: 'model',
      label: 'Model',
      dataType: ColumnDataType.text,
      width: 100,
      isGroupable: true,
    ),
    ReportColumn(
      key: 'type',
      label: 'Type',
      dataType: ColumnDataType.text,
      width: 90,
      isGroupable: true,
    ),
    ReportColumn(
      key: 'status',
      label: 'Status',
      dataType: ColumnDataType.status,
      width: 100,
      isGroupable: true,
    ),
    ReportColumn(
      key: 'city',
      label: 'City',
      dataType: ColumnDataType.text,
      width: 120,
      isGroupable: true,
    ),
    ReportColumn(
      key: 'vYear',
      label: 'Year',
      dataType: ColumnDataType.number,
      width: 70,
    ),
    ReportColumn(
      key: 'currentOdo',
      label: 'Current Odo',
      dataType: ColumnDataType.number,
      width: 100,
    ),
    ReportColumn(
      key: 'condition',
      label: 'Condition',
      dataType: ColumnDataType.text,
      width: 100,
      isGroupable: true,
    ),
  ];

  // ==================== FINE COLUMNS ====================
  static const fineColumns = [
    ReportColumn(
      key: 'fineId',
      label: 'Fine ID',
      dataType: ColumnDataType.number,
      width: 80,
    ),
    ReportColumn(
      key: 'vehicleNo',
      label: 'Vehicle No',
      dataType: ColumnDataType.text,
      width: 100,
      isGroupable: true,
    ),
    ReportColumn(
      key: 'empNo',
      label: 'Emp No',
      dataType: ColumnDataType.text,
      width: 90,
      isGroupable: true,
    ),
    ReportColumn(
      key: 'empName',
      label: 'Employee',
      dataType: ColumnDataType.text,
      width: 150,
      isGroupable: true,
    ),
    ReportColumn(
      key: 'fineType',
      label: 'Fine Type',
      dataType: ColumnDataType.text,
      width: 150,
      isGroupable: true,
    ),
    ReportColumn(
      key: 'fineDate',
      label: 'Date',
      dataType: ColumnDataType.date,
      width: 100,
    ),
    ReportColumn(
      key: 'amount',
      label: 'Amount',
      dataType: ColumnDataType.currency,
      width: 100,
      aggregation: AggregationType.sum,
    ),
    ReportColumn(
      key: 'location',
      label: 'Location',
      dataType: ColumnDataType.text,
      width: 150,
    ),
    ReportColumn(
      key: 'emirate',
      label: 'Emirate',
      dataType: ColumnDataType.text,
      width: 100,
      isGroupable: true,
    ),
    ReportColumn(
      key: 'status',
      label: 'Status',
      dataType: ColumnDataType.status,
      width: 90,
      isGroupable: true,
    ),
  ];

  // ==================== DOCUMENT COLUMNS ====================
  // Updated: docTypeName (resolved name from DocumentMaster)
  static const documentColumns = [
    ReportColumn(
      key: 'vehicleNo',
      label: 'Vehicle No',
      dataType: ColumnDataType.text,
      width: 100,
      isGroupable: true,
    ),
    ReportColumn(
      key: 'docTypeName',
      label: 'Document Type',
      dataType: ColumnDataType.text,
      width: 150,
      isGroupable: true,
    ),
    ReportColumn(
      key: 'documentNo',
      label: 'Document No',
      dataType: ColumnDataType.text,
      width: 120,
    ),
    ReportColumn(
      key: 'issueDate',
      label: 'Issue Date',
      dataType: ColumnDataType.date,
      width: 100,
    ),
    ReportColumn(
      key: 'expiryDate',
      label: 'Expiry Date',
      dataType: ColumnDataType.date,
      width: 100,
    ),
    ReportColumn(
      key: 'daysToExpiry',
      label: 'Days to Expiry',
      dataType: ColumnDataType.number,
      width: 110,
    ),
    ReportColumn(
      key: 'expiryStatus',
      label: 'Expiry Status',
      dataType: ColumnDataType.status,
      width: 110,
      isGroupable: true,
    ),
    ReportColumn(
      key: 'issueAuthority',
      label: 'Authority',
      dataType: ColumnDataType.text,
      width: 100,
      isGroupable: true,
    ),
    ReportColumn(
      key: 'city',
      label: 'City',
      dataType: ColumnDataType.text,
      width: 100,
      isGroupable: true,
    ),
  ];

  // ==================== MAINTENANCE COLUMNS ====================
  static const maintenanceColumns = [
    ReportColumn(
      key: 'recordId',
      label: 'ID',
      dataType: ColumnDataType.number,
      width: 70,
    ),
    ReportColumn(
      key: 'vehicleNo',
      label: 'Vehicle No',
      dataType: ColumnDataType.text,
      width: 100,
      isGroupable: true,
    ),
    ReportColumn(
      key: 'maintenanceType',
      label: 'Type',
      dataType: ColumnDataType.text,
      width: 150,
      isGroupable: true,
    ),
    ReportColumn(
      key: 'serviceDate',
      label: 'Service Date',
      dataType: ColumnDataType.date,
      width: 100,
    ),
    ReportColumn(
      key: 'nextServiceDate',
      label: 'Next Service',
      dataType: ColumnDataType.date,
      width: 100,
    ),
    ReportColumn(
      key: 'odometerReading',
      label: 'Odometer',
      dataType: ColumnDataType.number,
      width: 100,
    ),
    ReportColumn(
      key: 'amount',
      label: 'Cost',
      dataType: ColumnDataType.currency,
      width: 100,
      aggregation: AggregationType.sum,
    ),
    ReportColumn(
      key: 'garageName',
      label: 'Garage',
      dataType: ColumnDataType.text,
      width: 150,
      isGroupable: true,
    ),
    ReportColumn(
      key: 'invoiceNumber',
      label: 'Invoice No',
      dataType: ColumnDataType.text,
      width: 120,
    ),
  ];

  // ==================== ASSIGNMENT COLUMNS ====================
  // Updated: durationDays (calculated by repo)
  static const assignmentColumns = [
    ReportColumn(
      key: 'vehicleNo',
      label: 'Vehicle No',
      dataType: ColumnDataType.text,
      width: 100,
      isGroupable: true,
    ),
    ReportColumn(
      key: 'empNo',
      label: 'Emp No',
      dataType: ColumnDataType.text,
      width: 90,
      isGroupable: true,
    ),
    ReportColumn(
      key: 'empName',
      label: 'Employee',
      dataType: ColumnDataType.text,
      width: 150,
      isGroupable: true,
    ),
    ReportColumn(
      key: 'designation',
      label: 'Designation',
      dataType: ColumnDataType.text,
      width: 120,
      isGroupable: true,
    ),
    ReportColumn(
      key: 'department',
      label: 'Department',
      dataType: ColumnDataType.text,
      width: 120,
      isGroupable: true,
    ),
    ReportColumn(
      key: 'assignedDate',
      label: 'Assigned',
      dataType: ColumnDataType.date,
      width: 100,
    ),
    ReportColumn(
      key: 'returnDate',
      label: 'Returned',
      dataType: ColumnDataType.date,
      width: 100,
    ),
    ReportColumn(
      key: 'durationDays',
      label: 'Days',
      dataType: ColumnDataType.number,
      width: 80,
    ),
    ReportColumn(
      key: 'status',
      label: 'Status',
      dataType: ColumnDataType.status,
      width: 90,
      isGroupable: true,
    ),
  ];

  // ==================== TYRE COLUMNS (NEW) ====================
  static const tyreColumns = [
    ReportColumn(
      key: 'tyreId',
      label: 'Tyre ID',
      dataType: ColumnDataType.number,
      width: 80,
    ),
    ReportColumn(
      key: 'vehicleNo',
      label: 'Vehicle No',
      dataType: ColumnDataType.text,
      width: 100,
      isGroupable: true,
    ),
    ReportColumn(
      key: 'position',
      label: 'Position',
      dataType: ColumnDataType.text,
      width: 100,
      isGroupable: true,
    ),
    ReportColumn(
      key: 'brand',
      label: 'Brand',
      dataType: ColumnDataType.text,
      width: 120,
      isGroupable: true,
    ),
    ReportColumn(
      key: 'size',
      label: 'Size',
      dataType: ColumnDataType.text,
      width: 100,
      isGroupable: true,
    ),
    ReportColumn(
      key: 'installDt',
      label: 'Install Date',
      dataType: ColumnDataType.date,
      width: 100,
    ),
    ReportColumn(
      key: 'expDt',
      label: 'Expiry Date',
      dataType: ColumnDataType.date,
      width: 100,
    ),
    ReportColumn(
      key: 'daysToExpiry',
      label: 'Days to Expiry',
      dataType: ColumnDataType.number,
      width: 110,
    ),
    ReportColumn(
      key: 'expiryStatus',
      label: 'Expiry Status',
      dataType: ColumnDataType.status,
      width: 100,
      isGroupable: true,
    ),
    ReportColumn(
      key: 'kmUsed',
      label: 'KM Used',
      dataType: ColumnDataType.number,
      width: 90,
    ),
    ReportColumn(
      key: 'status',
      label: 'Status',
      dataType: ColumnDataType.status,
      width: 90,
      isGroupable: true,
    ),
  ];

  // ==================== FINANCIAL COLUMNS ====================
  static const financialColumns = [
    ReportColumn(
      key: 'category',
      label: 'Category',
      dataType: ColumnDataType.text,
      width: 130,
      isGroupable: true,
    ),
    ReportColumn(
      key: 'vehicleNo',
      label: 'Vehicle No',
      dataType: ColumnDataType.text,
      width: 100,
      isGroupable: true,
    ),
    ReportColumn(
      key: 'date',
      label: 'Date',
      dataType: ColumnDataType.date,
      width: 100,
    ),
    ReportColumn(
      key: 'description',
      label: 'Description',
      dataType: ColumnDataType.text,
      width: 160,
    ),
    ReportColumn(
      key: 'cost',
      label: 'Amount',
      dataType: ColumnDataType.currency,
      width: 110,
      aggregation: AggregationType.sum,
    ),
    ReportColumn(
      key: 'reference',
      label: 'Reference',
      dataType: ColumnDataType.text,
      width: 120,
    ),
    ReportColumn(
      key: 'vendor',
      label: 'Vendor / Authority',
      dataType: ColumnDataType.text,
      width: 150,
      isGroupable: true,
    ),
    ReportColumn(
      key: 'empName',
      label: 'Employee',
      dataType: ColumnDataType.text,
      width: 150,
      isGroupable: true,
    ),
    ReportColumn(
      key: 'status',
      label: 'Status',
      dataType: ColumnDataType.status,
      width: 90,
      isGroupable: true,
    ),
  ];

  // ==================== OPERATIONAL COLUMNS ====================
  static const operationalColumns = [
    ReportColumn(
      key: 'vehicleNo',
      label: 'Vehicle No',
      dataType: ColumnDataType.text,
      width: 100,
      isGroupable: true,
    ),
    ReportColumn(
      key: 'brand',
      label: 'Brand',
      dataType: ColumnDataType.text,
      width: 100,
      isGroupable: true,
    ),
    ReportColumn(
      key: 'model',
      label: 'Model',
      dataType: ColumnDataType.text,
      width: 100,
    ),
    ReportColumn(
      key: 'type',
      label: 'Type',
      dataType: ColumnDataType.text,
      width: 90,
      isGroupable: true,
    ),
    ReportColumn(
      key: 'status',
      label: 'Status',
      dataType: ColumnDataType.status,
      width: 100,
      isGroupable: true,
    ),
    ReportColumn(
      key: 'assignedTo',
      label: 'Assigned To',
      dataType: ColumnDataType.text,
      width: 150,
    ),
    ReportColumn(
      key: 'currentOdo',
      label: 'Odometer',
      dataType: ColumnDataType.number,
      width: 100,
    ),
    ReportColumn(
      key: 'condition',
      label: 'Condition',
      dataType: ColumnDataType.text,
      width: 100,
      isGroupable: true,
    ),
  ];

  /// Get columns for a given report type
  static List<ReportColumn> getColumnsForType(ReportType type) {
    return switch (type.category) {
      ReportCategory.vehicle => List.from(vehicleColumns),
      ReportCategory.fine => List.from(fineColumns),
      ReportCategory.document => List.from(documentColumns),
      ReportCategory.maintenance => List.from(maintenanceColumns),
      ReportCategory.assignment => List.from(assignmentColumns),
      ReportCategory.tyre => List.from(tyreColumns),
      ReportCategory.financial => List.from(financialColumns),
      ReportCategory.operational => List.from(operationalColumns),
    };
  }
}
