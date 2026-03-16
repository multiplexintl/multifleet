import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// ============================================================
/// THEME SERVICE
/// ============================================================
/// Manages app theme (mode, accent color) with persistence.
/// Initialize in main.dart before runApp:
///   await Get.putAsync(() => ThemeService().init());
/// ============================================================

class ThemeService extends GetxService {
  static ThemeService get to => Get.find<ThemeService>();

  // ==================== STORAGE KEYS ====================
  static const _keyThemeMode = 'theme_mode';
  static const _keyAccentColor = 'accent_color';
  static const _keyDensity = 'visual_density';

  // ==================== REACTIVE STATE ====================
  final _themeMode = ThemeMode.light.obs;
  final _accentColor = const Color(0xFF14B8A6).obs; // Default Teal
  final _density = VisualDensity.comfortable.obs;

  // ==================== GETTERS ====================
  ThemeMode get themeMode => _themeMode.value;
  Color get accentColor => _accentColor.value;
  VisualDensity get density => _density.value;

  /// Is current effective theme dark?
  bool get isDark {
    if (_themeMode.value == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return _themeMode.value == ThemeMode.dark;
  }

  // ==================== PREDEFINED ACCENT COLORS ====================
  static const List<AccentColorOption> accentColors = [
    AccentColorOption('Teal', Color(0xFF14B8A6)),
    AccentColorOption('Blue', Color(0xFF3B82F6)),
    AccentColorOption('Indigo', Color(0xFF6366F1)),
    AccentColorOption('Purple', Color(0xFF8B5CF6)),
    AccentColorOption('Pink', Color(0xFFEC4899)),
    AccentColorOption('Rose', Color(0xFFF43F5E)),
    AccentColorOption('Orange', Color(0xFFF97316)),
    AccentColorOption('Amber', Color(0xFFF59E0B)),
    AccentColorOption('Emerald', Color(0xFF10B981)),
    AccentColorOption('Cyan', Color(0xFF06B6D4)),
  ];

  // ==================== STORAGE ====================
  final _storage = GetStorage();

  // ==================== INITIALIZATION ====================
  Future<ThemeService> init() async {
    // Load theme mode
    final modeIndex = _storage.read<int>(_keyThemeMode) ?? 1; // default: light
    _themeMode.value =
        ThemeMode.values[modeIndex.clamp(0, ThemeMode.values.length - 1)];

    // Load accent color
    final colorValue = _storage.read<int>(_keyAccentColor);
    if (colorValue != null) {
      _accentColor.value = Color(colorValue);
    }

    // Load density
    final densityIndex = _storage.read<int>(_keyDensity) ?? 1;
    _density.value = [
      VisualDensity.compact,
      VisualDensity.comfortable,
      VisualDensity.standard,
    ][densityIndex.clamp(0, 2)];

    return this;
  }

  // ==================== SETTERS ====================
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode.value = mode;
    Get.changeThemeMode(mode);
    _updateSystemUI();

    await _storage.write(_keyThemeMode, mode.index);
    await _storage.save();
  }

  Future<void> setAccentColor(Color color) async {
    _accentColor.value = color;
    // Rebuild themes
    Get.changeTheme(lightTheme);
    if (isDark) Get.changeTheme(darkTheme);

    await _storage.write(_keyAccentColor, color.value);
    await _storage
        .save(); // Force flush to persistent storage (critical for web)
  }

  Future<void> setDensity(VisualDensity density) async {
    _density.value = density;

    final index = [
      VisualDensity.compact,
      VisualDensity.comfortable,
      VisualDensity.standard,
    ].indexOf(density);
    await _storage.write(_keyDensity, index);
    await _storage
        .save(); // Force flush to persistent storage (critical for web)
  }

  // ==================== COMPUTED COLORS ====================
  /// Generate lighter variant of accent (for hover, badges)
  Color get accentLight {
    final hsl = HSLColor.fromColor(_accentColor.value);
    return hsl.withLightness((hsl.lightness + 0.2).clamp(0.0, 1.0)).toColor();
  }

  /// Generate darker variant of accent (for pressed states)
  Color get accentDark {
    final hsl = HSLColor.fromColor(_accentColor.value);
    return hsl.withLightness((hsl.lightness - 0.15).clamp(0.0, 1.0)).toColor();
  }

  /// Accent with opacity for backgrounds
  Color accentWithOpacity(double opacity) =>
      _accentColor.value.withOpacity(opacity);

  // ==================== THEME DATA ====================
  ThemeData get lightTheme => _buildTheme(Brightness.light);
  ThemeData get darkTheme => _buildTheme(Brightness.dark);

