import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:multifleet/widgets/search_vehicle.dart';

import '../controllers/fine_controller.dart';

class VehicleFinePage extends StatelessWidget {
  const VehicleFinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VehicleFineController());
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

                  // Vehicle assignments section
                  Obx(() => controller.selectedVehicle.value != null
                      ? _buildAssignmentsSection(controller, constraints)
                      : SizedBox()),

                  // Fine form section
                  Obx(() => controller.selectedAssignment.value != null
                      ? _buildFineForm(controller, constraints)
                      : SizedBox()),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSearchSection(VehicleFineController controller) {
    return SearchVehicleWidget(
      controller: controller.plateNumberController,
      heading: "Search and add fine",
      onSearch: () => controller.searchVehicle(),
      onClear: () => controller.clearSearch(),
      onDataChanged: (letter, emirate, number) {
        log('Letter: $letter, Emirate: $emirate, Number: $number');
      },
    );
  }

  Widget _buildAssignmentsSection(
      VehicleFineController controller, BoxConstraints constraints) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Vehicle Assignment History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${controller.selectedVehicle.value!['brand']} ${controller.selectedVehicle.value!['model']} (${controller.selectedVehicle.value!['plateNumber']})',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Obx(
              () => controller.vehicleAssignments.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                            'No assignment history found for this vehicle'),
                      ),
                    )
                  : Column(
                      children: [
                        // Header row
                        constraints.maxWidth > 600
                            ? _buildAssignmentHeaderRow()
                            : SizedBox(),

                        // Assignments list
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: controller.vehicleAssignments.length,
                          itemBuilder: (context, index) {
                            final assignment =
                                controller.vehicleAssignments[index];
                            return Obx(() => Column(
                                  children: [
                                    InkWell(
                                      onTap: () => controller
                                          .selectAssignment(assignment),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 16),
                                        decoration: BoxDecoration(
                                          color: controller.selectedAssignment
                                                      .value ==
                                                  assignment
                                              ? Colors.blue.withOpacity(0.1)
                                              : null,
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            // Assignment details
                                            constraints.maxWidth > 600
                                                ? _buildAssignmentRow(
                                                    assignment, controller)
                                                : _buildAssignmentTile(
                                                    assignment, controller),

                                            // Fines section
                                            if (assignment['fines'] != null &&
                                                (assignment['fines'] as List)
                                                    .isNotEmpty)
                                              Obx(() => InkWell(
                                                    onTap: () => controller
                                                        .toggleFineDetails(
                                                            assignment['id']),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 8.0),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            controller
                                                                    .expandedFineIds
                                                                    .contains(
                                                                        assignment[
                                                                            'id'])
                                                                ? Icons
                                                                    .keyboard_arrow_up
                                                                : Icons
                                                                    .keyboard_arrow_down,
                                                            size: 16,
                                                          ),
                                                          SizedBox(width: 4),
                                                          Text(
                                                            '${(assignment['fines'] as List).length} ${(assignment['fines'] as List).length == 1 ? 'Fine' : 'Fines'}',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.blue,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Fine details
                                    if (assignment['fines'] != null &&
                                        (assignment['fines'] as List)
                                            .isNotEmpty &&
                                        controller.expandedFineIds
                                            .contains(assignment['id']))
                                      _buildFineDetailsList(
                                          assignment['fines'] as List,
                                          constraints),
                                  ],
                                ));
                          },
                        ),

                        // Load more button
                        Obx(() => controller.vehicleAssignments.length <
                                controller.totalAssignments.value
                            ? Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: ElevatedButton(
                                  onPressed: controller.isLoadingMore.value
                                      ? null
                                      : () => controller.loadMoreAssignments(),
                                  child: controller.isLoadingMore.value
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text('Load More'),
                                ),
                              )
                            : SizedBox()),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

// New widget to show fine details
  Widget _buildFineDetailsList(List fines, BoxConstraints constraints) {
    return Container(
      padding: EdgeInsets.all(12),
      color: Colors.grey.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Fine History',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),

          // Fines list
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: fines.length,
            itemBuilder: (context, index) {
              final fine = fines[index] as Map<String, dynamic>;
              return Container(
                margin: EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: constraints.maxWidth > 600
                    ? _buildFineRow(fine)
                    : _buildFineTile(fine),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFineRow(Map<String, dynamic> fine) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            DateFormat('dd MMM yyyy, hh:mm a').format(fine['fineDate']),
            style: TextStyle(fontSize: 13),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            '${fine['fineAmount']} AED',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            fine['fineNumber'],
            style: TextStyle(fontSize: 13),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: fine['paid']
                  ? Colors.green.withOpacity(0.2)
                  : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              fine['paid'] ? 'Paid' : 'Unpaid',
              style: TextStyle(
                fontSize: 12,
                color: fine['paid'] ? Colors.green : Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFineTile(Map<String, dynamic> fine) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('dd MMM yyyy').format(fine['fineDate']),
              style: TextStyle(fontSize: 12),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: fine['paid']
                    ? Colors.green.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                fine['paid'] ? 'Paid' : 'Unpaid',
                style: TextStyle(
                  fontSize: 11,
                  color: fine['paid'] ? Colors.green : Colors.red,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Amount: ${fine['fineAmount']} AED',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Text(
              'No: ${fine['fineNumber']}',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  // Widget _buildAssignmentsSection(
  //     VehicleFineController controller, BoxConstraints constraints) {
  //   return Card(
  //     elevation: 4,
  //     margin: EdgeInsets.symmetric(vertical: 16),
  //     child: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Text(
  //                 'Vehicle Assignment History',
  //                 style: TextStyle(
  //                   fontSize: 18,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //               Text(
  //                 '${controller.selectedVehicle.value!['brand']} ${controller.selectedVehicle.value!['model']} (${controller.selectedVehicle.value!['plateNumber']})',
  //                 style: TextStyle(
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ],
  //           ),
  //           SizedBox(height: 16),
  //           Obx(
  //             () => controller.vehicleAssignments.isEmpty
  //                 ? Center(
  //                     child: Padding(
  //                       padding: const EdgeInsets.all(20.0),
  //                       child: Text(
  //                           'No assignment history found for this vehicle'),
  //                     ),
  //                   )
  //                 : Column(
  //                     children: [
  //                       // Header row
  //                       constraints.maxWidth > 600
  //                           ? _buildAssignmentHeaderRow()
  //                           : SizedBox(),

  //                       // Assignments list
  //                       ListView.builder(
  //                         shrinkWrap: true,
  //                         physics: NeverScrollableScrollPhysics(),
  //                         itemCount: controller.vehicleAssignments.length,
  //                         itemBuilder: (context, index) {
  //                           final assignment =
  //                               controller.vehicleAssignments[index];
  //                           return InkWell(
  //                             onTap: () =>
  //                                 controller.selectAssignment(assignment),
  //                             child: Container(
  //                               padding: EdgeInsets.symmetric(
  //                                   vertical: 10, horizontal: 16),
  //                               decoration: BoxDecoration(
  //                                 color: controller.selectedAssignment.value ==
  //                                         assignment
  //                                     ? Colors.blue.withOpacity(0.1)
  //                                     : null,
  //                                 border: Border(
  //                                   bottom: BorderSide(
  //                                     color: Colors.grey.shade300,
  //                                     width: 1,
  //                                   ),
  //                                 ),
  //                               ),
  //                               child: constraints.maxWidth > 600
  //                                   ? _buildAssignmentRow(
  //                                       assignment, controller)
  //                                   : _buildAssignmentTile(
  //                                       assignment, controller),
  //                             ),
  //                           );
  //                         },
  //                       ),

  //                       // Load more button
  //                       Obx(() => controller.vehicleAssignments.length <
  //                               controller.totalAssignments.value
  //                           ? Padding(
  //                               padding: const EdgeInsets.all(16.0),
  //                               child: ElevatedButton(
  //                                 onPressed: controller.isLoadingMore.value
  //                                     ? null
  //                                     : () => controller.loadMoreAssignments(),
  //                                 child: controller.isLoadingMore.value
  //                                     ? SizedBox(
  //                                         width: 20,
  //                                         height: 20,
  //                                         child: CircularProgressIndicator(
  //                                           strokeWidth: 2,
  //                                         ),
  //                                       )
  //                                     : Text('Load More'),
  //                               ),
  //                             )
  //                           : SizedBox()),
  //                     ],
  //                   ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildAssignmentHeaderRow() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Employee',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Designation',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Start Date',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'End Date',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              'Status',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentRow(
      Map<String, dynamic> assignment, VehicleFineController controller) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(assignment['employeeName']),
        ),
        Expanded(
          flex: 2,
          child: Text(assignment['designation']),
        ),
        Expanded(
          flex: 2,
          child: Text(controller.formatDate(assignment['startDate'])),
        ),
        Expanded(
          flex: 2,
          child: Text(assignment['endDate'] != null
              ? controller.formatDate(assignment['endDate'])
              : 'Current'),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(assignment['status']).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              assignment['status'],
              style: TextStyle(
                color: _getStatusColor(assignment['status']),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAssignmentTile(
      Map<String, dynamic> assignment, VehicleFineController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          assignment['employeeName'],
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text(assignment['designation']),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(assignment['status']).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                assignment['status'],
                style: TextStyle(
                  color: _getStatusColor(assignment['status']),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.calendar_today, size: 14, color: Colors.grey),
            SizedBox(width: 4),
            Text(
              'From: ${controller.formatDate(assignment['startDate'])}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ],
        ),
        SizedBox(height: 2),
        assignment['endDate'] != null
            ? Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    'To: ${controller.formatDate(assignment['endDate'])}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              )
            : Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    'To: Current',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ),
      ],
    );
  }

  Widget _buildFineForm(
      VehicleFineController controller, BoxConstraints constraints) {
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
              'Add Fine',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Adding fine for ${controller.selectedAssignment.value!['employeeName']} (${controller.selectedVehicle.value!['plateNumber']})',
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 20),

            // Form fields
            useWideLayout
                ? _buildWideFormLayout(controller)
                : _buildNarrowFormLayout(controller),

            SizedBox(height: 20),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => controller.clearFineForm(),
                  child: Text('Clear'),
                ),
                SizedBox(width: 10),
                Obx(() => ElevatedButton(
                      onPressed: controller.isSubmitting.value
                          ? null
                          : () => controller.submitFine(),
                      child: controller.isSubmitting.value
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text('Submit'),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWideFormLayout(VehicleFineController controller) {
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
                  // Fine amount
                  Text('Fine Amount *'),
                  SizedBox(height: 8),
                  TextField(
                    controller: controller.fineAmountController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter fine amount',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                  ),
                  SizedBox(height: 16),

                  // Fine date picker
                  Text('Fine Date & Time *'),
                  SizedBox(height: 8),
                  _buildDateTimePicker(
                    context: Get.context!,
                    initialDate: controller.fineDate.value,
                    onDateSelected: (date) => controller.fineDate.value = date,
                  ),
                  SizedBox(height: 16),

                  // Fine number
                  Text('Fine Number *'),
                  SizedBox(height: 8),
                  TextField(
                    controller: controller.fineNumberController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter fine number',
                    ),
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
                  // Fine location
                  Text('Fine Location'),
                  SizedBox(height: 8),
                  TextField(
                    controller: controller.fineLocationController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter location where fine occurred',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Traffic file number
                  Text('Traffic File Number'),
                  SizedBox(height: 8),
                  TextField(
                    controller: controller.trafficFileNumberController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter traffic file number',
                    ),
                  ),
                  SizedBox(height: 16),
                  // Traffic file number
                  Text('Remarks'),
                  SizedBox(height: 8),
                  TextField(
                    controller: controller.remarksController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter any remarks',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNarrowFormLayout(VehicleFineController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fine amount
        Text('Fine Amount *'),
        SizedBox(height: 8),
        TextField(
          controller: controller.fineAmountController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter fine amount',
            prefixIcon: Icon(Icons.attach_money),
          ),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
        ),
        SizedBox(height: 16),

        // Fine date picker
        Text('Fine Date & Time *'),
        SizedBox(height: 8),
        _buildDateTimePicker(
          context: Get.context!,
          initialDate: controller.fineDate.value,
          onDateSelected: (date) => controller.fineDate.value = date,
        ),
        SizedBox(height: 16),

        // Fine location
        Text('Fine Location'),
        SizedBox(height: 8),
        TextField(
          controller: controller.fineLocationController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter location where fine occurred',
            prefixIcon: Icon(Icons.location_on),
          ),
        ),
        SizedBox(height: 16),

        // Fine number
        Text('Fine Number *'),
        SizedBox(height: 8),
        TextField(
          controller: controller.fineNumberController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter fine number',
          ),
        ),
        SizedBox(height: 16),

        // Traffic file number
        Text('Traffic File Number'),
        SizedBox(height: 8),
        TextField(
          controller: controller.trafficFileNumberController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter traffic file number',
          ),
        ),
        SizedBox(height: 16),

        // Traffic file number
        Text('Remarks'),
        SizedBox(height: 8),
        TextField(
          controller: controller.remarksController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter any remarks',
          ),
        ),
      ],
    );
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
          lastDate: DateTime.now().add(Duration(days: 365)),
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'terminated':
        return Colors.red;
      case 'on leave':
        return Colors.orange;
      case 'pending':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
