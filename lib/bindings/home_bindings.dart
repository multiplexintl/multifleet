// homescreen_binding.dart
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeScreenBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeScreenController>(() => HomeScreenController());
  }
}
