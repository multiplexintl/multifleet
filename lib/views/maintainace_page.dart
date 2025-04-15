import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:multifleet/widgets/search_vehicle.dart';

import '../controllers/maintaince_controller.dart';

class MaintenancePage extends StatelessWidget {
  const MaintenancePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    final controller = Get.put(MaintenanceController());

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: LayoutBuilder(builder: (context, constraints) {
              bool isPhone = constraints.maxWidth < 600;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Search Section
                  if (!isPhone)
                    Row(
                      children: [
                        Expanded(
                          flex: 6,
                          child: _buildSearchSection(controller),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("OR"),
                        ),
                        Expanded(
                          flex: 2,
                          child: _buidlBulkUploadButton(controller, isPhone),
                        ),
                      ],
                    ),
                  if (isPhone)
                    Column(
                      children: [
                        _buildSearchSection(controller),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("OR"),
                        ),
                        _buidlBulkUploadButton(controller, isPhone),
                      ],
                    ),

                  const SizedBox(height: 20),
                  Obx(
                    () => controller.showBulkUpload.value
                        ? _buildBulkUploadSection(controller)
                        : SizedBox.shrink(),
                  ),

                  // Vehicle and Maintenance Details (if found)
                  Obx(
                    () => controller.vehicleFound.value &&
                            !controller.showBulkUpload.value
                        ? Column(
                            children: [
                              _buildVehicleDetailsCard(controller),
                              const SizedBox(height: 20),
                              _buildAddMaintenanceSection(controller),
                              const SizedBox(height: 20),
                              _buildMaintenanceHistorySection(controller),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  InkWell _buidlBulkUploadButton(
      MaintenanceController controller, bool isPhone) {
    return InkWell(
      onTap: () => controller.toggleBulkUpload(),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.blue[800],
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.only(
            top: isPhone ? 20 : 50,
            bottom: isPhone ? 20 : 50,
          ),
          child: Center(
            child: Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      controller.showBulkUpload.value
                          ? Icons.note_add
                          : Icons.file_upload,
                      color: Colors.white,
                    ),
                    SizedBox(width: 5),
                    Text(
                      controller.showBulkUpload.value
                          ? 'Add Single Record'
                          : 'Bulk Upload',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                )),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSection(MaintenanceController controller) {
    return SearchVehicleWidget(
      controller: controller.plateNumberController,
      heading: "Add / Search Service",
      onTapTextField: () => controller.showBulkUpload.value = false,
      onSearch: () => controller.searchVehicle(),
      onClear: () => controller.clearSearch(),
      onDataChanged: (letter, emirate, number) {
        controller.plateNumberController.text = letter + number;
        log('Letter: $letter, Emirate: $emirate, Number: $number');
        log(controller.plateNumberController.text);
      },
    );
  }

  Widget _buildVehicleDetailsCard(MaintenanceController controller) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                // Responsive layout based on width
                if (constraints.maxWidth > 600) {
                  // Wider screens - 3 columns
                  return Row(
                    children: [
                      Expanded(
                        child: _buildDetailItem(
                          'Plate Number',
                          controller.vehicleData.value!['plateNumber'],
                          Icons.directions_car,
                        ),
                      ),
                      Expanded(
                        child: _buildDetailItem(
                          'Vehicle',
                          '${controller.vehicleData.value!['brand']} ${controller.vehicleData.value!['model']}',
                          Icons.car_repair,
                        ),
                      ),
                      Expanded(
                        child: _buildDetailItem(
                          'Current KM',
                          '${controller.vehicleData.value!['currentKm']} km',
                          Icons.speed,
                        ),
                      ),
                    ],
                  );
                } else {
                  // Narrower screens - stacked
                  return Column(
                    children: [
                      _buildDetailItem(
                        'Plate Number',
                        controller.vehicleData.value!['plateNumber'],
                        Icons.directions_car,
                      ),
                      const SizedBox(height: 8),
                      _buildDetailItem(
                        'Vehicle',
                        '${controller.vehicleData.value!['brand']} ${controller.vehicleData.value!['model']}',
                        Icons.car_repair,
                      ),
                      const SizedBox(height: 8),
                      _buildDetailItem(
                        'Current KM',
                        '${controller.vehicleData.value!['currentKm']} km',
                        Icons.speed,
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[800]),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceActions(MaintenanceController controller) {
    return Row(
      children: [
        Expanded(
          child: Obx(() => ElevatedButton.icon(
                icon: Icon(
                  controller.showBulkUpload.value
                      ? Icons.note_add
                      : Icons.file_upload,
                  color: Colors.white,
                ),
                label: Text(
                  controller.showBulkUpload.value
                      ? 'Add Single Record'
                      : 'Bulk Upload',
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: controller.toggleBulkUpload,
              )),
        ),
      ],
    );
  }

  Widget _buildAddMaintenanceSection(MaintenanceController controller) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Maintenance Record',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                // Responsive layout based on width
                if (constraints.maxWidth > 800) {
                  // Three columns layout for wider screens
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildInvoiceNumberField(controller),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDatePickerField(controller),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildGarageDropdown(controller),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildDescriptionField(controller),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildAmountField(controller),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildKilometerField(controller),
                          ),
                        ],
                      ),
                    ],
                  );
                } else if (constraints.maxWidth > 600) {
                  // Two columns layout for medium screens
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildInvoiceNumberField(controller),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDatePickerField(controller),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildGarageDropdown(controller),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildAmountField(controller),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDescriptionField(controller),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildKilometerField(controller),
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  // Single column layout for narrow screens
                  return Column(
                    children: [
                      _buildInvoiceNumberField(controller),
                      const SizedBox(height: 16),
                      _buildDatePickerField(controller),
                      const SizedBox(height: 16),
                      _buildGarageDropdown(controller),
                      const SizedBox(height: 16),
                      _buildDescriptionField(controller),
                      const SizedBox(height: 16),
                      _buildAmountField(controller),
                      const SizedBox(height: 16),
                      _buildKilometerField(controller),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: controller.saveMaintenanceRecord,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Save Maintenance Record',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulkUploadSection(MaintenanceController controller) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bulk Upload Maintenance Records',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Upload an Excel file with maintenance records for multiple vehicles. The file should include columns for plate number, invoice number, invoice date, description, garage, amount, and kilometer reading.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.file_present),
                    label: const Text('Select Excel File'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      // File selection logic would go here
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.upload_file, color: Colors.white),
                    label: const Text(
                      'Upload Records',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: controller.uploadBulkMaintenanceRecords,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[800]),
                      const SizedBox(width: 8),
                      Text(
                        'Template Requirements',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• File must be in .xlsx format\n'
                    '• The first row must contain column headers\n'
                    '• Required columns: Plate Number, Invoice Number, Invoice Date, Description, Garage, Amount, Kilometer\n'
                    '• Dates should be in DD/MM/YYYY format',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text('Download Template'),
                    onPressed: () {
                      // Template download logic would go here
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceHistorySection(MaintenanceController controller) {
    return Obx(() => Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Maintenance History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    Text(
                      '${controller.maintenanceRecords.length} Records',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                controller.maintenanceRecords.isNotEmpty
                    ? _buildMaintenanceTable(controller)
                    : Container(
                        padding: const EdgeInsets.all(24),
                        width: double.infinity,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.build_circle_outlined,
                                size: 48, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No maintenance records found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
              ],
            ),
          ),
        ));
  }

  Widget _buildMaintenanceTable(MaintenanceController controller) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
        headingTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blue[800],
        ),
        columns: const [
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Invoice')),
          DataColumn(label: Text('Garage')),
          DataColumn(label: Text('Description')),
          DataColumn(label: Text('Amount'), numeric: true),
          DataColumn(label: Text('KM'), numeric: true),
          DataColumn(label: Text('Actions')),
        ],
        rows: controller.maintenanceRecords.map((record) {
          return DataRow(
            cells: [
              DataCell(
                  Text(DateFormat('dd/MM/yyyy').format(record['invoiceDate']))),
              DataCell(Text(record['invoiceNumber'])),
              DataCell(Text(record['garage'])),
              DataCell(Text(record['description'])),
              DataCell(Text('AED ${record['amount'].toStringAsFixed(2)}')),
              DataCell(Text('${record['kilometer']}')),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      tooltip: 'Edit',
                      onPressed: () {
                        // Edit record logic
                      },
                    ),
                    IconButton(
                      icon:
                          Icon(Icons.delete, size: 20, color: Colors.red[400]),
                      tooltip: 'Delete',
                      onPressed: () {
                        // Delete record logic
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // Form field widgets
  Widget _buildInvoiceNumberField(MaintenanceController controller) {
    return TextField(
      controller: controller.invoiceNumberController,
      decoration: InputDecoration(
        labelText: 'Invoice Number',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: const Icon(Icons.receipt),
      ),
    );
  }

  Widget _buildDatePickerField(MaintenanceController controller) {
    return Obx(() => TextField(
          decoration: InputDecoration(
            labelText: 'Invoice Date',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(Icons.calendar_today),
          ),
          readOnly: true,
          controller: TextEditingController(
            text:
                DateFormat('dd/MM/yyyy').format(controller.selectedDate.value),
          ),
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: Get.context!,
              initialDate: controller.selectedDate.value,
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (picked != null && picked != controller.selectedDate.value) {
              controller.selectedDate.value = picked;
            }
          },
        ));
  }

  Widget _buildGarageDropdown(MaintenanceController controller) {
    return Obx(() => DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Garage',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(Icons.home_repair_service),
          ),
          value: controller.selectedGarage.value,
          items: controller.garageList.map((garage) {
            return DropdownMenuItem<String>(
              value: garage,
              child: Text(garage),
            );
          }).toList(),
          onChanged: (value) {
            controller.selectedGarage.value = value;
          },
          hint: const Text('Select Garage'),
        ));
  }

  Widget _buildDescriptionField(MaintenanceController controller) {
    return TextField(
      controller: controller.descriptionController,
      decoration: InputDecoration(
        labelText: 'Description',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: const Icon(Icons.description),
      ),
      maxLines: 1,
    );
  }

  Widget _buildAmountField(MaintenanceController controller) {
    return TextField(
      controller: controller.totalAmountController,
      decoration: InputDecoration(
        labelText: 'Amount (AED)',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: const Icon(Icons.attach_money),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
    );
  }

  Widget _buildKilometerField(MaintenanceController controller) {
    return TextField(
      controller: controller.kilometerController,
      decoration: InputDecoration(
        labelText: 'Kilometer Reading',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: const Icon(Icons.speed),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }
}
