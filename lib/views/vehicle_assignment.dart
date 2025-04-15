import 'dart:developer';

import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:multifleet/models/vehicle.dart';
import 'package:multifleet/widgets/search_vehicle.dart';

import '../controllers/vehicle_assign_controller.dart';
import '../widgets/custom_widgets.dart';

class VehicleAssignmentPage extends StatelessWidget {
  const VehicleAssignmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VehicleAssignmentController());

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search section
                  _buildSearchSection(controller),
                  SizedBox(height: 20),

                  // Vehicle details
                  Obx(() => controller.selectedVehicle.value != null
                      ? _buildVehicleDetails(controller.selectedVehicle.value!)
                      : SizedBox()),

                  // Employee assignment form
                  Obx(() => controller.selectedVehicle.value != null
                      ? _buildAssignmentForm(context, controller, constraints)
                      : SizedBox()),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSearchSection(VehicleAssignmentController controller) {
    return SearchVehicleWidget(
      controller: controller.plateNumberController,
      heading: "Search to assign",
      onSearch: () => controller.searchVehicle(),
      onClear: () => controller.clearSearch(),
      onDataChanged: (letter, emirate, number) {
        controller.onPlateChanged(letter, emirate, number);
      },
    );
  }

  Widget _buildVehicleDetails(Vehicle vehicle) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vehicle Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildDetailRow(
                'Brand & Model', '${vehicle.brand} ${vehicle.model}'),
            _buildDetailRow('Plate Number', vehicle.vehicleNo ?? ''),
            _buildDetailRow('Vehicle Type', vehicle.type ?? ''),
            _buildDetailRow('Chassis Number', vehicle.chassisNo ?? ''),
            _buildDetailRow('Traffic File', vehicle.chassisNo ?? ''),
            // _buildDetailRow('Policy Number', vehicle.insuranceType ?? ''),
            // _buildDetailRow('Current KM', vehicle.currentOdo.toString()),
            // _buildDetailRow('Mulkiya Expiry', vehicle.mulkiyaExpiry ?? ''),
            // _buildDetailRow('Insurance Expiry', vehicle.insuranceExpiry ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentForm(BuildContext context,
      VehicleAssignmentController controller, BoxConstraints constraints) {
    // Determine if we should use a single column or multi-column layout
    final bool useWideLayout = constraints.maxWidth >= 768;

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Employee Assignment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),

            // Form fields
            useWideLayout
                ? _buildWideFormLayout(context, controller)
                : _buildNarrowFormLayout(context, controller),

            SizedBox(height: 20),

            // Images section
            Text(
              'Upload Images (Max 6)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            _buildImagesSection(controller),
            SizedBox(height: 20),

            // Action buttons
            _buildActionButtons(
              onPressedOK: () {
                // controller.submitAssignment();
                // Get.showSnackbar(GetSnackBar(
                //   title: "Test",
                //   message: "Testing Snackbar",
                //   backgroundColor: Colors.green,
                //   duration: Duration(seconds: 2),

                // ));
              },
              onPressedCancel: () {
                controller.clearForm();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWideFormLayout(
      BuildContext context, VehicleAssignmentController controller) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Employee dropdown
                  Text('Employee Name *'),
                  SizedBox(height: 8),
                  _buildEmployeeDropdown(context, controller),
                  SizedBox(height: 16),

                  // Start date picker
                  Text('Start Date & Time *'),
                  SizedBox(height: 8),
                  _buildDateTimePicker(
                    context: Get.context!,
                    initialDate: controller.startDate.value,
                    onDateSelected: (date) => controller.startDate.value = date,
                  ),
                  SizedBox(height: 16),

                  // Remarks
                  Text('Remarks'),
                  SizedBox(height: 8),
                  TextField(
                    controller: controller.remarksController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter any comments or notes',
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            SizedBox(width: 20),
            // Right column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Designation dropdown
                  Text('Designation *'),
                  SizedBox(height: 8),
                  _buildDesignationDropdown(context, controller),
                  SizedBox(height: 16),

                  // End date picker
                  Text('End Date & Time'),
                  SizedBox(height: 8),
                  _buildDateTimePicker(
                    context: Get.context!,
                    initialDate: controller.endDate.value,
                    onDateSelected: (date) => controller.endDate.value = date,
                  ),
                  SizedBox(height: 16),

                  // Status dropdown
                  Text('Status *'),
                  SizedBox(height: 8),
                  _buildStatusDropdown(controller),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNarrowFormLayout(
      BuildContext context, VehicleAssignmentController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Employee dropdown
        Text('Employee Name *'),
        SizedBox(height: 8),
        _buildEmployeeDropdown(context, controller),
        SizedBox(height: 16),

        // Designation dropdown
        Text('Designation *'),
        SizedBox(height: 8),
        _buildDesignationDropdown(context, controller),
        SizedBox(height: 16),

        // Start date picker
        Text('Start Date & Time *'),
        SizedBox(height: 8),
        _buildDateTimePicker(
          context: Get.context!,
          initialDate: controller.startDate.value,
          onDateSelected: (date) => controller.startDate.value = date,
        ),
        SizedBox(height: 16),

        // End date picker
        Text('End Date & Time'),
        SizedBox(height: 8),
        _buildDateTimePicker(
          context: Get.context!,
          initialDate: controller.endDate.value,
          onDateSelected: (date) => controller.endDate.value = date,
        ),
        SizedBox(height: 16),

        // Status dropdown
        Text('Status *'),
        SizedBox(height: 8),
        _buildStatusDropdown(controller),
        SizedBox(height: 16),

        // Remarks
        Text('Remarks'),
        SizedBox(height: 8),
        TextField(
          controller: controller.remarksController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter any comments or notes',
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildEmployeeDropdown(
      BuildContext context, VehicleAssignmentController con) {
    return SizedBox(
      height: 60,
      child: DropDownSearchField<String>(
        displayAllSuggestionWhenTap: true,
        isMultiSelectDropdown: false,
        debounceDuration: Duration(milliseconds: 500),
        textFieldConfiguration: TextFieldConfiguration(
          controller: con.empNameController,
          keyboardType: TextInputType.name,
          style: Theme.of(context).textTheme.labelLarge,
          decoration: CustomWidget().inputDecoration(
            context: context,
            labelText: "Employee",
            radius: 16,
          ),
        ),
        hideOnEmpty: true,
        hideOnLoading: false,
        suggestionsCallback: (pattern) async {
          return await con.getEmpSuggestions(pattern);
        },
        itemBuilder: (context, suggestion) {
          return ListTile(
            leading: Icon(Icons.business),
            title: Text(suggestion),
            subtitle: Text(suggestion),
          );
        },
        onSuggestionSelected: (suggestion) {
          con.onEmpSelected(suggestion);
        },
      ),
    );
  }

  Widget _buildDesignationDropdown(
      BuildContext context, VehicleAssignmentController con) {
    return SizedBox(
      height: 60,
      child: DropDownSearchField<String>(
        displayAllSuggestionWhenTap: true,
        isMultiSelectDropdown: false,
        debounceDuration: Duration(milliseconds: 500),
        textFieldConfiguration: TextFieldConfiguration(
          controller: con.designationController,
          keyboardType: TextInputType.name,
          style: Theme.of(context).textTheme.labelLarge,
          decoration: CustomWidget().inputDecoration(
            context: context,
            labelText: "Designation",
            radius: 16,
          ),
        ),
        hideOnEmpty: true,
        hideOnLoading: false,
        suggestionsCallback: (pattern) async {
          return await con.getDesignationSuggestions(pattern);
        },
        itemBuilder: (context, suggestion) {
          return ListTile(
            leading: Icon(Icons.business),
            title: Text(suggestion),
            subtitle: Text(suggestion),
          );
        },
        onSuggestionSelected: (suggestion) {
          con.onDesignationSelected(suggestion);
        },
      ),
    );
  }

  Widget _buildStatusDropdown(VehicleAssignmentController controller) {
    return Obx(() => DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          value: controller.selectedStatus.value,
          items: controller.statusOptions
              .map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  ))
              .toList(),
          onChanged: (value) => controller.selectedStatus.value = value,
        ));
  }

  Widget _buildDateTimePicker({
    required BuildContext context,
    required DateTime? initialDate,
    required Function(DateTime) onDateSelected,
  }) {
    return InkWell(
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: initialDate ?? DateTime.now(),
          firstDate: DateTime.now().subtract(Duration(days: 365)),
          lastDate: DateTime.now().add(Duration(days: 365 * 5)),
        );

        if (pickedDate != null) {
          final TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );

          if (pickedTime != null) {
            final newDateTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );
            onDateSelected(newDateTime);
          }
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              initialDate != null
                  ? DateFormat('dd MMM yyyy, hh:mm a').format(initialDate)
                  : 'Select date and time',
              style: TextStyle(
                color: initialDate != null ? Colors.black : Colors.grey,
              ),
            ),
            Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesSection(VehicleAssignmentController controller) {
    return Column(
      children: [
        // Image preview grid
        Obx(
          () => controller.selectedImages.isEmpty
              ? SizedBox.shrink()
              : GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: controller.selectedImages.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              'assets/placeholder_image.png', // In a real app, use Image.file(File(controller.selectedImages[index].path))
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                        ),
                        Positioned(
                          top: -8,
                          right: -8,
                          child: InkWell(
                            onTap: () => controller.removeImage(index),
                            child: Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
        SizedBox(height: 16),
        // Add image button
        Obx(() => ElevatedButton.icon(
              onPressed: controller.selectedImages.length >= 6
                  ? null
                  : () => controller.pickImages(),
              icon: Icon(Icons.add_photo_alternate),
              label: Text(
                  'Add Image${controller.selectedImages.length > 0 ? " (${controller.selectedImages.length}/6)" : ""}'),
            )),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label + ":",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      {required void Function()? onPressedOK,
      required void Function()? onPressedCancel}) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: onPressedOK,
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
              onPressed: onPressedCancel,
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

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }
}
