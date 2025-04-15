import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multifleet/controllers/loading_controller.dart';
import 'package:multifleet/controllers/login_controller.dart';
import 'package:multifleet/routes.dart';
import 'package:multifleet/widgets/custom_widgets.dart';

import 'package:multifleet/widgets/loading.dart';

import '../widgets/custom_snackbar.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var con = Get.put(LoginController());
    var loadingCon = Get.find<LoadingController>();
    return Scaffold(
      body: LoadingOverlay(
        loadingController: loadingCon,
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Determine responsive width based on screen size
              double cardWidth =
                  constraints.maxWidth > 600 ? 400 : constraints.maxWidth * 0.9;

              return Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  width: cardWidth,
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // App Logo or Title
                        Center(
                          child: Text(
                            'Login',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[800],
                                ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Employee ID TextField
                        TextField(
                          controller: con.empController,
                          onChanged: (value) {
                            con.empController.value =
                                con.empController.value.copyWith(
                              text: value.toUpperCase(),
                              selection:
                                  TextSelection.collapsed(offset: value.length),
                            );
                          },
                          decoration: InputDecoration(
                            labelText: 'Employee ID',
                            prefixIcon: Icon(Icons.badge_outlined,
                                color: Colors.blue[700]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Password TextField
                        Obx(() => TextField(
                              controller: con.pwdController,
                              obscureText: !con.isPwdVisible.value,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: Icon(Icons.lock_outline,
                                    color: Colors.blue[700]),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                      con.isPwdVisible.value
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.blue[700]),
                                  onPressed: () {
                                    con.togglePwdVisibilty();
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            )),
                        const SizedBox(height: 8),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // Implement forgot password navigation
                            },
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(color: Colors.blue[700]),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Login and Clear Buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  con.login();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[800],
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  // Implement clear fields logic
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.blue[800],
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: BorderSide(color: Colors.blue[800]!),
                                ),
                                child: const Text(
                                  'Clear',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
