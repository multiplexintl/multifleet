import 'dart:developer';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:multifleet/repo/home_repo.dart';
import 'package:multifleet/routes.dart';
import 'package:multifleet/services/company_service.dart';

import '../models/user.dart';
import '../models/vehicle_docs.dart';
import '../services/user_service.dart';

class HomeScreenController extends GetxController {
  UserService userService = Get.find<UserService>();
  final companyService = Get.find<CompanyService>();

  User? get user => userService.user;
  final RxInt currentSidebarIndex = 0.obs;
  final RxInt currentHeaderIndex = 0.obs;
  final storage = GetStorage();
  //
  RxInt expiryInsuranceVehicle = 0.obs;
  RxInt expiryMulkiyaVehicle = 0.obs;

  @override
  void onInit() {
    super.onInit();
    ever(userService.userObs, (_) => update());
    currentSidebarIndex.value = storage.read('sidebarIndex') ?? 0;
    currentHeaderIndex.value = storage.read('headerIndex') ?? 0;
    getVehicleDocs();
  }

  // Change sidebar page and persist
  void changeSidebarPage(int index) {
    currentSidebarIndex.value = index;
    storage.write('sidebarIndex', index);
  }

  // Change header page and persist
  void changeHeaderPage(int index) {
    currentHeaderIndex.value = index;
    storage.write('headerIndex', index);
  }

  // need to get vehicle docs and create a list of near expiry list of vehicles

  Future<void> getVehicleDocs() async {
    var res = await HomeRepo().getVehicleDocs(
        company: '${companyService.selectedCompanyObs.value?.id}');
    res.fold((error) {}, (docs) {
      // log(docs.toString());
      if (docs.isNotEmpty) {
        expiryInsuranceVehicle.value =
            getVehiclesExpiringInOneMonth(docs, 1001);
        log("Insurance Near Expiry Vehicle Count: ${expiryInsuranceVehicle.value.toString()}");

        expiryMulkiyaVehicle.value = getVehiclesExpiringInOneMonth(docs, 1002);
        log("Mulkiya Near Expiry Vehicle Count: ${expiryMulkiyaVehicle.value.toString()}");
      }
    });
  }

  int getVehiclesExpiringInOneMonth(
      List<VehicleDocument> documents, int docType) {
    // Get current date
    final now = DateTime.now();

    // Calculate the date 1 month from now
    final oneMonthLater = DateTime(now.year, now.month + 1, now.day);

    // Filter and count documents
    int count = 0;

    for (var doc in documents) {
      // Check if document matches the requested type
      if (doc.docType == docType) {
        // Parse the expiry date (assuming format is DD/MM/YYYY)
        if (doc.expiryDate != null) {
          // Check if expiry date is within 1 month
          if (doc.expiryDate!.isAfter(now) &&
              doc.expiryDate!.isBefore(oneMonthLater)) {
            count++;
          }
        }
      }
    }

    return count;
  }

  void logout() {
    userService.clearUser();
    Get.offAllNamed(RouteLinks.login);
  }
}
