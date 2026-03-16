import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multifleet/repo/login_repo.dart';
import 'package:multifleet/widgets/custom_snackbar.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../routes.dart';
import '../models/user.dart';
import '../services/company_service.dart';
import '../services/user_service.dart';
import 'loading_controller.dart';

class LoginController extends GetxController {
  final empController = TextEditingController();
  final pwdController = TextEditingController();
  var loadingCon = Get.find<LoadingController>();
  var isPwdVisible = false.obs;
  final version = ''.obs;

  @override
  void onInit() {
    super.onInit();
    PackageInfo.fromPlatform().then((info) => version.value = info.version);
  }

  void togglePwdVisibilty() async {
    isPwdVisible.toggle();
  }

  Future<void> login() async {
    try {
      loadingCon.startLoading();
      var res = await LoginRepo()
          .getEmployee(empCode: empController.text, pwd: pwdController.text);
      String? error;
      User? emp;
      res.fold((l) => error = l, (r) => emp = r);
      if (error != null) {
        CustomSnackbar.show(
          title: "Error!!",
          message: error!,
          backgroundColor: Colors.red,
        );
      } else if (emp!.status == 'Active') {
        final userService = Get.find<UserService>();
        await userService.saveUser(emp!);

        // Set the user's company as the default selected company
        if (emp!.company != null) {
          final companyService = Get.find<CompanyService>();
          final userCompany = companyService.companies
              .firstWhereOrNull((c) => c.id == emp!.company);
          final target =
              userCompany ?? companyService.companies.firstOrNull;
          if (target != null) {
            await companyService.selectCompany(target);
          }
        }

        Get.offNamed(RouteLinks.home);
      } else {
        CustomSnackbar.show(
          title: "User Not Active!!",
          message: "This user is not active, please contact IT",
          backgroundColor: Colors.red,
        );
      }
    } on Exception catch (e) {
      CustomSnackbar.show(
        title: "Error!!",
        message: e.toString(),
        backgroundColor: Colors.red,
      );
    } finally {
      loadingCon.stopLoading();
    }
  }
}
