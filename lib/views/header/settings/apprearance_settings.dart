import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multifleet/theme/app_theme.dart';

import '../../../services/theme_service.dart';

/// ============================================================
/// APPEARANCE SETTINGS
/// ============================================================
/// Settings panel for theme mode, accent color, and density.
/// ============================================================

class AppearanceSettings extends StatelessWidget {
  const AppearanceSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.to;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildSectionHeader(
            icon: Icons.palette_outlined,
            title: 'Appearance',
            subtitle: 'Customize how MultiFleet looks',
          ),
          const SizedBox(height: 24),

          // Theme Mode
          _ThemeModeSection(theme: theme),
          const SizedBox(height: 24),

          // Accent Color
          _AccentColorSection(theme: theme),
          const SizedBox(height: 24),

          // Density
          _DensitySection(theme: theme),
          const SizedBox(height: 24),

          // Preview Card
          _PreviewSection(theme: theme),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Obx(() => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ThemeService.to.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: ThemeService.to.accentColor, size: 24),
            )),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }
}

// ==================== THEME MODE SECTION ====================

class _ThemeModeSection extends StatelessWidget {
  final ThemeService theme;

  const _ThemeModeSection({required this.theme});

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: 'Theme Mode',
      subtitle: 'Choose your preferred color scheme',
      child: Obx(() => Row(
            children: [
              _ThemeModeOption(
                icon: Icons.light_mode_outlined,
                label: 'Light',
                isSelected: theme.themeMode == ThemeMode.light,
                onTap: () => theme.setThemeMode(ThemeMode.light),
              ),
              const SizedBox(width: 12),
              _ThemeModeOption(
                icon: Icons.dark_mode_outlined,
                label: 'Dark',
                isSelected: theme.themeMode == ThemeMode.dark,
                onTap: () => theme.setThemeMode(ThemeMode.dark),
              ),
              const SizedBox(width: 12),
              _ThemeModeOption(
                icon: Icons.brightness_auto_outlined,
                label: 'System',
                isSelected: theme.themeMode == ThemeMode.system,
                onTap: () => theme.setThemeMode(ThemeMode.system),
              ),
            ],
          )),
    );
  }
}

class _ThemeModeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeModeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(() {
        final accent = ThemeService.to.accentColor;

        return Material(
          color: isSelected ? accent.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? accent : Theme.of(context).dividerColor,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    icon,
                    size: 28,
                    color: isSelected ? accent : AppColors.textSecondary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? accent : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ==================== ACCENT COLOR SECTION ====================

class _AccentColorSection extends StatelessWidget {
  final ThemeService theme;

  const _AccentColorSection({required this.theme});

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: 'Accent Color',
      subtitle: 'Select your preferred accent color',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Color Grid
          Obx(() => Wrap(
                spacing: 12,
                runSpacing: 12,
                children: ThemeService.accentColors.map((option) {
                  final isSelected =
                      theme.accentColor.value == option.color.value;

                  return _ColorOption(
                    color: option.color,
                    name: option.name,
                    isSelected: isSelected,
                    onTap: () => theme.setAccentColor(option.color),
                  );
                }).toList(),
              )),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // Custom color picker button
          Obx(() => OutlinedButton.icon(
                onPressed: () => _showCustomColorPicker(context),
                icon: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: theme.accentColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.textMuted),
                  ),
                ),
                label: const Text('Custom Color'),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              )),
        ],
      ),
    );
  }

  void _showCustomColorPicker(BuildContext context) {
    final hueController = (HSLColor.fromColor(theme.accentColor).hue).obs;
    final satController =
        (HSLColor.fromColor(theme.accentColor).saturation).obs;
    final lightController =
        (HSLColor.fromColor(theme.accentColor).lightness).obs;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Custom Accent Color'),
        content: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Preview
              Obx(() {
                final color = HSLColor.fromAHSL(
                  1.0,
                  hueController.value,
                  satController.value,
                  lightController.value,
                ).toColor();

                return Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
                      style: TextStyle(
                        color: lightController.value > 0.5
                            ? Colors.black
                            : Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),

              // Hue slider
              _ColorSlider(
                label: 'Hue',
                value: hueController,
                max: 360,
                gradient: LinearGradient(
                  colors: List.generate(
                    7,
                    (i) => HSLColor.fromAHSL(1, i * 60.0, 0.8, 0.5).toColor(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Saturation slider
              Obx(() => _ColorSlider(
                    label: 'Saturation',
                    value: satController,
                    max: 1,
                    gradient: LinearGradient(
                      colors: [
                        HSLColor.fromAHSL(1, hueController.value, 0,
                                lightController.value)
                            .toColor(),
                        HSLColor.fromAHSL(1, hueController.value, 1,
                                lightController.value)
                            .toColor(),
                      ],
                    ),
                  )),
              const SizedBox(height: 16),

              // Lightness slider
              Obx(() => _ColorSlider(
                    label: 'Lightness',
                    value: lightController,
                    max: 1,
                    gradient: LinearGradient(
                      colors: [
                        Colors.black,
                        HSLColor.fromAHSL(1, hueController.value,
                                satController.value, 0.5)
                            .toColor(),
                        Colors.white,
                      ],
                    ),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Obx(() {
            final color = HSLColor.fromAHSL(
              1.0,
              hueController.value,
              satController.value,
              lightController.value,
            ).toColor();

            return ElevatedButton(
              onPressed: () {
                theme.setAccentColor(color);
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            );
          }),
        ],
      ),
    );
  }
}

class _ColorOption extends StatelessWidget {
  final Color color;
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorOption({
    required this.color,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: name,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? Colors.white : Colors.transparent,
              width: 3,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: isSelected
              ? const Icon(Icons.check, color: Colors.white, size: 24)
              : null,
        ),
      ),
    );
  }
}

class _ColorSlider extends StatelessWidget {
  final String label;
  final RxDouble value;
  final double max;
  final Gradient gradient;

  const _ColorSlider({
    required this.label,
    required this.value,
    required this.max,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            Obx(() => Text(
                  max > 1
                      ? value.value.toInt().toString()
                      : value.value.toStringAsFixed(2),
                  style:
                      TextStyle(fontSize: 12, color: AppColors.textSecondary),
                )),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 24,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Obx(() => SliderTheme(
                data: SliderThemeData(
                  trackHeight: 24,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 10),
                  overlayShape:
                      const RoundSliderOverlayShape(overlayRadius: 16),
                  thumbColor: Colors.white,
                  overlayColor: Colors.white24,
                  trackShape: const RoundedRectSliderTrackShape(),
                  activeTrackColor: Colors.transparent,
                  inactiveTrackColor: Colors.transparent,
                ),
                child: Slider(
                  value: value.value,
                  min: 0,
                  max: max,
                  onChanged: (v) => value.value = v,
                ),
              )),
        ),
      ],
    );
  }
}

