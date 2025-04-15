import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:multifleet/models/vehicle.dart';
import 'package:multifleet/repo/vehicles_repo.dart';
import 'package:multifleet/widgets/custom_widgets.dart';

import '../models/tire.dart';

// GetX Controller for vehicle management
class AddEditVehicleController extends GetxController {
  // final plateNumberController = TextEditingController(text: "11909-AA");
  // Text controllers for search and create vehicle
  final plateNumberController = TextEditingController(text: "11909-AA");
  final createPlateNumberController = TextEditingController();
  final createBrandController = TextEditingController();
  final createModelController = TextEditingController();
  final createChassisNumberController = TextEditingController();
  final createTrafficFileNumberController = TextEditingController();
  final createCompanyController = TextEditingController();

  // Additional text controllers that were previously in the extension
  final yearController = TextEditingController();
  final initialOdoController = TextEditingController();
  final currentOdoController = TextEditingController();
  final typeController = TextEditingController();
  final cityController = TextEditingController();
  final fuelStationController = TextEditingController();
  final insuranceExpiryController = TextEditingController();
  final mulkiyaExpiryController = TextEditingController();

  // Observable values for dropdowns
  final selectedInsuranceType = Rx<String?>(null);
  final selectedCondition = Rx<String?>(null);
  final selectedStatus = Rx<String?>(null);
  final selectedCity = Rx<String?>(null);
  final selectedFuelStation = Rx<String?>(null);

  // Tire list for new vehicle
  final tiresList = <Tire>[].obs;

  // Constants for dropdown options
  final List<String> insuranceTypes = ['Comprehensive', 'Third Party', 'None'];
  final List<String> vehicleConditions = ['Excellent', 'Good', 'Fair', 'Poor'];
  final List<String> vehicleStatuses = [
    'Active',
    'Inactive',
    'Under Maintenance',
    'Sold'
  ];
  final List<String> permittedAreas = [
    'Dubai',
    'Abu Dhabi',
    'Sharjah',
    'Ajman',
    'Fujairah',
    'Ras Al Khaimah',
    'Umm Al Quwain'
  ];
  final List<String> fuelStations = [
    'ADNOC',
    'ENOC',
    'EMARAT',
    'Caltex',
    'Other'
  ];

  // Constants
  final int maxTiresAllowed = 10;

  // Form step tracking
  final currentStep = 0.obs;

  // Observable variables
  final isSearching = false.obs;
  final vehicleData = Rx<Vehicle?>(null);

  // @override
  // void onInit() {
  //   super.onInit();
  //   // Initialize with any default values if needed
  // }

  @override
  void onClose() {
    // Dispose controllers
    plateNumberController.dispose();
    createPlateNumberController.dispose();
    createBrandController.dispose();
    createModelController.dispose();
    createChassisNumberController.dispose();
    createTrafficFileNumberController.dispose();
    createCompanyController.dispose();
    yearController.dispose();
    initialOdoController.dispose();
    currentOdoController.dispose();
    typeController.dispose();
    cityController.dispose();
    fuelStationController.dispose();
    insuranceExpiryController.dispose();
    mulkiyaExpiryController.dispose();
    super.onClose();
  }

  void onPlateChanged(String? letter, String? emirate, String? number) {
    plateNumberController.text = "$number-$letter";
    log(plateNumberController.text);
  }

  Future<void> searchVehicle() async {
    try {
      isSearching.value = true;

      if (plateNumberController.text.isNotEmpty) {
        var res = await VehiclesRepo().getAllVehicles(
            company: 'EPIC01', query: plateNumberController.text);
        res.fold((error) {
          log(error);
          if (error == 'Vehicle Not Found!!.') {
            showCreateVehicleDialog();
          }
        }, (vehicle) {
          if (vehicle.isNotEmpty) {
            log(vehicle.toString());
            vehicleData.value = vehicle[0];
            // vehicleData.value = FakeVehicleData().generateFakeVehicles().first;
          } else {
            showCreateVehicleDialog();
          }
        });
      } else {
        CustomWidget.customSnackBar(
            title: 'Error',
            message: 'Please enter a plate number',
            isError: true);
      }
    } on Exception catch (e) {
      log(e.toString());
    } finally {
      isSearching.value = false;
    }
  }

