import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multifleet/theme/app_theme.dart';

import '../../../services/system_preference_service.dart';
import '../../../services/theme_service.dart';

/// ============================================================
/// SYSTEM PREFERENCES SETTINGS
/// ============================================================

class SystemPreferencesSettings extends StatelessWidget {
  const SystemPreferencesSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = SystemPreferencesService.to;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          const SizedBox(height: 24),

          // Date & Time Section
          _DateTimeSection(prefs: prefs),
          const SizedBox(height: 24),

          // Regional Section
          _RegionalSection(prefs: prefs),
          const SizedBox(height: 24),

          // Alert Thresholds Section
          _AlertsSection(prefs: prefs),
          const SizedBox(height: 24),

          // Display Section
          _DisplaySection(prefs: prefs),
          const SizedBox(height: 24),

          // Reset Section
          _ResetSection(prefs: prefs),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Obx(() => Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ThemeService.to.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.tune_outlined,
                color: ThemeService.to.accentColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'System Preferences',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  'Configure app-wide settings and defaults',
                  style:
                      TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ));
  }
}

// ==================== DATE & TIME SECTION ====================

class _DateTimeSection extends StatelessWidget {
  final SystemPreferencesService prefs;

  const _DateTimeSection({required this.prefs});

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: 'Date & Time',
      icon: Icons.calendar_today_outlined,
      children: [
        // Date Format
        Obx(() => _DropdownTile(
              title: 'Date Format',
              subtitle: 'How dates are displayed',
              value: prefs.dateFormat,
              items: SystemPreferencesService.dateFormats,
              displayBuilder: (value) => _formatDateExample(value),
              onChanged: prefs.setDateFormat,
            )),
        const Divider(height: 1),

        // Time Format
        Obx(() => _SegmentedTile(
              title: 'Time Format',
              subtitle: 'Choose 12 or 24 hour format',
              value: prefs.timeFormat,
              options: const {'24h': '24 Hour', '12h': '12 Hour'},
              onChanged: prefs.setTimeFormat,
            )),
      ],
    );
  }

  String _formatDateExample(String format) {
    final now = DateTime.now();
    final d = now.day.toString().padLeft(2, '0');
    final m = now.month.toString().padLeft(2, '0');
    final y = now.year.toString();
    final mmm = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ][now.month - 1];

    switch (format) {
      case 'dd/MM/yyyy':
        return '$d/$m/$y';
      case 'MM/dd/yyyy':
        return '$m/$d/$y';
      case 'yyyy-MM-dd':
        return '$y-$m-$d';
      case 'dd-MM-yyyy':
        return '$d-$m-$y';
      case 'dd MMM yyyy':
        return '$d $mmm $y';
      case 'MMM dd, yyyy':
        return '$mmm $d, $y';
      default:
        return format;
    }
  }
}

// ==================== REGIONAL SECTION ====================

class _RegionalSection extends StatelessWidget {
  final SystemPreferencesService prefs;

  const _RegionalSection({required this.prefs});

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: 'Regional',
      icon: Icons.language_outlined,
      children: [
        // Currency
        Obx(() => _DropdownTile(
              title: 'Currency',
              subtitle: 'Default currency for amounts',
              value: prefs.currency,
              items: SystemPreferencesService.currencies,
              onChanged: prefs.setCurrency,
            )),
        const Divider(height: 1),

        // Distance Unit
        Obx(() => _SegmentedTile(
              title: 'Distance Unit',
              subtitle: 'Kilometers or miles',
              value: prefs.distanceUnit,
              options: const {'km': 'Kilometers', 'miles': 'Miles'},
              onChanged: prefs.setDistanceUnit,
            )),
        const Divider(height: 1),

        // Fuel Unit
        Obx(() => _DropdownTile(
              title: 'Fuel Unit',
              subtitle: 'Unit for fuel measurements',
              value: prefs.fuelUnit,
              items: SystemPreferencesService.fuelUnits,
              onChanged: prefs.setFuelUnit,
            )),
      ],
    );
  }
}

// ==================== ALERTS SECTION ====================

class _AlertsSection extends StatelessWidget {
  final SystemPreferencesService prefs;

  const _AlertsSection({required this.prefs});

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: 'Alert Thresholds',
      icon: Icons.notifications_outlined,
      children: [
        // Expiry Alert Days
        Obx(() => _SliderTile(
              title: 'Document Expiry Alert',
              subtitle: 'Alert ${prefs.expiryAlertDays} days before expiry',
              value: prefs.expiryAlertDays.toDouble(),
              min: 7,
              max: 90,
              divisions: 83,
              labelBuilder: (v) => '${v.toInt()} days',
              onChanged: (v) => prefs.setExpiryAlertDays(v.toInt()),
            )),
        const Divider(height: 1),

        // Maintenance Alert Days
        Obx(() => _SliderTile(
              title: 'Maintenance Due Alert (Days)',
              subtitle: 'Alert ${prefs.maintenanceAlertDays} days before due',
              value: prefs.maintenanceAlertDays.toDouble(),
              min: 1,
              max: 30,
              divisions: 29,
              labelBuilder: (v) => '${v.toInt()} days',
              onChanged: (v) => prefs.setMaintenanceAlertDays(v.toInt()),
            )),
        const Divider(height: 1),

        // Maintenance Alert Km
        Obx(() => _SliderTile(
              title: 'Maintenance Due Alert (Distance)',
              subtitle:
                  'Alert ${prefs.maintenanceAlertKm} ${prefs.distanceUnit} before due',
              value: prefs.maintenanceAlertKm.toDouble(),
              min: 100,
              max: 2000,
              divisions: 19,
              labelBuilder: (v) => '${v.toInt()} ${prefs.distanceUnit}',
              onChanged: (v) => prefs.setMaintenanceAlertKm(v.toInt()),
            )),
      ],
    );
  }
}

