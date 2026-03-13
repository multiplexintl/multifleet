import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ============================================================
/// SYSTEM PREFERENCES SERVICE
/// ============================================================
/// Manages app-wide preferences with persistence.
/// Initialize in main.dart:
///   await Get.putAsync(() => SystemPreferencesService().init());
/// ============================================================

class SystemPreferencesService extends GetxService {
  static SystemPreferencesService get to =>
      Get.find<SystemPreferencesService>();

  // ==================== STORAGE KEYS ====================
  static const _keyDateFormat = 'date_format';
  static const _keyTimeFormat = 'time_format';
  static const _keyCurrency = 'currency';
  static const _keyDistanceUnit = 'distance_unit';
  static const _keyFuelUnit = 'fuel_unit';
  static const _keyLanguage = 'language';
  static const _keyExpiryAlertDays = 'expiry_alert_days';
  static const _keyMaintenanceAlertDays = 'maintenance_alert_days';
  static const _keyMaintenanceAlertKm = 'maintenance_alert_km';
  static const _keyDefaultPageSize = 'default_page_size';
  static const _keyAutoRefreshInterval = 'auto_refresh_interval';
  static const _keyShowInactiveItems = 'show_inactive_items';
  static const _keyCompactTables = 'compact_tables';
  static const _keyConfirmBeforeDelete = 'confirm_before_delete';
  static const _keyEnableNotifications = 'enable_notifications';
  static const _keyEmailNotifications = 'email_notifications';

  // ==================== REACTIVE STATE ====================

  // Date & Time
  final _dateFormat = 'dd/MM/yyyy'.obs;
  final _timeFormat = '24h'.obs;

  // Regional
  final _currency = 'AED'.obs;
  final _distanceUnit = 'km'.obs;
  final _fuelUnit = 'Liters'.obs;
  final _language = 'en'.obs;

  // Alerts & Notifications
  final _expiryAlertDays = 30.obs;
  final _maintenanceAlertDays = 7.obs;
  final _maintenanceAlertKm = 500.obs;
  final _enableNotifications = true.obs;
  final _emailNotifications = false.obs;

  // Display
  final _defaultPageSize = 25.obs;
  final _autoRefreshInterval = 0.obs; // 0 = disabled
  final _showInactiveItems = true.obs;
  final _compactTables = false.obs;
  final _confirmBeforeDelete = true.obs;

  // ==================== GETTERS ====================

  // Date & Time
  String get dateFormat => _dateFormat.value;
  String get timeFormat => _timeFormat.value;
  String get dateTimeFormat =>
      '$dateFormat ${timeFormat == '24h' ? 'HH:mm' : 'hh:mm a'}';

  // Regional
  String get currency => _currency.value;
  String get distanceUnit => _distanceUnit.value;
  String get fuelUnit => _fuelUnit.value;
  String get language => _language.value;

  // Alerts
  int get expiryAlertDays => _expiryAlertDays.value;
  int get maintenanceAlertDays => _maintenanceAlertDays.value;
  int get maintenanceAlertKm => _maintenanceAlertKm.value;
  bool get enableNotifications => _enableNotifications.value;
  bool get emailNotifications => _emailNotifications.value;

  // Display
  int get defaultPageSize => _defaultPageSize.value;
  int get autoRefreshInterval => _autoRefreshInterval.value;
  bool get showInactiveItems => _showInactiveItems.value;
  bool get compactTables => _compactTables.value;
  bool get confirmBeforeDelete => _confirmBeforeDelete.value;

  // ==================== OPTIONS ====================

  static const List<String> dateFormats = [
    'dd/MM/yyyy',
    'MM/dd/yyyy',
    'yyyy-MM-dd',
    'dd-MM-yyyy',
    'dd MMM yyyy',
    'MMM dd, yyyy',
  ];

  static const List<String> timeFormats = ['24h', '12h'];

  static const List<String> currencies = [
    'AED',
    'QAR',
    'OMR',
    'BHD',
    'SAR',
    'KWD',
    'USD',
    'EUR',
    'GBP'
  ];

  static const List<String> distanceUnits = ['km', 'miles'];

  static const List<String> fuelUnits = ['Liters', 'Gallons', 'kWh'];

  static const List<String> languages = ['en', 'ar'];

  static const List<int> pageSizes = [10, 25, 50, 100];

  static const List<int> refreshIntervals = [0, 30, 60, 120, 300]; // seconds

  // ==================== INITIALIZATION ====================

