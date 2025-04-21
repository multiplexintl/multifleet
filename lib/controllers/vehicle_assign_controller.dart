import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multifleet/helpers/fake_data_service.dart';
import 'package:multifleet/models/vehicle.dart';
import 'package:multifleet/services/company_service.dart';

import '../repo/vehicles_repo.dart';
import '../widgets/custom_widgets.dart';

class VehicleAssignmentController extends GetxController {
  final companyService = Get.find<CompanyService>();
  // Text controllers
  final TextEditingController plateNumberController =
      TextEditingController(text: "11908-AA");
  final TextEditingController empNameController = TextEditingController();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();

  // Selected values
  final Rx<Vehicle?> selectedVehicle = Rx<Vehicle?>(null);
  final Rx<String?> selectedEmployee = Rx<String?>(null);
  final Rx<String?> selectedDesignation = Rx<String?>(null);
  final Rx<String?> selectedStatus = Rx<String?>("Active");

  // Date and time values
  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);

  // Images
  final RxList<XFile> selectedImages = <XFile>[].obs;

  // Loading states
  final RxBool isSearching = false.obs;
  final RxBool isSubmitting = false.obs;

  // Lists for dropdowns
  final RxList<String> employees = <String>[
    'John Doe',
    'Jane Smith',
    'Ahmed Khan',
    'Sara Johnson',
    'Mike Williams',
    'Ali Hassan',
    'Fatima Al-Mansouri'
  ].obs;

  final RxList<String> designations = <String>[
    'Driver',
    'Manager',
    'Director',
    'Salesperson',
    'Technician',
    'Executive',
    'Supervisor'
  ].obs;

  final RxList<String> statusOptions =
      <String>['Active', 'Pending', 'On Leave', 'Terminated'].obs;

// @override
//   void onInit() {

