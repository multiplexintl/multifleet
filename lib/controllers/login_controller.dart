import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multifleet/repo/login_repo.dart';
import 'package:multifleet/widgets/custom_snackbar.dart';
import 'package:multifleet/widgets/custom_widgets.dart';

import '../routes.dart';
import '../services/user_service.dart';
import 'loading_controller.dart';

class LoginController extends GetxController {
  final empController = TextEditingController();
  final pwdController = TextEditingController();
  var loadingCon = Get.find<LoadingController>();
  var isPwdVisible = false.obs;

  // @override
  // void onInit() {
  //   // TODO: implement onInit
  //   super.onInit();
  // }

  void togglePwdVisibilty() async {
    isPwdVisible.toggle();
  }

  Future<void> login() async {
    try {
      loadingCon.startLoading();
      var res = await LoginRepo()
          .getEmployee(empCode: empController.text, pwd: pwdController.text);
      res.fold((error) {
        CustomSnackbar.show(
          title: "Error!!",
          message: error,
          backgroundColor: Colors.red,
        );
      }, (emp) {
        if (emp.status == 'Active') {
          final userService = Get.find<UserService>();
          userService.saveUser(emp);
          Get.offNamed(RouteLinks.home);
        } else {
          CustomSnackbar.show(
            title: "User Not Active!!",
            message: "This user is not active, please contact IT",
            backgroundColor: Colors.red,
          );
        }
      });
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
