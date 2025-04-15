// vehicle_listing_binding.dart
import 'package:get/get.dart';
import '../controllers/vehicle_listing_controller.dart';

class VehicleListingBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VehicleListingController>(() => VehicleListingController());
  }
}
