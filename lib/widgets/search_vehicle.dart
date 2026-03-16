import 'package:flutter/material.dart';
import 'package:multifleet/models/plate_data.dart';

import '../theme/app_theme.dart';
import 'license_plate_widget.dart';

class SearchVehicleWidget extends StatefulWidget {
  final String? heading;
  final String? labelText;
  final TextEditingController? controller;
  final void Function()? onSearch;
  final String? searchText;
  final void Function()? onClear;
  final String? clearText;
  final void Function()? onTapTextField;
  final Function(PlateData) onDataChanged;

  const SearchVehicleWidget({
    super.key,
    this.controller,
    this.onSearch,
    this.onClear,
    this.heading,
    this.searchText,
    this.clearText,
    this.labelText,
    this.onTapTextField,
    required this.onDataChanged,
  });

  @override
  State<SearchVehicleWidget> createState() => _SearchVehicleWidgetState();
}

class _SearchVehicleWidgetState extends State<SearchVehicleWidget> {
  int _clearCount = 0;

  void _handleClear() {
    setState(() => _clearCount++);
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: AppRadius.borderLg,
        boxShadow: AppShadows.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          if (widget.heading != null)
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.divider),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius: AppRadius.borderMd,
                    ),
                    child: Icon(
                      Icons.search_outlined,
                      color: AppColors.accent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    widget.heading ?? 'Search Vehicle',
                    style: AppTextStyles.h4,
                  ),
                ],
              ),
            ),

          // Content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;

                if (isMobile) {
                  // Mobile layout - stack vertically
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // License plate — key forces rebuild (and reset) on clear
                      LicensePlateWidget(
                        key: ValueKey(_clearCount),
                        onChanged: widget.onDataChanged,
                        width: constraints.maxWidth,
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Buttons row
                      Row(
                        children: [
                          Expanded(
                            child: _SearchButton(
                              label: widget.searchText ?? 'Search',
                              icon: Icons.search_outlined,
                              onPressed: widget.onSearch,
                              isPrimary: true,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _SearchButton(
                              label: widget.clearText ?? 'Clear',
                              icon: Icons.refresh_outlined,
                              onPressed: _handleClear,
                              isPrimary: false,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  // Desktop/tablet layout - horizontal
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 3,
                        // key forces rebuild (and reset) on clear
                        child: LicensePlateWidget(
                          key: ValueKey(_clearCount),
                          onChanged: widget.onDataChanged,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xxxl),
                      _SearchButton(
                        label: widget.searchText ?? 'Search',
                        icon: Icons.search_outlined,
                        onPressed: widget.onSearch,
                        isPrimary: true,
                        minWidth: 130,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      _SearchButton(
                        label: widget.clearText ?? 'Clear',
                        icon: Icons.refresh_outlined,
                        onPressed: _handleClear,
                        isPrimary: false,
                        minWidth: 130,
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final double? minWidth;

  const _SearchButton({
    required this.label,
    required this.icon,
    this.onPressed,
    this.isPrimary = true,
    this.minWidth,
  });

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return SizedBox(
        height: 48,
        width: minWidth,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 20),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderMd,
            ),
          ),
        ),
      );
    } else {
      return SizedBox(
        height: 48,
        width: minWidth,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 20),
          label: Text(label),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            side: BorderSide(color: AppColors.divider),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderMd,
            ),
          ),
        ),
      );
    }
  }
}
// import 'package:flutter/material.dart';
// import 'package:multifleet/widgets/button_widget.dart';

// import 'license_plate_widget.dart';

// class SearchVehicleWidget extends StatelessWidget {
//   final String? heading;
//   final String? labelText;
//   final TextEditingController? controller;
//   final void Function()? onSearch;
//   final String? searchText;
//   final void Function()? onClear;
//   final String? clearText;
//   final void Function()? onTapTextField;
//   final dynamic Function(String, String, String) onDataChanged;

//   const SearchVehicleWidget({
//     super.key,
//     this.controller,
//     this.onSearch,
//     this.onClear,
//     this.heading,
//     this.searchText,
//     this.clearText,
//     this.labelText,
//     this.onTapTextField,
//     required this.onDataChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 4,
//       child: Padding(
//         padding:
//             const EdgeInsets.only(left: 50, right: 50, bottom: 25, top: 25),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               heading ?? 'Search Vehicle',
//               style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Responsive layout for different screen sizes
//             LayoutBuilder(
//               builder: (context, constraints) {
//                 if (constraints.maxWidth < 600) {
//                   // Mobile layout - stack vertically
//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       // License plate takes full width on mobile
//                       UnifiedLicensePlateWidget(
//                         onDataChanged: onDataChanged,
//                         width: constraints.maxWidth - 32, // Account for padding
//                       ),
//                       const SizedBox(height: 16),

//                       // Buttons in a row
//                       Row(
//                         children: [
//                           Expanded(
//                             child: CustomButtonWidget(
//                               title: searchText ?? "Search",
//                               isCancel: false,
//                               onPressed: onSearch,
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: CustomButtonWidget(
//                               title: clearText ?? "Clear",
//                               isCancel: true,
//                               onPressed: onClear,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   );
//                 } else {
//                   // Desktop/tablet layout - horizontal
//                   return Row(
//                     children: [
//                       Expanded(
//                         flex: 3,
//                         child: UnifiedLicensePlateWidget(
//                           onDataChanged: onDataChanged,
//                         ),
//                       ),
//                       const SizedBox(width: 220),
//                       Expanded(
//                         child: CustomButtonWidget(
//                           title: searchText ?? "Search",
//                           isCancel: false,
//                           onPressed: onSearch,
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: CustomButtonWidget(
//                           title: clearText ?? "Clear",
//                           isCancel: true,
//                           onPressed: onClear,
//                         ),
//                       ),
//                     ],
//                   );
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
