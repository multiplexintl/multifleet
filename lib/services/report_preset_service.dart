import 'dart:convert';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/reports/report_config.dart';
import '../models/reports/report_data.dart';
import '../models/reports/report_types.dart';

/// ============================================================
/// REPORT PRESET SERVICE
/// ============================================================
/// Service for managing saved report presets using SharedPreferences
/// ============================================================

class ReportPresetService {
  static const String _presetKeyPrefix = 'report_presets_';
  static const String _recentReportsKey = 'recent_reports_';
  static const int _maxRecentReports = 10;

  ReportPresetService._();
  static final ReportPresetService _instance = ReportPresetService._();
  static ReportPresetService get instance => _instance;

  SharedPreferences? _prefs;

  /// Initialize the service
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get storage key for user
  String _getPresetsKey(String userId) => '$_presetKeyPrefix$userId';
  String _getRecentKey(String userId) => '$_recentReportsKey$userId';

  // ==================== PRESET MANAGEMENT ====================

  /// Get all presets for a user
  Future<List<ReportPreset>> getPresets(String userId) async {
    await init();

    try {
      final key = _getPresetsKey(userId);
      final jsonString = _prefs?.getString(key);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((e) => ReportPreset.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log('[ReportPresetService] Error loading presets: $e');
      return [];
    }
  }

  /// Save a new preset
  Future<ReportPreset> savePreset({
    required String userId,
    required String name,
    String? description,
    required ReportConfig config,
    bool isFavorite = false,
    bool isDefault = false,
  }) async {
    await init();

    final presets = await getPresets(userId);

    // If setting as default, unset other defaults for same report type
    if (isDefault) {
      for (var i = 0; i < presets.length; i++) {
        if (presets[i].config.reportType == config.reportType &&
            presets[i].isDefault) {
          presets[i] = presets[i].copyWith(isDefault: false);
        }
      }
    }

    final preset = ReportPreset(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      name: name,
      description: description,
      config: config,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isFavorite: isFavorite,
      isDefault: isDefault,
    );

    presets.add(preset);
    await _savePresets(userId, presets);

    log('[ReportPresetService] Preset saved: ${preset.name}');
    return preset;
  }

  /// Update an existing preset
  Future<ReportPreset?> updatePreset({
    required String userId,
    required String presetId,
    String? name,
    String? description,
    ReportConfig? config,
    bool? isFavorite,
    bool? isDefault,
  }) async {
    await init();

    final presets = await getPresets(userId);
    final index = presets.indexWhere((p) => p.id == presetId);

    if (index == -1) {
      log('[ReportPresetService] Preset not found: $presetId');
      return null;
    }

    // If setting as default, unset other defaults for same report type
    if (isDefault == true) {
      final reportType = config?.reportType ?? presets[index].config.reportType;
      for (var i = 0; i < presets.length; i++) {
        if (i != index &&
            presets[i].config.reportType == reportType &&
            presets[i].isDefault) {
          presets[i] = presets[i].copyWith(isDefault: false);
        }
      }
    }

    final updatedPreset = presets[index].copyWith(
      name: name,
      description: description,
      config: config,
      isFavorite: isFavorite,
      isDefault: isDefault,
      updatedAt: DateTime.now(),
    );

    presets[index] = updatedPreset;
    await _savePresets(userId, presets);

    log('[ReportPresetService] Preset updated: ${updatedPreset.name}');
    return updatedPreset;
  }

  /// Delete a preset
  Future<bool> deletePreset(String userId, String presetId) async {
    await init();

    final presets = await getPresets(userId);
    final initialLength = presets.length;
    presets.removeWhere((p) => p.id == presetId);

    if (presets.length == initialLength) {
      return false;
    }

    await _savePresets(userId, presets);
    log('[ReportPresetService] Preset deleted: $presetId');
    return true;
  }

  /// Get preset by ID
  Future<ReportPreset?> getPresetById(String userId, String presetId) async {
    final presets = await getPresets(userId);
    return presets.firstWhere(
      (p) => p.id == presetId,
      orElse: () => throw Exception('Preset not found'),
    );
  }

  /// Get presets by report type
  Future<List<ReportPreset>> getPresetsByType(
    String userId,
    ReportType reportType,
  ) async {
    final presets = await getPresets(userId);
    return presets.where((p) => p.config.reportType == reportType).toList();
  }

  /// Get favorite presets
  Future<List<ReportPreset>> getFavoritePresets(String userId) async {
    final presets = await getPresets(userId);
    return presets.where((p) => p.isFavorite).toList();
  }

  /// Get default preset for a report type
  Future<ReportPreset?> getDefaultPreset(
    String userId,
    ReportType reportType,
  ) async {
    final presets = await getPresets(userId);
    return presets.firstWhere(
      (p) => p.config.reportType == reportType && p.isDefault,
      orElse: () => throw Exception('No default preset'),
    );
  }

  /// Toggle favorite status
  Future<ReportPreset?> toggleFavorite(String userId, String presetId) async {
    final preset = await getPresetById(userId, presetId);
    if (preset == null) return null;

    return updatePreset(
      userId: userId,
      presetId: presetId,
      isFavorite: !preset.isFavorite,
    );
  }

  /// Save presets to storage
  Future<void> _savePresets(String userId, List<ReportPreset> presets) async {
    final key = _getPresetsKey(userId);
    final jsonList = presets.map((p) => p.toJson()).toList();
    await _prefs?.setString(key, jsonEncode(jsonList));
  }

  // ==================== RECENT REPORTS ====================

  /// Get recent report configurations
  Future<List<ReportConfig>> getRecentReports(String userId) async {
    await init();

    try {
      final key = _getRecentKey(userId);
      final jsonString = _prefs?.getString(key);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((e) => ReportConfig.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log('[ReportPresetService] Error loading recent reports: $e');
      return [];
    }
  }

  /// Add to recent reports
  Future<void> addToRecentReports(String userId, ReportConfig config) async {
    await init();

    final recent = await getRecentReports(userId);

    // Remove if already exists (to avoid duplicates)
    recent.removeWhere((r) =>
        r.reportType == config.reportType &&
        r.toJsonString() == config.toJsonString());

    // Add to front
    recent.insert(0, config);

    // Limit to max recent reports
    if (recent.length > _maxRecentReports) {
      recent.removeRange(_maxRecentReports, recent.length);
    }

    final key = _getRecentKey(userId);
    final jsonList = recent.map((r) => r.toJson()).toList();
    await _prefs?.setString(key, jsonEncode(jsonList));
  }

  /// Clear recent reports
  Future<void> clearRecentReports(String userId) async {
    await init();
    final key = _getRecentKey(userId);
    await _prefs?.remove(key);
  }

  // ==================== BUILT-IN PRESETS ====================

  /// Get built-in preset templates
  List<ReportPreset> getBuiltInPresets() {
    final now = DateTime.now();

    return [
      // Vehicle Reports
      ReportPreset(
        id: 'builtin_fleet_inventory',
        userId: 'system',
        name: 'Complete Fleet Inventory',
        description: 'Full list of all vehicles with all details',
        config: ReportConfig(
          reportType: ReportType.fleetInventory,
          title: 'Fleet Inventory Report',
          columns: ReportColumnDefinitions.vehicleColumns,
          dateRange: ReportDateRange.thisYear,
          showSummary: true,
          showTotals: true,
          chartConfig: const ChartConfig(
            type: ChartType.pie,
            title: 'Vehicles by Status',
            xAxisKey: 'status',
          ),
        ),
        createdAt: now,
        updatedAt: now,
      ),

      ReportPreset(
        id: 'builtin_vehicle_status',
        userId: 'system',
        name: 'Vehicle Status Summary',
        description: 'Quick overview of fleet status distribution',
        config: ReportConfig(
          reportType: ReportType.vehicleStatus,
          title: 'Vehicle Status Report',
          groupBy: GroupByOption.status,
          showSummary: true,
          chartConfig: const ChartConfig(
            type: ChartType.donut,
            title: 'Status Distribution',
            xAxisKey: 'status',
          ),
        ),
        createdAt: now,
        updatedAt: now,
      ),

      // Fine Reports
      ReportPreset(
        id: 'builtin_fine_summary',
        userId: 'system',
        name: 'Monthly Fine Summary',
        description: 'Fine statistics for current month',
        config: ReportConfig(
          reportType: ReportType.fineSummary,
          title: 'Monthly Fine Summary',
          columns: ReportColumnDefinitions.fineColumns,
          dateRange: ReportDateRange.thisMonth,
          showSummary: true,
          showTotals: true,
          chartConfig: const ChartConfig(
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
        id: 'builtin_fine_by_employee',
        userId: 'system',
        name: 'Employee Fine Report',
        description: 'Fines grouped by employee',
        config: ReportConfig(
          reportType: ReportType.fineByEmployee,
          title: 'Fines by Employee',
          groupBy: GroupByOption.employee,
          dateRange: ReportDateRange.thisQuarter,
          showSummary: true,
          showTotals: true,
          chartConfig: const ChartConfig(
            type: ChartType.horizontalBar,
            title: 'Top Employees by Fine Amount',
            xAxisKey: 'empName',
            yAxisKey: 'amount',
          ),
        ),
        createdAt: now,
        updatedAt: now,
      ),

      ReportPreset(
        id: 'builtin_unpaid_fines',
        userId: 'system',
        name: 'Unpaid Fines',
        description: 'All outstanding fines requiring payment',
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
          sortConfig: const SortConfig(
            columnKey: 'amount',
            direction: SortDirection.descending,
          ),
          showSummary: true,
          showTotals: true,
        ),
        createdAt: now,
        updatedAt: now,
      ),

      // Document Reports
      ReportPreset(
        id: 'builtin_expiry_alert',
        userId: 'system',
        name: 'Document Expiry Alert',
        description: 'Documents expiring in next 30 days',
        config: ReportConfig(
          reportType: ReportType.documentExpirySummary,
          title: 'Expiry Alert - Next 30 Days',
          columns: ReportColumnDefinitions.documentColumns,
          dateRange: ReportDateRange.last30Days,
          sortConfig: const SortConfig(
            columnKey: 'expiryDate',
            direction: SortDirection.ascending,
          ),
          showSummary: true,
          chartConfig: const ChartConfig(
            type: ChartType.bar,
            title: 'Documents by Type',
            xAxisKey: 'docType',
          ),
        ),
        createdAt: now,
        updatedAt: now,
      ),

      // Maintenance Reports
      ReportPreset(
        id: 'builtin_maintenance_cost',
        userId: 'system',
        name: 'Maintenance Cost Analysis',
        description: 'Cost breakdown by vehicle and type',
        config: ReportConfig(
          reportType: ReportType.maintenanceCostAnalysis,
          title: 'Maintenance Cost Analysis',
          columns: ReportColumnDefinitions.maintenanceColumns,
          groupBy: GroupByOption.vehicle,
          dateRange: ReportDateRange.thisQuarter,
          showSummary: true,
          showTotals: true,
          chartConfig: const ChartConfig(
            type: ChartType.bar,
            title: 'Cost by Vehicle',
            xAxisKey: 'vehicleNo',
            yAxisKey: 'cost',
          ),
        ),
        createdAt: now,
        updatedAt: now,
      ),

      // Assignment Reports
      ReportPreset(
        id: 'builtin_current_assignments',
        userId: 'system',
        name: 'Current Assignments',
        description: 'All active vehicle assignments',
        config: ReportConfig(
          reportType: ReportType.currentAssignments,
          title: 'Current Vehicle Assignments',
          columns: ReportColumnDefinitions.assignmentColumns,
          filters: [
            const ReportFilter(
              columnKey: 'status',
              operator: FilterOperator.equals,
              value: 'Active',
            ),
          ],
          showSummary: true,
        ),
        createdAt: now,
        updatedAt: now,
      ),

      // Financial Reports
      ReportPreset(
        id: 'builtin_monthly_expenses',
        userId: 'system',
        name: 'Monthly Expense Report',
        description: 'Complete expense breakdown for the month',
        config: ReportConfig(
          reportType: ReportType.monthlyExpenses,
          title: 'Monthly Expense Report',
          dateRange: ReportDateRange.thisMonth,
          showSummary: true,
          showTotals: true,
          chartConfig: const ChartConfig(
            type: ChartType.pie,
            title: 'Expense Distribution',
            xAxisKey: 'category',
            yAxisKey: 'amount',
          ),
        ),
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  /// Get all available presets (built-in + user)
  Future<List<ReportPreset>> getAllPresets(String userId) async {
    final userPresets = await getPresets(userId);
    final builtInPresets = getBuiltInPresets();

    return [...builtInPresets, ...userPresets];
  }

  // ==================== IMPORT/EXPORT ====================

  /// Export presets to JSON string
  Future<String> exportPresets(String userId) async {
    final presets = await getPresets(userId);
    return jsonEncode(presets.map((p) => p.toJson()).toList());
  }

  /// Import presets from JSON string
  Future<int> importPresets(String userId, String jsonString) async {
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final importedPresets = jsonList
          .map((e) => ReportPreset.fromJson(e as Map<String, dynamic>))
          .toList();

      final existingPresets = await getPresets(userId);

      // Add imported presets with new IDs
      for (final preset in importedPresets) {
        existingPresets.add(preset.copyWith(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: userId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      }

      await _savePresets(userId, existingPresets);
      return importedPresets.length;
    } catch (e) {
      log('[ReportPresetService] Error importing presets: $e');
      return 0;
    }
  }
}
