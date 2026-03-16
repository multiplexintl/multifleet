import 'package:flutter/material.dart';

import '../services/theme_service.dart';

/// ============================================================
/// MULTIFLEET DESIGN SYSTEM
/// ============================================================
/// A comprehensive design system for consistent UI across the app.
/// Colors adapt automatically to light/dark mode via ThemeService.
/// ============================================================

class AppColors {
  AppColors._();

  // ==================== INTERNAL THEME DELEGATION ====================
  static final _light = LightColors();
  static final _dark = DarkColors();
  static dynamic get _c => ThemeService.to.isDark ? _dark : _light;

  // ==================== PRIMARY COLORS (theme-aware) ====================
  static Color get primaryDark => _c.primaryDark;
  static Color get primaryLight => _c.primaryLight;
  static Color get primaryMuted => _c.primaryMuted;

  // ==================== ACCENT COLORS (from ThemeService) ====================
  static Color get accent => ThemeService.to.accentColor;
  static Color get accentLight => ThemeService.to.accentLight;
  static Color get accentDark => ThemeService.to.accentDark;

  // ==================== SURFACE COLORS (theme-aware) ====================
  static Color get surface => _c.surface;
  static Color get cardBg => _c.cardBg;
  static Color get sidebarBg => _c.sidebarBg;
  static Color get inputBg => _c.inputBg;
  static Color get divider => _c.divider;

  // ==================== STATUS COLORS ====================
  static const Color success = Color(0xFF22C55E);
  static Color get successLight => _c.successLight;

  static const Color warning = Color(0xFFF59E0B);
  static Color get warningLight => _c.warningLight;

  static const Color error = Color(0xFFEF4444);
  static Color get errorLight => _c.errorLight;

  static const Color info = Color(0xFF3B82F6);
  static Color get infoLight => _c.infoLight;

  // ==================== TEXT COLORS (theme-aware) ====================
  static Color get textPrimary => _c.textPrimary;
  static Color get textSecondary => _c.textSecondary;
  static Color get textMuted => _c.textMuted;
  static const Color textOnDark = Colors.white;
  static const Color textOnAccent = Colors.white;

  // ==================== GRADIENTS (theme-aware) ====================
  static LinearGradient get primaryGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primaryDark, primaryLight],
      );

  static LinearGradient get accentGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [accent, accentLight],
      );

  // ==================== HELPER METHODS ====================

  static Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return success;
      case 'inactive':
        return error;
      case 'under maintenance':
      case 'maintenance':
        return warning;
      case 'pending':
        return info;
      default:
        return primaryMuted;
    }
  }

  static Color getStatusBgColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return successLight;
      case 'inactive':
        return errorLight;
      case 'under maintenance':
      case 'maintenance':
        return warningLight;
      case 'pending':
        return infoLight;
      default:
        return surface;
    }
  }

  static Color getExpiryColor(DateTime? expiryDate) {
    if (expiryDate == null) return primaryMuted;

    final daysUntilExpiry = expiryDate.difference(DateTime.now()).inDays;

    if (daysUntilExpiry < 0) return error;
    if (daysUntilExpiry <= 30) return warning;
    if (daysUntilExpiry <= 90) return const Color(0xFFD97706);
    return success;
  }
}

/// ============================================================
/// TEXT STYLES
/// ============================================================

class AppTextStyles {
  AppTextStyles._();

  // ==================== HEADINGS ====================
  static TextStyle get h1 => TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      );

  static TextStyle get h2 => TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle get h3 => TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get h4 => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  // ==================== BODY TEXT ====================
  static TextStyle get bodyLarge => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
      );

  static TextStyle get body => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodySmall => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
      );

  // ==================== LABELS ====================
  static TextStyle get label => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  static TextStyle get labelSmall => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  // ==================== BUTTON TEXT ====================
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  // ==================== SPECIAL ====================
  static TextStyle get caption => TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.normal,
        color: AppColors.textMuted,
      );

  static TextStyle get overline => TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
        color: AppColors.textMuted,
      );
}

/// ============================================================
/// SPACING & SIZING
/// ============================================================

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  // Padding shortcuts
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);
}

class AppRadius {
  AppRadius._();

  static const double sm = 6;
  static const double md = 10;
  static const double lg = 12;
  static const double xl = 16;
  static const double xxl = 20;
  static const double full = 999;

  static BorderRadius get borderSm => BorderRadius.circular(sm);
  static BorderRadius get borderMd => BorderRadius.circular(md);
  static BorderRadius get borderLg => BorderRadius.circular(lg);
  static BorderRadius get borderXl => BorderRadius.circular(xl);
  static BorderRadius get borderXxl => BorderRadius.circular(xxl);
  static BorderRadius get borderFull => BorderRadius.circular(full);
}

class AppShadows {
  AppShadows._();

  static List<BoxShadow> get sm => [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get md => [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get lg => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 15,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get xl => [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];
}

/// ============================================================
/// RESPONSIVE BREAKPOINTS
/// ============================================================

class AppBreakpoints {
  AppBreakpoints._();

  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double wide = 1440;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobile &&
      MediaQuery.of(context).size.width < desktop;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktop;

  static bool isWide(BuildContext context) =>
      MediaQuery.of(context).size.width >= wide;
}

/// ============================================================
/// REUSABLE WIDGETS
/// ============================================================

/// Modern Card Widget
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final VoidCallback? onTap;
  final bool hasShadow;
  final bool hasBorder;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.onTap,
    this.hasShadow = true,
    this.hasBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: color ?? AppColors.cardBg,
          borderRadius: AppRadius.borderLg,
          border: hasBorder ? Border.all(color: AppColors.divider) : null,
          boxShadow: hasShadow ? AppShadows.sm : null,
        ),
        child: child,
      ),
    );
  }
}

