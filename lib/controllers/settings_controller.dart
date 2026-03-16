import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// ============================================================
/// SETTINGS CONTROLLER
/// ============================================================

enum SettingsSection {
  // Appearance
  appearance('Appearance', 'appearance'),

  // Masters - Vehicle
  vehicleCategories('Vehicle Categories', 'vehicle_categories'),
  fuelTypes('Fuel Types', 'fuel_types'),
  tireBrands('Tire Brands', 'tire_brands'),

  // Masters - Documents & Compliance
  documentTypes('Document Types', 'document_types'),
  fineCategories('Fine Categories', 'fine_categories'),

  // Masters - Vehicle (additional)
  vehicleConditions('Vehicle Conditions', 'vehicle_conditions'),
  tyrePositions('Tyre Positions', 'tyre_positions'),

  // Masters - Operations (additional)
  employees('Employees', 'employees'),
  cities('Cities', 'cities'),

  // Masters - Maintenance
  serviceTypes('Service Types', 'service_types'),
  serviceIntervals('Service Intervals', 'service_intervals'),
  vendors('Vendors', 'vendors'),

  // Masters - Operations
  fuelStations('Fuel Stations', 'fuel_stations'),
  costCenters('Cost Centers', 'cost_centers'),
  regions('Regions / Zones', 'regions'),
  expenseCategories('Expense Categories', 'expense_categories'),

  // System
  systemPreferences('System Preferences', 'system_preferences'),
  notifications('Notifications', 'notifications'),

  // Data Management
  importExport('Import / Export', 'import_export'),
  auditLogs('Audit Logs', 'audit_logs'),

  // Future
  integrations('Integrations', 'integrations');

  final String label;
  final String key;
  const SettingsSection(this.label, this.key);
}

/// Grouping for sidebar display
enum SettingsGroup {
  appearance('Appearance', [SettingsSection.appearance]),
  vehicleMasters('Vehicle Masters', [
    SettingsSection.vehicleCategories,
    SettingsSection.vehicleConditions,
    SettingsSection.fuelTypes,
    SettingsSection.tireBrands,
    SettingsSection.tyrePositions,
  ]),
  complianceMasters('Compliance Masters', [
    SettingsSection.documentTypes,
    SettingsSection.fineCategories,
  ]),
  maintenanceMasters('Maintenance Masters', [
    SettingsSection.serviceTypes,
    SettingsSection.serviceIntervals,
    SettingsSection.vendors,
  ]),
  operationMasters('Operations Masters', [
    SettingsSection.fuelStations,
    SettingsSection.costCenters,
    SettingsSection.regions,
    SettingsSection.expenseCategories,
    SettingsSection.employees,
    SettingsSection.cities,
  ]),
  system('System', [
    SettingsSection.systemPreferences,
    SettingsSection.notifications,
  ]),
  dataManagement('Data Management', [
    SettingsSection.importExport,
    SettingsSection.auditLogs,
  ]),
  integrations('Integrations', [SettingsSection.integrations]);

  final String label;
  final List<SettingsSection> sections;
  const SettingsGroup(this.label, this.sections);
}

class SettingsController extends GetxController {
  // Current selected section
  final selectedSection = SettingsSection.appearance.obs;

  // Sidebar visibility (for tablet/mobile)
  final showSidebar = true.obs;

  // Search query for filtering sections
  final searchQuery = ''.obs;

  void selectSection(SettingsSection section) {
    selectedSection.value = section;
  }

  void toggleSidebar() {
    showSidebar.toggle();
  }

  /// Filtered groups based on search
  List<SettingsGroup> get filteredGroups {
    if (searchQuery.value.isEmpty) return SettingsGroup.values;

    final query = searchQuery.value.toLowerCase();
    return SettingsGroup.values.where((group) {
      return group.label.toLowerCase().contains(query) ||
          group.sections.any((s) => s.label.toLowerCase().contains(query));
    }).toList();
  }

  /// Get icon for section
  IconData getIconForSection(SettingsSection section) {
    switch (section) {
      case SettingsSection.appearance:
        return Icons.palette_outlined;
      case SettingsSection.vehicleCategories:
        return Icons.directions_car_outlined;
      case SettingsSection.fuelTypes:
        return Icons.local_gas_station_outlined;
      case SettingsSection.tireBrands:
        return Icons.tire_repair_outlined;
      case SettingsSection.documentTypes:
        return Icons.description_outlined;
      case SettingsSection.fineCategories:
        return Icons.receipt_long_outlined;
      case SettingsSection.serviceTypes:
        return Icons.build_outlined;
      case SettingsSection.serviceIntervals:
        return Icons.schedule_outlined;
      case SettingsSection.vendors:
        return Icons.store_outlined;
      case SettingsSection.fuelStations:
        return Icons.ev_station_outlined;
      case SettingsSection.costCenters:
        return Icons.account_balance_outlined;
      case SettingsSection.regions:
        return Icons.map_outlined;
      case SettingsSection.expenseCategories:
        return Icons.payments_outlined;
      case SettingsSection.systemPreferences:
        return Icons.tune_outlined;
      case SettingsSection.notifications:
        return Icons.notifications_outlined;
      case SettingsSection.importExport:
        return Icons.import_export_outlined;
      case SettingsSection.auditLogs:
        return Icons.history_outlined;
      case SettingsSection.integrations:
        return Icons.extension_outlined;
      case SettingsSection.vehicleConditions:
        return Icons.car_repair_outlined;
      case SettingsSection.tyrePositions:
        return Icons.tire_repair_outlined;
      case SettingsSection.employees:
        return Icons.people_outlined;
      case SettingsSection.cities:
        return Icons.location_city_outlined;
    }
  }
}
