import 'package:get/get.dart';
import 'package:multifleet/services/company_service.dart';

import '../services/user_service.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(UserService(), permanent: true);
    Get.put(CompanyService(), permanent: true);
    // Other global dependencies
  }
}
