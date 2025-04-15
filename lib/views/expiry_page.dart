import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:multifleet/widgets/custom_widgets.dart';

import '../controllers/expiry_controller.dart';
import '../models/vehicle_docs.dart';

class VehicleExpiryPage extends StatelessWidget {
  const VehicleExpiryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ExpiryDetailsController());

    return Scaffold(
      body: SafeArea(
        child: Obx(() => controller.showComparisonView.value
            ? _buildComparisonView(controller)
            : _buildMainView(controller)),
      ),
    );
  }

  Widget _buildMainView(ExpiryDetailsController controller) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min, // Prevents constraint issues
          children: [
            _buildFilterSection(controller),
            const SizedBox(height: 16),
            _buildSearchBar(controller),
            const SizedBox(height: 16),
            _buildSummaryCards(controller),
            const SizedBox(height: 16),
            _buildVehiclesList(controller)
            // Expanded(
            //   child: _buildVehiclesList(controller),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(ExpiryDetailsController controller) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 800) {
              // Wide layout - three filters in a row
              return Row(
                children: [
                  Expanded(
                    child: _buildExpiryTypeFilter(controller),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTimeframeFilter(controller),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildVehicleTypeFilter(controller),
                  ),
                ],
              );
            } else if (constraints.maxWidth > 500) {
              // Medium layout - two filters in a row, one below
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildExpiryTypeFilter(controller),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTimeframeFilter(controller),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildVehicleTypeFilter(controller),
                ],
              );
            } else {
              // Narrow layout - filters stacked vertically
              return Column(
                children: [
                  _buildExpiryTypeFilter(controller),
                  const SizedBox(height: 16),
                  _buildTimeframeFilter(controller),
                  const SizedBox(height: 16),
                  _buildVehicleTypeFilter(controller),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildExpiryTypeFilter(ExpiryDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Expiry Type',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              value: controller.selectedExpiryType.value,
              items: controller.expiryTypeOptions.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.selectedExpiryType.value = value;
                }
              },
            )),
      ],
    );
  }

  Widget _buildTimeframeFilter(ExpiryDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Timeframe',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              value: controller.selectedTimeframe.value,
              items: controller.timeframeOptions.map((timeframe) {
                return DropdownMenuItem<String>(
                  value: timeframe,
                  child: Text(timeframe),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.selectedTimeframe.value = value;
                }
              },
            )),
      ],
    );
  }

  Widget _buildVehicleTypeFilter(ExpiryDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vehicle Type',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              value: controller.selectedVehicleType.value,
              items: controller.vehicleTypeOptions.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.selectedVehicleType.value = value;
                }
              },
            )),
      ],
    );
  }

  Widget _buildSearchBar(ExpiryDetailsController controller) {
    return TextField(
      controller: controller.searchController,
      decoration: InputDecoration(
        hintText: 'Search by plate number, brand, or model',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: Obx(() => controller.isSearching.value
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: controller.clearSearch,
              )
            : const SizedBox.shrink()),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: controller.search,
    );
  }

  Widget _buildSummaryCards(ExpiryDetailsController controller) {
    return Obx(() {
      // Calculate counts
      int totalVehicles = controller.vehiclesList.length;

      // Count vehicles with insurance (docType 1001) expiring soon
      int expiringInsurance = controller.vehiclesList.where((v) {
        if (v.documents == null || v.documents!.isEmpty) return false;
        return v.documents!.any((doc) =>
            doc.docType == 1001 &&
            controller.getExpiryStatus(doc.expiryDate) == 'Soon');
      }).length;

      // Count vehicles with registration/mulkiya (docType 1002) expiring soon
      int expiringMulkiya = controller.vehiclesList.where((v) {
        if (v.documents == null || v.documents!.isEmpty) return false;
        return v.documents!.any((doc) =>
            doc.docType == 1002 &&
            controller.getExpiryStatus(doc.expiryDate) == 'Soon');
      }).length;

      // Count vehicles with service (docType 1003) due soon or expired
      int dueService = controller.vehiclesList.where((v) {
        if (v.documents == null || v.documents!.isEmpty) return false;
        return v.documents!.any((doc) =>
            doc.docType == 1003 &&
            (controller.getExpiryStatus(doc.expiryDate) == 'Soon' ||
                controller.getExpiryStatus(doc.expiryDate) == 'Expired'));
      }).length;

      return LayoutBuilder(
        builder: (context, constraints) {
          // Responsive layout for summary cards
          if (constraints.maxWidth > 800) {
            // Wide layout - four cards in a row
            return Row(
              children: [
                Expanded(
                    child: _buildSummaryCard(
                        'Total Vehicles',
                        totalVehicles.toString(),
                        Icons.directions_car,
                        Colors.blue)),
                const SizedBox(width: 8),
                Expanded(
                    child: _buildSummaryCard(
                        'Insurance Expiring Soon',
                        expiringInsurance.toString(),
                        Icons.shield,
                        Colors.orange)),
                const SizedBox(width: 8),
                Expanded(
                    child: _buildSummaryCard(
                        'Mulkiya Expiring Soon',
                        expiringMulkiya.toString(),
                        Icons.description,
                        Colors.red)),
                const SizedBox(width: 8),
                Expanded(
                    child: _buildSummaryCard('Service Due',
                        dueService.toString(), Icons.build, Colors.green)),
              ],
            );
          } else if (constraints.maxWidth > 500) {
            // Medium layout - two cards in each row
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: _buildSummaryCard(
                            'Total Vehicles',
                            totalVehicles.toString(),
                            Icons.directions_car,
                            Colors.blue)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _buildSummaryCard(
                            'Insurance Expiring Soon',
                            expiringInsurance.toString(),
                            Icons.shield,
                            Colors.orange)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                        child: _buildSummaryCard(
                            'Mulkiya Expiring Soon',
                            expiringMulkiya.toString(),
                            Icons.description,
                            Colors.red)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _buildSummaryCard('Service Due',
                            dueService.toString(), Icons.build, Colors.green)),
                  ],
                ),
              ],
            );
          } else {
            // Narrow layout - cards stacked vertically
            return Column(
              children: [
                _buildSummaryCard('Total Vehicles', totalVehicles.toString(),
                    Icons.directions_car, Colors.blue),
                const SizedBox(height: 8),
                _buildSummaryCard('Insurance Expiring Soon',
                    expiringInsurance.toString(), Icons.shield, Colors.orange),
                const SizedBox(height: 8),
                _buildSummaryCard('Mulkiya Expiring Soon',
                    expiringMulkiya.toString(), Icons.description, Colors.red),
                const SizedBox(height: 8),
                _buildSummaryCard('Service Due', dueService.toString(),
                    Icons.build, Colors.green),
              ],
            );
          }
        },
      );
    });
  }

  Widget _buildSummaryCard(
      String title, String count, IconData icon, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehiclesList(ExpiryDetailsController controller) {
    return Obx(() {
      if (controller.filteredVehiclesList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No vehicles match the current filters',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            // Wide layout - table view
            return _buildVehiclesTable(controller);
          } else {
            // Narrower layout - card list
            return _buildVehiclesCardList(controller);
          }
        },
      );
    });
  }

  Widget _buildVehiclesTable(ExpiryDetailsController controller) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 800;

          if (isSmallScreen) {
            // Mobile/small screen view - card list instead of table
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.filteredVehiclesList.length,
              itemBuilder: (context, index) {
                final vehicle = controller.filteredVehiclesList[index];

                // Find insurance document (docType 1001)
                final insuranceDoc = vehicle.documents?.firstWhere(
                  (doc) => doc.docType == 1001,
                );

                // Find mulkiya document (docType 1002)
                final mulkiyaDoc = vehicle.documents?.firstWhere(
                  (doc) => doc.docType == 1002,
                );

                // Status strings and colors
                String insuranceStatus = insuranceDoc?.expiryDate != null
                    ? controller.getExpiryStatus(insuranceDoc!.expiryDate)
                    : 'Unknown';
                String mulkiyaStatus = mulkiyaDoc?.expiryDate != null
                    ? controller.getExpiryStatus(mulkiyaDoc!.expiryDate)
                    : 'Unknown';

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  vehicle.vehicleNo ?? "N/A",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Text(
                                vehicle.status ?? 'Unknown',
                                style: TextStyle(
                                  color: (vehicle.status == 'Active')
                                      ? Colors.green
                                      : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('${vehicle.brand ?? ""} ${vehicle.model ?? ""}'),
                          Text('Type: ${vehicle.type ?? "N/A"}'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text('Insurance: ',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w500)),
                              Text(insuranceDoc?.expiryDate != null
                                  ? DateFormat('dd/MM/yyyy')
                                      .format(insuranceDoc!.expiryDate!)
                                  : 'N/A'),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: controller
                                      .getStatusColor(insuranceStatus)
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  insuranceStatus,
                                  style: TextStyle(
                                    color: controller
                                        .getStatusColor(insuranceStatus),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Text('Mulkiya: ',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w500)),
                              Text(mulkiyaDoc?.expiryDate != null
                                  ? DateFormat('dd/MM/yyyy')
                                      .format(mulkiyaDoc!.expiryDate!)
                                  : 'N/A'),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: controller
                                      .getStatusColor(mulkiyaStatus)
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  mulkiyaStatus,
                                  style: TextStyle(
                                    color: controller
                                        .getStatusColor(mulkiyaStatus),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () =>
                                  controller.selectVehicle(vehicle),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[800],
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: const Text(
                                'Details',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            // Desktop/large screen view - data table
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 20,
                headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
                headingTextStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
                columns: const [
                  DataColumn(label: Text('Vehicle No.')),
                  DataColumn(label: Text('Vehicle')),
                  DataColumn(label: Text('Type')),
                  DataColumn(label: Text('Insurance Expiry')),
                  DataColumn(label: Text('Mulkiya Expiry')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: controller.filteredVehiclesList.map((vehicle) {
                  // Find insurance document (docType 1001)
                  final insuranceDoc = vehicle.documents?.firstWhere(
                    (doc) => doc.docType == 1001,
                  );

                  // Find mulkiya document (docType 1002)
                  final mulkiyaDoc = vehicle.documents?.firstWhere(
                    (doc) => doc.docType == 1002,
                  );

                  // Status strings and colors
                  String insuranceStatus = insuranceDoc?.expiryDate != null
                      ? controller.getExpiryStatus(insuranceDoc!.expiryDate)
                      : 'Unknown';
                  String mulkiyaStatus = mulkiyaDoc?.expiryDate != null
                      ? controller.getExpiryStatus(mulkiyaDoc!.expiryDate)
                      : 'Unknown';

                  return DataRow(
                    cells: [
                      DataCell(Text(vehicle.vehicleNo ?? 'N/A')),
                      DataCell(Text(
                          '${vehicle.brand ?? ""} ${vehicle.model ?? ""}')),
                      DataCell(Text(vehicle.type ?? 'N/A')),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(insuranceDoc?.expiryDate != null
                                ? DateFormat('dd/MM/yyyy')
                                    .format(insuranceDoc!.expiryDate!)
                                : 'N/A'),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: controller
                                    .getStatusColor(insuranceStatus)
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                insuranceStatus,
                                style: TextStyle(
                                  color: controller
                                      .getStatusColor(insuranceStatus),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(mulkiyaDoc?.expiryDate != null
                                ? DateFormat('dd/MM/yyyy')
                                    .format(mulkiyaDoc!.expiryDate!)
                                : 'N/A'),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: controller
                                    .getStatusColor(mulkiyaStatus)
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                mulkiyaStatus,
                                style: TextStyle(
                                  color:
                                      controller.getStatusColor(mulkiyaStatus),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      DataCell(Text(vehicle.status ?? 'Unknown')),
                      DataCell(
                        ElevatedButton(
                          onPressed: () => controller.selectVehicle(vehicle),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[800],
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            'Details',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildVehiclesCardList(ExpiryDetailsController controller) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.filteredVehiclesList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final vehicle = controller.filteredVehiclesList[index];

        // Find insurance document (docType 1001)
        final insuranceDoc = vehicle.documents?.firstWhere(
          (doc) => doc.docType == 1001,
        );

        // Find mulkiya document (docType 1002)
        final mulkiyaDoc = vehicle.documents?.firstWhere(
          (doc) => doc.docType == 1002,
        );

        // Status strings and colors
        String insuranceStatus = insuranceDoc?.expiryDate != null
            ? controller.getExpiryStatus(insuranceDoc!.expiryDate)
            : 'Unknown';
        String mulkiyaStatus = mulkiyaDoc?.expiryDate != null
            ? controller.getExpiryStatus(mulkiyaDoc!.expiryDate)
            : 'Unknown';

        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => controller.selectVehicle(vehicle),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                            vehicle.type?.toLowerCase() == 'car'
                                ? Icons.directions_car
                                : Icons.local_shipping,
                            color: Colors.blue[800]),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vehicle.vehicleNo ?? 'Unknown',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${vehicle.brand ?? ''} ${vehicle.model ?? ''} ${vehicle.vYear != null ? '(${vehicle.vYear})' : ''}',
                              style: TextStyle(
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          vehicle.type ?? 'Unknown',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isSmallScreen = constraints.maxWidth < 340;

                      if (isSmallScreen) {
                        // Very small screen - stack vertically
                        return Column(
                          children: [
                            _buildExpiryItem(
                              'Insurance',
                              insuranceDoc?.expiryDate != null
                                  ? DateFormat('dd/MM/yyyy')
                                      .format(insuranceDoc!.expiryDate!)
                                  : 'N/A',
                              insuranceStatus,
                              controller.getStatusColor(insuranceStatus),
                            ),
                            const SizedBox(height: 8),
                            _buildExpiryItem(
                              'Mulkiya',
                              mulkiyaDoc?.expiryDate != null
                                  ? DateFormat('dd/MM/yyyy')
                                      .format(mulkiyaDoc!.expiryDate!)
                                  : 'N/A',
                              mulkiyaStatus,
                              controller.getStatusColor(mulkiyaStatus),
                            ),
                          ],
                        );
                      } else {
                        // Normal screen - side by side
                        return Row(
                          children: [
                            Expanded(
                              child: _buildExpiryItem(
                                'Insurance',
                                insuranceDoc?.expiryDate != null
                                    ? DateFormat('dd/MM/yyyy')
                                        .format(insuranceDoc!.expiryDate!)
                                    : 'N/A',
                                insuranceStatus,
                                controller.getStatusColor(insuranceStatus),
                              ),
                            ),
                            Expanded(
                              child: _buildExpiryItem(
                                'Mulkiya',
                                mulkiyaDoc?.expiryDate != null
                                    ? DateFormat('dd/MM/yyyy')
                                        .format(mulkiyaDoc!.expiryDate!)
                                    : 'N/A',
                                mulkiyaStatus,
                                controller.getStatusColor(mulkiyaStatus),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Company',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              vehicle.company ?? 'N/A',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Initial Odometer',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.speed, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  vehicle.initialOdo != null
                                      ? '${vehicle.initialOdo} km'
                                      : 'N/A',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Chip(
                        backgroundColor: (vehicle.status == 'Active')
                            ? Colors.green[100]
                            : Colors.grey[200],
                        label: Text(
                          vehicle.status ?? 'Unknown',
                          style: TextStyle(
                            color: (vehicle.status == 'Active')
                                ? Colors.green[800]
                                : Colors.grey[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () => controller.selectVehicle(vehicle),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue[800],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('View Details'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpiryItem(
      String title, String date, String status, Color statusColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              date,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonView(ExpiryDetailsController controller) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: controller.closeComparisonView,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Vehicle Comparison Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildVehicleHeader(controller),
                  const SizedBox(height: 24),
                  _buildComparisonHeader(controller),
                  const SizedBox(height: 16),
                  _buildInsuranceComparison(controller),
                  const SizedBox(height: 24),
                  _buildMulkiyaComparison(controller),
                  const SizedBox(height: 24),
                  _buildServiceComparison(controller),
                  const SizedBox(height: 24),
                  _buildConditionComparison(controller),
                  const SizedBox(height: 32),
                  _buildComparisonActions(controller),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleHeader(ExpiryDetailsController controller) {
    return Obx(() => Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.directions_car,
                        color: Colors.blue[800],
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.selectedVehicle.value!.vehicleNo ?? '',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${controller.selectedVehicle.value!.brand} ${controller.selectedVehicle.value!.model} (${controller.selectedVehicle.value!.vYear})',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        controller.selectedVehicle.value!.type ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildVehicleInfoItem(
                        'Current KM',
                        '${controller.selectedVehicle.value!.initialOdo} km',
                        Icons.speed,
                      ),
                    ),
                    Expanded(
                      child: _buildVehicleInfoItem(
                        'Condition',
                        controller.selectedVehicle.value!.status ?? '',
                        Icons.star,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildVehicleInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
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
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComparisonHeader(ExpiryDetailsController controller) {
    return Obx(() => Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Current Status',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      DateFormat('dd/MM/yyyy').format(DateTime.now()),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Previous Renewal',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    // Text(
                    //   DateFormat('dd/MM/yyyy')
                    //       .format(controller.previousData.value!.),
                    //   style: TextStyle(
                    //     color: Colors.grey[600],
                    //     fontSize: 12,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  Widget _buildInsuranceComparison(ExpiryDetailsController controller) {
    // Get insurance document
    final insuranceDoc =
        controller.selectedVehicle.value?.documents?.firstWhere(
      (doc) => doc.docType == 1001,
    );

    String expiryDateStr = 'N/A';
    String statusStr = 'Unknown';
    Color? statusColor;

    if (insuranceDoc?.expiryDate != null) {
      expiryDateStr =
          DateFormat('dd/MM/yyyy').format(insuranceDoc!.expiryDate!);
      statusStr = controller.getExpiryStatus(insuranceDoc.expiryDate);
      statusColor = controller.getStatusColor(statusStr);
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shield, color: Colors.blue[800]),
                const SizedBox(width: 8),
                const Text(
                  'Insurance Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  // Two-column layout
                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildComparisonItem(
                              'Expiry Date',
                              expiryDateStr,
                              null,
                            ),
                            const SizedBox(height: 12),
                            _buildComparisonItem(
                              'Status',
                              statusStr,
                              statusColor,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 80,
                        color: Colors.grey[300],
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildComparisonItem(
                              'Insurance Company',
                              insuranceDoc?.issueAuthority ?? 'N/A',
                              null,
                            ),
                            const SizedBox(height: 12),
                            _buildComparisonItem(
                              'City',
                              insuranceDoc?.city ?? 'N/A',
                              null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  // Single-column layout
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildComparisonItem(
                        'Expiry Date',
                        expiryDateStr,
                        null,
                      ),
                      const SizedBox(height: 12),
                      _buildComparisonItem(
                        'Status',
                        statusStr,
                        statusColor,
                      ),
                      const Divider(height: 24),
                      _buildComparisonItem(
                        'Insurance Company',
                        insuranceDoc?.issueAuthority ?? 'N/A',
                        null,
                      ),
                      const SizedBox(height: 12),
                      _buildComparisonItem(
                        'City',
                        insuranceDoc?.city ?? 'N/A',
                        null,
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

  Widget _buildMulkiyaComparison(ExpiryDetailsController controller) {
    // Get mulkiya document
    final mulkiyaDoc = controller.selectedVehicle.value?.documents?.firstWhere(
      (doc) => doc.docType == 1002,
    );

    String expiryDateStr = 'N/A';
    String statusStr = 'Unknown';
    Color? statusColor;

    if (mulkiyaDoc?.expiryDate != null) {
      expiryDateStr = DateFormat('dd/MM/yyyy').format(mulkiyaDoc!.expiryDate!);
      statusStr = controller.getExpiryStatus(mulkiyaDoc.expiryDate);
      statusColor = controller.getStatusColor(statusStr);
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description, color: Colors.blue[800]),
                const SizedBox(width: 8),
                const Text(
                  'Mulkiya Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  // Two-column layout
                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildComparisonItem(
                              'Expiry Date',
                              expiryDateStr,
                              null,
                            ),
                            const SizedBox(height: 12),
                            _buildComparisonItem(
                              'Status',
                              statusStr,
                              statusColor,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 80,
                        color: Colors.grey[300],
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildComparisonItem(
                              'Issue Authority',
                              mulkiyaDoc?.issueAuthority ?? 'N/A',
                              null,
                            ),
                            const SizedBox(height: 12),
                            _buildComparisonItem(
                              'Issue Date',
                              mulkiyaDoc?.issueDate != null
                                  ? DateFormat('dd/MM/yyyy')
                                      .format(mulkiyaDoc!.issueDate!)
                                  : 'N/A',
                              null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  // Single-column layout
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildComparisonItem(
                        'Expiry Date',
                        expiryDateStr,
                        null,
                      ),
                      const SizedBox(height: 12),
                      _buildComparisonItem(
                        'Status',
                        statusStr,
                        statusColor,
                      ),
                      const Divider(height: 24),
                      _buildComparisonItem(
                        'Issue Authority',
                        mulkiyaDoc?.issueAuthority ?? 'N/A',
                        null,
                      ),
                      const SizedBox(height: 12),
                      _buildComparisonItem(
                        'Issue Date',
                        mulkiyaDoc?.issueDate != null
                            ? DateFormat('dd/MM/yyyy')
                                .format(mulkiyaDoc!.issueDate!)
                            : 'N/A',
                        null,
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

  Widget _buildServiceComparison(ExpiryDetailsController controller) {
    // Since there's no direct service document in the Vehicle class,
    // we'll use the tire info as a substitute for service details
    final tire = controller.selectedVehicle.value?.tires?.isNotEmpty == true
        ? controller.selectedVehicle.value!.tires![0]
        : null;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.build, color: Colors.blue[800]),
                const SizedBox(width: 8),
                const Text(
                  'Maintenance Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  // Two-column layout
                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildComparisonItem(
                              'Vehicle Year',
                              controller.selectedVehicle.value?.vYear
                                      ?.toString() ??
                                  'N/A',
                              null,
                            ),
                            const SizedBox(height: 12),
                            _buildComparisonItem(
                              'Vehicle Status',
                              controller.selectedVehicle.value?.status ?? 'N/A',
                              null,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 80,
                        color: Colors.grey[300],
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildComparisonItem(
                              'Initial Odometer',
                              controller.selectedVehicle.value?.initialOdo !=
                                      null
                                  ? '${controller.selectedVehicle.value!.initialOdo} km'
                                  : 'N/A',
                              null,
                            ),
                            const SizedBox(height: 12),
                            _buildComparisonItem(
                              'Tire Brand',
                              tire?.brand ?? 'N/A',
                              null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  // Single-column layout
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildComparisonItem(
                        'Vehicle Year',
                        controller.selectedVehicle.value?.vYear?.toString() ??
                            'N/A',
                        null,
                      ),
                      const SizedBox(height: 12),
                      _buildComparisonItem(
                        'Vehicle Status',
                        controller.selectedVehicle.value?.status ?? 'N/A',
                        null,
                      ),
                      const Divider(height: 24),
                      _buildComparisonItem(
                        'Initial Odometer',
                        controller.selectedVehicle.value?.initialOdo != null
                            ? '${controller.selectedVehicle.value!.initialOdo} km'
                            : 'N/A',
                        null,
                      ),
                      const SizedBox(height: 12),
                      _buildComparisonItem(
                        'Tire Brand',
                        tire?.brand ?? 'N/A',
                        null,
                      ),
                    ],
                  );
                }
              },
            ),

            // Additional tire information if available
            if (tire != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Tire Information',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 600) {
                    // Two-column layout for tire details
                    return Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildComparisonItem(
                                'Position',
                                tire.position ?? 'N/A',
                                null,
                              ),
                              const SizedBox(height: 12),
                              _buildComparisonItem(
                                'Size',
                                tire.size ?? 'N/A',
                                null,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 80,
                          color: Colors.grey[300],
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildComparisonItem(
                                'KM Used',
                                tire.kmUsed != null
                                    ? '${tire.kmUsed} km'
                                    : 'N/A',
                                null,
                              ),
                              const SizedBox(height: 12),
                              _buildComparisonItem(
                                'Installation Date',
                                "${tire.installDt ?? "N/A"}",
                                null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  } else {
                    // Single-column layout for tire details
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildComparisonItem(
                          'Position',
                          tire.position ?? 'N/A',
                          null,
                        ),
                        const SizedBox(height: 12),
                        _buildComparisonItem(
                          'Size',
                          tire.size ?? 'N/A',
                          null,
                        ),
                        const SizedBox(height: 12),
                        _buildComparisonItem(
                          'KM Used',
                          tire.kmUsed != null ? '${tire.kmUsed} km' : 'N/A',
                          null,
                        ),
                        const SizedBox(height: 12),
                        _buildComparisonItem(
                          'Installation Date',
                          "${tire.installDt ?? 'N/A'}",
                          null,
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonItem(String label, String value, Color? valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildConditionComparison(ExpiryDetailsController controller) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.blue[800]),
                const SizedBox(width: 8),
                const Text(
                  'Condition Comparison',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: const Text(
                    'Metric',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Current',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Previous',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Change',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildComparisonRow(
              'Condition',
              controller.selectedVehicle.value!['condition'],
              controller.previousData.value!['vehicleCondition'],
              _getConditionDifference(
                controller.selectedVehicle.value!['condition'],
                controller.previousData.value!['vehicleCondition'],
              ),
            ),
            const SizedBox(height: 12),
            _buildComparisonRow(
              'KM Reading',
              '${controller.selectedVehicle.value!['currentKm']} km',
              '${controller.previousData.value!['kmAtRenewal']} km',
              '+${controller.selectedVehicle.value!['currentKm'] - controller.previousData.value!['kmAtRenewal']} km',
            ),
            const SizedBox(height: 12),
            _buildComparisonRow(
              'Vehicle Age',
              '${DateTime.now().year - controller.selectedVehicle.value!['year']} years',
              '${controller.previousData.value!['date'].year - controller.selectedVehicle.value!['year']} years',
              '+1 year',
            ),
          ],
        ),
      ),
    );
  }

  String _getConditionDifference(String current, String previous) {
    List<String> conditionOrder = ['Excellent', 'Good', 'Average', 'Poor'];

    int currentIndex = conditionOrder.indexOf(current);
    int previousIndex = conditionOrder.indexOf(previous);

    if (currentIndex < previousIndex) {
      return 'Improved';
    } else if (currentIndex > previousIndex) {
      return 'Deteriorated';
    } else {
      return 'No change';
    }
  }

  Widget _buildComparisonRow(
      String metric, String current, String previous, String change) {
    Color changeColor;
    if (change.contains('Improved') ||
        change.contains('+') && !change.contains('km')) {
      changeColor = Colors.green;
    } else if (change.contains('Deteriorated') ||
        change.contains('-') && !change.contains('km')) {
      changeColor = Colors.red;
    } else {
      changeColor = Colors.grey;
    }

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            metric,
            style: TextStyle(
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    current,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    previous,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    change,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: changeColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildComparisonActions(ExpiryDetailsController controller) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => showRenewalDialog(controller),
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text(
              'Start Renewal Process',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => showServiceDialog(controller),
            icon: Icon(Icons.build, color: Colors.blue[800]),
            label: Text(
              'Schedule Service',
              style: TextStyle(color: Colors.blue[800]),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Renewal Dialog Widget
  void showRenewalDialog(ExpiryDetailsController controller) {
    final formKey = GlobalKey<FormState>();
    final insuranceTypeController = TextEditingController();
    final coverageAmountController = TextEditingController();
    final startDateController = TextEditingController();
    final endDateController = TextEditingController();
    final providerController = TextEditingController();
    final policyNumberController = TextEditingController();
    final notesController = TextEditingController();

    DateTime selectedStartDate = DateTime.now();
    DateTime selectedEndDate = DateTime.now().add(const Duration(days: 365));

    // Initialize the date controller values
    startDateController.text =
        DateFormat('yyyy-MM-dd').format(selectedStartDate);
    endDateController.text = DateFormat('yyyy-MM-dd').format(selectedEndDate);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: Get.width > 600 ? 600 : Get.width * 0.9,
          constraints: BoxConstraints(
            maxHeight: Get.height * 0.8,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Get.back(),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Vehicle Renewal',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Insurance Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Insurance Type
                    TextFormField(
                      controller: insuranceTypeController,
                      decoration: InputDecoration(
                        labelText: 'Insurance Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter insurance type';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Coverage Amount
                    TextFormField(
                      controller: coverageAmountController,
                      decoration: InputDecoration(
                        labelText: 'Coverage Amount',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixText: '\$ ',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter coverage amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Start Date
                    TextFormField(
                      controller: startDateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Start Date',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: Get.context!,
                          initialDate: selectedStartDate,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          selectedStartDate = picked;
                          startDateController.text =
                              DateFormat('yyyy-MM-dd').format(picked);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // End Date
                    TextFormField(
                      controller: endDateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'End Date',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: Get.context!,
                          initialDate: selectedEndDate,
                          firstDate: selectedStartDate,
                          lastDate:
                              selectedStartDate.add(const Duration(days: 730)),
                        );
                        if (picked != null) {
                          selectedEndDate = picked;
                          endDateController.text =
                              DateFormat('yyyy-MM-dd').format(picked);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Provider
                    TextFormField(
                      controller: providerController,
                      decoration: InputDecoration(
                        labelText: 'Provider',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter provider name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Policy Number
                    TextFormField(
                      controller: policyNumberController,
                      decoration: InputDecoration(
                        labelText: 'Policy Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter policy number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    TextFormField(
                      controller: notesController,
                      decoration: InputDecoration(
                        labelText: 'Additional Notes',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Get.back(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                // Save the renewal data
                                final renewalData = {
                                  'insuranceType': insuranceTypeController.text,
                                  'coverageAmount':
                                      coverageAmountController.text,
                                  'startDate': startDateController.text,
                                  'endDate': endDateController.text,
                                  'provider': providerController.text,
                                  'policyNumber': policyNumberController.text,
                                  'notes': notesController.text,
                                };

                                // Close dialog
                                Get.back();

                                // Show success message
                                CustomWidget.customSnackBar(
                                  isError: false,
                                  title: 'Success',
                                  message:
                                      'Vehicle renewal information saved successfully',
                                );

                                // Here you would update your controller or model with the new data
                                // controller.updateRenewalData(renewalData);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Save',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

// Schedule Service Dialog Widget
  void showServiceDialog(ExpiryDetailsController controller) {
    final formKey = GlobalKey<FormState>();
    final serviceTypeController = TextEditingController();
    final serviceDateController = TextEditingController();
    final serviceTimeController = TextEditingController();
    final serviceProviderController = TextEditingController();
    final estimatedCostController = TextEditingController();
    final notesController = TextEditingController();

    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);

    // Initialize the date controller value
    serviceDateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
    serviceTimeController.text =
        '${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}';

    // List of service types
    final serviceTypes = [
      'Oil Change',
      'Brake Service',
      'Tire Rotation',
      'Battery Replacement',
      'General Maintenance',
      'Air Conditioning',
      'Engine Repair',
      'Transmission Service',
      'Other'
    ];

    String selectedServiceType = serviceTypes[0];

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: Get.width > 600 ? 600 : Get.width * 0.9,
          constraints: BoxConstraints(
            maxHeight: Get.height * 0.8,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Get.back(),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Schedule Service',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Service Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Service Type Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedServiceType,
                      decoration: InputDecoration(
                        labelText: 'Service Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: serviceTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          selectedServiceType = newValue;
                          serviceTypeController.text = newValue;
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a service type';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Custom Service Type (conditionally shown if "Other" is selected)
                    if (selectedServiceType == 'Other')
                      Column(
                        children: [
                          TextFormField(
                            controller: serviceTypeController,
                            decoration: InputDecoration(
                              labelText: 'Specify Service Type',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: (value) {
                              if (selectedServiceType == 'Other' &&
                                  (value == null || value.isEmpty)) {
                                return 'Please specify the service type';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),

                    // Service Date
                    TextFormField(
                      controller: serviceDateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Service Date',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: Get.context!,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 90)),
                        );
                        if (picked != null) {
                          selectedDate = picked;
                          serviceDateController.text =
                              DateFormat('yyyy-MM-dd').format(picked);
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a date';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Service Time
                    TextFormField(
                      controller: serviceTimeController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Service Time',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: const Icon(Icons.access_time),
                      ),
                      onTap: () async {
                        final TimeOfDay? pickedTime = await showTimePicker(
                          context: Get.context!,
                          initialTime: selectedTime,
                        );
                        if (pickedTime != null) {
                          selectedTime = pickedTime;
                          serviceTimeController.text =
                              '${pickedTime.hour}:${pickedTime.minute.toString().padLeft(2, '0')}';
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a time';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Service Provider
                    TextFormField(
                      controller: serviceProviderController,
                      decoration: InputDecoration(
                        labelText: 'Service Provider/Center',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter service provider';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Estimated Cost
                    TextFormField(
                      controller: estimatedCostController,
                      decoration: InputDecoration(
                        labelText: 'Estimated Cost',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixText: '\$ ',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    TextFormField(
                      controller: notesController,
                      decoration: InputDecoration(
                        labelText: 'Service Notes',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Get.back(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                // Save the service data
                                final serviceData = {
                                  'serviceType': selectedServiceType == 'Other'
                                      ? serviceTypeController.text
                                      : selectedServiceType,
                                  'serviceDate': serviceDateController.text,
                                  'serviceTime': serviceTimeController.text,
                                  'serviceProvider':
                                      serviceProviderController.text,
                                  'estimatedCost': estimatedCostController.text,
                                  'notes': notesController.text,
                                };

                                // Close dialog
                                Get.back();

                                // Show success message
                                CustomWidget.customSnackBar(
                                  isError: false,
                                  title: 'Success',
                                  message: 'Service scheduled successfully',
                                );

                                // Here you would update your controller or model with the new data
                                // controller.updateServiceData(serviceData);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[800],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Schedule',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
