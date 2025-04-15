import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multifleet/bindings/home_bindings.dart';
import 'package:multifleet/bindings/vehicle_binding.dart';
import 'package:multifleet/views/header/dashboard.dart';
import 'middleware/auth_middleware.dart';

import 'views/home_screen.dart';
import 'views/login_screen.dart';
import 'views/splash_screen.dart';

class RouteGenerator {
  // Common transition settings
  static const Transition _transition = Transition.cupertino;
  static const Curve _curve = Curves.easeIn;
  static const Duration _duration = Duration(milliseconds: 1000);
  static const bool _fullscreenDialog = false;
  static const bool _popGesture = false;

  // Helper function to create GetPage with optional middleware
  static GetPage _createPage(String route, Widget Function() page,
      {List<GetMiddleware>? middlewares, List<Bindings> bindings = const []}) {
    return GetPage(
        name: route,
        page: page,
        transition: _transition,
        curve: _curve,
        fullscreenDialog: _fullscreenDialog,
        popGesture: _popGesture,
        transitionDuration: _duration,
        middlewares: middlewares,
        bindings: bindings);
  }

  // List of app routes
  static final list = [
    _createPage(RouteLinks.splash, () => const SplashScreen()),
    _createPage(RouteLinks.login, () => const LoginScreen()),
    _createPage(
      RouteLinks.home,
      () => const HomeScreen(),
      middlewares: [AuthMiddleware()],
      bindings: [
        HomeScreenBinding(),
        VehicleListingBinding(),
      ],
    ),
    _createPage(
      RouteLinks.dashboard,
      () => const DashboardPage(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}

// Route Names (Centralized)
class RouteLinks {
  static const String splash = "/splash";
  static const String login = "/login";
  static const String home = "/home";
  static const String dashboard = "/dashboard";
}