  Future<SystemPreferencesService> init() async {
    final prefs = await SharedPreferences.getInstance();

    // Date & Time
    _dateFormat.value = prefs.getString(_keyDateFormat) ?? 'dd/MM/yyyy';
    _timeFormat.value = prefs.getString(_keyTimeFormat) ?? '24h';

    // Regional
    _currency.value = prefs.getString(_keyCurrency) ?? 'AED';
    _distanceUnit.value = prefs.getString(_keyDistanceUnit) ?? 'km';
    _fuelUnit.value = prefs.getString(_keyFuelUnit) ?? 'Liters';
    _language.value = prefs.getString(_keyLanguage) ?? 'en';

    // Alerts
    _expiryAlertDays.value = prefs.getInt(_keyExpiryAlertDays) ?? 30;
    _maintenanceAlertDays.value = prefs.getInt(_keyMaintenanceAlertDays) ?? 7;
    _maintenanceAlertKm.value = prefs.getInt(_keyMaintenanceAlertKm) ?? 500;
    _enableNotifications.value = prefs.getBool(_keyEnableNotifications) ?? true;
    _emailNotifications.value = prefs.getBool(_keyEmailNotifications) ?? false;

    // Display
    _defaultPageSize.value = prefs.getInt(_keyDefaultPageSize) ?? 25;
    _autoRefreshInterval.value = prefs.getInt(_keyAutoRefreshInterval) ?? 0;
    _showInactiveItems.value = prefs.getBool(_keyShowInactiveItems) ?? true;
    _compactTables.value = prefs.getBool(_keyCompactTables) ?? false;
    _confirmBeforeDelete.value = prefs.getBool(_keyConfirmBeforeDelete) ?? true;

    return this;
  }

  // ==================== SETTERS ====================

  Future<void> setDateFormat(String value) async {
    _dateFormat.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDateFormat, value);
  }

  Future<void> setTimeFormat(String value) async {
    _timeFormat.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTimeFormat, value);
  }

  Future<void> setCurrency(String value) async {
    _currency.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrency, value);
  }

  Future<void> setDistanceUnit(String value) async {
    _distanceUnit.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDistanceUnit, value);
  }

  Future<void> setFuelUnit(String value) async {
    _fuelUnit.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFuelUnit, value);
  }

  Future<void> setLanguage(String value) async {
    _language.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, value);
  }

  Future<void> setExpiryAlertDays(int value) async {
    _expiryAlertDays.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyExpiryAlertDays, value);
  }

  Future<void> setMaintenanceAlertDays(int value) async {
    _maintenanceAlertDays.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyMaintenanceAlertDays, value);
  }

  Future<void> setMaintenanceAlertKm(int value) async {
    _maintenanceAlertKm.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyMaintenanceAlertKm, value);
  }

  Future<void> setEnableNotifications(bool value) async {
    _enableNotifications.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnableNotifications, value);
  }

  Future<void> setEmailNotifications(bool value) async {
    _emailNotifications.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEmailNotifications, value);
  }

  Future<void> setDefaultPageSize(int value) async {
    _defaultPageSize.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyDefaultPageSize, value);
  }

  Future<void> setAutoRefreshInterval(int value) async {
    _autoRefreshInterval.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyAutoRefreshInterval, value);
  }

  Future<void> setShowInactiveItems(bool value) async {
    _showInactiveItems.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShowInactiveItems, value);
  }

  Future<void> setCompactTables(bool value) async {
    _compactTables.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyCompactTables, value);
  }

  Future<void> setConfirmBeforeDelete(bool value) async {
    _confirmBeforeDelete.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyConfirmBeforeDelete, value);
  }

  // ==================== RESET ====================

  Future<void> resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();

    // Clear all keys
    await prefs.remove(_keyDateFormat);
    await prefs.remove(_keyTimeFormat);
    await prefs.remove(_keyCurrency);
    await prefs.remove(_keyDistanceUnit);
    await prefs.remove(_keyFuelUnit);
    await prefs.remove(_keyLanguage);
    await prefs.remove(_keyExpiryAlertDays);
    await prefs.remove(_keyMaintenanceAlertDays);
    await prefs.remove(_keyMaintenanceAlertKm);
    await prefs.remove(_keyEnableNotifications);
    await prefs.remove(_keyEmailNotifications);
    await prefs.remove(_keyDefaultPageSize);
    await prefs.remove(_keyAutoRefreshInterval);
    await prefs.remove(_keyShowInactiveItems);
    await prefs.remove(_keyCompactTables);
    await prefs.remove(_keyConfirmBeforeDelete);

    // Reset to defaults
    _dateFormat.value = 'dd/MM/yyyy';
    _timeFormat.value = '24h';
    _currency.value = 'AED';
    _distanceUnit.value = 'km';
    _fuelUnit.value = 'Liters';
    _language.value = 'en';
    _expiryAlertDays.value = 30;
    _maintenanceAlertDays.value = 7;
    _maintenanceAlertKm.value = 500;
    _enableNotifications.value = true;
    _emailNotifications.value = false;
    _defaultPageSize.value = 25;
    _autoRefreshInterval.value = 0;
    _showInactiveItems.value = true;
    _compactTables.value = false;
    _confirmBeforeDelete.value = true;
  }

  // ==================== HELPERS ====================

  /// Format a date using current preference
  String formatDate(DateTime? date) {
    if (date == null) return '-';

    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    final mmm = _monthNames[date.month - 1];

    switch (dateFormat) {
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
        return '$d/$m/$y';
    }
  }

  /// Format currency amount
  String formatCurrency(double? amount) {
    if (amount == null) return '-';
    return '$currency ${amount.toStringAsFixed(2)}';
  }

  /// Format distance
  String formatDistance(double? distance) {
    if (distance == null) return '-';
    return '${distance.toStringAsFixed(0)} $distanceUnit';
  }

  static const _monthNames = [
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
  ];
}
