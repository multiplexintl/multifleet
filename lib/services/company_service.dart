import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:multifleet/models/company.dart';
import 'package:multifleet/widgets/custom_widgets.dart';

abstract class CompanyAwareController {
  void onCompanyChanged(Company newCompany);
}

class CompanyService extends GetxService {
  final _storage = GetStorage();
  final Rx<Company?> _selectedCompany = Rx<Company?>(null);

  // Hard-coded list of companies
  final List<Company> companies = [
    Company(id: 'EPIC01', name: 'Multiplex International LLC'),
    Company(id: 'EPIC02', name: 'Exquisite LLC'),
    Company(id: 'EPIC03', name: 'Multiplex International LLC - Qatar'),
    Company(id: 'EPIC04', name: 'Multiplex International LLC - Oman'),
  ];

  // Registry for controllers that need to respond to company changes
  final List<CompanyAwareController> _registeredControllers = [];

  // Getters for the selected company
  Company? get selectedCompany => _selectedCompany.value;
  Rx<Company?> get selectedCompanyObs => _selectedCompany;

  // Getter for the companies list
  List<Company> get companyList => companies;

  @override
  void onInit() {
    super.onInit();
    _loadCompanyFromStorage();
  }

  void _loadCompanyFromStorage() {
    final companyId = _storage.read('selectedCompanyId');
    if (companyId != null) {
      // Find the company in our list by ID
      final foundCompany = companies.firstWhere(
        (company) => company.id == companyId,
        orElse: () => companies.first, // Default to first company if not found
      );
      _selectedCompany.value = foundCompany;
    } else if (companies.isNotEmpty) {
      // Default to first company if none selected
      _selectedCompany.value = companies.first;
    }
  }

  // Register a controller to receive company change notifications
  void registerController(CompanyAwareController controller) {
    if (!_registeredControllers.contains(controller)) {
      _registeredControllers.add(controller);

      // Immediately notify the controller of the current company
      // This helps when controllers are created after app startup
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
  void selectCompany(Company company) {
    if (_selectedCompany.value?.id != company.id) {
      // Update the selected company
      _selectedCompany.value = company;
      _storage.write('selectedCompanyId', company.id);

      // Notify all registered controllers about the change
      for (var controller in _registeredControllers) {
        controller.onCompanyChanged(company);
      }

      // Show a brief notification to the user
      CustomWidget.customSnackBar(
        title: "Company Changed",
        message: 'Company changed to ${company.name}',
        isError: false,
        isInfo: true,
        duration: 2,
      );
    }
  }

  void clearSelectedCompany() {
    _selectedCompany.value = null;
    _storage.remove('selectedCompanyId');
  }
}
