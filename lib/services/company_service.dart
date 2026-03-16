import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:multifleet/models/company.dart';
import 'package:multifleet/repo/retry_helper.dart';
import 'package:multifleet/widgets/custom_widgets.dart';

abstract class CompanyAwareController {
  Future<void> onCompanyChanged(Company newCompany);
}

class CompanyService extends GetxService {
  final _storage = GetStorage();
  final Rx<Company?> _selectedCompany = Rx<Company?>(null);

  /// Reactive list of companies — populated from API (with storage fallback).
  final RxList<Company> companies = <Company>[].obs;

  /// True once the initial company has been resolved (from API or cache).
  /// Controllers can await this before making company-scoped API calls.
  final isReady = false.obs;

  // Registry for controllers that need to respond to company changes
  final List<CompanyAwareController> _registeredControllers = [];

  // Getters for the selected company
  Company? get selectedCompany => _selectedCompany.value;
  Rx<Company?> get selectedCompanyObs => _selectedCompany;

  // Getter for the companies list (kept for backwards compatibility)
  List<Company> get companyList => companies;

  @override
  void onInit() {
    super.onInit();
    fetchCompanies();
  }

  /// Fetches companies from API, caches to storage, then restores selected
  /// company. Falls back to storage-cached list if the API call fails.
  Future<void> fetchCompanies() async {
    final result = await getCompanyMaster();
    result.fold(
      (error) {
        log('CompanyService: API failed ($error), loading from storage');
        _loadCompaniesFromStorage();
      },
      (fetched) {
        if (fetched.isNotEmpty) {
          companies.assignAll(fetched);
          _saveCompaniesToStorage(fetched);
        } else {
          _loadCompaniesFromStorage();
        }
        _restoreSelectedCompany();
      },
    );
  }

  // ── Storage helpers ──────────────────────────────────────────────────────

  void _saveCompaniesToStorage(List<Company> list) {
    try {
      final encoded = jsonEncode(list.map((c) => c.toJson()).toList());
      _storage.write('cachedCompanies', encoded);
    } catch (e) {
      log('CompanyService: failed to cache companies: $e');
    }
  }

  void _loadCompaniesFromStorage() {
    try {
      final raw = _storage.read<String>('cachedCompanies');
      if (raw != null) {
        final List<dynamic> decoded = jsonDecode(raw);
        companies.assignAll(
          decoded
              .map((e) => Company.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
      }
    } catch (e) {
      log('CompanyService: failed to restore cached companies: $e');
    }
    _restoreSelectedCompany();
  }

  void _restoreSelectedCompany() {
    if (companies.isEmpty) return;
    final companyId = _storage.read<String>('selectedCompanyId');
    if (companyId != null) {
      final found = companies.firstWhereOrNull((c) => c.id == companyId);
      _selectedCompany.value = found ?? companies.first;
    } else {
      _selectedCompany.value = companies.first;
    }
    // Notify all already-registered controllers that a company is now available.
    // This fires after a browser refresh when the company is restored from
    // storage/API before individual page controllers have registered.
    isReady.value = true;
    final company = _selectedCompany.value;
    if (company != null) {
      for (final controller in List.of(_registeredControllers)) {
        controller.onCompanyChanged(company);
      }
    }
  }

  // ── Public API ───────────────────────────────────────────────────────────

  // Register a controller to receive company change notifications
  void registerController(CompanyAwareController controller) {
    if (!_registeredControllers.contains(controller)) {
      _registeredControllers.add(controller);
      if (_selectedCompany.value != null) {
        controller.onCompanyChanged(_selectedCompany.value!);
      }
    }
  }

  // Unregister a controller when it's disposed
  void unregisterController(CompanyAwareController controller) {
    _registeredControllers.remove(controller);
  }

  // Select a new company and notify all registered controllers
  Future<void> selectCompany(Company company) async {
    if (_selectedCompany.value?.id != company.id) {
      _selectedCompany.value = company;
      await _storage.write('selectedCompanyId', company.id);
      await _storage.save(); // Force flush (critical for web)

      for (var controller in _registeredControllers) {
        controller.onCompanyChanged(company);
      }

      CustomWidget.customSnackBar(
        title: "Company Changed",
        message: 'Company changed to ${company.name}',
        isError: false,
        isInfo: true,
        duration: 2,
      );
    }
  }

  // Get company name by id
  String getCompanyNameById(String id) {
    return companies.firstWhereOrNull((c) => c.id == id)?.name ?? '';
  }

  Future<void> clearSelectedCompany() async {
    _selectedCompany.value = null;
    await _storage.remove('selectedCompanyId');
    await _storage.save(); // Force flush (critical for web)
  }

  // ── API ──────────────────────────────────────────────────────────────────

  Future<Either<String, List<Company>>> getCompanyMaster() async {
    final String uri = GlobalConfiguration().getValue('api_base_url');
    return await RetryHelper.retry<Either<String, List<Company>>>(
      apiCall: () async {
        final Uri url = Uri.parse('${uri}Master/GetCompanyMaster');
        final client = http.Client();
        log(url.toString());
        final response = await client.get(url);
        log("Response Code: ${response.statusCode}");

        if (response.statusCode == 200) {
          List<dynamic> responseBody = jsonDecode(response.body);
          var result =
              responseBody.map((element) => Company.fromJson(element)).toList();
          return Right(result);
        } else {
          return Left(response.body);
        }
      },
      defaultValue: const Left("Retry failed"),
      maxRetries: 3,
      shouldRetry: (result) =>
          result.fold((l) => l == "Retry failed", (_) => false),
    );
  }
}