// ==================== DISPLAY SECTION ====================

class _DisplaySection extends StatelessWidget {
  final SystemPreferencesService prefs;

  const _DisplaySection({required this.prefs});

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: 'Display & Behavior',
      icon: Icons.display_settings_outlined,
      children: [
        // Default Page Size
        Obx(() => _DropdownTile(
              title: 'Default Page Size',
              subtitle: 'Items per page in lists',
              value: prefs.defaultPageSize.toString(),
              items: SystemPreferencesService.pageSizes
                  .map((e) => e.toString())
                  .toList(),
              displayBuilder: (v) => '$v items',
              onChanged: (v) => prefs.setDefaultPageSize(int.parse(v)),
            )),
        const Divider(height: 1),

        // Auto Refresh
        Obx(() => _DropdownTile(
              title: 'Auto Refresh',
              subtitle: 'Automatically refresh data',
              value: prefs.autoRefreshInterval.toString(),
              items: SystemPreferencesService.refreshIntervals
                  .map((e) => e.toString())
                  .toList(),
              displayBuilder: (v) {
                final seconds = int.parse(v);
                if (seconds == 0) return 'Disabled';
                if (seconds < 60) return '$seconds seconds';
                return '${seconds ~/ 60} minutes';
              },
              onChanged: (v) => prefs.setAutoRefreshInterval(int.parse(v)),
            )),
        const Divider(height: 1),

        // Show Inactive Items
        Obx(() => _SwitchTile(
              title: 'Show Inactive Items',
              subtitle: 'Display inactive records in lists',
              value: prefs.showInactiveItems,
              onChanged: prefs.setShowInactiveItems,
            )),
        const Divider(height: 1),

        // Compact Tables
        Obx(() => _SwitchTile(
              title: 'Compact Tables',
              subtitle: 'Use smaller row height in data tables',
              value: prefs.compactTables,
              onChanged: prefs.setCompactTables,
            )),
        const Divider(height: 1),

        // Confirm Before Delete
        Obx(() => _SwitchTile(
              title: 'Confirm Before Delete',
              subtitle: 'Show confirmation dialog before deleting',
              value: prefs.confirmBeforeDelete,
              onChanged: prefs.setConfirmBeforeDelete,
            )),
      ],
    );
  }
}

// ==================== RESET SECTION ====================

class _ResetSection extends StatelessWidget {
  final SystemPreferencesService prefs;

  const _ResetSection({required this.prefs});

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: 'Reset',
      icon: Icons.restart_alt_outlined,
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: const Text('Reset to Defaults'),
          subtitle: const Text('Restore all preferences to default values'),
          trailing: OutlinedButton(
            onPressed: () => _showResetConfirmation(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
            child: const Text('Reset'),
          ),
        ),
      ],
    );
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Preferences?'),
        content: const Text(
          'This will restore all system preferences to their default values. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              prefs.resetToDefaults();
              Navigator.pop(context);
              Get.snackbar(
                'Reset Complete',
                'All preferences restored to defaults',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

// ==================== REUSABLE WIDGETS ====================

class _SettingsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SettingsCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, size: 20, color: ThemeService.to.accentColor),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.dividerColor),
          // Content
          ...children,
        ],
      ),
    );
  }
}

class _DropdownTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final List<String> items;
  final String Function(String)? displayBuilder;
  final Function(String) onChanged;

  const _DropdownTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.items,
    this.displayBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(title),
      subtitle: Text(subtitle,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        items: items
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(displayBuilder?.call(item) ?? item),
                ))
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}

class _SegmentedTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final Map<String, String> options;
  final Function(String) onChanged;

  const _SegmentedTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(title),
      subtitle: Text(subtitle,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      trailing: SegmentedButton<String>(
        segments: options.entries
            .map((e) => ButtonSegment(value: e.key, label: Text(e.value)))
            .toList(),
        selected: {value},
        onSelectionChanged: (v) => onChanged(v.first),
        showSelectedIcon: false,
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final Function(bool) onChanged;

  const _SwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(title),
      subtitle: Text(subtitle,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _SliderTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String Function(double) labelBuilder;
  final Function(double) onChanged;

  const _SliderTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: ThemeService.to.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  labelBuilder(value),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: ThemeService.to.accentColor,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
