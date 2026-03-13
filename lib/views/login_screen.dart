import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multifleet/controllers/loading_controller.dart';
import 'package:multifleet/controllers/login_controller.dart';
import 'package:multifleet/theme/app_theme.dart';
import 'package:multifleet/widgets/loading.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    final loadingController = Get.find<LoadingController>();
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;

    return Scaffold(
      body: LoadingOverlay(
        loadingController: loadingController,
        child: isWide
            ? _buildWideLayout(context, controller)
            : _buildNarrowLayout(context, controller),
      ),
    );
  }

  // ==================== WIDE LAYOUT (Desktop/Tablet) ====================

  Widget _buildWideLayout(BuildContext context, LoginController controller) {
    return Row(
      children: [
        // Left side - Branding
        Expanded(
          flex: 5,
          child: _buildBrandingSide(),
        ),

        // Right side - Login form
        Expanded(
          flex: 4,
          child: _buildLoginFormSide(context, controller),
        ),
      ],
    );
  }

  Widget _buildBrandingSide() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryDark,
            AppColors.primaryLight,
            const Color(0xFF0F766E),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Background decorations
          _buildBrandingDecorations(),

          // Content
          Padding(
            padding: const EdgeInsets.all(48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: AppRadius.borderMd,
                      ),
                      child: Icon(
                        Icons.directions_car_rounded,
                        color: AppColors.accentLight,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Text(
                      'MultiFleet',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Main heading
                const Text(
                  'Fleet Management\nMade Simple',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'Manage your vehicles, track maintenance, handle documents, '
                  'and keep your fleet running smoothly - all in one place.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 40),

                // Feature highlights
                _buildFeatureItem(
                    Icons.directions_car_outlined, 'Vehicle Tracking'),
                const SizedBox(height: 16),
                _buildFeatureItem(
                    Icons.description_outlined, 'Document Management'),
                const SizedBox(height: 16),
                _buildFeatureItem(
                    Icons.build_outlined, 'Maintenance Scheduling'),
                const SizedBox(height: 16),
                _buildFeatureItem(
                    Icons.analytics_outlined, 'Reports & Analytics'),

                const Spacer(),

                // Footer
                Text(
                  '© 2026 MultiFleet • Version 1.0.0',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandingDecorations() {
    return Stack(
      children: [
        Positioned(
          top: -80,
          right: -80,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent.withOpacity(0.1),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentLight.withOpacity(0.05),
            ),
          ),
        ),
        Positioned(
          top: 200,
          right: 100,
          child: Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent.withOpacity(0.4),
            ),
          ),
        ),
        Positioned(
          bottom: 250,
          left: 80,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentLight.withOpacity(0.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.2),
            borderRadius: AppRadius.borderSm,
          ),
          child: Icon(icon, color: AppColors.accentLight, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginFormSide(BuildContext context, LoginController controller) {
    return Container(
      color: AppColors.surface,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(48),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: _buildLoginForm(context, controller),
          ),
        ),
      ),
    );
  }

  // ==================== NARROW LAYOUT (Mobile) ====================

  Widget _buildNarrowLayout(BuildContext context, LoginController controller) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryDark,
            AppColors.primaryLight,
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Logo section
              _buildMobileLogo(),

              const SizedBox(height: 40),

              // Login card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: AppRadius.borderXl,
                  boxShadow: AppShadows.lg,
                ),
                child: _buildLoginForm(context, controller),
              ),

              const SizedBox(height: 32),

              // Footer
              Text(
                '© 2026 MultiFleet • Version 1.0.0',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLogo() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.directions_car_rounded,
            size: 40,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'MultiFleet',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Vehicle Management System',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // ==================== LOGIN FORM ====================

  Widget _buildLoginForm(BuildContext context, LoginController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Text(
          'Welcome back',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to continue managing your fleet',
          style: TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: 32),

        // Employee ID Field
        _buildFieldLabel('Employee ID'),
        const SizedBox(height: 8),
        _buildEmployeeIdField(controller),

        const SizedBox(height: 20),

        // Password Field
        _buildFieldLabel('Password'),
        const SizedBox(height: 8),
        _buildPasswordField(controller),

        const SizedBox(height: 12),

        // Forgot Password
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              // TODO: Implement forgot password
              _showForgotPasswordDialog();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accent,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            child: const Text(
              'Forgot Password?',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Login Button
        _buildLoginButton(controller),

        const SizedBox(height: 16),

        // Clear Button
        _buildClearButton(controller),

        const SizedBox(height: 24),

        // Divider with text
        _buildDivider(),

        const SizedBox(height: 24),

        // Help text
        Center(
          child: Text(
            'Need help? IT Support',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildEmployeeIdField(LoginController controller) {
    return TextField(
      controller: controller.empController,
      textCapitalization: TextCapitalization.characters,
      onChanged: (value) {
        controller.empController.value =
            controller.empController.value.copyWith(
          text: value.toUpperCase(),
          selection: TextSelection.collapsed(offset: value.length),
        );
      },
      style: AppTextStyles.body,
      decoration: InputDecoration(
        hintText: 'Enter your employee ID',
        hintStyle: TextStyle(color: AppColors.textMuted),
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: AppRadius.borderSm,
          ),
          child: Icon(
            Icons.badge_outlined,
            color: AppColors.accent,
            size: 18,
          ),
        ),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(color: AppColors.accent, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildPasswordField(LoginController controller) {
    return Obx(() => TextField(
          controller: controller.pwdController,
          obscureText: !controller.isPwdVisible.value,
          onSubmitted: (_) => controller.login(),
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: 'Enter your password',
            hintStyle: TextStyle(color: AppColors.textMuted),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: AppRadius.borderSm,
              ),
              child: Icon(
                Icons.lock_outline,
                color: AppColors.accent,
                size: 18,
              ),
            ),
            suffixIcon: IconButton(
              onPressed: controller.togglePwdVisibilty,
              icon: Icon(
                controller.isPwdVisible.value
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textMuted,
                size: 20,
              ),
            ),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: BorderSide(color: AppColors.accent, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ));
  }

  Widget _buildLoginButton(LoginController controller) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: controller.login,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: AppColors.accent.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderMd,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Sign In',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildClearButton(LoginController controller) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: () {
          controller.empController.clear();
          controller.pwdController.clear();
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          side: BorderSide(color: AppColors.divider),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderMd,
          ),
        ),
        child: const Text(
          'Clear Fields',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.divider)),
      ],
    );
  }

  void _showForgotPasswordDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_reset_rounded,
                  color: AppColors.accent,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Reset Password',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'Please contact your administrator to reset your password.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),

              // Contact Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.borderMd,
                ),
                child: Row(
                  children: [
                    Icon(Icons.email_outlined,
                        color: AppColors.accent, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'itsupport@multiplex.ae',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.borderMd,
                    ),
                  ),
                  child: const Text('Got it'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:multifleet/controllers/loading_controller.dart';
// import 'package:multifleet/controllers/login_controller.dart';

// import 'package:multifleet/widgets/loading.dart';

// class LoginScreen extends StatelessWidget {
//   const LoginScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     var con = Get.put(LoginController());
//     var loadingCon = Get.find<LoadingController>();
//     return Scaffold(
//       body: LoadingOverlay(
//         loadingController: loadingCon,
//         child: Center(
//           child: LayoutBuilder(
//             builder: (context, constraints) {
//               // Determine responsive width based on screen size
//               double cardWidth =
//                   constraints.maxWidth > 600 ? 400 : constraints.maxWidth * 0.9;

//               return Card(
//                 elevation: 8,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Container(
//                   width: cardWidth,
//                   padding: const EdgeInsets.all(24),
//                   child: SingleChildScrollView(
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         // App Logo or Title
//                         Center(
//                           child: Text(
//                             'Login',
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .headlineMedium
//                                 ?.copyWith(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.blue[800],
//                                 ),
//                           ),
//                         ),
//                         const SizedBox(height: 24),

//                         // Employee ID TextField
//                         TextField(
//                           controller: con.empController,
//                           onChanged: (value) {
//                             con.empController.value =
//                                 con.empController.value.copyWith(
//                               text: value.toUpperCase(),
//                               selection:
//                                   TextSelection.collapsed(offset: value.length),
//                             );
//                           },
//                           decoration: InputDecoration(
//                             labelText: 'Employee ID',
//                             prefixIcon: Icon(Icons.badge_outlined,
//                                 color: Colors.blue[700]),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 16),

//                         // Password TextField
//                         Obx(() => TextField(
//                               controller: con.pwdController,
//                               obscureText: !con.isPwdVisible.value,
//                               onSubmitted: (value) {
//                                 con.login();
//                               },
//                               decoration: InputDecoration(
//                                 labelText: 'Password',
//                                 prefixIcon: Icon(Icons.lock_outline,
//                                     color: Colors.blue[700]),
//                                 suffixIcon: IconButton(
//                                   icon: Icon(
//                                       con.isPwdVisible.value
//                                           ? Icons.visibility
//                                           : Icons.visibility_off,
//                                       color: Colors.blue[700]),
//                                   onPressed: () {
//                                     con.togglePwdVisibilty();
//                                   },
//                                 ),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                               ),
//                             )),
//                         const SizedBox(height: 8),

//                         // Forgot Password
//                         Align(
//                           alignment: Alignment.centerRight,
//                           child: TextButton(
//                             onPressed: () {
//                               // Implement forgot password navigation
//                             },
//                             child: Text(
//                               'Forgot Password?',
//                               style: TextStyle(color: Colors.blue[700]),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 16),

//                         // Login and Clear Buttons
//                         Row(
//                           children: [
//                             Expanded(
//                               child: ElevatedButton(
//                                 onPressed: () {
//                                   con.login();
//                                 },
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.blue[800],
//                                   padding:
//                                       const EdgeInsets.symmetric(vertical: 16),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                 ),
//                                 child: const Text(
//                                   'Login',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 16),
//                             Expanded(
//                               child: OutlinedButton(
//                                 onPressed: () {
//                                   // Implement clear fields logic
//                                 },
//                                 style: OutlinedButton.styleFrom(
//                                   foregroundColor: Colors.blue[800],
//                                   padding:
//                                       const EdgeInsets.symmetric(vertical: 16),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   side: BorderSide(color: Colors.blue[800]!),
//                                 ),
//                                 child: const Text(
//                                   'Clear',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