  void addNewTire() {
    // final currentTires = vehicleData.value?.tires?.toList() ?? [];

    // // Only add if below the maximum
    // if (currentTires.length < maxTiresAllowed) {
    //   currentTires.add(Tire());

    //   // Update the vehicle data
    //   final updatedVehicle = vehicleData.value?.copyWith(tires: currentTires);
    //   vehicleData.value = updatedVehicle;
    // }
  }

  void removeTire(int index) {
    // final currentTires = vehicleData.value?.tires?.toList() ?? [];
    // if (index >= 0 && index < currentTires.length) {
    //   currentTires.removeAt(index);

    //   // Update the vehicle data
    //   final updatedVehicle = vehicleData.value?.copyWith(tires: currentTires);
    //   vehicleData.value = updatedVehicle;
    // }
  }

  void updateTireBrand(int index, String brand) {
    // final currentTires = vehicleData.value?.tires?.toList() ?? [];
    // if (index >= 0 && index < currentTires.length) {
    //   currentTires[index] = currentTires[index].copyWith(brand: brand);

    //   // Update the vehicle data
    //   final updatedVehicle = vehicleData.value?.copyWith(tires: currentTires);
    //   vehicleData.value = updatedVehicle;
    // }
  }

  void updateTireModel(int index, String model) {
    // final currentTires = vehicleData.value?.tires?.toList() ?? [];
    // if (index >= 0 && index < currentTires.length) {
    //   currentTires[index] = currentTires[index].copyWith(model: model);

    //   // Update the vehicle data
    //   final updatedVehicle = vehicleData.value?.copyWith(tires: currentTires);
    //   vehicleData.value = updatedVehicle;
    // }
  }

  void updateTireKm(int index, String km) {
    // final currentTires = vehicleData.value?.tires?.toList() ?? [];
    // if (index >= 0 && index < currentTires.length) {
    //   currentTires[index] = currentTires[index].copyWith(km: km);

    //   // Update the vehicle data
    //   final updatedVehicle = vehicleData.value?.copyWith(tires: currentTires);
    //   vehicleData.value = updatedVehicle;
    // }
  }

  // Method to handle vehicle creation
  void createVehicle() {
    // Validate required fields
    if (validateCreateVehicleForm()) {
      // Perform vehicle creation logic
      // This would typically involve an API call or database insertion
      Get.back(); // Close the bottom sheet

      CustomWidget.customSnackBar(
        title: 'Success',
        message:
            'Vehicle ${createPlateNumberController.text} created successfully!',
        isError: false,
      );

      // Update the search with the new vehicle
      plateNumberController.text = createPlateNumberController.text;

      // Trigger search to show the newly created vehicle
      searchVehicle();
    }
  }

  // Validate create vehicle form
  bool validateCreateVehicleForm() {
    if (createPlateNumberController.text.isEmpty) {
      CustomWidget.customSnackBar(
          title: 'Error', message: 'Plate Number is required', isError: true);
      return false;
    }
    // Add more validation as needed
    return true;
  }

  void clearSearch() {
    plateNumberController.clear();
    // vehicleFound.value = false;
    vehicleData.value = null;
  }

