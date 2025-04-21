import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
          borderSide: BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.all(Radius.circular(radius ?? 15))),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.transparent),
        borderRadius: BorderRadius.all(Radius.circular(radius ?? 15)),
      ),
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
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
              ? Colors.teal.shade300
              : Colors.green.shade700,
      duration: Duration(seconds: duration ?? 3),
      position: SnackbarPosition.topRight,
      onClose: onClose,
    );
  }
}
