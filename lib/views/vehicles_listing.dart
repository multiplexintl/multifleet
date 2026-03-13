import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multifleet/controllers/general_masters.dart';
import 'package:multifleet/controllers/home_controller.dart';
import 'package:multifleet/models/status_master/status_master.dart';
import 'package:multifleet/models/vehicle.dart';
import 'package:multifleet/theme/app_theme.dart';

import '../controllers/vehicle_listing_controller.dart';
import '../models/tyre.dart';
import '../models/vehicle_docs.dart';

class VehiclesListingPage extends StatelessWidget {
  const VehiclesListingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VehicleListingController>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.accent),
                const SizedBox(height: 16),
                Text(
                  'Loading vehicles...',
                  style: TextStyle(color: AppColors.primaryLight, fontSize: 14),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.accent,
          onRefresh: () => controller.getComprehensiveVehicleData(),
          child: CustomScrollView(
            slivers: [
              // App Bar / Header
              SliverToBoxAdapter(
                child: _buildHeader(controller),
              ),

              // Filter Section
              SliverToBoxAdapter(
                child: _buildFilterSection(controller, context),
              ),

              // Stats Bar
              SliverToBoxAdapter(
                child: _buildStatsBar(controller),
              ),

              // Vehicle Grid
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: _buildVehicleGrid(controller, context),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeader(VehicleListingController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      margin: EdgeInsets.only(left: 10, right: 10, top: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primaryLight],
        ),
        borderRadius: AppRadius.borderMd,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.directions_car_rounded,
                  color: AppColors.accentLight, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fleet Vehicles',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Obx(() => Text(
                        '${controller.filteredVehicles.length} of ${controller.originalVehicles.length} vehicles',
                        style: TextStyle(color: Colors.white60, fontSize: 14),
                      )),
                ],
              ),
            ),
            IconButton(
              onPressed: () => controller.getComprehensiveVehicleData(),
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              tooltip: 'Refresh',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(
      VehicleListingController controller, BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 600;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isCompact
          ? _buildCompactFilters(controller)
          : _buildExpandedFilters(controller),
    );
  }

  Widget _buildCompactFilters(VehicleListingController controller) {
    return Column(
      children: [
        // Search Field
        TextField(
          controller: controller.searchController,
          decoration: InputDecoration(
            hintText: 'Search plate, brand, model...',
            hintStyle: TextStyle(color: AppColors.textMuted),
            prefixIcon: Icon(Icons.search, color: AppColors.accent),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          onChanged: controller.searchVehicles,
        ),
        const SizedBox(height: 12),

        // Type & Status Row
        Row(
          children: [
            Expanded(child: _buildTypeDropdown(controller)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatusDropdown(controller)),
          ],
        ),
        const SizedBox(height: 12),

        // Clear Filter Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => controller.clearFilters(),
            icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
            label: const Text('Clear Filters'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: BorderSide(color: AppColors.divider),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedFilters(VehicleListingController controller) {
    return Row(
      children: [
        // Search Field
        Expanded(
          flex: 3,
          child: TextField(
            controller: controller.searchController,
            decoration: InputDecoration(
              hintText: 'Search plate, brand, model, chassis...',
              hintStyle: TextStyle(color: AppColors.textMuted),
              prefixIcon: Icon(Icons.search, color: AppColors.accent),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onChanged: controller.searchVehicles,
          ),
        ),
        const SizedBox(width: 16),

        // Type Dropdown
        Expanded(flex: 2, child: _buildTypeDropdown(controller)),
        const SizedBox(width: 16),

        // Status Dropdown
        Expanded(flex: 2, child: _buildStatusDropdown(controller)),
        const SizedBox(width: 16),

        // Expiring Soon Toggle
        Obx(() => FilterChip(
              label: const Text('Expiring Soon'),
              selected: controller.showExpiringSoon.value,
              onSelected: controller.toggleExpiringSoonFilter,
              selectedColor: AppColors.accent.withOpacity(0.2),
              checkmarkColor: AppColors.accent,
              labelStyle: TextStyle(
                color: controller.showExpiringSoon.value
                    ? AppColors.accent
                    : AppColors.primaryLight,
              ),
            )),
        const SizedBox(width: 8),

        // Clear Filter Button
        IconButton(
          onPressed: () => controller.clearFilters(),
          icon: const Icon(Icons.filter_alt_off_outlined),
          tooltip: 'Clear Filters',
          style: IconButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.divider),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeDropdown(VehicleListingController controller) {
    var genCon = Get.find<GeneralMastersController>();
    return Obx(() {
      final items = <DropdownMenuItem<StatusMaster?>>[
        DropdownMenuItem<StatusMaster?>(
          value: null,
          child: Text('All',
              style: AppTextStyles.body, overflow: TextOverflow.ellipsis),
        ),
        ...genCon.vehicleTypeMasters
            .map((status) => DropdownMenuItem<StatusMaster?>(
                  value: status,
                  child: Text(
                    status.status ?? '',
                    style: AppTextStyles.body,
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
      ];

      return DropdownButtonFormField<StatusMaster?>(
        value: controller.selectedVehicleType.value,
        decoration: InputDecoration(
          labelText: 'Type',
          labelStyle: TextStyle(color: AppColors.primaryLight),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          isDense: true,
        ),
        dropdownColor: AppColors.cardBg,
        borderRadius: AppRadius.borderMd,
        isExpanded: true,
        items: items,
        onChanged: (value) {
          controller.selectedVehicleType.value = value;
          controller.applyFilters();
        },
      );
    });
  }

  Widget _buildStatusDropdown(VehicleListingController controller) {
    var genCon = Get.find<GeneralMastersController>();
    return Obx(() {
      final items = <DropdownMenuItem<StatusMaster?>>[
        DropdownMenuItem<StatusMaster?>(
          value: null,
          child: Text('All',
              style: AppTextStyles.body, overflow: TextOverflow.ellipsis),
        ),
        ...genCon.vehicleStatusMasters
            .map((status) => DropdownMenuItem<StatusMaster?>(
                  value: status,
                  child: Text(
                    status.status ?? '',
                    style: AppTextStyles.body,
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
      ];

      return DropdownButtonFormField<StatusMaster?>(
        value: controller.selectedVehicleStatus.value,
        decoration: InputDecoration(
          labelText: 'Status',
          labelStyle: TextStyle(color: AppColors.primaryLight),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          isDense: true,
        ),
        dropdownColor: AppColors.cardBg,
        borderRadius: AppRadius.borderMd,
        isExpanded: true,
        items: items,
        onChanged: (value) {
          controller.selectedVehicleStatus.value = value;
          controller.applyFilters();
        },
      );
    });
  }

  Widget _buildStatsBar(VehicleListingController controller) {
    return Obx(() {
      final vehicles = controller.originalVehicles;
      final active = vehicles.where((v) => v.status == 'Active').length;
      final inactive = vehicles.where((v) => v.status == 'Inactive').length;
      final maintenance =
          vehicles.where((v) => v.status == 'Under Maintenance').length;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _buildStatChip('Active', active, Colors.green),
            const SizedBox(width: 8),
            _buildStatChip('Inactive', inactive, Colors.red),
            const SizedBox(width: 8),
            _buildStatChip('Maintenance', maintenance, Colors.orange),
          ],
        ),
      );
    });
  }

  Widget _buildStatChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            '$label: $count',
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleGrid(
      VehicleListingController controller, BuildContext context) {
    return Obx(() {
      final vehicles = controller.filteredVehicles;

      if (vehicles.isEmpty) {
        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.car_crash_outlined,
                    size: 64, color: AppColors.textMuted),
                const SizedBox(height: 16),
                Text(
                  'No vehicles found',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 16),
                ),
              ],
            ),
          ),
        );
      }

      return SliverLayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.crossAxisExtent;
          int crossAxisCount;
          double childAspectRatio;

          if (width < 600) {
            crossAxisCount = 1;
            childAspectRatio = 1.6;
          } else if (width < 900) {
            crossAxisCount = 2;
            childAspectRatio = 1.4;
          } else if (width < 1200) {
            crossAxisCount = 3;
            childAspectRatio = 1.3;
          } else {
            crossAxisCount = 4;
            childAspectRatio = 1.2;
          }

          return SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: childAspectRatio,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  _buildVehicleCard(vehicles[index], controller),
              childCount: vehicles.length,
            ),
          );
        },
      );
    });
  }

  Widget _buildVehicleCard(
      Vehicle vehicle, VehicleListingController controller) {
    final isActive = vehicle.status == 'Active';

    return GestureDetector(
      onTap: () async {
        if (controller.dialogueLoading.value) return;
        // fetch and documents and tyres and show loading state while fetching
        await controller.fetchAndAttachDocumentsAndTyres(vehicle);
        _showVehicleDetails(vehicle);
      },
      child: Obx(() {
        final isLoadingThis = controller.dialogueLoading.value &&
            controller.selectedVehicle.value.vehicleNo == vehicle.vehicleNo;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background Image
                _buildVehicleImage(vehicle),

                // Gradient Overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.8),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),

                // Status Badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.green : Colors.red.shade400,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: (isActive ? Colors.green : Colors.red)
                              .withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      vehicle.status ?? 'Unknown',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Vehicle Type Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      vehicle.type ?? 'Vehicle',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Content
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Plate Number
                        Text(
                          vehicle.vehicleNo ?? 'No Plate',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Brand & Model
                        Text(
                          '${vehicle.brand ?? ''} ${vehicle.model ?? ''}'
                              .trim(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Quick Info Row
                        Row(
                          children: [
                            _buildQuickInfo(Icons.calendar_today,
                                '${vehicle.vYear ?? '-'}'),
                            const SizedBox(width: 16),
                            _buildQuickInfo(Icons.speed,
                                '${vehicle.currentOdo ?? vehicle.initialOdo ?? 0} km'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Loading Overlay
                if (isLoadingThis)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: AppColors.accentLight,
                              strokeWidth: 3,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Loading details...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildVehicleImage(Vehicle vehicle) {
    if (vehicle.imagePath1 != null && vehicle.imagePath1!.isNotEmpty) {
      return Image.network(
        vehicle.imagePath1!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildPlaceholderImage(vehicle),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholderImage(vehicle, showLoading: true);
        },
      );
    }
    return _buildPlaceholderImage(vehicle);
  }

  Widget _buildPlaceholderImage(Vehicle vehicle, {bool showLoading = false}) {
    return Container(
      color: AppColors.primaryLight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Fallback asset image
          Image.asset(
            'assets/images/nissan_urvan.jpg', // Your fallback image
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: AppColors.primaryLight,
              child: Icon(
                Icons.directions_car,
                size: 80,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          ),
          if (showLoading)
            Center(
              child: CircularProgressIndicator(
                color: AppColors.accent,
                strokeWidth: 2,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.accentLight),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
        ),
      ],
    );
  }

  // ============== VEHICLE DETAILS DIALOG ==============

  void _showVehicleDetails(Vehicle vehicle) {
    final width = Get.width;
    final isWide = width > 800;
    log(vehicle.toString());

    Get.dialog(
      GetBuilder<VehicleListingController>(
        builder: (con) {
          return con.dialogueLoading.value
              ? Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                )
              : Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: EdgeInsets.symmetric(
                    horizontal: isWide ? width * 0.15 : 16,
                    vertical: 24,
                  ),
                  child: Container(
                    constraints:
                        const BoxConstraints(maxWidth: 900, maxHeight: 700),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        // Dialog Header with Image
                        _buildDialogHeader(vehicle),

                        // Content
                        Expanded(
                          child: DefaultTabController(
                            length: 3,
                            child: Column(
                              children: [
                                // Tab Bar
                                Container(
                                  color: AppColors.cardBg,
                                  child: TabBar(
                                    labelColor: AppColors.accent,
                                    unselectedLabelColor:
                                        AppColors.primaryLight,
                                    indicatorColor: AppColors.accent,
                                    indicatorWeight: 3,
                                    tabs: const [
                                      Tab(
                                          text: 'Details',
                                          icon: Icon(Icons.info_outline,
                                              size: 20)),
                                      Tab(
                                          text: 'Documents',
                                          icon: Icon(Icons.description_outlined,
                                              size: 20)),
                                      Tab(
                                          text: 'Tyres',
                                          icon: Icon(Icons.tire_repair,
                                              size: 20)),
                                    ],
                                  ),
                                ),

                                // Tab Content
                                Expanded(
                                  child: TabBarView(
                                    children: [
                                      _buildDetailsTab(vehicle),
                                      _buildDocumentsTab(vehicle),
                                      _buildTyresTab(vehicle),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Action Buttons
                        _buildDialogActions(vehicle),
                      ],
                    ),
                  ),
                );
        },
      ),
      barrierDismissible: true,
    );
  }

  Widget _buildDialogHeader(Vehicle vehicle) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: _buildVehicleImage(vehicle),
          ),

          // Gradient
          Container(
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),

          // Close Button
          Positioned(
            top: 12,
            right: 12,
            child: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.close, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black38,
              ),
            ),
          ),

          // Vehicle Info
          Positioned(
            bottom: 16,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.vehicleNo ?? 'No Plate',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${vehicle.brand ?? ''} ${vehicle.model ?? ''} ${vehicle.vYear ?? ''}'
                            .trim(),
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.9), fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        vehicle.status == 'Active' ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    vehicle.status ?? 'Unknown',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(Vehicle vehicle) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 500;

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildDetailColumn1(vehicle)),
                const SizedBox(width: 20),
                Expanded(child: _buildDetailColumn2(vehicle)),
              ],
            );
          }

          return Column(
            children: [
              _buildDetailColumn1(vehicle),
              const SizedBox(height: 16),
              _buildDetailColumn2(vehicle),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailColumn1(Vehicle vehicle) {
    return _buildDetailCard(
      title: 'Vehicle Information',
      icon: Icons.directions_car,
      children: [
        _buildDetailItem('Type', vehicle.type ?? '-'),
        _buildDetailItem('Brand', vehicle.brand ?? '-'),
        _buildDetailItem('Model', vehicle.model ?? '-'),
        _buildDetailItem('Year', vehicle.vYear?.toString() ?? '-'),
        _buildDetailItem('Condition', vehicle.condition ?? '-'),
      ],
    );
  }

  Widget _buildDetailColumn2(Vehicle vehicle) {
    return _buildDetailCard(
      title: 'Registration & Usage',
      icon: Icons.badge_outlined,
      children: [
        _buildDetailItem('Chassis No', vehicle.chassisNo ?? '-'),
        _buildDetailItem('Traffic File', vehicle.traficFileNo ?? '-'),
        _buildDetailItem('Initial ODO', '${vehicle.initialOdo ?? 0} km'),
        _buildDetailItem('Current ODO', '${vehicle.currentOdo ?? 0} km'),
        _buildDetailItem('Fuel Station', vehicle.fuelStation ?? '-'),
        if (vehicle.description != null && vehicle.description!.isNotEmpty)
          _buildDetailItem('Remarks', vehicle.description!),
      ],
    );
  }

  Widget _buildDetailCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.accent, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.primaryDark,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsTab(Vehicle vehicle) {
    final docs = vehicle.documents ?? [];

    if (docs.isEmpty) {
      return _buildEmptyState(Icons.description_outlined, 'No documents found');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: docs.length,
      itemBuilder: (context, index) => _buildDocumentItem(docs[index]),
    );
  }

  Widget _buildDocumentItem(VehicleDocument doc) {
    final expiryColor = _getExpiryColor(doc.expiryDate);
    final docTypeNames = {1001: 'Insurance', 1002: 'Registration'};
    final docName = docTypeNames[doc.docType] ?? 'Document ${doc.docType}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.article_outlined, color: AppColors.accent),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  docName,
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Issue: ${doc.formatDate(doc.issueDate)} • ${doc.issueAuthority ?? ''}',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: expiryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: expiryColor.withOpacity(0.3)),
            ),
            child: Text(
              doc.expiryDate != null
                  ? doc.formatDate(doc.expiryDate)
                  : 'No Expiry',
              style: TextStyle(
                color: expiryColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTyresTab(Vehicle vehicle) {
    final tyres = vehicle.tyres ?? [];

    if (tyres.isEmpty) {
      return _buildEmptyState(Icons.tire_repair, 'No tyres found');
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 140,
      ),
      itemCount: tyres.length,
      itemBuilder: (context, index) => _buildTyreItem(tyres[index]),
    );
  }

  Widget _buildTyreItem(Tyre tyre) {
    final isActive = tyre.status == 'Active';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isActive ? AppColors.cardBg : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? AppColors.divider : Colors.red.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.accent : Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tyre.position?.status ?? 'Unknown',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                isActive ? Icons.check_circle : Icons.cancel,
                size: 18,
                color: isActive ? Colors.green : Colors.red,
              ),
            ],
          ),
          const Spacer(),
          Text(
            tyre.brand ?? 'Unknown Brand',
            style: TextStyle(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Size: ${tyre.size ?? '-'} • ${tyre.kmUsed ?? 0} km',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 12),
          ),
          const SizedBox(height: 4),
          if (tyre.expDt != null)
            Text(
              'Exp: ${tyre.formatDate(tyre.expDt)}',
              style: TextStyle(
                color: _getExpiryColor(tyre.expDt),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildDialogActions(Vehicle vehicle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close),
            label: const Text('Close'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryLight,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () {
              Get.back();
              var con = Get.find<HomeScreenController>();
              con.getVehicleFromListing(vehicle);
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit Vehicle'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Color _getExpiryColor(DateTime? expiryDate) {
    if (expiryDate == null) return AppColors.textMuted;

    final daysUntilExpiry = expiryDate.difference(DateTime.now()).inDays;

    if (daysUntilExpiry < 0) return Colors.red.shade700;
    if (daysUntilExpiry <= 30) return Colors.orange;
    if (daysUntilExpiry <= 90) return Colors.amber.shade700;
    return Colors.green;
  }
}

// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:multifleet/models/vehicle.dart';

// import '../controllers/vehicle_listing_controller.dart';
// import '../models/tyre.dart';
// import '../models/vehicle_docs.dart';

// class VehiclesListingPage extends StatelessWidget {
//   const VehiclesListingPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final VehicleListingController controller =
//         Get.find<VehicleListingController>();
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.only(left: 20, right: 20, top: 30),
//         child: Obx(() => controller.isLoading.value
//             ? Center(
//                 child: SizedBox(
//                   height: 25,
//                   width: 25,
//                   child: CircularProgressIndicator.adaptive(),
//                 ),
//               )
//             : Column(
//                 children: [
//                   // Search and Filter Row
//                   _buildSearchSection(controller, context),
//                   SizedBox(height: 20),
//                   Expanded(
//                     child: GetBuilder<VehicleListingController>(
//                       builder: (con) {
//                         return LayoutBuilder(
//                           builder: (context, constraints) {
//                             // Determine layout based on screen width
//                             log("maxwidth ${constraints.maxWidth.toString()}");
//                             if (constraints.maxWidth < 600) {
//                               return _buildMobileLayout(con.filteredVehicles);
//                             } else if (constraints.maxWidth < 1400) {
//                               return _buildTabletLayout(con.filteredVehicles);
//                             } else {
//                               return _buildDesktopLayout(con.filteredVehicles);
//                             }
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               )),
//       ),
//     );
//   }

//   Widget _buildSearchSection(
//       VehicleListingController controller, BuildContext context) {
//     // Check device size
//     final bool isMobile = MediaQuery.of(context).size.width < 600;
//     final double width = MediaQuery.of(context).size.width;
//     final bool isDesktop = width >= 1200;

//     return Card(
//       elevation: 4,
//       child: AnimatedContainer(
//         duration: Duration(milliseconds: 300),
//         child: Obx(
//           () => Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header with title and collapse/expand button
//               InkWell(
//                 onTap: () => controller.toggleSearchVisible(),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Search Vehicles',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Icon(
//                         controller.isSearchVisible
//                             ? Icons.expand_less
//                             : Icons.expand_more,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               // Expandable content
//               if (controller.isSearchVisible)
//                 Padding(
//                   padding: const EdgeInsets.only(
//                       left: 16.0, right: 16.0, bottom: 16.0),
//                   child: isDesktop
//                       // Desktop view - Row layout
//                       ? Row(
//                           children: [
//                             // Search Field - equal flex
//                             Expanded(
//                               child: Padding(
//                                 padding: const EdgeInsets.only(right: 16.0),
//                                 child: TextField(
//                                   controller: controller.searchController,
//                                   decoration: InputDecoration(
//                                     hintText: 'Search vehicles...',
//                                     prefixIcon: Icon(Icons.search),
//                                     border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                   ),
//                                   onChanged: (value) =>
//                                       controller.searchVehicles(value),
//                                 ),
//                               ),
//                             ),

//                             // Vehicle Type Dropdown - equal flex
//                             Expanded(
//                               child: Padding(
//                                 padding: const EdgeInsets.only(right: 16.0),
//                                 child:
//                                     Obx(() => DropdownButtonFormField<String>(
//                                           decoration: InputDecoration(
//                                             labelText: 'Vehicle Type',
//                                             border: OutlineInputBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(10),
//                                             ),
//                                           ),
//                                           value: controller
//                                               .selectedVehicleType.value,
//                                           items: controller
//                                               .getVehicleTypes()
//                                               .map((type) => DropdownMenuItem(
//                                                     value: type,
//                                                     child: Text(type),
//                                                   ))
//                                               .toList(),
//                                           onChanged: (value) => controller
//                                               .filterByVehicleType(value!),
//                                         )),
//                               ),
//                             ),

//                             // Expiring Soon Filter - smaller width
//                             SizedBox(
//                               width: 200,
//                               child: Obx(() => CheckboxListTile(
//                                     title: Text('Expiring Soon'),
//                                     value: controller.showExpiringSoon.value,
//                                     onChanged: (value) => controller
//                                         .toggleExpiringSoonFilter(value!),
//                                     controlAffinity:
//                                         ListTileControlAffinity.leading,
//                                     contentPadding:
//                                         EdgeInsets.symmetric(horizontal: 8),
//                                     dense: true,
//                                   )),
//                             ),
//                           ],
//                         )
//                       // Mobile/Tablet view - Wrap layout
//                       : Wrap(
//                           spacing: 16,
//                           runSpacing: 16,
//                           alignment: WrapAlignment.start,
//                           children: [
//                             // Search Field
//                             SizedBox(
//                               width: isMobile
//                                   ? width - 50
//                                   : (width > 800
//                                       ? (width - 80) / 2
//                                       : width - 50),
//                               child: TextField(
//                                 controller: controller.searchController,
//                                 decoration: InputDecoration(
//                                   hintText: 'Search vehicles...',
//                                   prefixIcon: Icon(Icons.search),
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   isDense: isMobile,
//                                   contentPadding: isMobile
//                                       ? EdgeInsets.symmetric(
//                                           vertical: 12, horizontal: 16)
//                                       : null,
//                                 ),
//                                 onChanged: (value) =>
//                                     controller.searchVehicles(value),
//                               ),
//                             ),

//                             // Vehicle Type Dropdown
//                             SizedBox(
//                               width: isMobile
//                                   ? width - 50
//                                   : (width > 800
//                                       ? (width - 80) / 2
//                                       : width - 50),
//                               child: Obx(() => DropdownButtonFormField<String>(
//                                     decoration: InputDecoration(
//                                       labelText: 'Vehicle Type',
//                                       border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(10),
//                                       ),
//                                       isDense: isMobile,
//                                       contentPadding: isMobile
//                                           ? EdgeInsets.symmetric(
//                                               vertical: 12, horizontal: 16)
//                                           : null,
//                                     ),
//                                     value: controller.selectedVehicleType.value,
//                                     items: controller
//                                         .getVehicleTypes()
//                                         .map((type) => DropdownMenuItem(
//                                               value: type,
//                                               child: Text(type),
//                                             ))
//                                         .toList(),
//                                     onChanged: (value) =>
//                                         controller.filterByVehicleType(value!),
//                                   )),
//                             ),

//                             // Expiring Soon Filter
//                             SizedBox(
//                               width: isMobile
//                                   ? width - 50
//                                   : (width > 800
//                                       ? (width - 80) / 2
//                                       : width - 50),
//                               child: Obx(
//                                 () => CheckboxListTile(
//                                   title: Text('Expiring Soon'),
//                                   value: controller.showExpiringSoon.value,
//                                   onChanged: (value) => controller
//                                       .toggleExpiringSoonFilter(value!),
//                                   controlAffinity:
//                                       ListTileControlAffinity.leading,
//                                   contentPadding:
//                                       EdgeInsets.symmetric(horizontal: 8),
//                                   dense: true,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Mobile Layout - Single Column
//   Widget _buildMobileLayout(List<Vehicle> vehicles) {
//     return ListView.builder(
//       itemCount: vehicles.length,
//       itemBuilder: (context, index) =>
//           _buildVehicleExpansionTile(vehicles[index], index),
//     );
//   }

//   // Tablet Layout - Two Columns
//   Widget _buildTabletLayout(List<Vehicle> vehicles) {
//     return Row(
//       children: [
//         Expanded(
//           child: ListView.builder(
//             itemCount: (vehicles.length / 2).ceil(),
//             itemBuilder: (context, index) =>
//                 _buildVehicleExpansionTile(vehicles[index], index),
//           ),
//         ),
//         Expanded(
//           child: ListView.builder(
//             itemCount: vehicles.length ~/ 2,
//             itemBuilder: (context, index) => _buildVehicleExpansionTile(
//                 vehicles[(vehicles.length / 2).ceil() + index],
//                 (vehicles.length / 2).ceil() + index),
//           ),
//         ),
//       ],
//     );
//   }

//   // Desktop Layout - Three Columns
//   Widget _buildDesktopLayout(List<Vehicle> vehicles) {
//     return Obx(() => Row(
//           children: [
//             // First Column
//             Expanded(
//               child: ListView.builder(
//                 itemCount: (vehicles.length / 3).ceil(),
//                 itemBuilder: (context, index) =>
//                     _buildVehicleExpansionTile(vehicles[index], index),
//               ),
//             ),
//             // Second Column
//             Expanded(
//               child: ListView.builder(
//                 itemCount: (vehicles.length / 3).ceil(),
//                 itemBuilder: (context, index) => _buildVehicleExpansionTile(
//                     vehicles[((vehicles.length / 3).ceil()) + index],
//                     ((vehicles.length / 3).ceil()) + index),
//               ),
//             ),
//             // Third Column
//             Expanded(
//               child: ListView.builder(
//                 itemCount: vehicles.length - (2 * (vehicles.length / 3).ceil()),
//                 itemBuilder: (context, index) => _buildVehicleExpansionTile(
//                     vehicles[(2 * (vehicles.length / 3).ceil()) + index],
//                     (2 * (vehicles.length / 3).ceil()) + index),
//               ),
//             ),
//           ],
//         ));
//   }

//   Widget _buildVehicleExpansionTile(Vehicle vehicle, int index) {
//     return Card(
//       elevation: 6,
//       margin: EdgeInsets.all(20),
//       child: Theme(
//         data: ThemeData(dividerColor: Colors.transparent),
//         child: ExpansionTile(
//           onExpansionChanged: (value) {
//             log(vehicle.toString());
//           },
//           backgroundColor:
//               vehicle.status == 'Active' ? null : Colors.red.shade400,
//           collapsedBackgroundColor:
//               vehicle.status == 'Active' ? null : Colors.red.shade400,
//           collapsedShape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//           title: Text(
//             '${index + 1}. ${vehicle.vehicleNo}',
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//           subtitle: Text('${vehicle.brand} | ${vehicle.model}'),
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                   image: AssetImage('assets/images/nissan_urvan.jpg'),
//                   fit: BoxFit.cover,
//                   colorFilter: ColorFilter.mode(
//                     Colors.white.withOpacity(0.3),
//                     BlendMode.dstATop,
//                   ),
//                 ),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Vehicle Information Section
//                     _buildSectionTitle('Vehicle Information'),
//                     _buildDetailRow('Type', vehicle.type ?? ''),
//                     _buildDetailRow('Chassis Number', vehicle.chassisNo ?? ''),
//                     _buildDetailRow('Traffic File', vehicle.traficFileNo ?? ''),
//                     _buildDetailRow('Year', vehicle.vYear?.toString() ?? ''),
//                     _buildDetailRow(
//                         'Initial KM', vehicle.initialOdo?.toString() ?? ''),
//                     _buildDetailRow('Remarks', vehicle.description ?? ''),
//                     _buildDetailRow('Status', vehicle.status ?? ''),

//                     // Documents Section
//                     if (vehicle.documents != null &&
//                         vehicle.documents!.isNotEmpty)
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           SizedBox(height: 16),
//                           _buildSectionTitle('Documents'),
//                           ...vehicle.documents!
//                               .map((doc) => _buildDocumentCard(doc)),
//                         ],
//                       ),

//                     // Tyres Section
//                     if (vehicle.tyres != null && vehicle.tyres!.isNotEmpty)
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           SizedBox(height: 16),
//                           _buildSectionTitle('Tyre Details'),
//                           ...vehicle.tyres!.map((tyre) => _buildTyreCard(tyre)),
//                         ],
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

// // Helper method to build document cards
//   Widget _buildDocumentCard(VehicleDocument document) {
//     // Define document type names
//     Map<int, String> docTypeNames = {
//       1001: 'Insurance',
//       1002: 'Registration',
//       // Add more document types as needed
//     };

//     String docTypeName =
//         docTypeNames[document.docType] ?? 'Document ${document.docType}';

//     return Card(
//       margin: EdgeInsets.symmetric(vertical: 4),
//       color: Colors.white.withOpacity(0.9),
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   docTypeName,
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 15,
//                   ),
//                 ),
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color:
//                         _getExpiryColor(document.expiryDate?.toIso8601String()),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     document.expiryDate != null
//                         ? 'Expires: ${document.formatDate(document.expiryDate)}'
//                         : 'No Expiry Date',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             Divider(),
//             _buildDetailRow('Issue Authority', document.issueAuthority ?? ''),
//             _buildDetailRow(
//                 'Issue Date', document.formatDate(document.issueDate)),
//             _buildDetailRow('City', document.city ?? ''),
//           ],
//         ),
//       ),
//     );
//   }

// // Helper method to build tyre cards
//   Widget _buildTyreCard(Tyre tyre) {
//     return Card(
//       margin: EdgeInsets.symmetric(vertical: 4),
//       color: Colors.white.withOpacity(0.9),
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   tyre.position ?? 'Unknown Position',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 15,
//                   ),
//                 ),
//                 if (tyre.expDt != null)
//                   Container(
//                     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: _getExpiryColor(tyre.expDt?.toIso8601String()),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       'Expires: ${tyre.formatDate(tyre.expDt)}',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//             Divider(),
//             _buildDetailRow('Brand', tyre.brand ?? ''),
//             _buildDetailRow('Size', tyre.size ?? ''),
//             _buildDetailRow('KM Used', tyre.kmUsed?.toString() ?? '0'),
//             if (tyre.installDt != null)
//               _buildDetailRow('Install Date', tyre.formatDate(tyre.installDt)),
//             if (tyre.remarks != null && tyre.remarks!.isNotEmpty)
//               _buildDetailRow('Remarks', tyre.remarks ?? ''),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//         decoration: BoxDecoration(
//           color: Colors.black.withOpacity(0.6),
//           borderRadius: BorderRadius.circular(5),
//         ),
//         child: Text(
//           title,
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.9),
//           borderRadius: BorderRadius.circular(5),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               label,
//               style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black,
//               ),
//             ),
//             Spacer(),
//             Expanded(
//               child: Text(
//                 value,
//                 style: TextStyle(
//                     color: Colors.black87, fontWeight: FontWeight.w600),
//                 textAlign: TextAlign.right,
//                 overflow: TextOverflow.ellipsis,
//                 maxLines: 2,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Widget _buildExpiryRow(String label, String value, Color color) {
//   //   return Padding(
//   //     padding: const EdgeInsets.symmetric(vertical: 4.0),
//   //     child: Row(
//   //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //       children: [
//   //         Text(
//   //           label,
//   //           style: TextStyle(fontWeight: FontWeight.w600),
//   //         ),
//   //         Text(
//   //           value,
//   //           style: TextStyle(color: color),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }

//   Color _getExpiryColor(String? expiryDateStr) {
//     // If null or empty, return white
//     if (expiryDateStr == null || expiryDateStr.isEmpty) {
//       return Colors.grey;
//     }

//     // Try to parse the date string
//     DateTime? expiryDate;
//     try {
//       expiryDate = DateTime.parse(expiryDateStr);
//     } catch (e) {
//       // If parsing fails, return grey
//       return Colors.grey;
//     }

//     // Calculate days until expiry
//     final daysUntilExpiry = expiryDate.difference(DateTime.now()).inDays;

//     // Return appropriate color based on days remaining
//     if (daysUntilExpiry < 0) return Colors.red.shade800; // Already expired
//     if (daysUntilExpiry <= 30) return Colors.orange;
//     if (daysUntilExpiry <= 90) return Colors.amber;
//     return Colors.green;
//   }
// }
