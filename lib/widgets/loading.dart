import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/loading_controller.dart';

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final LoadingController loadingController;

  const LoadingOverlay(
      {super.key, required this.child, required this.loadingController});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Stack(
          children: [
            child,
            if (loadingController.isLoading)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black45,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading...',
                          style: Get.textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ));
  }
}