  ThemeData _buildTheme(Brightness brightness) {
    final isDarkMode = brightness == Brightness.dark;
    dynamic colors = isDarkMode ? DarkColors() : LightColors();

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      visualDensity: _density.value,

      // Colors
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: _accentColor.value,
        onPrimary: Colors.white,
        primaryContainer: accentLight,
        onPrimaryContainer: accentDark,
        secondary: _accentColor.value,
        onSecondary: Colors.white,
        secondaryContainer: accentWithOpacity(0.1),
        onSecondaryContainer: _accentColor.value,
        surface: colors.surface,
        onSurface: colors.textPrimary,
        surfaceContainerHighest: colors.cardBg,
        error: colors.error,
        onError: Colors.white,
        errorContainer: colors.errorLight,
        onErrorContainer: colors.error,
        outline: colors.divider,
        outlineVariant: colors.divider,
      ),

      // Scaffold
      scaffoldBackgroundColor: colors.surface,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: colors.cardBg,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle:
            isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),

      // Cards
      cardTheme: CardThemeData(
        color: colors.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colors.divider),
        ),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentColor.value,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _accentColor.value,
          side: BorderSide(color: _accentColor.value),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _accentColor.value,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.inputBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _accentColor.value, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.error),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: colors.textMuted),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: colors.divider,
        thickness: 1,
        space: 1,
      ),

      // Checkbox / Switch
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _accentColor.value;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _accentColor.value;
          return colors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accentWithOpacity(0.3);
          }
          return colors.divider;
        }),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: colors.surface,
        selectedColor: accentWithOpacity(0.15),
        labelStyle: TextStyle(color: colors.textPrimary, fontSize: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colors.divider),
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: colors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.cardBg,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.primaryDark,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),

      // Text
      textTheme: TextTheme(
        headlineLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary),
        headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary),
        headlineSmall: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary),
        titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary),
        titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: colors.textPrimary),
        titleSmall: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colors.textPrimary),
        bodyLarge: TextStyle(fontSize: 16, color: colors.textPrimary),
        bodyMedium: TextStyle(fontSize: 14, color: colors.textPrimary),
        bodySmall: TextStyle(fontSize: 12, color: colors.textSecondary),
        labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary),
        labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colors.textSecondary),
        labelSmall: TextStyle(fontSize: 11, color: colors.textMuted),
      ),
    );
  }

  void _updateSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      isDark
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: const Color(0xFF1E293B),
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Colors.white,
            ),
    );
  }
}

// ==================== COLOR DEFINITIONS ====================

class LightColors {
  final primaryDark = const Color(0xFF1E293B);
  final primaryLight = const Color(0xFF334155);
  final primaryMuted = const Color(0xFF64748B);

  final surface = const Color(0xFFF8FAFC);
  final cardBg = Colors.white;
  final sidebarBg = const Color(0xFFF1F5F9);
  final inputBg = Colors.white;
  final divider = const Color(0xFFE2E8F0);

  final success = const Color(0xFF22C55E);
  final successLight = const Color(0xFFDCFCE7);
  final warning = const Color(0xFFF59E0B);
  final warningLight = const Color(0xFFFEF3C7);
  final error = const Color(0xFFEF4444);
  final errorLight = const Color(0xFFFEE2E2);
  final info = const Color(0xFF3B82F6);
  final infoLight = const Color(0xFFDBEAFE);

  final textPrimary = const Color(0xFF1E293B);
  final textSecondary = const Color(0xFF64748B);
  final textMuted = const Color(0xFF94A3B8);
}

class DarkColors {
  final primaryDark = const Color(0xFF0F172A);
  final primaryLight = const Color(0xFF1E293B);
  final primaryMuted = const Color(0xFF475569);

  final surface = const Color(0xFF0F172A);
  final cardBg = const Color(0xFF1E293B);
  final sidebarBg = const Color(0xFF1E293B);
  final inputBg = const Color(0xFF334155);
  final divider = const Color(0xFF334155);

  final success = const Color(0xFF22C55E);
  final successLight = const Color(0xFF14532D);
  final warning = const Color(0xFFF59E0B);
  final warningLight = const Color(0xFF78350F);
  final error = const Color(0xFFEF4444);
  final errorLight = const Color(0xFF7F1D1D);
  final info = const Color(0xFF3B82F6);
  final infoLight = const Color(0xFF1E3A8A);

  final textPrimary = const Color(0xFFF1F5F9);
  final textSecondary = const Color(0xFF94A3B8);
  final textMuted = const Color(0xFF64748B);
}

// ==================== ACCENT COLOR OPTION ====================

class AccentColorOption {
  final String name;
  final Color color;

  const AccentColorOption(this.name, this.color);
}
