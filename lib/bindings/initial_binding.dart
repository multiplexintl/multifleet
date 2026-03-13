import 'package:get/get.dart';
import 'package:multifleet/controllers/dashboard_controller.dart';
import 'package:multifleet/controllers/user_controller.dart';
import 'package:multifleet/services/company_service.dart';

import '../controllers/general_masters.dart';
import '../services/user_service.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(UserService(), permanent: true);
    Get.put(CompanyService(), permanent: true);
    Get.lazyPut<UserController>(() => UserController());
    Get.put(GeneralMastersController(), permanent: true);
    Get.lazyPut<DashboardController>(() => DashboardController());
    // Other global dependencies
  }
}