//     super.onInit();
//   }

  void onPlateChanged(String? letter, String? emirate, String? number) {
    plateNumberController.text = "$number-$letter";
    log(plateNumberController.text);
  }

  // Search vehicle by plate number

  Future<void> searchVehicle() async {
    try {
      isSearching.value = true;

      if (plateNumberController.text.isNotEmpty) {
        var res = await VehiclesRepo().getAllVehicles(
            company: '${companyService.selectedCompanyObs.value?.id}',
            query: plateNumberController.text);
        res.fold((error) {
          log(error);
        }, (vehicles) {
          if (vehicles.isNotEmpty) {
            // Check if vehicles is already assigned
            var veh = vehicles[0];
            final isAssigned =
                FakeVehicleData.isVehicleAssigned(veh.vehicleNo!);
            log(isAssigned.toString());
            if (isAssigned) {
              _showReassignDialog(veh);
            } else {
              selectedVehicle.value = veh;
            }
          } else {
            CustomWidget.customSnackBar(
              isError: false,
              title: 'Not Found',
              message: 'No vehicle found with this plate number',
            );
          }
        });
      } else {
        CustomWidget.customSnackBar(
          isError: false,
          title: 'Error',
          message: 'Please enter a plate number',
        );
      }
    } on Exception catch (e) {
      log(e.toString());
    } finally {
      isSearching.value = false;
    }
  }

  // Future<void> searchVehicle() async {
  //   if (plateNumberController.text.isEmpty) return;

  //   isSearching.value = true;

  //   try {
  //     // Simulate API call or database query
  //     await Future.delayed(Duration(seconds: 1));

  //     final vehicle = FakeVehicleData()
  //         .findVehicleByPlateNumber(plateNumberController.text);

  //     if (vehicle != null) {
  //       // Check if vehicle is already assigned
  //       final isAssigned =
  //           FakeVehicleData.isVehicleAssigned(vehicle.vehicleNo!);

  //       if (isAssigned) {
  //         _showReassignDialog(vehicle);
  //       } else {
  //         selectedVehicle.value = vehicle;
  //       }
  //     } else {
  //       CustomWidget.customSnackBar(
  // isError: false,'Not Found', 'No vehicle found with this plate number',
  //           ,
  //           backgroundColor: Colors.red,
  //           colorText: Colors.white);
  //     }
  //   } finally {
  //     isSearching.value = false;
  //   }
  // }

  Future<List<String>> getEmpSuggestions(String query) async {
    List<String> matches = <String>[];
    // here do api
    if (query.isNotEmpty) {
      // matches.addAll(fakeCustomers);
      // var res = await RetrunRepo().fetchCustomer(
      //   company: homeCon.user.value.company!,
      //   query: query,
      // );
      // res.fold((error) {
      //   CustomWidget.customSnackBar(
      //       title: "Error!!", message: error, backgroundColor: Colors.red);
      // }, (custs) {
      //   matches.addAll(custs!);
      // });
      matches.addAll(employees);
    } else {
      // custSuggestions.clear();
    }
    return matches;
  }

  void onEmpSelected(String emp) {
    empNameController.text = emp;
    selectedEmployee.value = emp;
  }

  Future<List<String>> getDesignationSuggestions(String query) async {
    List<String> matches = <String>[];
    // here do api
    if (query.isNotEmpty) {
      // matches.addAll(fakeCustomers);
      // var res = await RetrunRepo().fetchCustomer(
      //   company: homeCon.user.value.company!,
      //   query: query,
      // );
      // res.fold((error) {
      //   CustomWidget.customSnackBar(
      //       title: "Error!!", message: error, backgroundColor: Colors.red);
      // }, (custs) {
      //   matches.addAll(custs!);
      // });
      matches.addAll(designations);
    } else {
      // custSuggestions.clear();
    }
    return matches;
  }

  void onDesignationSelected(String des) {
    designationController.text = des;
    selectedDesignation.value = des;
  }

  void _showReassignDialog(Vehicle vehicle) {
    Get.dialog(
      AlertDialog(
        title: Text('Vehicle Already Assigned'),
        content: Text(
            'This vehicle is already assigned to an employee. Would you like to reassign it?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              selectedVehicle.value = vehicle;
            },
            child: Text('Reassign'),
          ),
        ],
      ),
    );
  }

  // Clear search
  void clearSearch() {
    plateNumberController.clear();
    selectedVehicle.value = null;
  }

  // Pick images
  Future<void> pickImages() async {
    if (selectedImages.length >= 6) {
      CustomWidget.customSnackBar(
        isError: false,
        title: 'Limit Reached',
        message: 'Maximum 6 images allowed',
      );
      return;
    }

    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      if (selectedImages.length + images.length > 6) {
        final int remaining = 6 - selectedImages.length;
        selectedImages.addAll(images.take(remaining));
        CustomWidget.customSnackBar(
          isError: false,
          title: 'Limit Reached',
          message:
              'Added $remaining out of ${images.length} images. Maximum 6 images allowed.',
        );
      } else {
        selectedImages.addAll(images);
      }
    }
  }

  // Remove image
  void removeImage(int index) {
    selectedImages.removeAt(index);
  }

  // Submit assignment
  Future<void> submitAssignment() async {
    if (selectedVehicle.value == null) {
      CustomWidget.customSnackBar(
        isError: false,
        title: 'Error',
        message: 'Please search and select a vehicle first',
      );
      return;
    }

    if (selectedEmployee.value == null) {
      CustomWidget.customSnackBar(
        isError: false,
        title: 'Error',
        message: 'Please select an employee',
      );
      return;
    }

    if (selectedDesignation.value == null) {
      CustomWidget.customSnackBar(
        isError: false,
        title: 'Error',
        message: 'Please select a designation',
      );
      return;
    }

    if (startDate.value == null) {
      CustomWidget.customSnackBar(
        isError: false,
        title: 'Error',
        message: 'Please select a start date',
      );
      return;
    }

    isSubmitting.value = true;

    try {
      // Simulate API call or database insertion
      await Future.delayed(Duration(seconds: 1));

      CustomWidget.customSnackBar(
        isError: false,
        title: 'Success',
        message: 'Vehicle assigned successfully',
      );

      clearForm();
    } finally {
      isSubmitting.value = false;
    }
  }

  // Clear form
  void clearForm() {
    plateNumberController.clear();
    remarksController.clear();
    selectedVehicle.value = null;
    selectedEmployee.value = null;
    selectedDesignation.value = null;
    selectedStatus.value = "Active";
    startDate.value = null;
    endDate.value = null;
    selectedImages.clear();
  }

  // Format date for display
  String formatDateTime(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }
}
