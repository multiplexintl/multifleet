import 'dart:developer';

import 'package:get/get.dart';
import 'package:multifleet/models/employee.dart';
import 'package:multifleet/models/fine_type/fine_type.dart';
import 'package:multifleet/models/maintenance_master.dart';
import 'package:multifleet/models/vendor.dart';
import 'package:multifleet/repo/employee_repo.dart';
import 'package:multifleet/services/company_service.dart';

import '../models/city/city.dart';
import '../models/company.dart';
import '../models/doc_master.dart';
import '../models/fuel_station/fuel_station.dart';
import '../models/status_master/status_master.dart';
import '../models/vehicle_docs.dart';
import '../repo/city_repo.dart';
import '../repo/general_master_repo.dart';
import '../repo/maintenance_repo.dart';
import '../repo/vehicles_repo.dart';
import '../repo/vendor_repo.dart';

class GeneralMastersController extends GetxController
    implements CompanyAwareController {
  final companyService = Get.find<CompanyService>();

  // masters for Vehicle Status, Fine Status, Vehicle Assignment Status, Vehicle Type Master, Vehicle Condition Master
  final vehicleStatusMasters = <StatusMaster>[].obs;
  final fineStatusMasters = <StatusMaster>[].obs;
  final fineTypeMasters = <FineType>[].obs;
  final vehicleAssignmentStatusMasters = <StatusMaster>[].obs;
  final vehicleTypeMasters = <StatusMaster>[].obs;
  final vehicleConditionMasters = <StatusMaster>[].obs;
  final mainteneceMasters = <MaintenanceMaster>[].obs;
  final tirePositionMaster = <StatusMaster>[].obs;
  final RxList<Employee> allEmployees = <Employee>[].obs;
  final RxList<String> designations = <String>[].obs;
  final RxList<Employee> companyEmployees = <Employee>[].obs;
  final RxList<Vendor?> companyVendors = <Vendor>[].obs;
  final RxList<FuelStation> availableFuelStations = <FuelStation>[].obs;
  final RxList<VehicleDocument> companyVehicleDocuments =
      <VehicleDocument>[].obs;
  final RxList<DocumentMaster> companyDocumentTypes = <DocumentMaster>[].obs;
  final RxList<City> companyCity = <City>[].obs;

  // repo
  final generalMasterRepo = GeneralMasterRepo();
  final employeeRepo = EmployeeRepo();
  final vendorRepo = VendorRepo();
  final maintenanceRepo = MaintenanceRepo();
  final vehiclesRepo = VehiclesRepo();
  final cityRepo = CityRepo();

  // loading states
  final isLoading = false.obs;
  @override
  Future<void> onCompanyChanged(Company newCompany) async {
    await Future.wait([
      fetchEmployeesByCompany(newCompany.id ?? ''),
      fetchVendorsByCompany(newCompany.id ?? ''),
      fetchCompanyFuelStations(newCompany.id ?? ''),
      fetchCompanyDocumentTypes(newCompany.id ?? ''),
      fetchCities(newCompany.id ?? ''),
      fetchFineTypeMasters(newCompany.id ?? ''),
    ]);
  }

  @override
  void onInit() {
    super.onInit();
    // Fetch global masters (no company ID required) immediately.
    _fetchGlobalMasters();
    // Register for company changes. If company is already resolved (normal
    // navigation), registerController fires onCompanyChanged right away.
    // On browser refresh the company isn't set yet — CompanyService will call
    // onCompanyChanged once the company is restored from API/storage.
    companyService.registerController(this);
  }

  /// Masters that require no company ID — safe to fetch on startup.
  Future<void> _fetchGlobalMasters() async {
    await Future.wait([
      fetchVehicleStatusMasters(),
      fetchFineStatusMasters(),
      fetchVehicleAssignmentStatusMasters(),
      fetchVehicleTypeMasters(),
      fetchVehicleConditionMasters(),
      fetchAllEmployees(),
      fetchMaintenanceTypes(),
      fetchTirePositionMaster(),
    ]);
    populateDesignations();
  }

  // Comprehensive refresh — call manually when needed
  Future<void> fetchAllMasters() async {
    final companyId = companyService.selectedCompanyObs.value?.id ?? '';
    await Future.wait([
      fetchVehicleStatusMasters(),
      fetchFineStatusMasters(),
      fetchVehicleAssignmentStatusMasters(),
      fetchVehicleTypeMasters(),
      fetchVehicleConditionMasters(),
      fetchAllEmployees(),
      fetchMaintenanceTypes(),
      fetchTirePositionMaster(),
      if (companyId.isNotEmpty) ...[
        fetchEmployeesByCompany(companyId),
        fetchVendorsByCompany(companyId),
        fetchCompanyFuelStations(companyId),
        fetchCompanyDocumentTypes(companyId),
        fetchCities(companyId),
        fetchFineTypeMasters(companyId),
      ],
    ]);
    populateDesignations();
  }

  // function to fetch and vehicle master status
  Future<void> fetchVehicleStatusMasters() async {
    isLoading.value = true;
    vehicleStatusMasters.clear();
    try {
      var res = await generalMasterRepo.getVehicleStatusMaster();
      res.fold(
        (error) {
          log(error);
        },
        (data) {
          vehicleStatusMasters.addAll(data);
        },
      );
    } catch (e) {
      isLoading.value = false;
      log(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // function to fetch and fine master status
  Future<void> fetchFineStatusMasters() async {
    isLoading.value = true;
    fineStatusMasters.clear();
    try {
      var res = await generalMasterRepo.getFineStatusMaster();
      res.fold(
        (error) {
          log(error);
        },
        (data) {
          fineStatusMasters.addAll(data);
        },
      );
    } catch (e) {
      isLoading.value = false;
      log(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // function to fetch and fine type master
  Future<void> fetchFineTypeMasters(String company) async {
    isLoading.value = true;
    fineTypeMasters.clear();
    try {
      var res = await generalMasterRepo.getFineTypeMaster(company: company);
      res.fold(
        (error) {
          log(error);
        },
        (data) {
          fineTypeMasters.addAll(data);
        },
      );
      log(fineTypeMasters.toString());
    } catch (e) {
      isLoading.value = false;
      log(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // function to fetch and vehicle assignment status master
  Future<void> fetchVehicleAssignmentStatusMasters() async {
    isLoading.value = true;
    vehicleAssignmentStatusMasters.clear();
    try {
      var res = await generalMasterRepo.getVehicleAssignmentStatusMaster();
      res.fold(
        (error) {
          log(error);
        },
        (data) {
          vehicleAssignmentStatusMasters.addAll(data);
        },
      );
    } catch (e) {
      isLoading.value = false;
      log(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // function to fetch and vehicle type master
  Future<void> fetchVehicleTypeMasters() async {
    isLoading.value = true;
    vehicleTypeMasters.clear();
    try {
      var res = await generalMasterRepo.getVehicleTypeStatusMaster();
      res.fold(
        (error) {
          log(error);
        },
        (data) {
          vehicleTypeMasters.addAll(data);
        },
      );
    } catch (e) {
      isLoading.value = false;
      log(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // fetch and vehicle condition master
  Future<void> fetchVehicleConditionMasters() async {
    isLoading.value = true;
    vehicleConditionMasters.clear();
    try {
      var res = await generalMasterRepo.getVehicleConditionStatusMaster();
      res.fold(
        (error) {
          log(error);
        },
        (data) {
          vehicleConditionMasters.addAll(data);
        },
      );
    } catch (e) {
      isLoading.value = false;
      log(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // fetch all employees
  Future<void> fetchAllEmployees() async {
    isLoading.value = true;
    allEmployees.clear();
    try {
      var res = await employeeRepo.getAllEmployees();
      res.fold(
        (error) {
          log(error);
        },
        (data) {
          allEmployees.addAll(data);
        },
      );
    } catch (e) {
      isLoading.value = false;
      log(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // fetch employees by company
  Future<void> fetchEmployeesByCompany(String company) async {
    isLoading.value = true;
    companyEmployees.clear();
    try {
      var res = await employeeRepo.getAllEmployeesByCompany(company: company);
      res.fold(
        (error) {
          log(error);
        },
        (data) {
          companyEmployees.addAll(data);
        },
      );
    } catch (e) {
      isLoading.value = false;
      log(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // populate designations
  void populateDesignations() {
    designations.value = allEmployees
        .map((e) => e.designation)
        .whereType<String>()
        .toSet()
        .toList();
    log(designations.toString());
  }

  // fetch vendors by company
  Future<void> fetchVendorsByCompany(String company) async {
    isLoading.value = true;
    companyVendors.clear();
    try {
      var res = await vendorRepo.getVendorMaster(company: company);
      res.fold(
        (error) {
          log(error);
        },
        (data) {
          companyVendors.value = data;
        },
      );
    } catch (e) {
      log(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // fectch maintenance types
  Future<void> fetchMaintenanceTypes() async {
    isLoading.value = true;
    mainteneceMasters.clear();
    try {
      var res = await maintenanceRepo.getAllMaintenanceTypes();
      res.fold(
        (error) {
          log(error);
        },
        (data) {
          mainteneceMasters.addAll(data);
        },
      );
    } catch (e) {
      isLoading.value = false;
      log(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // load fuels Stations from API
  Future<void> fetchCompanyFuelStations(String company) async {
    availableFuelStations.clear();
    try {
      final response = await vehiclesRepo.getFuelStation(company: company);

      response.fold((error) {
        log(error);
      }, (docs) {
        availableFuelStations.value = docs;
        log(availableFuelStations.toString());
      });
    } catch (e) {
      log('Error loading document types: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Load document types from API
  Future<void> fetchCompanyDocumentTypes(String company) async {
    companyDocumentTypes.clear();
    try {
      // Replace with your API call
      final response =
          await vehiclesRepo.getAllVehicleDocumentMaster(company: company);

      response.fold((error) {
        log(error);
      }, (docs) {
        companyDocumentTypes.value = docs;
        log(companyDocumentTypes.toString());
      });
    } catch (e) {
      log('Error loading document types: $e');
    }
  }

// Get document type description for display
  String? getDocumentTypeDescription(int? docTypeId) {
    if (docTypeId == null) return null;

    final docType = companyDocumentTypes.firstWhere(
      (doc) => doc.docType == docTypeId,
      orElse: () => DocumentMaster(),
    );

    return docType.docDescription;
  }

  // fetch city from API
  Future<void> fetchCities(String company) async {
    companyCity.clear();
    try {
      final response = await cityRepo.getCityMaster(company: company);

      response.fold((error) {
        log(error);
      }, (docs) {
        companyCity.value = docs;
        log(companyCity.toString());
      });
    } catch (e) {
      log('Error loading document types: $e');
    }
  }

  // fetch tire postion master
  Future<void> fetchTirePositionMaster() async {
    isLoading.value = true;
    try {
      var res = await generalMasterRepo.getVehicleTirePositionMaster();
      res.fold(
        (error) {
          log(error);
        },
        (data) {
          tirePositionMaster.addAll(data);
          log(tirePositionMaster.toString());
        },
      );
    } catch (e) {
      isLoading.value = false;
      log(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