  /// view
  void showCreateVehicleDialog() {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Vehicle Not Found',
          style:
              TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'The vehicle with plate number ${plateNumberController.text} does not exist. Would you like to create a new vehicle?',
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      showAddVehicleBottomSheet();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800]),
                    child: const Text(
                      'Create Vehicle',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Add Vehicle Bottom Sheet and related methods
  void showAddVehicleBottomSheet() {
    // Reset form state
    _resetFormState();

    // Pre-fill plate number from search if available
    createPlateNumberController.text = plateNumberController.text;

    Get.bottomSheet(
      Obx(() => Container(
            height: Get.height * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                _buildBottomSheetHeader(),
                Expanded(
                  child: Stepper(
                    physics: ClampingScrollPhysics(),
                    currentStep: currentStep.value,
                    onStepContinue: () {
                      if (currentStep.value < 3) {
                        currentStep.value++;
                      } else {
                        // _submitVehicleForm();
                      }
                    },
                    onStepCancel: () {
                      if (currentStep.value > 0) {
                        currentStep.value--;
                      } else {
                        Get.back();
                      }
                    },
                    controlsBuilder: (context, details) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: details.onStepContinue,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[800],
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: Text(
                                  currentStep.value == 3
                                      ? 'Create Vehicle'
                                      : 'Continue',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: details.onStepCancel,
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: Text(
                                  currentStep.value == 0 ? 'Cancel' : 'Back',
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    steps: [
                      Step(
                        title: Text('Basic Information'),
                        content: _buildBasicInfoStep(),
                        isActive: currentStep.value >= 0,
                      ),
                      Step(
                        title: Text('Additional Details'),
                        content: _buildAdditionalDetailsStep(),
                        isActive: currentStep.value >= 1,
                      ),
                      Step(
                        title: Text('Status & Insurance'),
                        content: _buildStatusInsuranceStep(),
                        isActive: currentStep.value >= 2,
                      ),
                      Step(
                        title: Text('Tires'),
                        content: _buildTiresStep(),
                        isActive: currentStep.value >= 3,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
      isScrollControlled: true,
      enableDrag: false,
    );
  }

  Widget _buildBottomSheetHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Add New Vehicle',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return Column(
      children: [
        _buildTextField(
          controller: createPlateNumberController,
          label: 'Plate Number',
          icon: Icons.directions_car,
          isRequired: true,
        ),
        SizedBox(height: 16),
        _buildTextField(
          controller: createBrandController,
          label: 'Brand',
          icon: Icons.branding_watermark,
          isRequired: true,
        ),
        SizedBox(height: 16),
        _buildTextField(
          controller: createModelController,
          label: 'Model',
          icon: Icons.model_training,
          isRequired: true,
        ),
        SizedBox(height: 16),
        _buildTextField(
          controller: typeController,
          label: 'Vehicle Type',
          icon: Icons.category,
        ),
        SizedBox(height: 16),
        _buildTextField(
          controller: yearController,
          label: 'Year',
          icon: Icons.calendar_today,
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 16),
        _buildTextField(
          controller: createCompanyController,
          label: 'Company',
          icon: Icons.business,
        ),
      ],
    );
  }

  Widget _buildAdditionalDetailsStep() {
    return Column(
      children: [
        _buildTextField(
          controller: createChassisNumberController,
          label: 'Chassis Number',
          icon: Icons.format_list_numbered,
        ),
        SizedBox(height: 16),
        _buildTextField(
          controller: createTrafficFileNumberController,
          label: 'Traffic File Number',
          icon: Icons.file_copy,
        ),
        SizedBox(height: 16),
        _buildTextField(
          controller: initialOdoController,
          label: 'Initial Odometer',
          icon: Icons.speed,
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 16),
        _buildTextField(
          controller: currentOdoController,
          label: 'Current Odometer',
          icon: Icons.speed,
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 16),
        _buildDropdown(
          label: 'City',
          value: selectedCity.value,
          options: permittedAreas,
          onChanged: (value) => selectedCity.value = value,
          icon: Icons.location_city,
        ),
        SizedBox(height: 16),
        _buildDropdown(
          label: 'Fuel Station',
          value: selectedFuelStation.value,
          options: fuelStations,
          onChanged: (value) => selectedFuelStation.value = value,
          icon: Icons.local_gas_station,
        ),
      ],
    );
  }

  Widget _buildStatusInsuranceStep() {
    return Column(
      children: [
        _buildDropdown(
          label: 'Vehicle Condition',
          value: selectedCondition.value,
          options: vehicleConditions,
          onChanged: (value) => selectedCondition.value = value,
          icon: Icons.assessment,
        ),
        SizedBox(height: 16),
        _buildDropdown(
          label: 'Status',
          value: selectedStatus.value,
          options: vehicleStatuses,
          onChanged: (value) => selectedStatus.value = value,
          icon: Icons.flag,
        ),
        SizedBox(height: 16),
        _buildDropdown(
          label: 'Insurance Type',
          value: selectedInsuranceType.value,
          options: insuranceTypes,
          onChanged: (value) => selectedInsuranceType.value = value,
          icon: Icons.security,
        ),
        SizedBox(height: 16),
        _buildDatePickerField(
          controller: insuranceExpiryController,
          label: 'Insurance Expiry Date',
          icon: Icons.calendar_month,
        ),
        SizedBox(height: 16),
        _buildDatePickerField(
          controller: mulkiyaExpiryController,
          label: 'Mulkiya Expiry Date',
          icon: Icons.calendar_month,
        ),
      ],
    );
  }

  Widget _buildTiresStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tires (${tiresList.length}/$maxTiresAllowed)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton.icon(
              onPressed:
                  tiresList.length < maxTiresAllowed ? _addNewTire : null,
              icon: Icon(Icons.add),
              label: Text('Add Tire'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Obx(() => tiresList.isEmpty
            ? Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.tire_repair,
                          size: 48, color: Colors.grey[400]),
                      SizedBox(height: 16),
                      Text(
                        'No tires added yet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: tiresList.length,
                itemBuilder: (context, index) {
                  return _buildTireCard(index);
                },
              )),
      ],
    );
  }

  Widget _buildTireCard(int index) {
    final brandController = TextEditingController(text: tiresList[index].brand);
    final modelController = TextEditingController(text: tiresList[index].brand);
    final kmController =
        TextEditingController(text: tiresList[index].kmUsed.toString());

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tire ${index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeTire(index),
                ),
              ],
            ),
            SizedBox(height: 12),
            TextField(
              controller: brandController,
              decoration: InputDecoration(
                labelText: 'Brand',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) => _updateTireBrand(index, value),
            ),
            SizedBox(height: 12),
            TextField(
              controller: modelController,
              decoration: InputDecoration(
                labelText: 'Model',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) => _updateTireModel(index, value),
            ),
            SizedBox(height: 12),
            TextField(
              controller: kmController,
              decoration: InputDecoration(
                labelText: 'Kilometers',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => _updateTireKm(index, value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> options,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: options.map((option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(option),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDatePickerField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: Get.context!,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(Duration(days: 365 * 5)),
        );
        if (pickedDate != null) {
          controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
        }
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: Icon(Icons.calendar_today),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _resetFormState() {
    // Reset text controllers
    createPlateNumberController.clear();
    createBrandController.clear();
    createModelController.clear();
    createChassisNumberController.clear();
    createTrafficFileNumberController.clear();
    createCompanyController.clear();
    yearController.clear();
    initialOdoController.clear();
    currentOdoController.clear();
    typeController.clear();
    cityController.clear();
    fuelStationController.clear();
    insuranceExpiryController.clear();
    mulkiyaExpiryController.clear();

    // Reset dropdown values
    selectedInsuranceType.value = null;
    selectedCondition.value = null;
    selectedStatus.value = null;
    selectedCity.value = null;
    selectedFuelStation.value = null;

    // Reset step and tires
    currentStep.value = 0;
    tiresList.clear();
  }

  void _addNewTire() {
    if (tiresList.length < maxTiresAllowed) {
      tiresList.add(Tire());
    }
  }

  void _removeTire(int index) {
    if (index >= 0 && index < tiresList.length) {
      tiresList.removeAt(index);
    }
  }

  void _updateTireBrand(int index, String brand) {
    if (index >= 0 && index < tiresList.length) {
      final updatedTire = tiresList[index].copyWith(brand: brand);
      tiresList[index] = updatedTire;
    }
  }

  void _updateTireModel(int index, String model) {
    if (index >= 0 && index < tiresList.length) {
      final updatedTire = tiresList[index].copyWith(brand: model);
      tiresList[index] = updatedTire;
    }
  }

  void _updateTireKm(int index, String km) {
    if (index >= 0 && index < tiresList.length) {
      final updatedTire = tiresList[index].copyWith(kmUsed: int.parse(km));
      tiresList[index] = updatedTire;
    }
  }
}
