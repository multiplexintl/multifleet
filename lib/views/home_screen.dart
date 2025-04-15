import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multifleet/routes.dart';

import 'package:multifleet/views/add_edit_vehicle.dart';
import 'package:multifleet/views/assigned_vehicle_page.dart';
import 'package:multifleet/views/expiry_page.dart';
import 'package:multifleet/views/header/dashboard.dart';
import 'package:multifleet/views/header/reports.dart';
import 'package:multifleet/views/maintainace_page.dart';
import 'package:multifleet/views/vehicle_assignment.dart';
import 'package:multifleet/views/vehicles_listing.dart';

import '../controllers/home_controller.dart';
import 'fine_details_page.dart';
import 'header/profile.dart';
import 'header/settings.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeScreenController controller = Get.find<HomeScreenController>();
    return Scaffold(
      drawer: MediaQuery.of(context).size.width < 600
          ? _buildMobileDrawer(context)
          : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Determine if it's a mobile, tablet, or desktop view
          bool isMobile = constraints.maxWidth < 600;
          bool isTablet =
              constraints.maxWidth >= 600 && constraints.maxWidth < 1200;
          log(isTablet.toString());
          return Column(
            children: [
              // Sticky Header
              _buildHeader(context),

              // Main Content Area
              Expanded(
                child: Row(
                  children: [
                    // Sidebar Navigation
                    if (!isMobile)
                      _buildSidebar(isMobile, isTablet, controller),

                    // Main Content
                    Expanded(
                      flex: 2,
                      child: Obx(() {
                        // Determine which content to show based on active navigation
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.05, 0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: controller.currentHeaderIndex.value > 0
                              ? _buildHeaderContent(
                                  controller.currentHeaderIndex.value)
                              : _buildMainContent(
                                  controller.currentSidebarIndex.value),
                        );
                      }),
                    ),

                    // Right Side Containers
                    _buildRightSideContainers(controller, isMobile, isTablet),
                  ],
                ),
              ),

              // Footer
              _buildFooter(context),
            ],
          );
        },
      ),
    );
  }

  // Mobile drawer based on the existing sidebar items
  Widget _buildMobileDrawer(BuildContext context) {
    final HomeScreenController controller = Get.find<HomeScreenController>();

    return Drawer(
      child: Container(
        color: Colors.blue[50],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue[800],
              ),
              child: const Text(
                'MultiFleet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            // Home option in drawer
            _drawerItem(
              Icons.home,
              'Home',
              -1,
              () {
                controller.changeHeaderPage(1);
                controller.changeSidebarPage(0);
                Navigator.pop(context);
              },
              controller,
              isHeader: true,
              headerIndex: 1,
            ),
            // Dashboard option in drawer
            _drawerItem(
              Icons.dashboard,
              'Dashboard',
              -1,
              () {
                controller.changeHeaderPage(2);
                controller.changeSidebarPage(0);
                Navigator.pop(context);
              },
              controller,
              isHeader: true,
              headerIndex: 2,
            ),
            // Reports option in drawer
            _drawerItem(
              Icons.bar_chart,
              'Reports',
              -1,
              () {
                controller.changeHeaderPage(3);
                controller.changeSidebarPage(0);
                Navigator.pop(context);
              },
              controller,
              isHeader: true,
              headerIndex: 3,
            ),
            // Settings option in drawer
            _drawerItem(
              Icons.settings,
              'Settings',
              -1,
              () {
                controller.changeHeaderPage(4);
                controller.changeSidebarPage(0);
                Navigator.pop(context);
              },
              controller,
              isHeader: true,
              headerIndex: 4,
            ),
            // Divider between header and sidebar items
            Divider(color: Colors.blue[200]),
            // Reuse the sidebar items but configure them for the drawer
            _drawerItem(
              Icons.directions_car,
              'Vehicle Listing',
              0,
              () {
                controller.changeHeaderPage(0);
                controller.changeSidebarPage(0);
                Navigator.pop(context);
              },
              controller,
            ),
            _drawerItem(
              Icons.assignment,
              'Add/Edit Vehicles',
              1,
              () {
                controller.changeHeaderPage(0);
                controller.changeSidebarPage(1);
                Navigator.pop(context);
              },
              controller,
            ),
            _drawerItem(
              Icons.assignment,
              'Vehicle Assignment',
              2,
              () {
                controller.changeHeaderPage(0);
                controller.changeSidebarPage(2);
                Navigator.pop(context);
              },
              controller,
            ),
            _drawerItem(
              Icons.report,
              'Assigned Vehicles',
              3,
              () {
                controller.changeHeaderPage(0);
                controller.changeSidebarPage(3);
                Navigator.pop(context);
              },
              controller,
            ),
            _drawerItem(
              Icons.warning,
              'Add Fine',
              4,
              () {
                controller.changeHeaderPage(0);
                controller.changeSidebarPage(4);
                Navigator.pop(context);
              },
              controller,
            ),
            _drawerItem(
              Icons.calendar_today,
              'Expiry Details',
              5,
              () {
                controller.changeHeaderPage(0);
                controller.changeSidebarPage(5);
                Navigator.pop(context);
              },
              controller,
            ),
            _drawerItem(
              Icons.miscellaneous_services,
              'Service & Maintainace',
              6,
              () {
                controller.changeHeaderPage(0);
                controller.changeSidebarPage(6);
                Navigator.pop(context);
              },
              controller,
            ),
          ],
        ),
      ),
    );
  }

  // Drawer item based on the existing sidebar item
  Widget _drawerItem(IconData icon, String title, int pageIndex,
      void Function()? onTap, HomeScreenController controller,
      {bool isHeader = false, int headerIndex = 0}) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
        child: Container(
          decoration: BoxDecoration(
            color: isHeader
                ? (controller.currentHeaderIndex.value == headerIndex
                    ? Colors.blue[800]
                    : Colors.transparent)
                : (controller.currentSidebarIndex.value == pageIndex &&
                        controller.currentHeaderIndex.value == 0
                    ? Colors.blue[800]
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: Icon(
              icon,
              color: isHeader
                  ? (controller.currentHeaderIndex.value == headerIndex
                      ? Colors.white
                      : Colors.blue[800])
                  : (controller.currentSidebarIndex.value == pageIndex &&
                          controller.currentHeaderIndex.value == 0
                      ? Colors.white
                      : Colors.blue[800]),
            ),
            title: Text(
              title,
              style: TextStyle(
                color: isHeader
                    ? (controller.currentHeaderIndex.value == headerIndex
                        ? Colors.white
                        : Colors.black)
                    : (controller.currentSidebarIndex.value == pageIndex &&
                            controller.currentHeaderIndex.value == 0
                        ? Colors.white
                        : Colors.black),
              ),
            ),
            onTap: onTap,
          ),
        ),
      ),
    );
  }

  // Build Main Content based on selected sidebar page
  Widget _buildMainContent(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return VehiclesListingPage();
      case 1:
        return AddEditVehiclePage();
      case 2:
        return VehicleAssignmentPage();
      case 3:
        return VehicleAssignmentsListPage();
      case 4:
        return VehicleFinePage();
      case 5:
        return VehicleExpiryPage();
      case 6:
        return MaintenancePage();
      default:
        return SizedBox();
    }
  }

  // Build Header Content based on selected header page
  Widget _buildHeaderContent(int pageIndex) {
    switch (pageIndex) {
      // case 1: // Home
      //   return HomePageContent();
      case 2: // Dashboard
        return DashboardPage();
      case 3: // Reports
        return ReportsPage();
      case 4: // Settings
        return SettingsPageContent();
      case 5: // Profile
        return ProfilePageContent();
      default:
        return SizedBox();
    }
  }

  // Header Widget
  Widget _buildHeader(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    final HomeScreenController controller = Get.find<HomeScreenController>();

    return Container(
      color: Colors.blue[800],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (isMobile)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),

          // Logo or App Name
          Text(
            isMobile ? 'MultiFleet' : 'MultiFleet Vehicle Management System',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Header Navigation Items
          if (!isMobile)
            Wrap(
              spacing: 16,
              children: [
                // _headerNavItem(
                //   context,
                //   'Home',
                //   1,
                //   controller,
                //   onPressed: () {
                //     controller.changeHeaderPage(1);
                //   },
                // ),
                _headerNavItem(
                  context,
                  'Dashboard',
                  2,
                  controller,
                  onPressed: () {
                    controller.changeHeaderPage(2);
                  },
                ),
                _headerNavItem(
                  context,
                  'Reports',
                  3,
                  controller,
                  onPressed: () {
                    controller.changeHeaderPage(3);
                  },
                ),
                _headerNavItem(
                  context,
                  'Settings',
                  4,
                  controller,
                  onPressed: () {
                    controller.changeHeaderPage(4);
                  },
                ),
                _headerNavItem(
                  context,
                  'Profile',
                  5,
                  controller,
                  onPressed: () {
                    controller.changeHeaderPage(5);
                  },
                ),

                // Logout Button
                ElevatedButton.icon(
                  onPressed: () {
                    Get.offAllNamed(RouteLinks.login);
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // Header Navigation Item
  Widget _headerNavItem(BuildContext context, String title, int pageIndex,
      HomeScreenController controller,
      {required void Function()? onPressed}) {
    return Obx(() => AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: controller.currentHeaderIndex.value == pageIndex
                ? Colors.white.withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: controller.currentHeaderIndex.value == pageIndex
                    ? FontWeight.bold
                    : FontWeight.w600,
              ),
            ),
          ),
        ));
  }

  // Sidebar Navigation
  Widget _buildSidebar(
      bool isMobile, bool isTablet, HomeScreenController controller) {
    return Container(
      width: isMobile ? 60 : (isTablet ? 120 : 250),
      color: Colors.blue[50],
      child: ListView(
        children: [
          _sidebarItem(
            Icons.directions_car,
            'Vehicle Listing',
            isMobile,
            isTablet,
            0,
            () {
              controller.changeHeaderPage(0);
              controller.changeSidebarPage(0);
            },
            controller,
          ),
          _sidebarItem(
            Icons.assignment,
            'Add/Edit Vehicles',
            isMobile,
            isTablet,
            1,
            () {
              controller.changeHeaderPage(0);
              controller.changeSidebarPage(1);
            },
            controller,
          ),
          _sidebarItem(
            Icons.assignment,
            'Vehicle Assignment',
            isMobile,
            isTablet,
            2,
            () {
              controller.changeHeaderPage(0);
              controller.changeSidebarPage(2);
            },
            controller,
          ),
          _sidebarItem(
            Icons.report,
            'Assigned Vehicles',
            isMobile,
            isTablet,
            3,
            () {
              controller.changeHeaderPage(0);
              controller.changeSidebarPage(3);
            },
            controller,
          ),
          _sidebarItem(
            Icons.warning,
            'Add Fine',
            isMobile,
            isTablet,
            4,
            () {
              controller.changeHeaderPage(0);
              controller.changeSidebarPage(4);
            },
            controller,
          ),
          _sidebarItem(
            Icons.calendar_today,
            'Expiry Details',
            isMobile,
            isTablet,
            5,
            () {
              controller.changeHeaderPage(0);
              controller.changeSidebarPage(5);
            },
            controller,
          ),
          _sidebarItem(
            Icons.miscellaneous_services,
            'Service & Maintainace',
            isMobile,
            isTablet,
            6,
            () {
              controller.changeHeaderPage(0);
              controller.changeSidebarPage(6);
            },
            controller,
          ),
        ],
      ),
    );
  }

  // Sidebar Item with active state and animations
  Widget _sidebarItem(IconData icon, String title, bool isMobile, bool isTablet,
      int pageIndex, void Function()? onTap, HomeScreenController controller) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.all(8.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: controller.currentSidebarIndex.value == pageIndex &&
                    controller.currentHeaderIndex.value == 0
                ? Colors.blue[800]
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: controller.currentSidebarIndex.value == pageIndex &&
                    controller.currentHeaderIndex.value == 0
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: ListTile(
            title: isMobile
                ? null
                : isTablet
                    ? Icon(
                        icon,
                        color:
                            controller.currentSidebarIndex.value == pageIndex &&
                                    controller.currentHeaderIndex.value == 0
                                ? Colors.white
                                : Colors.blue[800],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            icon,
                            color: controller.currentSidebarIndex.value ==
                                        pageIndex &&
                                    controller.currentHeaderIndex.value == 0
                                ? Colors.white
                                : Colors.blue[800],
                          ),
                          SizedBox(width: 20),
                          SizedBox(
                            width: 150,
                            child: Text(
                              title,
                              style: TextStyle(
                                color: controller.currentSidebarIndex.value ==
                                            pageIndex &&
                                        controller.currentHeaderIndex.value == 0
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
            onTap: onTap,
          ),
        ),
      ),
    );
  }

  // Right Side Containers
  Widget _buildRightSideContainers(
      HomeScreenController con, bool isMobile, bool isTablet) {
    // If mobile, don't show right side containers
    if (isMobile) return Container();

    return Container(
      width: isTablet ? 200 : 300,
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Obx(() => ListView(
            children: [
              // Near Expiry Insurance Container
              _reminderContainer(
                icon: Icons.warning_amber_rounded,
                title: 'Insurance Expiry',
                content: '${con.expiryInsuranceVehicle} Vehicles near expiry',
                color: Colors.orange[100]!,
              ),

              const SizedBox(height: 16),
              // Near Expiry Mulkiya Container
              _reminderContainer(
                icon: Icons.warning_amber_rounded,
                title: 'Mulkiya Expiry',
                content: '${con.expiryMulkiyaVehicle} Vehicles near expiry',
                color: Colors.cyan[100]!,
              ),

              const SizedBox(height: 16),

              // 5 Lakh KM Reminder
              _reminderContainer(
                icon: Icons.speed,
                title: '5 Lakh KM Alert',
                content: '2 Vehicles approaching 5L KM',
                color: Colors.red[100]!,
              ),

              const SizedBox(height: 16),

              // Service Due Vehicles
              _reminderContainer(
                icon: Icons.miscellaneous_services,
                title: 'Service Due',
                content: '4 Vehicles need service',
                color: Colors.green[100]!,
              ),
            ],
          )),
    );
  }

  // Reminder Container Widget
  Widget _reminderContainer({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue[800]),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // Footer Widget
  Widget _buildFooter(BuildContext context) {
    return Container(
      color: Colors.blue[800],
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '© 2025 MultiFleet Vehicle Management System',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
          Text(
            'Version 1.0.0',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
