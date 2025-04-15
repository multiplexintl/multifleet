import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multifleet/models/vehicle.dart';

import '../controllers/vehicle_listing_controller.dart';
import '../models/tire.dart';
import '../models/vehicle_docs.dart';

class VehiclesListingPage extends StatelessWidget {
  const VehiclesListingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final VehicleListingController controller =
        Get.find<VehicleListingController>();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 30),
        child: Obx(() => controller.isLoading.value
            ? SizedBox(
                height: 25,
                width: 25,
                child: CircularProgressIndicator.adaptive(),
              )
            : Column(
                children: [
                  // Search and Filter Row
                  _buildSearchSection(controller, context),
                  SizedBox(height: 20),
                  Expanded(
                    child: GetBuilder<VehicleListingController>(
                      builder: (con) {
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            // Determine layout based on screen width
                            if (constraints.maxWidth < 600) {
                              return _buildMobileLayout(con.filteredVehicles);
                            } else if (constraints.maxWidth < 1200) {
                              return _buildTabletLayout(con.filteredVehicles);
                            } else {
                              return _buildDesktopLayout(con.filteredVehicles);
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              )),
      ),
    );
  }

  Widget _buildSearchSection(
      VehicleListingController controller, BuildContext context) {
    // Check device size
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1200;

    return Card(
      elevation: 4,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and collapse/expand button
              InkWell(
                onTap: () => controller.toggleSearchVisible(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Search Vehicles',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        controller.isSearchVisible
                            ? Icons.expand_less
                            : Icons.expand_more,
                      ),
                    ],
                  ),
                ),
              ),

              // Expandable content
              if (controller.isSearchVisible)
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, bottom: 16.0),
                  child: isDesktop
                      // Desktop view - Row layout
                      ? Row(
                          children: [
                            // Search Field - equal flex
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: TextField(
                                  controller: controller.searchController,
                                  decoration: InputDecoration(
                                    hintText: 'Search vehicles...',
                                    prefixIcon: Icon(Icons.search),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onChanged: (value) =>
                                      controller.searchVehicles(value),
                                ),
                              ),
                            ),

                            // Vehicle Type Dropdown - equal flex
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child:
                                    Obx(() => DropdownButtonFormField<String>(
                                          decoration: InputDecoration(
                                            labelText: 'Vehicle Type',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          value: controller
                                              .selectedVehicleType.value,
                                          items: controller
                                              .getVehicleTypes()
                                              .map((type) => DropdownMenuItem(
                                                    value: type,
                                                    child: Text(type),
                                                  ))
                                              .toList(),
                                          onChanged: (value) => controller
                                              .filterByVehicleType(value!),
                                        )),
                              ),
                            ),

                            // Expiring Soon Filter - smaller width
                            SizedBox(
                              width: 200,
                              child: Obx(() => CheckboxListTile(
                                    title: Text('Expiring Soon'),
                                    value: controller.showExpiringSoon.value,
                                    onChanged: (value) => controller
                                        .toggleExpiringSoonFilter(value!),
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 8),
                                    dense: true,
                                  )),
                            ),
                          ],
                        )
                      // Mobile/Tablet view - Wrap layout
                      : Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          alignment: WrapAlignment.start,
                          children: [
                            // Search Field
                            SizedBox(
                              width: isMobile
                                  ? width - 50
                                  : (width > 800
                                      ? (width - 80) / 2
                                      : width - 50),
                              child: TextField(
                                controller: controller.searchController,
                                decoration: InputDecoration(
                                  hintText: 'Search vehicles...',
                                  prefixIcon: Icon(Icons.search),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  isDense: isMobile,
                                  contentPadding: isMobile
                                      ? EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 16)
                                      : null,
                                ),
                                onChanged: (value) =>
                                    controller.searchVehicles(value),
                              ),
                            ),

                            // Vehicle Type Dropdown
                            SizedBox(
                              width: isMobile
                                  ? width - 50
                                  : (width > 800
                                      ? (width - 80) / 2
                                      : width - 50),
                              child: Obx(() => DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      labelText: 'Vehicle Type',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      isDense: isMobile,
                                      contentPadding: isMobile
                                          ? EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 16)
                                          : null,
                                    ),
                                    value: controller.selectedVehicleType.value,
                                    items: controller
                                        .getVehicleTypes()
                                        .map((type) => DropdownMenuItem(
                                              value: type,
                                              child: Text(type),
                                            ))
                                        .toList(),
                                    onChanged: (value) =>
                                        controller.filterByVehicleType(value!),
                                  )),
                            ),

                            // Expiring Soon Filter
                            SizedBox(
                              width: isMobile
                                  ? width - 50
                                  : (width > 800
                                      ? (width - 80) / 2
                                      : width - 50),
                              child: Obx(
                                () => CheckboxListTile(
                                  title: Text('Expiring Soon'),
                                  value: controller.showExpiringSoon.value,
                                  onChanged: (value) => controller
                                      .toggleExpiringSoonFilter(value!),
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 8),
                                  dense: true,
                                ),
                              ),
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

  // Mobile Layout - Single Column
  Widget _buildMobileLayout(List<Vehicle> vehicles) {
    return ListView.builder(
      itemCount: vehicles.length,
      itemBuilder: (context, index) =>
          _buildVehicleExpansionTile(vehicles[index], index),
    );
  }

  // Tablet Layout - Two Columns
  Widget _buildTabletLayout(List<Vehicle> vehicles) {
    return Row(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: (vehicles.length / 2).ceil(),
            itemBuilder: (context, index) =>
                _buildVehicleExpansionTile(vehicles[index], index),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: vehicles.length ~/ 2,
            itemBuilder: (context, index) => _buildVehicleExpansionTile(
                vehicles[(vehicles.length / 2).ceil() + index],
                (vehicles.length / 2).ceil() + index),
          ),
        ),
      ],
    );
  }

  // Desktop Layout - Three Columns
  Widget _buildDesktopLayout(List<Vehicle> vehicles) {
    return Obx(() => Row(
          children: [
            // First Column
            Expanded(
              child: ListView.builder(
                itemCount: (vehicles.length / 3).ceil(),
                itemBuilder: (context, index) =>
                    _buildVehicleExpansionTile(vehicles[index], index),
              ),
            ),
            // Second Column
            Expanded(
              child: ListView.builder(
                itemCount: (vehicles.length / 3).ceil(),
                itemBuilder: (context, index) => _buildVehicleExpansionTile(
                    vehicles[((vehicles.length / 3).ceil()) + index],
                    ((vehicles.length / 3).ceil()) + index),
              ),
            ),
            // Third Column
            Expanded(
              child: ListView.builder(
                itemCount: vehicles.length - (2 * (vehicles.length / 3).ceil()),
                itemBuilder: (context, index) => _buildVehicleExpansionTile(
                    vehicles[(2 * (vehicles.length / 3).ceil()) + index],
                    (2 * (vehicles.length / 3).ceil()) + index),
              ),
            ),
          ],
        ));
  }

  Widget _buildVehicleExpansionTile(Vehicle vehicle, int index) {
    return Card(
      elevation: 6,
      margin: EdgeInsets.all(20),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          onExpansionChanged: (value) {
            log(vehicle.toString());
          },
          backgroundColor:
              vehicle.status == 'Active' ? null : Colors.red.shade400,
          collapsedBackgroundColor:
              vehicle.status == 'Active' ? null : Colors.red.shade400,
          collapsedShape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text(
            '${index + 1}. ${vehicle.vehicleNo}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('${vehicle.brand} | ${vehicle.model}'),
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/nissan_urvan.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.white.withOpacity(0.3),
                    BlendMode.dstATop,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vehicle Information Section
                    _buildSectionTitle('Vehicle Information'),
                    _buildDetailRow('Type', vehicle.type ?? ''),
                    _buildDetailRow('Chassis Number', vehicle.chassisNo ?? ''),
                    _buildDetailRow('Traffic File', vehicle.traficFileNo ?? ''),
                    _buildDetailRow('Year', vehicle.vYear?.toString() ?? ''),
                    _buildDetailRow(
                        'Initial KM', vehicle.initialOdo?.toString() ?? ''),
                    _buildDetailRow('Remarks', vehicle.description ?? ''),
                    _buildDetailRow('Status', vehicle.status ?? ''),

                    // Documents Section
                    if (vehicle.documents != null &&
                        vehicle.documents!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16),
                          _buildSectionTitle('Documents'),
                          ...vehicle.documents!
                              .map((doc) => _buildDocumentCard(doc)),
                        ],
                      ),

                    // Tires Section
                    if (vehicle.tires != null && vehicle.tires!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16),
                          _buildSectionTitle('Tire Details'),
                          ...vehicle.tires!.map((tire) => _buildTireCard(tire)),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Helper method to build document cards
  Widget _buildDocumentCard(VehicleDocument document) {
    // Define document type names
    Map<int, String> docTypeNames = {
      1001: 'Insurance',
      1002: 'Registration',
      // Add more document types as needed
    };

    String docTypeName =
        docTypeNames[document.docType] ?? 'Document ${document.docType}';

    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  docTypeName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        _getExpiryColor(document.expiryDate?.toIso8601String()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    document.expiryDate != null
                        ? 'Expires: ${document.formatDate(document.expiryDate)}'
                        : 'No Expiry Date',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            Divider(),
            _buildDetailRow('Issue Authority', document.issueAuthority ?? ''),
            _buildDetailRow(
                'Issue Date', document.formatDate(document.issueDate)),
            _buildDetailRow('City', document.city ?? ''),
          ],
        ),
      ),
    );
  }

