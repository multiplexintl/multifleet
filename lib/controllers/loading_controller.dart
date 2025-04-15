import 'package:get/get.dart';

class LoadingController extends GetxController {
  final RxBool _isLoading = false.obs;

  bool get isLoading => _isLoading.value;

  void startLoading() => _isLoading.value = true;
  void stopLoading() => _isLoading.value = false;
}
