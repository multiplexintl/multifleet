import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:multifleet/controllers/loading_controller.dart';

import 'bindings/initial_binding.dart';
import 'controllers/splash_controller.dart';
import 'routes.dart';
import 'services/system_preference_service.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalConfiguration().loadFromAsset("config");
  await GetStorage.init();
  // Initialize theme service
  await Get.putAsync(() => ThemeService().init());
  await Get.putAsync(() => SystemPreferencesService().init());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService.to;

    return Obx(() {
      return GetMaterialApp(
        initialBinding: InitialBindings(),
        builder: (context, child) {
          Get.put(LoadingController());
          Get.put(SplashController());
          return child!;
        },
        title: 'MultiFleet',
        initialRoute: RouteLinks.splash,
        getPages: RouteGenerator.list,
        debugShowCheckedModeBanner: false,
        theme: themeService.lightTheme,
        darkTheme: themeService.darkTheme,
        themeMode: themeService.themeMode,
      );
    });
  }
}
