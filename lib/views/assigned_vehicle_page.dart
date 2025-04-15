import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:multifleet/controllers/home_controller.dart';

import '../controllers/assigned_vehicle_controller.dart';

class VehicleAssignmentsListPage extends StatelessWidget {
  const VehicleAssignmentsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AssignedVehicleController());

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: LayoutBuilder(builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filters section
              _buildFiltersSection(context, controller, constraints),
              SizedBox(height: 20),

              // Results count
              Obx(() => Text(
                    '${controller.filteredAssignments.length} assignments found',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
              SizedBox(height: 10),

              // Results list
              Expanded(
                child: Obx(() => controller.isLoading.value
                    ? Center(child: CircularProgressIndicator())
                    : _buildAssignmentsList(controller, constraints)),
              ),
            ],
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to assignment creation page
          // Get.find<HomeScreenController>().changePage(2);
        },
        tooltip: 'New Assignment',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildFiltersSection(BuildContext context,
      AssignedVehicleController controller, BoxConstraints constraints) {
    final bool useWideLayout = constraints.maxWidth >= 768;

    return Card(
      elevation: 4,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => controller.toggleFiltersVisible(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Assignments',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        controller.isFiltersVisible
                            ? Icons.expand_less
                            : Icons.expand_more,
                      ),
                    ],
                  ),
                ),
              ),
              if (controller.isFiltersVisible)
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      useWideLayout
                          ? _buildWideFilterLayout(context, controller)
                          : _buildNarrowFilterLayout(context, controller),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => controller.clearFilters(),
                            child: Text('Clear Filters'),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () => controller.applyFilters(),
                            child: Text('Apply Filters'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  // Widget _buildFiltersSection(BuildContext context,
  //     AssignedVehicleController controller, BoxConstraints constraints) {
  //   final bool useWideLayout = constraints.maxWidth >= 768;

  //   return Card(
  //     elevation: 4,
  //     child: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             'Filter Assignments',
  //             style: TextStyle(
  //               fontSize: 18,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //           SizedBox(height: 16),
  //           useWideLayout
  //               ? _buildWideFilterLayout(context, controller)
  //               : _buildNarrowFilterLayout(context, controller),
  //           SizedBox(height: 16),
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.end,
  //             children: [
  //               OutlinedButton(
  //                 onPressed: () => controller.clearFilters(),
  //                 child: Text('Clear Filters'),
  //               ),
  //               SizedBox(width: 10),
  //               ElevatedButton(
  //                 onPressed: () => controller.applyFilters(),
  //                 child: Text('Apply Filters'),
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildWideFilterLayout(
      BuildContext context, AssignedVehicleController controller) {
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
                  // Vehicle Type dropdown
                  Text('Vehicle Type'),
                  SizedBox(height: 8),
                  _buildVehicleTypeDropdown(controller),
                  SizedBox(height: 16),

                  // Start date picker
                  Text('From Date'),
                  SizedBox(height: 8),
                  _buildDatePicker(
                    context: context,
                    initialDate: controller.startDateFilter.value,
                    onDateSelected: (date) =>
                        controller.startDateFilter.value = date,
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
                  // Status dropdown
                  Text('Status'),
                  SizedBox(height: 8),
                  _buildStatusDropdown(controller),
                  SizedBox(height: 16),

                  // End date picker
                  Text('To Date'),
                  SizedBox(height: 8),
                  _buildDatePicker(
                    context: context,
                    initialDate: controller.endDateFilter.value,
                    onDateSelected: (date) =>
                        controller.endDateFilter.value = date,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        // Search field (full width)
        TextField(
          controller: controller.searchController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Search by plate number, employee or designation',
            prefixIcon: Icon(Icons.search),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowFilterLayout(
      BuildContext context, AssignedVehicleController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search field
        TextField(
          controller: controller.searchController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Search by plate number, employee or designation',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        SizedBox(height: 16),

        // Vehicle Type dropdown
        Text('Vehicle Type'),
        SizedBox(height: 8),
        _buildVehicleTypeDropdown(controller),
        SizedBox(height: 16),

        // Status dropdown
        Text('Status'),
        SizedBox(height: 8),
        _buildStatusDropdown(controller),
        SizedBox(height: 16),

        // Start date picker
        Text('From Date'),
        SizedBox(height: 8),
        _buildDatePicker(
          context: context,
          initialDate: controller.startDateFilter.value,
          onDateSelected: (date) => controller.startDateFilter.value = date,
        ),
        SizedBox(height: 16),

        // End date picker
        Text('To Date'),
        SizedBox(height: 8),
        _buildDatePicker(
          context: context,
          initialDate: controller.endDateFilter.value,
          onDateSelected: (date) => controller.endDateFilter.value = date,
        ),
      ],
    );
  }

  Widget _buildVehicleTypeDropdown(AssignedVehicleController controller) {
    return Obx(() => DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          value: controller.selectedVehicleType.value.isEmpty
              ? null
              : controller.selectedVehicleType.value,
          hint: Text('All Types'),
          items: controller.vehicleTypeOptions
              .map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  ))
              .toList(),
          onChanged: (value) =>
              controller.selectedVehicleType.value = value ?? '',
        ));
  }

  Widget _buildStatusDropdown(AssignedVehicleController controller) {
    return Obx(() => DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          value: controller.selectedStatus.value.isEmpty
              ? null
              : controller.selectedStatus.value,
          hint: Text('All Statuses'),
          items: controller.statusOptions
              .map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  ))
              .toList(),
          onChanged: (value) => controller.selectedStatus.value = value ?? '',
        ));
  }

  Widget _buildDatePicker({
    required BuildContext context,
    required DateTime? initialDate,
    required Function(DateTime?) onDateSelected,
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
          onDateSelected(pickedDate);
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
                  ? DateFormat('dd MMM yyyy').format(initialDate)
                  : 'Select date',
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

  Widget _buildAssignmentsList(
      AssignedVehicleController controller, BoxConstraints constraints) {
    if (controller.filteredAssignments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.car_rental, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No vehicle assignments found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final bool isWideScreen = constraints.maxWidth >= 768;

    if (isWideScreen) {
      return _buildAssignmentsTable(controller);
    } else {
      return _buildAssignmentsCards(controller);
    }
  }

  Widget _buildAssignmentsTable(AssignedVehicleController controller) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: 20,
          headingRowHeight: 50,
          dataRowHeight: 60,
          columns: [
            DataColumn(
                label:
                    Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Plate No',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Vehicle Type',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Employee',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Designation',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Start Date',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('End Date',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Status',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Actions',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: List.generate(
            controller.filteredAssignments.length,
            (index) {
              final item = controller.filteredAssignments[index];
              return DataRow(
                cells: [
                  DataCell(Text('${index + 1}')),
                  DataCell(Text(item['plateNumber'])),
                  DataCell(Text(item['vehicleType'])),
                  DataCell(Text(item['employeeName'])),
                  DataCell(Text(item['designation'])),
                  DataCell(Text(
                      DateFormat('dd MMM yyyy').format(item['startDate']))),
                  DataCell(Text(item['endDate'] != null
                      ? DateFormat('dd MMM yyyy').format(item['endDate'])
                      : '-')),
                  DataCell(_buildStatusChip(item['status'])),
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.visibility, color: Colors.blue),
                        onPressed: () => controller.viewAssignmentDetails(item),
                        tooltip: 'View Details',
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.amber),
                        onPressed: () => controller.editAssignment(item),
                        tooltip: 'Edit',
                      ),
                    ],
                  )),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAssignmentsCards(AssignedVehicleController controller) {
    return ListView.builder(
      itemCount: controller.filteredAssignments.length,
      itemBuilder: (context, index) {
        final item = controller.filteredAssignments[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '#${index + 1} - ${item['plateNumber']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    _buildStatusChip(item['status']),
                  ],
                ),
                Divider(),
                _buildDetailRow('Vehicle Type', item['vehicleType']),
                _buildDetailRow('Assigned To', item['employeeName']),
                _buildDetailRow('Designation', item['designation']),
                _buildDetailRow('Start Date',
                    DateFormat('dd MMM yyyy').format(item['startDate'])),
                _buildDetailRow(
                    'End Date',
                    item['endDate'] != null
                        ? DateFormat('dd MMM yyyy').format(item['endDate'])
                        : '-'),
                if (item['remarks'] != null && item['remarks'].isNotEmpty)
                  _buildDetailRow('Remarks', item['remarks']),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: Icon(Icons.visibility),
                      label: Text('View'),
                      onPressed: () => controller.viewAssignmentDetails(item),
                    ),
                    SizedBox(width: 8),
                    TextButton.icon(
                      icon: Icon(Icons.edit),
                      label: Text('Edit'),
                      onPressed: () => controller.editAssignment(item),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    switch (status.toLowerCase()) {
      case 'active':
        chipColor = Colors.green;
        break;
      case 'pending':
        chipColor = Colors.orange;
        break;
      case 'expired':
        chipColor = Colors.red;
        break;
      default:
        chipColor = Colors.blue;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor),
      ),
      child: Text(
        status,
        style: TextStyle(color: chipColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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
}
