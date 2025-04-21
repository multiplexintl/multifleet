import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multiselect_dropdown_flutter/multiselect_dropdown_flutter.dart';

/// A reusable multi-select dropdown component that properly handles type conversion
/// and provides a consistent interface for selection.
class MultiSelectDropDown extends StatelessWidget {
  /// The label text displayed above the dropdown
  final String label;

  /// The list of available options to select from
  final List<String> options;

  /// The list of initially selected items
  final List<String> initiallySelected;

  /// Callback function that is called when selections change
  final void Function(List<String>)? onChanged;

  /// Optional decoration for the dropdown box
  final BoxDecoration? boxDecoration;

  /// Optional hint text when no selections are made
  final String? hint;

  const MultiSelectDropDown({
    super.key,
    required this.label,
    required this.options,
    this.initiallySelected = const [],
    this.onChanged,
    this.boxDecoration,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    // Create an observable list with initial values to track selections
    final selectedItems = initiallySelected.obs;

    return MultiSelectDropdown.simpleList(
      list: options,
      initiallySelected: selectedItems,
      // Use provided decoration or default one
      boxDecoration: boxDecoration ??
          BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),

      whenEmpty: label,
      includeSelectAll: true,
      includeSearch: true,
      onChange: (dynamic selectedItems) {
        // Convert List<dynamic> to List<String> explicitly
        final List<String> items = (selectedItems as List<dynamic>)
            .map((item) => item.toString())
            .toList();

        // Update our local observable
        selectedItems = items;

        // Call the callback if provided
        if (onChanged != null) {
          onChanged!(items);
        }
      },
    );
  }
}

/// Helper function to build a multi-select dropdown field in your forms
Widget buildMultiSelectField({
  required String label,
  required List<String> options,
  required List<String> initiallySelected,
  required void Function(List<String>) onChanged,
  String? hint,
  BoxDecoration? boxDecoration,
}) {
  return MultiSelectDropDown(
    label: label,
    options: options,
    initiallySelected: initiallySelected,
    onChanged: onChanged,
    hint: hint,
    boxDecoration: boxDecoration,
  );
}