/// Status Badge Widget
class AppBadge extends StatelessWidget {
  final String text;
  final Color? color;
  final Color? backgroundColor;
  final IconData? icon;
  final bool isSmall;

  const AppBadge({
    super.key,
    required this.text,
    this.color,
    this.backgroundColor,
    this.icon,
    this.isSmall = false,
  });

  factory AppBadge.status(String? status) {
    return AppBadge(
      text: status ?? 'Unknown',
      color: Colors.white,
      backgroundColor: AppColors.getStatusColor(status),
    );
  }

  factory AppBadge.expiry(DateTime? expiryDate, String text) {
    return AppBadge(
      text: text,
      color: AppColors.getExpiryColor(expiryDate),
      backgroundColor: AppColors.getExpiryColor(expiryDate).withOpacity(0.1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 12,
        vertical: isSmall ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.accent.withOpacity(0.1),
        borderRadius: AppRadius.borderFull,
        border: backgroundColor == null
            ? Border.all(color: (color ?? AppColors.accent).withOpacity(0.3))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon,
                size: isSmall ? 12 : 14, color: color ?? AppColors.accent),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color ?? AppColors.accent,
                fontSize: isSmall ? 10 : 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Primary Button
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final bool isSmall;
  final Color? color;
  final double? width;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.isSmall = false,
    this.color,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? AppColors.accent;

    if (isOutlined) {
      return SizedBox(
        width: width,
        child: OutlinedButton.icon(
          onPressed: isLoading ? null : onPressed,
          icon: isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: buttonColor,
                  ),
                )
              : (icon != null
                  ? Icon(icon, size: isSmall ? 16 : 18)
                  : const SizedBox.shrink()),
          label: Text(text,
              style:
                  isSmall ? AppTextStyles.buttonSmall : AppTextStyles.button),
          style: OutlinedButton.styleFrom(
            foregroundColor: buttonColor,
            side: BorderSide(color: buttonColor),
            padding: EdgeInsets.symmetric(
              horizontal: isSmall ? 12 : 20,
              vertical: isSmall ? 8 : 12,
            ),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
          ),
        ),
      );
    }

    return SizedBox(
      width: width,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : (icon != null
                ? Icon(icon, size: isSmall ? 16 : 18)
                : const SizedBox.shrink()),
        label: Text(text,
            style: isSmall ? AppTextStyles.buttonSmall : AppTextStyles.button),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 12 : 20,
            vertical: isSmall ? 8 : 12,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
          elevation: 0,
        ),
      ),
    );
  }
}

/// Icon Button with background
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final String? tooltip;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.backgroundColor,
    this.size = 40,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.accent.withOpacity(0.1),
        borderRadius: AppRadius.borderMd,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: color ?? AppColors.accent, size: size * 0.5),
        padding: EdgeInsets.zero,
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}

/// Text Field with consistent styling
class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;
  final int maxLines;

  const AppTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
        labelText: labelText,
        labelStyle:
            AppTextStyles.label.copyWith(color: AppColors.textSecondary),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.accent, size: 20)
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.textMuted.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(color: AppColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

/// Dropdown with consistent styling
class AppDropdown<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final String Function(T) displayBuilder;
  final Function(T?)? onChanged;

  const AppDropdown({
    super.key,
    this.value,
    required this.items,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    required this.displayBuilder,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(displayBuilder(item), style: AppTextStyles.body),
              ))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle:
            AppTextStyles.label.copyWith(color: AppColors.textSecondary),
        hintText: hintText,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.accent, size: 20)
            : null,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dropdownColor: AppColors.cardBg,
      borderRadius: AppRadius.borderMd,
    );
  }
}

/// Section Header
class AppSectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget? trailing;

  const AppSectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.accent, size: 20),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(title, style: AppTextStyles.h4),
          if (trailing != null) ...[
            const Spacer(),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// Empty State Widget
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(title,
                style:
                    AppTextStyles.h4.copyWith(color: AppColors.textSecondary)),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle!,
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSpacing.xl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Loading Widget
class AppLoading extends StatelessWidget {
  final String? message;

  const AppLoading({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.accent),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(message!, style: AppTextStyles.bodySmall),
          ],
        ],
      ),
    );
  }
}

/// Stat Card for dashboards
class AppStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final String? subtitle;
  final VoidCallback? onTap;

  const AppStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? AppColors.accent;

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: cardColor.withOpacity(0.1),
              borderRadius: AppRadius.borderMd,
            ),
            child: Icon(icon, color: cardColor, size: 24),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(value, style: AppTextStyles.h3),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(subtitle!, style: AppTextStyles.caption),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Alert/Reminder Card
class AppAlertCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const AppAlertCard({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: AppRadius.borderMd,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.label.copyWith(color: color),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(content, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}

/// Chip for filters
class AppChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;

  const AppChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.cardBg,
          borderRadius: AppRadius.borderFull,
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.divider,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Detail Row for dialogs/detail views
class AppDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const AppDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: AppColors.textMuted),
            const SizedBox(width: AppSpacing.sm),
          ],
          SizedBox(
            width: 100,
            child: Text(label, style: AppTextStyles.bodySmall),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
