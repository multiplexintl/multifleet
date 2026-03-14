import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/reports/report_config.dart';
import '../models/reports/report_data.dart';
import '../models/reports/report_types.dart';

import '../repo/report_repo.dart';
import '../services/report_export_service.dart';
import '../services/report_service.dart';

import 'package:multifleet/models/company.dart';
import 'package:multifleet/services/company_service.dart';

/// ============================================================
/// REPORT CONTROLLER (Updated with Real API Integration)
/// ============================================================
/// Implements CompanyAwareController to react to company changes.
/// Uses ReportRepository for data fetching.
/// ============================================================

class ReportController extends GetxController
    implements CompanyAwareController {
  final _reportService = ReportService.instance;
  final _reportRepo = ReportRepository();

  // Company service reference
  late final CompanyService _companyService;

  // ==================== STATE ====================

  final Rx<ReportConfig> currentConfig = Rx<ReportConfig>(
    const ReportConfig(reportType: ReportType.fleetInventory),
  );
  final Rx<GeneratedReport?> generatedReport = Rx<GeneratedReport?>(null);
  final RxList<ReportPreset> userPresets = <ReportPreset>[].obs;
  final RxList<ReportPreset> builtInPresets = <ReportPreset>[].obs;
  final RxList<ReportConfig> recentReports = <ReportConfig>[].obs;

  // Loading states
  final isLoading = false.obs;
  final isGenerating = false.obs;
  final isExporting = false.obs;
  final errorMessage = RxnString(null);

  // UI state
  final Rx<ReportCategory> selectedCategory = ReportCategory.vehicle.obs;
  final Rx<ReportType?> selectedReportType = Rx<ReportType?>(null);
  final showPresetPanel = true.obs;
  final selectedTab = 0.obs;

  // Column/Filter state
  final RxList<ReportColumn> availableColumns = <ReportColumn>[].obs;
  final RxList<String> selectedColumnKeys = <String>[].obs;
  final RxList<ReportFilter> activeFilters = <ReportFilter>[].obs;

  // ==================== GETTERS ====================

  String get currentUserId => 'user_default'; // TODO: Get from auth service
  String get currentCompanyId =>
      _companyService.selectedCompanyObs.value?.id ?? 'EPIC01';

  List<ReportPreset> get allPresets => [...builtInPresets, ...userPresets];
  List<ReportPreset> get favoritePresets =>
      userPresets.where((p) => p.isFavorite).toList();
  List<ReportPreset> get categoryPresets => allPresets
      .where((p) => p.config.reportType.category == selectedCategory.value)
      .toList();
  List<ReportType> get categoryReportTypes =>
      ReportType.forCategory(selectedCategory.value);
  bool get hasReportData => generatedReport.value?.hasData ?? false;

  // ==================== LIFECYCLE ====================

  @override
  void onInit() {
    super.onInit();
    _companyService = Get.find<CompanyService>();
    _companyService.registerController(this);
    _init();
  }

  @override
  void onClose() {
    _companyService.unregisterController(this);
    super.onClose();
  }

  @override
  Future<void> onCompanyChanged(Company newCompany) async {
    log('[ReportController] Company changed to: ${newCompany.id}');
    // Clear cached data and regenerate if a report was generated
    _reportRepo.clearCache();
    generatedReport.value = null;
  }

  void _init() {
    builtInPresets.value = _getBuiltInPresets();
    _initializeColumns();
  }

  // ==================== PRESET MANAGEMENT ====================

  void loadPreset(ReportPreset preset) {
    currentConfig.value = preset.config;
    selectedReportType.value = preset.config.reportType;
    selectedCategory.value = preset.config.reportType.category;
    _initializeColumns();
    activeFilters.value = List.from(preset.config.filters);
  }

  Future<void> saveAsPreset({
    required String name,
    String? description,
    bool isFavorite = false,
    bool isDefault = false,
  }) async {
    final preset = ReportPreset(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: currentUserId,
      name: name,
      description: description,
      config: currentConfig.value,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isFavorite: isFavorite,
      isDefault: isDefault,
    );
    userPresets.add(preset);
    Get.snackbar(
      'Success',
      'Preset saved: $name',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.9),
      colorText: Colors.white,
    );
  }

  Future<void> deletePreset(String id) async =>
      userPresets.removeWhere((p) => p.id == id);

  Future<void> togglePresetFavorite(String id) async {
    final idx = userPresets.indexWhere((p) => p.id == id);
    if (idx != -1) {
      userPresets[idx] =
          userPresets[idx].copyWith(isFavorite: !userPresets[idx].isFavorite);
    }
  }

  // ==================== CONFIGURATION ====================

  void setReportType(ReportType type) {
    selectedReportType.value = type;
    currentConfig.value = currentConfig.value.copyWith(
      reportType: type,
      title: type.label,
      columns: ReportColumnDefinitions.getColumnsForType(type),
    );
    _initializeColumns();
    generatedReport.value = null;
  }

  void setCategory(ReportCategory cat) {
    selectedCategory.value = cat;
    final types = ReportType.forCategory(cat);
    if (types.isNotEmpty) setReportType(types.first);
  }

  void setDateRange(ReportDateRange range) =>
      currentConfig.value = currentConfig.value.copyWith(dateRange: range);

  void setCustomDateRange(DateTime start, DateTime end) =>
      currentConfig.value = currentConfig.value.copyWith(
        dateRange: ReportDateRange.custom,
        customStartDate: start,
        customEndDate: end,
      );

  void setGroupBy(GroupByOption opt) =>
      currentConfig.value = currentConfig.value.copyWith(groupBy: opt);

  void setSortConfig(String key, SortDirection dir) =>
      currentConfig.value = currentConfig.value.copyWith(
        sortConfig: SortConfig(columnKey: key, direction: dir),
      );

  void clearSort() =>
      currentConfig.value = currentConfig.value.copyWith(sortConfig: null);

  void toggleShowSummary() => currentConfig.value = currentConfig.value
      .copyWith(showSummary: !currentConfig.value.showSummary);

  void toggleShowTotals() => currentConfig.value =
      currentConfig.value.copyWith(showTotals: !currentConfig.value.showTotals);

  void setLimit(int? limit) =>
      currentConfig.value = currentConfig.value.copyWith(limit: limit);

  // ==================== COLUMN MANAGEMENT ====================

  void _initializeColumns() {
    final cols = currentConfig.value.columns.isNotEmpty
        ? currentConfig.value.columns
        : ReportColumnDefinitions.getColumnsForType(
            currentConfig.value.reportType);
    availableColumns.value = cols;
    selectedColumnKeys.value =
        cols.where((c) => c.isVisible).map((c) => c.key).toList();
  }

  void toggleColumn(String key) {
    selectedColumnKeys.contains(key)
        ? selectedColumnKeys.remove(key)
        : selectedColumnKeys.add(key);
    _updateColumnsInConfig();
  }

  void selectAllColumns() {
    selectedColumnKeys.value = availableColumns.map((c) => c.key).toList();
    _updateColumnsInConfig();
  }

  void clearAllColumns() {
    selectedColumnKeys.clear();
    _updateColumnsInConfig();
  }

  void _updateColumnsInConfig() {
    final updated = availableColumns
        .map((c) => c.copyWith(isVisible: selectedColumnKeys.contains(c.key)))
        .toList();
    currentConfig.value = currentConfig.value.copyWith(columns: updated);
  }

  // ==================== FILTER MANAGEMENT ====================

  void addFilter(ReportFilter f) {
    activeFilters.add(f);
    _syncFiltersToConfig();
  }

  void updateFilter(int idx, ReportFilter f) {
    if (idx >= 0 && idx < activeFilters.length) {
      activeFilters[idx] = f;
      _syncFiltersToConfig();
    }
  }

  void removeFilter(int idx) {
    if (idx >= 0 && idx < activeFilters.length) {
      activeFilters.removeAt(idx);
      _syncFiltersToConfig();
    }
  }

  void clearAllFilters() {
    activeFilters.clear();
    _syncFiltersToConfig();
  }

  void _syncFiltersToConfig() => currentConfig.value =
      currentConfig.value.copyWith(filters: List.from(activeFilters));

  // ==================== CHART CONFIGURATION ====================

  void setChartType(ChartType type) =>
      currentConfig.value = currentConfig.value.copyWith(
          chartConfig: currentConfig.value.chartConfig.copyWith(type: type));

  void setChartTitle(String title) =>
      currentConfig.value = currentConfig.value.copyWith(
          chartConfig: currentConfig.value.chartConfig.copyWith(title: title));

  void setChartAxes(String? x, String? y) =>
      currentConfig.value = currentConfig.value.copyWith(
        chartConfig:
            currentConfig.value.chartConfig.copyWith(xAxisKey: x, yAxisKey: y),
      );

  // ==================== REPORT GENERATION ====================

  Future<void> generateReport() async {
    if (selectedReportType.value == null) {
      Get.snackbar(
        'Error',
        'Please select a report type first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.9),
        colorText: Colors.white,
      );
      return;
    }

    isGenerating.value = true;
    errorMessage.value = null;

    try {
      log('[ReportController] Generating report: ${currentConfig.value.reportType}');
      final rawData = await _fetchReportData();

      if (rawData.isEmpty) {
        errorMessage.value = 'No data found for the selected criteria';
        Get.snackbar(
          'No Data',
          'No records found for this report',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.9),
          colorText: Colors.white,
        );
        return;
      }

      log('[ReportController] Processing ${rawData.length} records');

      final report = _reportService.generateReport(
        config: currentConfig.value,
        rawData: rawData,
        companyId: currentCompanyId,
      );

      generatedReport.value = report;
      selectedTab.value = 1; // Switch to preview tab

      // Add to recent reports
      recentReports.insert(0, currentConfig.value);
      if (recentReports.length > 10) recentReports.removeLast();

      log('[ReportController] Report generated: ${report.dataRowCount} rows');
    } catch (e, stack) {
      log('[ReportController] Error: $e');
      log('[ReportController] Stack: $stack');
      errorMessage.value = 'Failed to generate report: $e';
      Get.snackbar(
        'Error',
        'Failed to generate report',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
      );
    } finally {
      isGenerating.value = false;
    }
  }

  /// Fetch report data from APIs based on report category
  Future<List<Map<String, dynamic>>> _fetchReportData() async {
    final company = currentCompanyId;
    final category = currentConfig.value.reportType.category;

    log('[ReportController] Fetching data for category: $category, company: $company');

    switch (category) {
      case ReportCategory.vehicle:
        final result = await _reportRepo.getVehiclesForReport(company);
        return result.fold(
          (error) {
            log('[ReportController] Vehicle fetch error: $error');
            return <Map<String, dynamic>>[];
          },
          (data) => data,
        );

      case ReportCategory.fine:
        final result = await _reportRepo.getFinesForReport(company);
        return result.fold(
          (error) {
            log('[ReportController] Fine fetch error: $error');
            return <Map<String, dynamic>>[];
          },
          (data) => data,
        );

      case ReportCategory.document:
        final result = await _reportRepo.getDocumentsForReport(company);
        return result.fold(
          (error) {
            log('[ReportController] Document fetch error: $error');
            return <Map<String, dynamic>>[];
          },
          (data) => data,
        );

      case ReportCategory.assignment:
        final result = await _reportRepo.getAssignmentsForReport(company);
        return result.fold(
          (error) {
            log('[ReportController] Assignment fetch error: $error');
            return <Map<String, dynamic>>[];
          },
          (data) => data,
        );

      case ReportCategory.tyre:
        final result = await _reportRepo.getTyresForReport(company);
        return result.fold(
          (error) {
            log('[ReportController] Tyre fetch error: $error');
            return <Map<String, dynamic>>[];
          },
          (data) => data,
        );

      case ReportCategory.maintenance:
        // TODO: Enable when maintenance API is ready
        final result = await _reportRepo.getMaintenanceForReport(company);
        return result.fold(
          (error) {
            log('[ReportController] Maintenance fetch error: $error');
            return <Map<String, dynamic>>[];
          },
          (data) => data,
        );

      case ReportCategory.financial:
        // Financial reports combine multiple data sources
        return _fetchFinancialData(company);

      case ReportCategory.operational:
        // Operational reports combine multiple data sources
        return _fetchOperationalData(company);
    }
  }

  /// Fetch combined data for financial reports
  Future<List<Map<String, dynamic>>> _fetchFinancialData(String company) async {
    final List<Map<String, dynamic>> combined = [];

    // Fines
    final finesResult = await _reportRepo.getFinesForReport(company);
    finesResult.fold(
      (error) => log('[ReportController] Financial: fines error: $error'),
      (data) {
        for (final f in data) {
          combined.add({
            ...f,
            'category': 'Fine',
            'description': f['fineType'] ?? '',
            'cost': f['amount'] ?? 0.0,
            'date': f['fineDate'],
            'reference': f['ticketNo'] ?? '',
            'vendor': f['issuingAuthority'] ?? '',
          });
        }
      },
    );

    // Maintenance / Service
    final maintResult = await _reportRepo.getMaintenanceForReport(company);
    maintResult.fold(
      (error) => log('[ReportController] Financial: maintenance error: $error'),
      (data) {
        for (final m in data) {
          combined.add({
            ...m,
            'category': 'Maintenance',
            'description': m['maintenanceType'] ?? '',
            'cost': m['amount'] ?? 0.0,
            'date': m['serviceDate'],
            'reference': m['invoiceNo'] ?? '',
            'vendor': m['garageName'] ?? '',
          });
        }
      },
    );

    // Document renewals (only records that have an amount)
    final docsResult = await _reportRepo.getDocumentsForReport(company);
    docsResult.fold(
      (error) => log('[ReportController] Financial: documents error: $error'),
      (data) {
        for (final d in data) {
          final amt = d['amount'];
          if (amt != null && (amt as num) > 0) {
            combined.add({
              ...d,
              'category': 'Document Renewal',
              'description': d['docTypeName'] ?? '',
              'cost': amt.toDouble(),
              'date': d['issueDate'],
              'reference': d['documentNo'] ?? '',
              'vendor': d['issueAuthority'] ?? '',
            });
          }
        }
      },
    );

    return combined;
  }

  /// Fetch combined data for operational reports
  Future<List<Map<String, dynamic>>> _fetchOperationalData(
      String company) async {
    final List<Map<String, dynamic>> combined = [];

    // Get vehicles with status info
    final vehiclesResult = await _reportRepo.getVehiclesForReport(company);
    vehiclesResult.fold(
      (error) => log('[ReportController] Operational: vehicles error: $error'),
      (data) => combined.addAll(data),
    );

    // Enrich with assignment info
    final assignResult = await _reportRepo.getAssignmentsForReport(company);
    assignResult.fold(
      (error) =>
          log('[ReportController] Operational: assignments error: $error'),
      (assignments) {
        // Create a map of active assignments by vehicle
        final activeAssignments = <String, Map<String, dynamic>>{};
        for (final a in assignments) {
          if (a['isActive'] == true) {
            activeAssignments[a['vehicleNo']] = a;
          }
        }

        // Enrich vehicle data with assignment info
        for (int i = 0; i < combined.length; i++) {
          final vehicleNo = combined[i]['vehicleNo'];
          if (activeAssignments.containsKey(vehicleNo)) {
            combined[i] = {
              ...combined[i],
              'assignedTo': activeAssignments[vehicleNo]!['empName'],
              'assignedEmpNo': activeAssignments[vehicleNo]!['empNo'],
              'assignedDate': activeAssignments[vehicleNo]!['assignedDate'],
            };
          }
        }
      },
    );

    return combined;
  }

  // ==================== EXPORT ====================

  Future<void> exportReport(ExportFormat fmt) async {
    if (generatedReport.value == null) {
      Get.snackbar(
        'Error',
        'Generate a report first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.9),
        colorText: Colors.white,
      );
      return;
    }

    isExporting.value = true;
    try {
      final report = generatedReport.value!;
      if (fmt == ExportFormat.excel) {
        await ReportExportService.instance.exportExcel(report);
      } else if (fmt == ExportFormat.pdf) {
        await ReportExportService.instance.exportPdf(report);
      }
      Get.snackbar(
        'Exported',
        '${report.title} saved as ${fmt.label}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.9),
        colorText: Colors.white,
      );
    } catch (e) {
      log('[ReportController] Export error: $e');
      Get.snackbar(
        'Export Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
      );
    } finally {
      isExporting.value = false;
    }
  }

  // ==================== UI HELPERS ====================

  void togglePresetPanel() => showPresetPanel.value = !showPresetPanel.value;
  void setSelectedTab(int idx) => selectedTab.value = idx;

  void reset() {
    currentConfig.value =
        const ReportConfig(reportType: ReportType.fleetInventory);
    generatedReport.value = null;
    activeFilters.clear();
    selectedTab.value = 0;
    _initializeColumns();
  }

  // ==================== BUILT-IN PRESETS ====================

  List<ReportPreset> _getBuiltInPresets() {
    final now = DateTime.now();
    return [
      ReportPreset(
        id: 'b1',
        userId: 'system',
        name: 'Fleet Inventory',
        description: 'Complete list of all vehicles',
        config: const ReportConfig(
          reportType: ReportType.fleetInventory,
          title: 'Fleet Inventory',
          chartConfig: ChartConfig(
            type: ChartType.pie,
            title: 'Vehicles by Status',
            xAxisKey: 'status',
          ),
        ),
        createdAt: now,
        updatedAt: now,
      ),
      ReportPreset(
        id: 'b2',
        userId: 'system',
        name: 'Monthly Fines',
        description: 'Fines summary for current month',
        config: const ReportConfig(
          reportType: ReportType.fineSummary,
          title: 'Monthly Fines Summary',
          dateRange: ReportDateRange.thisMonth,
          chartConfig: ChartConfig(
            type: ChartType.bar,
            title: 'Fines by Type',
            xAxisKey: 'fineType',
            yAxisKey: 'amount',
          ),
        ),
        createdAt: now,
        updatedAt: now,
      ),
      ReportPreset(
        id: 'b3',
        userId: 'system',
        name: 'Unpaid Fines',
        description: 'All pending/unpaid traffic fines',
        config: ReportConfig(
          reportType: ReportType.unpaidFines,
          title: 'Unpaid Fines Report',
          filters: [
            const ReportFilter(
              columnKey: 'status',
              operator: FilterOperator.notEquals,
              value: 'Paid',
            ),
          ],
          chartConfig: const ChartConfig(
            type: ChartType.pie,
            title: 'Unpaid by Emirate',
            xAxisKey: 'emirate',
          ),
        ),
        createdAt: now,
        updatedAt: now,
      ),
      ReportPreset(
        id: 'b4',
        userId: 'system',
        name: 'Document Expiry Alert',
        description: 'Documents expiring within 60 days',
        config: const ReportConfig(
          reportType: ReportType.documentExpirySummary,
          title: 'Document Expiry Alert',
          dateRange: ReportDateRange.next60Days,
          chartConfig: ChartConfig(
            type: ChartType.bar,
            title: 'Expiring by Type',
            xAxisKey: 'docTypeName',
          ),
        ),
        createdAt: now,
        updatedAt: now,
      ),
      ReportPreset(
        id: 'b5',
        userId: 'system',
        name: 'Current Assignments',
        description: 'All active vehicle assignments',
        config: ReportConfig(
          reportType: ReportType.currentAssignments,
          title: 'Active Assignments',
          filters: [
            const ReportFilter(
              columnKey: 'status',
              operator: FilterOperator.equals,
              value: 'Active',
            ),
          ],
          groupBy: GroupByOption.department,
        ),
        createdAt: now,
        updatedAt: now,
      ),
      ReportPreset(
        id: 'b6',
        userId: 'system',
        name: 'Tyre Status',
        description: 'All tyres with expiry status',
        config: const ReportConfig(
          reportType: ReportType.tyreInventory,
          title: 'Tyre Status Report',
          chartConfig: ChartConfig(
            type: ChartType.pie,
            title: 'By Status',
            xAxisKey: 'expiryStatus',
          ),
        ),
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