// Helper method to build tire cards
  Widget _buildTireCard(Tire tire) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tire.position ?? 'Unknown Position',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                if (tire.expDt != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getExpiryColor(tire.expDt?.toIso8601String()),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Expires: ${tire.formatDate(tire.expDt)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            Divider(),
            _buildDetailRow('Brand', tire.brand ?? ''),
            _buildDetailRow('Size', tire.size ?? ''),
            _buildDetailRow('KM Used', tire.kmUsed?.toString() ?? '0'),
            if (tire.installDt != null)
              _buildDetailRow('Install Date', tire.formatDate(tire.installDt)),
            if (tire.remarks != null && tire.remarks!.isNotEmpty)
              _buildDetailRow('Remarks', tire.remarks ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            Spacer(),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.w600),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildExpiryRow(String label, String value, Color color) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 4.0),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Text(
  //           label,
  //           style: TextStyle(fontWeight: FontWeight.w600),
  //         ),
  //         Text(
  //           value,
  //           style: TextStyle(color: color),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Color _getExpiryColor(String? expiryDateStr) {
    // If null or empty, return white
    if (expiryDateStr == null || expiryDateStr.isEmpty) {
      return Colors.grey;
    }

    // Try to parse the date string
    DateTime? expiryDate;
    try {
      expiryDate = DateTime.parse(expiryDateStr);
    } catch (e) {
      // If parsing fails, return grey
      return Colors.grey;
    }

    // Calculate days until expiry
    final daysUntilExpiry = expiryDate.difference(DateTime.now()).inDays;

    // Return appropriate color based on days remaining
    if (daysUntilExpiry < 0) return Colors.red.shade800; // Already expired
    if (daysUntilExpiry <= 30) return Colors.red;
    if (daysUntilExpiry <= 90) return Colors.orange;
    return Colors.green;
  }
}
