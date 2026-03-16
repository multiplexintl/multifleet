import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../models/user.dart';

class UserService extends GetxService {
  final _storage = GetStorage();
  final Rx<User?> _user = Rx<User?>(null);

  User? get user => _user.value;
  Rx<User?> get userObs => _user;

  @override
  void onInit() {
    super.onInit();
    // Try to load user from storage when service initializes
    _loadUserFromStorage();
  }

  void _loadUserFromStorage() {
    final userData = _storage.read('user');
    if (userData != null) {
      _user.value =
          User.fromJson(userData); // Convert stored JSON to User object
    }
  }

  Future<void> saveUser(User user) async {
    _user.value = user;
    await _storage.write('user', user.toJson());
    await _storage
        .save(); // Force flush to persistent storage (critical for web)
  }

  Future<void> clearUser() async {
    _user.value = null;
    await _storage.remove('user');
    await _storage.save();
  }

  bool get isLoggedIn => user != null;
}