// ==================== DENSITY SECTION ====================

class _DensitySection extends StatelessWidget {
  final ThemeService theme;

  const _DensitySection({required this.theme});

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: 'Display Density',
      subtitle: 'Adjust the spacing and size of UI elements',
      child: Obx(() => Row(
            children: [
              _DensityOption(
                icon: Icons.density_small,
                label: 'Compact',
                isSelected: theme.density == VisualDensity.compact,
                onTap: () => theme.setDensity(VisualDensity.compact),
              ),
              const SizedBox(width: 12),
              _DensityOption(
                icon: Icons.density_medium,
                label: 'Comfortable',
                isSelected: theme.density == VisualDensity.comfortable,
                onTap: () => theme.setDensity(VisualDensity.comfortable),
              ),
              const SizedBox(width: 12),
              _DensityOption(
                icon: Icons.density_large,
                label: 'Spacious',
                isSelected: theme.density == VisualDensity.standard,
                onTap: () => theme.setDensity(VisualDensity.standard),
              ),
            ],
          )),
    );
  }
}

class _DensityOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DensityOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(() {
        final accent = ThemeService.to.accentColor;

        return Material(
          color: isSelected ? accent.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? accent : Theme.of(context).dividerColor,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(icon,
                      color: isSelected ? accent : AppColors.textSecondary),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? accent : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ==================== PREVIEW SECTION ====================

class _PreviewSection extends StatelessWidget {
  final ThemeService theme;

  const _PreviewSection({required this.theme});

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: 'Preview',
      subtitle: 'See how your changes will look',
      child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Buttons preview
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Primary'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('Secondary'),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Text Button'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Chips preview
              Wrap(
                spacing: 8,
                children: [
                  Chip(
                    label: const Text('Active'),
                    backgroundColor: theme.accentColor.withOpacity(0.1),
                    side: BorderSide(color: theme.accentColor),
                  ),
                  const Chip(label: Text('Inactive')),
                  InputChip(
                    label: const Text('Selectable'),
                    selected: true,
                    onSelected: (_) {},
                    selectedColor: theme.accentColor.withOpacity(0.15),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Progress indicators
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation(theme.accentColor),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: 0.6,
                      backgroundColor: theme.accentColor.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation(theme.accentColor),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Switch and Checkbox
              Row(
                children: [
                  Switch(value: true, onChanged: (_) {}),
                  const SizedBox(width: 8),
                  Checkbox(value: true, onChanged: (_) {}),
                  const SizedBox(width: 8),
                  Radio(value: true, groupValue: true, onChanged: (_) {}),
                ],
              ),
            ],
          )),
    );
  }
}

// ==================== SETTINGS CARD WRAPPER ====================

class _SettingsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SettingsCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
