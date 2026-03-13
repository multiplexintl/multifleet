import 'dart:developer';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:multifleet/controllers/add_edit_vehicle_controller.dart';
import 'package:multifleet/models/company.dart';
import 'package:multifleet/models/notification/notification.dart';
import 'package:multifleet/models/vehicle.dart';
import 'package:multifleet/models/vehicle_maintenance/vehicle_maintenance.dart';
import 'package:multifleet/repo/home_repo.dart';
import 'package:multifleet/routes.dart';
import 'package:multifleet/services/company_service.dart';

import '../models/user.dart';
import '../services/user_service.dart';

class HomeScreenController extends GetxController
    implements CompanyAwareController {
  UserService userService = Get.find<UserService>();
  final companyService = Get.find<CompanyService>();

  User? get user => userService.user;
  final RxInt currentSidebarIndex = 0.obs;
  final RxInt currentHeaderIndex = 0.obs;
  final storage = GetStorage();

  // Notification data from API
  final Rx<Notification?> notificationData = Rx<Notification?>(null);
  final RxBool isLoadingNotifications = false.obs;

  // Alert counts derived from notification data
  RxInt expiryInsuranceVehicles = 0.obs;
  RxInt expiryMulkiyaVehicles = 0.obs;
  RxInt kmApproachingVehicles = 0.obs;
  RxInt serviceDueVehicles = 0.obs;
  RxInt unpaidFinesCount = 0.obs;

  // Scheduled maintenance for today
  RxList<VehicleMaintenance> todayScheduledMaintenance =
      <VehicleMaintenance>[].obs;

  @override
  void onInit() {
    super.onInit();
    ever(userService.userObs, (_) => update());
    currentSidebarIndex.value = storage.read('sidebarIndex') ?? 0;
    currentHeaderIndex.value = storage.read('headerIndex') ?? 0;
    // Notifications are global (no company required), safe to fetch immediately
    fetchNotifications();
    // getTodayScheduledMaintenance requires a company — triggered via
    // onCompanyChanged once CompanyService resolves the company.
    companyService.registerController(this);
  }

  @override
  Future<void> onCompanyChanged(Company newCompany) async {
    log("company changed in home");
    todayScheduledMaintenance.clear();
    getTodayScheduledMaintenance(company: newCompany.id);
  }

  // Change sidebar page and persist
  void changeSidebarPage(int index) {
    currentSidebarIndex.value = index;
    storage.write('sidebarIndex', index);
  }

  // get vehicle from listing and go to edit page
  void getVehicleFromListing(Vehicle vehicle) {
    log(vehicle.toString());
    var editCon = Get.find<AddEditVehicleController>();
    editCon.plateNumberController.text = vehicle.vehicleNo!;
    editCon.searchVehicle();
    changeSidebarPage(1);
  }

  // Change header page and persist
  void changeHeaderPage(int index) {
    currentHeaderIndex.value = index;
    storage.write('headerIndex', index);
  }

  // Fetch notifications from API and compute all alert counts
  Future<void> fetchNotifications() async {
    isLoadingNotifications.value = true;
    var res = await HomeRepo().getNotifications();
    res.fold(
      (error) {
        log("Error fetching notifications: $error");
        isLoadingNotifications.value = false;
      },
      (notification) {
        notificationData.value = notification;
        _computeAlertCounts(notification);
        isLoadingNotifications.value = false;
      },
    );
  }

  void _computeAlertCounts(Notification notification) {
    // Doc expiry: group by docDescription to separate insurance vs mulkiya
    final docs = notification.lstDocExpiry ?? [];
    int insuranceCount = 0;
    int mulkiyaCount = 0;
    for (var doc in docs) {
      final desc = (doc.docDescription ?? '').toLowerCase();
      if (desc.contains('insurance')) {
        insuranceCount++;
      } else if (desc.contains('mulkiya') || desc.contains('registration')) {
        mulkiyaCount++;
      }
    }
    expiryInsuranceVehicles.value = insuranceCount;
    expiryMulkiyaVehicles.value = mulkiyaCount;

    // Odometer / KM approaching
    kmApproachingVehicles.value = (notification.lstOdoReminder ?? []).length;

    // Service due
    serviceDueVehicles.value = (notification.lstServiceReminder ?? []).length;

    // Unpaid fines
    unpaidFinesCount.value = (notification.lstUnpaidFines ?? []).length;

    log("Insurance: $insuranceCount, Mulkiya: $mulkiyaCount, KM: ${kmApproachingVehicles.value}, Service: ${serviceDueVehicles.value}, Fines: ${unpaidFinesCount.value}");
  }

  // Get doc expiry items filtered by type (insurance or mulkiya)
  Map<String, List<dynamic>> getDocExpiryByCompany(String type) {
    final docs = notificationData.value?.lstDocExpiry ?? [];
    final filtered = docs.where((doc) {
      final desc = (doc.docDescription ?? '').toLowerCase();
      if (type == 'insurance') return desc.contains('insurance');
      if (type == 'mulkiya') {
        return desc.contains('mulkiya') || desc.contains('registration');
      }
      return false;
    }).toList();

    final Map<String, List<dynamic>> grouped = {};
    for (var doc in filtered) {
      final company = doc.company ?? 'Unknown';
      grouped.putIfAbsent(company, () => []);
      grouped[company]!.add(doc);
    }
    return grouped;
  }

  // Get odometer reminders grouped by company
  Map<String, List<dynamic>> getOdoRemindersByCompany() {
    final items = notificationData.value?.lstOdoReminder ?? [];
    final Map<String, List<dynamic>> grouped = {};
    for (var item in items) {
      final company = item.company ?? 'Unknown';
      grouped.putIfAbsent(company, () => []);
      grouped[company]!.add(item);
    }
    return grouped;
  }

  // Get service reminders grouped by company
  Map<String, List<dynamic>> getServiceRemindersByCompany() {
    final items = notificationData.value?.lstServiceReminder ?? [];
    final Map<String, List<dynamic>> grouped = {};
    for (var item in items) {
      final company = item.company ?? 'Unknown';
      grouped.putIfAbsent(company, () => []);
      grouped[company]!.add(item);
    }
    return grouped;
  }

  // Get unpaid fines grouped by company
  Map<String, List<dynamic>> getUnpaidFinesByCompany() {
    final items = notificationData.value?.lstUnpaidFines ?? [];
    final Map<String, List<dynamic>> grouped = {};
    for (var item in items) {
      final company = item.company ?? 'Unknown';
      grouped.putIfAbsent(company, () => []);
      grouped[company]!.add(item);
    }
    return grouped;
  }

  // Fetch today's scheduled maintenance
  Future<void> getTodayScheduledMaintenance({String? company}) async {
    final companyId = company ?? companyService.selectedCompany?.id;
    if (companyId == null) return;
    final today = DateTime.now();
    final formattedDate =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    var res = await HomeRepo().getTodaysMaintenanceSchedule(
        company: companyId,
        date: formattedDate);
    res.fold(
      (error) {
        log("Error fetching today's maintenance: $error");
      },
      (maintenance) {
        todayScheduledMaintenance.value = maintenance;
      },
    );
  }

  Future<void> logout() async {
    await userService.clearUser();
    Get.offAllNamed(RouteLinks.login);
  }
}
