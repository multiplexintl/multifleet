import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:multifleet/widgets/search_vehicle.dart';
import 'package:multiselect_dropdown_flutter/multiselect_dropdown_flutter.dart';

import '../controllers/add_edit_vehicle_controller.dart';

// Main StatelessWidget Page
class AddEditVehiclePage extends StatelessWidget {
  const AddEditVehiclePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    final controller = Get.put(AddEditVehicleController());

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search Section
                _buildSearchSection(controller),

                const SizedBox(height: 20),

                // Vehicle Details Section (if found)
                Obx(() => controller.isSearching.value
                    ? Center(
                        child: Text("Searching..."),
                      )
                    : controller.vehicleData.value != null
                        ? _buildVehicleDetailsSection(controller)
                        : Center(child: Text("Search Any Vehicle"))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSection(AddEditVehicleController controller) {
    return SearchVehicleWidget(
      controller: controller.plateNumberController,
      onSearch: () => controller.searchVehicle(),
      onClear: () => controller.clearSearch(),
      onDataChanged: (letter, emirate, number) {
        controller.onPlateChanged(letter, emirate, number);
      },
    );
  }

  Widget _buildVehicleDetailsSection(AddEditVehicleController controller) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Permanent Details Section
            _buildSectionHeader('Permanent Vehicle Details'),
            _buildPermanentDetailsSection(controller),

            const Divider(height: 32),

            // Changeable Details Section
            _buildSectionHeader('Changeable Vehicle Details'),
            _buildChangeableDetailsSection(controller),

            const Divider(height: 32),

            // Tires Section
            _buildSectionHeader('Tire Details'),
            // _buildTiresSection(controller),

            const SizedBox(height: 50),

            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue[800],
        ),
      ),
    );
  }

  Widget _buildPermanentDetailsSection(AddEditVehicleController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = _calculateCrossAxisCount(constraints.maxWidth);

        return Obx(() => GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 9.5,
              mainAxisSpacing: 20,
              crossAxisSpacing: 25,
              children: [
                _buildReadOnlyField(
                    'Plate Number', controller.vehicleData.value!.vehicleNo),
                _buildReadOnlyField(
                    'Brand', controller.vehicleData.value!.brand),
                _buildReadOnlyField(
                    'Model', controller.vehicleData.value!.model),
                _buildReadOnlyField('Type', controller.vehicleData.value!.type),
                _buildReadOnlyField(
                    'Chassis Number', controller.vehicleData.value!.chassisNo),
                _buildReadOnlyField('Traffic File Number',
                    controller.vehicleData.value!.traficFileNo),
                _buildReadOnlyField(
                    'Company', controller.vehicleData.value!.company),
              ],
            ));
      },
    );
  }

  Widget _buildChangeableDetailsSection(AddEditVehicleController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = _calculateCrossAxisCount(constraints.maxWidth);

        return Obx(() => GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 9.5,
              mainAxisSpacing: 20,
              crossAxisSpacing: 25,
              children: [
                _buildDropdownField(
                    'Insurance Type', controller.insuranceTypes),
                // _buildDateField(
                //     'Mulkiya Expiry',
                //     controller.vehicleData.value?.mulkiyaExpiry != null &&
                //             controller
                //                 .vehicleData.value!.mulkiyaExpiry!.isNotEmpty
                //         ? DateTime.parse(
                //             controller.vehicleData.value!.mulkiyaExpiry!)
                //         : null, onDateSelected: (date) {
                //   if (date != null) {
                //     // controller.updateInsuranceExpiry(date.toIso8601String());
                //   }
                // }),
                // _buildDateField(
                //     'Insurance Expiry',
                //     controller.vehicleData.value?.insuranceExpiry != null &&
                //             controller
                //                 .vehicleData.value!.insuranceExpiry!.isNotEmpty
                //         ? DateTime.parse(
                //             controller.vehicleData.value!.insuranceExpiry!)
                //         : null, onDateSelected: (date) {
                //   if (date != null) {
                //     // controller.updateInsuranceExpiry(date.toIso8601String());
                //   }
                // }),
                _buildNumberField(
                    'Current KM', controller.vehicleData.value!.initialOdo!),
                _buildMultiSelectDropdownField(
                    'Permitted Areas', controller.permittedAreas),
                _buildDropdownField(
                    'Vehicle Condition', controller.vehicleConditions),
                _buildDropdownField('Fuel Station', controller.fuelStations),
                _buildDropdownField(
                    'Vehicle Status', controller.vehicleStatuses),
              ],
            ));
      },
    );
  }

  // Widget _buildTiresSection(AddEditVehicleController controller) {
  //   return LayoutBuilder(
  //     builder: (context, constraints) {
  //       int tiresPerRow = _calculateTiresPerRow(constraints.maxWidth);

  //       return Obx(() {
  //         // Safely access tires list, defaulting to empty list if null
  //         final tires = controller.vehicleData.value?.tires ?? [];
  //         final maxTires =
  //             controller.maxTiresAllowed; // Get the max number from controller

  //         return Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             // Header with add button
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Text(
  //                   'Tires (${tires.length}/$maxTires)',
  //                   style: TextStyle(
  //                       fontSize: 18,
  //                       fontWeight: FontWeight.bold,
  //                       color: Colors.blue[900]),
  //                 ),
  //                 if (tires.length <
  //                     maxTires) // Only show add button if below max
  //                   ElevatedButton.icon(
  //                     onPressed: () => controller.addNewTire(),
  //                     icon: const Icon(Icons.add_circle_outline),
  //                     label: const Text('Add Tire'),
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: Colors.blue[700],
  //                       foregroundColor: Colors.white,
  //                     ),
  //                   ),
  //               ],
  //             ),
  //             const SizedBox(height: 16),

  //             // No tires message
  //             if (tires.isEmpty)
  //               Center(
  //                 child: Container(
  //                   padding: const EdgeInsets.all(16),
  //                   margin: const EdgeInsets.symmetric(vertical: 20),
  //                   decoration: BoxDecoration(
  //                     color: Colors.grey[100],
  //                     borderRadius: BorderRadius.circular(8),
  //                   ),
  //                   child: Text(
  //                     'No tires added yet. Click "Add Tire" to begin.',
  //                     style: TextStyle(fontSize: 16, color: Colors.grey[600]),
  //                   ),
  //                 ),
  //               ),

  //             // Tire grid
  //             if (tires.isNotEmpty)
  //               GridView.builder(
  //                 shrinkWrap: true,
  //                 physics: const NeverScrollableScrollPhysics(),
  //                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //                   crossAxisCount: tiresPerRow,
  //                   childAspectRatio: 1.3,
  //                   crossAxisSpacing: 10,
  //                   mainAxisSpacing: 10,
  //                   mainAxisExtent: 250,
  //                 ),
  //                 itemCount: tires.length,
  //                 itemBuilder: (context, index) {
  //                   var tire = tires[index];
  //                   return Card(
  //                     elevation: 2,
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(12),
  //                     ),
  //                     child: Padding(
  //                       padding: const EdgeInsets.all(12.0),
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                         children: [
  //                           Row(
  //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                             children: [
  //                               Text(
  //                                 'Tire ${index + 1}',
  //                                 style: TextStyle(
  //                                     fontWeight: FontWeight.bold,
  //                                     color: Colors.blue[800]),
  //                               ),
  //                               IconButton(
  //                                 icon: const Icon(Icons.delete_outline,
  //                                     color: Colors.red),
  //                                 onPressed: () => controller.removeTire(index),
  //                                 iconSize: 20,
  //                                 splashRadius: 20,
  //                               ),
  //                             ],
  //                           ),
  //                           _buildEditableField('Brand', tire?.brand ?? '',
  //                               onChanged: (newValue) {
  //                             controller.updateTireBrand(index, newValue);
  //                           }),
  //                           const SizedBox(height: 15),
  //                           _buildEditableField('Model', tire?.model ?? '',
  //                               onChanged: (newValue) {
  //                             controller.updateTireModel(index, newValue);
  //                           }),
  //                           const SizedBox(height: 15),
  //                           _buildEditableField('KM', tire?.km ?? '',
  //                               onChanged: (newValue) {
  //                             controller.updateTireKm(index, newValue);
  //                           }),
  //                         ],
  //                       ),
  //                     ),
  //                   );
  //                 },
  //               ),
  //           ],
  //         );
  //       });
  //     },
  //   );
  // }

  // Utility method to calculate cross-axis count
  int _calculateCrossAxisCount(double width) {
    if (width > 1200) return 3;
    if (width > 800) return 2;
    return 1;
  }

  // Utility method to calculate tires per row
  int _calculateTiresPerRow(double width) {
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                // Save changes logic
                Get.snackbar(
                  'Success',
                  'Changes saved successfully!',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: () {
                // Cancel logic
                Get.back();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800]!,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Utility Widgets for Different Field Types
  Widget _buildReadOnlyField(String label, dynamic value) {
    return ListTile(
      title: Text(label, style: const TextStyle(fontSize: 12)),
      subtitle: Text(value.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEditableField(String label, String? value,
      {Function(String)? onChanged}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      initialValue: value ?? '', // Handle null value
      onChanged: onChanged, // Pass the typed value through callback
    );
  }

  Widget _buildDropdownField(String label, List<String> options) {
    return DropdownButtonHideUnderline(
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        items: options.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (value) {
          // Handle dropdown change
        },
      ),
    );
  }

  Widget _buildMultiSelectDropdownField(String label, List<String> options) {
    return MultiSelectDropDown(
      label: label,
      options: options,
    );
  }

  Widget _buildDateField(String label, DateTime? initialDate,
      {Function(DateTime?)? onDateSelected}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      initialValue:
          initialDate != null ? initialDate.toString().split(' ')[0] : '',
      readOnly: true, // Make field read-only since we're using a picker
      onTap: () async {
        // Date picker logic
        final selectedDate = await showDatePicker(
          context: Get.context!,
          initialDate: initialDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
        );

        // Handle the selected date
        if (selectedDate != null && onDateSelected != null) {
          onDateSelected(selectedDate);
        }
      },
    );
  }

  Widget _buildNumberField(String label, num value) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      initialValue: value.toString(),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }
}

// Custom Multi-Select Dropdown Widget
class MultiSelectDropDown extends StatelessWidget {
  final String label;
  final List<String> options;
  final void Function(List<String>)? onChanged;

  const MultiSelectDropDown({
    super.key,
    required this.label,
    required this.options,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selectedItems = <String>[].obs;

    return MultiSelectDropdown.simpleList(
      list: options,
      initiallySelected: selectedItems,
      boxDecoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      onChange: (selectedItems) {
        selectedItems = selectedItems as List<String>;
        if (onChanged != null) {
          onChanged!(selectedItems);
        }
      },
    );
  }
}
