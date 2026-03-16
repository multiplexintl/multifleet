import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

Widget buildAutocompleteTextField({
  required BuildContext context,
  required TextEditingController controller,
  required String label,
  required String storageKey,
  IconData? icon,
  bool isRequired = false,
  bool isReadOnly = false,
  TextInputType keyboardType = TextInputType.text,
  void Function(String)? onChanged,
  List<String>? initialSuggestions,
}) {
  // Get the storage instance
  final storage = GetStorage();

  // Initialize suggestions from storage or use initialSuggestions if storage is empty
  List<String> storedSuggestions =
      storage.read<List>(storageKey)?.map((e) => e.toString()).toList() ?? [];

  // If we have initial suggestions and storage is empty, use them
  if (initialSuggestions != null && storedSuggestions.isEmpty) {
    storedSuggestions = [...initialSuggestions];
  }

  // Create an Rx list to reactively update suggestions
  final suggestions = storedSuggestions.obs;

  // Function to add a new suggestion to storage
  void addNewSuggestion(String value) {
    if (value.isNotEmpty && !suggestions.contains(value)) {
      suggestions.add(value);
      // Keep the list sorted for better usability
      suggestions.sort();
      // Save to storage
      storage.write(storageKey, suggestions.toList());
    }
  }

  // Get a key for this field to help with width calculation
  final textFieldKey = GlobalKey();

  return Autocomplete<String>(
    optionsBuilder: (TextEditingValue textEditingValue) {
      if (textEditingValue.text.isEmpty) {
        return const Iterable<String>.empty();
      }
      return suggestions.where((suggestion) => suggestion
          .toLowerCase()
          .contains(textEditingValue.text.toLowerCase()));
    },
    onSelected: (String selection) {
      controller.text = selection;
      if (onChanged != null) {
        onChanged(selection);
      }
    },
    fieldViewBuilder: (
      BuildContext context,
      TextEditingController fieldController,
      FocusNode fieldFocusNode,
      VoidCallback onFieldSubmitted,
    ) {
      // Set the autocomplete controller to the provided controller's value
      fieldController.text = controller.text;

      return RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (RawKeyEvent event) {
          // Check if Tab key is pressed
          if (event is RawKeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.tab) {
            // Add current value to suggestions when Tab is pressed
            String currentValue = fieldController.text.trim();
            if (currentValue.isNotEmpty) {
              addNewSuggestion(currentValue);
              // Update the main controller
              controller.text = currentValue;
            }
            // Tab handling is managed by Flutter framework, no need to do anything else
          }
        },
        child: TextField(
          key: textFieldKey,
          controller: fieldController,
          focusNode: fieldFocusNode,
          keyboardType: keyboardType,
          readOnly: isReadOnly,
          decoration: InputDecoration(
            labelText: isRequired ? '$label *' : label,
            prefixIcon: icon != null ? Icon(icon) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onChanged: (value) {
            // Update the main controller
            controller.text = value;
            if (onChanged != null) {
              onChanged(value);
            }
          },
          onSubmitted: (value) {
            // Add to suggestions when user submits
            addNewSuggestion(value);
            onFieldSubmitted();
          },
          onEditingComplete: () {
            log("message");
          },
        ),
      );
    },
    optionsViewBuilder: (
      BuildContext context,
      AutocompleteOnSelected<String> onSelected,
      Iterable<String> options,
    ) {
      // Get the render box of our text field to match its width
      final RenderBox? renderBox =
          textFieldKey.currentContext?.findRenderObject() as RenderBox?;
      final double width =
          renderBox?.size.width ?? 300; // Fallback width if not found

      return Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 4.0,
          child: Container(
            width: width, // Match the width of the text field
            constraints: BoxConstraints(
              maxHeight: 200,
            ),
            child: ListView.builder(
              padding: EdgeInsets.all(8.0),
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (BuildContext context, int index) {
                final String option = options.elementAt(index);
                return InkWell(
                  onTap: () {
                    onSelected(option);
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Text(
                      option,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    },
  );
}
