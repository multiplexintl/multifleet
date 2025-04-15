// In a new file: middleware/auth_middleware.dart
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../services/user_service.dart';
import '../routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final userService = Get.find<UserService>();
    return userService.isLoggedIn
        ? null
        : RouteSettings(name: RouteLinks.login);
  }
}
