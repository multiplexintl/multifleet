import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/company.dart';
import '../models/user.dart';
import '../services/company_service.dart';
import '../services/user_service.dart';

/// ============================================================
/// USER CONTROLLER
/// ============================================================
/// Manages current user state with company awareness.

class UserController extends GetxController implements CompanyAwareController {
  // Services
  late final UserService _userService;
  late final CompanyService _companyService;

  // State
  final _user = Rxn<User>();
  final isLoading = false.obs;
  final isChangingPassword = false.obs;
  final passwordChangeError = ''.obs;

  // Getters
  User? get user => _user.value;
  Rx<User?> get userObs => _user;
  bool get isLoggedIn => _user.value != null;

  String get company => _user.value?.company ?? '';
  String get empNo => _user.value?.empNo ?? '';
  String get empName => _user.value?.empName ?? '';
  String get status => _user.value?.status ?? '';

  /// User initials for avatar
  String get initials {
    final name = empName;
    if (name.isEmpty) return '?';

    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  /// Avatar color based on name hash
  Color get avatarColor {
    final name = empName;
    const colors = [
      Color(0xFF3B82F6), // Blue
      Color(0xFF10B981), // Emerald
      Color(0xFF8B5CF6), // Purple
      Color(0xFFEC4899), // Pink
      Color(0xFFF59E0B), // Amber
      Color(0xFF14B8A6), // Teal
      Color(0xFFEF4444), // Red
      Color(0xFF6366F1), // Indigo
    ];

    if (name.isEmpty) return colors[0];
    return colors[name.hashCode.abs() % colors.length];
  }

  /// Status color for badge
  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF22C55E);
      case 'inactive':
        return const Color(0xFFEF4444);
      case 'pending':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF64748B);
    }
  }

  // ==================== LIFECYCLE ====================

  @override
  void onInit() {
    super.onInit();

    // Get services
    _userService = Get.find<UserService>();
    _companyService = Get.find<CompanyService>();

    // Register for company changes
    _companyService.registerController(this);

    // Load user from service
    _loadUser();

    // Listen to user changes from service
    ever(_userService.userObs, (user) {
      _user.value = user;
    });
  }

  @override
  void onClose() {
    _companyService.unregisterController(this);
    super.onClose();
  }

  // ==================== COMPANY AWARENESS ====================

  @override
  Future<void> onCompanyChanged(Company newCompany) async {
    log('UserController: Company changed to ${newCompany.id}');
    // Optionally reload user data if it's company-specific
    // For now, user data is not company-specific, so we just log
  }

  // ==================== USER OPERATIONS ====================

  void _loadUser() {
    _user.value = _userService.user;
  }

  /// Refresh user data from storage
  void refreshUser() {
    _loadUser();
  }

  /// Update user in service and storage
  Future<void> updateUser(User user) async {
    await _userService.saveUser(user);
    _user.value = user;
  }

  /// Clear user (logout)
  Future<void> clearUser() async {
    await _userService.clearUser();
    _user.value = null;
  }

  // ==================== PASSWORD CHANGE ====================

  /// Change user password
  /// Returns true if successful
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    passwordChangeError.value = '';

    // Validation
    if (currentPassword.isEmpty) {
      passwordChangeError.value = 'Current password is required';
      return false;
    }

    if (newPassword.isEmpty) {
      passwordChangeError.value = 'New password is required';
      return false;
    }

    if (newPassword.length < 6) {
      passwordChangeError.value = 'Password must be at least 6 characters';
      return false;
    }

    if (newPassword != confirmPassword) {
      passwordChangeError.value = 'Passwords do not match';
      return false;
    }

    if (currentPassword == newPassword) {
      passwordChangeError.value = 'New password must be different from current';
      return false;
    }

    isChangingPassword.value = true;

    try {
      // TODO: Call your API to change password
      // final result = await AuthRepo().changePassword(
      //   company: company,
      //   empNo: empNo,
      //   currentPassword: currentPassword,
      //   newPassword: newPassword,
      // );
      //
      // return result.fold(
      //   (error) {
      //     passwordChangeError.value = error;
      //     return false;
      //   },
      //   (success) {
      //     CustomWidget.customSnackBar(
      //       isError: false,
      //       title: 'Success',
      //       message: 'Password changed successfully',
      //     );
      //     return true;
      //   },
      // );

      // Mock implementation - remove when API is ready
      await Future.delayed(const Duration(seconds: 1));

      log('Password change requested for user: $empNo');
      return true;
    } catch (e) {
      log('Password change error: $e');
      passwordChangeError.value =
          'Failed to change password. Please try again.';
      return false;
    } finally {
      isChangingPassword.value = false;
    }
  }

  /// Clear password change error
  void clearPasswordError() {
    passwordChangeError.value = '';
  }
}
