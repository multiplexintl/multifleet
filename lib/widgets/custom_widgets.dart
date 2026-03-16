import 'package:flutter/material.dart';
import 'package:multifleet/theme/app_theme.dart';

import 'custom_snackbar.dart';

class CustomWidget {
  InputDecoration inputDecoration(
      {required BuildContext context, String? labelText, double? radius}) {
    return InputDecoration(
      labelText: labelText,
      contentPadding:
          const EdgeInsets.only(left: 21, right: 15, top: 15, bottom: 15),
      filled: true,
      fillColor: Colors.transparent,
      labelStyle: Theme.of(context).textTheme.labelLarge?.merge(const TextStyle(
            letterSpacing: 1.2,
          )),
      floatingLabelStyle:
          Theme.of(context).textTheme.labelLarge?.merge(const TextStyle(
                letterSpacing: 1.2,
              )),
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.textMuted),
          borderRadius: BorderRadius.all(Radius.circular(radius ?? 15))),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.transparent),
        borderRadius: BorderRadius.all(Radius.circular(radius ?? 15)),
      ),
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.textMuted),
          borderRadius: BorderRadius.all(Radius.circular(radius ?? 15))),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
        borderRadius: BorderRadius.all(
          Radius.circular(radius ?? 15),
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.transparent),
        borderRadius: BorderRadius.all(
          Radius.circular(radius ?? 15),
        ),
      ),
      errorStyle: Theme.of(context).textTheme.bodySmall?.merge(
            const TextStyle(
              color: Colors.red,
              height: 0.5,
            ),
          ),
    );
  }

  static Future<void> customSnackBar({
    required String title,
    required String message,
    bool isError = false,
    bool isInfo = false,
    int? duration,
    void Function()? onClose,
  }) async {
    return CustomSnackbar.show(
      title: title,
      message: message,
      backgroundColor: isError
          ? Colors.red.shade700
          : isInfo
              ? AppColors.accent
              : Colors.green.shade700,
      duration: Duration(seconds: duration ?? 3),
      position: SnackbarPosition.topRight,
      onClose: onClose,
    );
  }

  Widget buildDropdown<T>({
    String? label,
    String? hint,
    required T? value,
    required List<T> options,
    required void Function(T?) onChanged,
    required IconData icon,
    String Function(T)? displayTextBuilder, // Optional custom display text
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label ?? '',
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      hint: Text(hint ?? ''),
      items: options.map((option) {
        return DropdownMenuItem<T>(
          value: option,
          child: Text(displayTextBuilder != null
              ? displayTextBuilder(option)
              : option.toString()),
        );
      }).toList(),
      onChanged: onChanged,
      isDense: true,
      isExpanded: true,
    );
  }
}
