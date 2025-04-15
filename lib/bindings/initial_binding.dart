import 'package:get/get.dart';

import '../services/user_service.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(UserService(), permanent: true);
    // Other global dependencies
  }
}
