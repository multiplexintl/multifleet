import 'package:get/get.dart';
import '../routes.dart';
import '../services/user_service.dart';

class SplashController extends GetxController {
  var isLoading = false.obs;

  @override
  void onInit() async {
    super.onInit();
    await Future.delayed(Duration(seconds: 3));

    // Only navigate if we're actually at the splash screen
    if (Get.currentRoute == RouteLinks.splash) {
      final userService = Get.find<UserService>();
      final nextRoute =
          userService.isLoggedIn ? RouteLinks.home : RouteLinks.login;
      Get.offAllNamed(nextRoute);
    }
  }
}
