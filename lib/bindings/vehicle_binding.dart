// vehicle_listing_binding.dart
import 'package:get/get.dart';
import 'package:multifleet/controllers/add_edit_vehicle_controller.dart';
import 'package:multifleet/controllers/fine_controller.dart';
import 'package:multifleet/controllers/maintenance_controller.dart';
import '../controllers/vehicle_listing_controller.dart';

class VehicleListingBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VehicleListingController>(() => VehicleListingController());
    Get.lazyPut<AddEditVehicleController>(() => AddEditVehicleController());
    Get.lazyPut<FineController>(() => FineController());
    Get.lazyPut<MaintenanceController>(() => MaintenanceController());
  }
}
