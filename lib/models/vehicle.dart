import 'package:multifleet/models/city/city.dart';
import 'package:multifleet/models/fuel_station/fuel_station.dart';
import 'package:multifleet/models/status_master/status_master.dart';
import 'package:multifleet/models/tyre.dart';
import 'package:multifleet/models/vehicle_docs.dart';

import 'vehicle_assignment_model.dart';

class Vehicle {
  // ── Core identity ──────────────────────────────────────────────────────────
  String? company;
  String? vehicleNo;
  String? description;
  String? brand;
  String? model;
  String? traficFileNo;
  String? chassisNo;
  int? vYear;

  // ── Odometer ───────────────────────────────────────────────────────────────
  int? initialOdo;
  int? currentOdo;

  // ── Images ─────────────────────────────────────────────────────────────────
  String? imagePath1;
  String? imagePath2;
  String? imagePath3;
  String? imagePath4;
  String? imagePath5;
  String? imagePath6;

  // ── Raw ID fields (used for API create/update) ─────────────────────────────
  int? vehicleStatusId;
  int? vehicleTypeId;
  int? conditionId;
  int? fuelStationId;
  List<int>? cityIds; // parsed from "1001,1002,1003"

  // ── Raw string fields (returned by GET, kept for display fallback) ──────────
  String? status;
  String? type;
  String? condition;
  String? fuelStation;

  // ── Resolved master objects (populated via resolveFromMasters) ─────────────
  StatusMaster? vehicleStatusMaster;
  StatusMaster? vehicleTypeMaster;
  StatusMaster? vehicleConditionMaster;
  FuelStation? fuelStationMaster;
  List<City>? cities;

  // ── Relations ──────────────────────────────────────────────────────────────
  List<VehicleAssignment>? lastVehicleAssignment;
  List<VehicleDocument>? documents;
  List<Tyre>? tyres;

  Vehicle({
    this.company,
    this.vehicleNo,
    this.description,
    this.brand,
    this.model,
    this.traficFileNo,
    this.chassisNo,
    this.vYear,
    this.initialOdo,
    this.currentOdo,
    this.imagePath1,
    this.imagePath2,
    this.imagePath3,
    this.imagePath4,
    this.imagePath5,
    this.imagePath6,
    this.vehicleStatusId,
    this.vehicleTypeId,
    this.conditionId,
    this.fuelStationId,
    this.cityIds,
    this.status,
    this.type,
    this.condition,
    this.fuelStation,
    this.vehicleStatusMaster,
    this.vehicleTypeMaster,
    this.vehicleConditionMaster,
    this.fuelStationMaster,
    this.cities,
    this.lastVehicleAssignment,
    this.documents,
    this.tyres,
  });

  // ── fromJson (GET response) ────────────────────────────────────────────────
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    // City comes as city names in GET: "Ras Al Khaimah, Dubai"
    // CityID will come as "1001,1002" once backend adds it
    final rawCityIds = json['CityID'] as String?;
    final cityIds = rawCityIds
        ?.split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .map((e) => int.tryParse(e))
        .whereType<int>()
        .toList();

    return Vehicle(
      company: json['Company'] as String?,
      vehicleNo: json['VehicleNo'] as String?,
      description: json['Description'] as String?,
      brand: json['Brand'] as String?,
      model: json['Model'] as String?,
      traficFileNo: json['TraficFileNo'] as String?,
      chassisNo: json['ChassisNo'] as String?,
      // VYear can be int or String depending on endpoint
      vYear: json['VYear'] is int
          ? json['VYear'] as int?
          : int.tryParse(json['VYear']?.toString() ?? ''),
      // Odo values come as double (5000.0) from GET
      initialOdo: (json['InitialOdo'] as num?)?.toInt(),
      currentOdo: (json['CurrentOdo'] as num?)?.toInt(),
      imagePath1: json['ImagePath1'] as String?,
      imagePath2: json['ImagePath2'] as String?,
      imagePath3: json['ImagePath3'] as String?,
      imagePath4: json['ImagePath4'] as String?,
      imagePath5: json['ImagePath5'] as String?,
      imagePath6: json['ImagePath6'] as String?,
      vehicleStatusId: json['VehicleStatusID'] as int?,
      vehicleTypeId: json['VehicleTypeID'] as int?,
      conditionId: json['ConditionID'] as int?,
      fuelStationId: json['FuelStationID'] as int?,
      cityIds: cityIds,
      // String fields returned by GET for display
      status: json['Status'] as String?,
      type: json['Type'] as String?,
      condition: json['Condition'] as String?,
      fuelStation: json['FuelStation'] as String?,
      lastVehicleAssignment: json['lstVehicleAssignment'] != null
          ? (json['lstVehicleAssignment'] as List)
              .map((e) => VehicleAssignment.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      documents: json['Documents'] != null
          ? (json['Documents'] as List)
              .map((e) => VehicleDocument.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      tyres: json['Tyres'] != null
          ? (json['Tyres'] as List)
              .map((e) => Tyre.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  // ── toJson (CREATE / UPDATE payload) ──────────────────────────────────────
  // Matches the create/update JSON contract exactly.
  // City is sent as comma-separated IDs: "1001,1002"
  Map<String, dynamic> toJson() => {
        'Company': company,
        'VehicleNo': vehicleNo,
        'VehicleTypeID': vehicleTypeId,
        'TraficFileNo': traficFileNo,
        'VYear': vYear?.toString(), // API expects string in create
        'ChassisNo': chassisNo,
        'Description': description,
        'Brand': brand,
        'Model': model,
        'City': cityIds?.join(','), // "1001,1002"
        'InitialOdo': initialOdo,
        'CurrentOdo': currentOdo,
        'VehicleStatusID': vehicleStatusId,
        'ImagePath1': imagePath1 ?? '',
        'ImagePath2': imagePath2 ?? '',
        'ImagePath3': imagePath3 ?? '',
        'ImagePath4': imagePath4 ?? '',
        'ImagePath5': imagePath5 ?? '',
        'ImagePath6': imagePath6 ?? '',
        'ConditionID': conditionId,
        'FuelStationID': fuelStationId,
        'Documents': documents?.map((e) => e.toJson()).toList(),
        'Tyre':
            tyres?.map((e) => e.toJson()).toList(), // key is "Tyre" not "Tyres"
      };

  // ── resolveFromMasters ─────────────────────────────────────────────────────
  // Call this after fetching vehicles to populate the master objects from IDs.
  void resolveFromMasters({
    required List<StatusMaster> statusMasters,
    required List<StatusMaster> typeMasters,
    required List<StatusMaster> conditionMasters,
    required List<FuelStation> fuelStations,
    required List<City> allCities,
  }) {
    vehicleStatusMaster = vehicleStatusId != null
        ? statusMasters.where((e) => e.statusId == vehicleStatusId).firstOrNull
        : null;

    vehicleTypeMaster = vehicleTypeId != null
        ? typeMasters.where((e) => e.statusId == vehicleTypeId).firstOrNull
        : null;

    vehicleConditionMaster = conditionId != null
        ? conditionMasters.where((e) => e.statusId == conditionId).firstOrNull
        : null;

    fuelStationMaster = fuelStationId != null
        ? fuelStations
            .where((e) => e.fuelStationId == fuelStationId)
            .firstOrNull
        : null;

    cities = cityIds != null
        ? allCities.where((e) => cityIds!.contains(e.cityId)).toList()
        : null;
  }

  // ── copyWith ───────────────────────────────────────────────────────────────
  // Uses a sentinel pattern for nullable fields so you can explicitly set
  // a field to null (pass clearX: true) or leave it unchanged (omit it).
  Vehicle copyWith({
    String? company,
    String? vehicleNo,
    String? description,
    String? brand,
    String? model,
    String? traficFileNo,
    String? chassisNo,
    int? vYear,
    int? initialOdo,
    int? currentOdo,
    String? imagePath1,
    String? imagePath2,
    String? imagePath3,
    String? imagePath4,
    String? imagePath5,
    String? imagePath6,
    int? vehicleStatusId,
    int? vehicleTypeId,
    int? conditionId,
    int? fuelStationId,
    List<int>? cityIds,
    String? status,
    String? type,
    String? condition,
    String? fuelStation,
    StatusMaster? vehicleStatusMaster,
    StatusMaster? vehicleTypeMaster,
    StatusMaster? vehicleConditionMaster,
    FuelStation? fuelStationMaster,
    List<City>? cities,
    List<VehicleAssignment>? lastVehicleAssignment,
    List<VehicleDocument>? documents,
    List<Tyre>? tyres,
  }) {
    return Vehicle(
      company: company ?? this.company,
      vehicleNo: vehicleNo ?? this.vehicleNo,
      description: description ?? this.description,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      traficFileNo: traficFileNo ?? this.traficFileNo,
      chassisNo: chassisNo ?? this.chassisNo,
      vYear: vYear ?? this.vYear,
      initialOdo: initialOdo ?? this.initialOdo,
      currentOdo: currentOdo ?? this.currentOdo,
      imagePath1: imagePath1 ?? this.imagePath1,
      imagePath2: imagePath2 ?? this.imagePath2,
      imagePath3: imagePath3 ?? this.imagePath3,
      imagePath4: imagePath4 ?? this.imagePath4,
      imagePath5: imagePath5 ?? this.imagePath5,
      imagePath6: imagePath6 ?? this.imagePath6,
      vehicleStatusId: vehicleStatusId ?? this.vehicleStatusId,
      vehicleTypeId: vehicleTypeId ?? this.vehicleTypeId,
      conditionId: conditionId ?? this.conditionId,
      fuelStationId: fuelStationId ?? this.fuelStationId,
      cityIds: cityIds ?? this.cityIds,
      status: status ?? this.status,
      type: type ?? this.type,
      condition: condition ?? this.condition,
      fuelStation: fuelStation ?? this.fuelStation,
      vehicleStatusMaster: vehicleStatusMaster ?? this.vehicleStatusMaster,
      vehicleTypeMaster: vehicleTypeMaster ?? this.vehicleTypeMaster,
      vehicleConditionMaster:
          vehicleConditionMaster ?? this.vehicleConditionMaster,
      fuelStationMaster: fuelStationMaster ?? this.fuelStationMaster,
      cities: cities ?? this.cities,
      lastVehicleAssignment:
          lastVehicleAssignment ?? this.lastVehicleAssignment,
      documents: documents ?? this.documents,
      tyres: tyres ?? this.tyres,
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Vehicle withDocuments(List<VehicleDocument> docs) =>
      copyWith(documents: docs);

  Vehicle withTyres(List<Tyre> vehicleTyres) => copyWith(tyres: vehicleTyres);

  @override
  String toString() {
    return 'Vehicle(company: $company, vehicleNo: $vehicleNo, brand: $brand, '
        'model: $model, vYear: $vYear, status: $status, type: $type, '
        'condition: $condition, fuelStation: $fuelStation, '
        'vehicleStatusId: $vehicleStatusId, vehicleTypeId: $vehicleTypeId, '
        'conditionId: $conditionId, fuelStationId: $fuelStationId, '
        'cityIds: $cityIds, currentOdo: $currentOdo)';
  }
}

// ── GET response JSON sample ───────────────────────────────────────────────
// [
//     {
//         "Company": "EPIC01",
//         "VehicleNo": "DXB-10011",
//         "Description": "Heavy Truck",
//         "Brand": "Mitsubishi",
//         "Model": "Fuso",
//         "City": "Ras Al Khaimah, Dubai, Al Ain",
//         "CityID": "1001,1002,1003",           <-- coming soon from backend
//         "InitialOdo": 5000.0,
//         "ImagePath1": "",
//         "ImagePath2": "",
//         "Status": "Active",
//         "Type": "Truck",
//         "TraficFileNo": "DXB-TF-10011",
//         "VYear": 2022,
//         "ChassisNo": "UAECHS000001",
//         "lstVehicleAssignment": [ ... ],
//         "CurrentOdo": 78000.0,
//         "ImagePath3": "",
//         "ImagePath4": "",
//         "ImagePath5": "",
//         "ImagePath6": "",
//         "Condition": "Very Good",
//         "FuelStation": "ENOC",
//         "ConditionID": 2,
//         "FuelStationID": 1001,
//         "VehicleStatusID": 1,
//         "VehicleTypeID": 1
//     }
// ]

// ── CREATE / UPDATE payload JSON sample ────────────────────────────────────
// {
//     "Company": "EPIC01",
//     "VehicleNo": "DXB-12786",
//     "VehicleTypeID": 1,
//     "TraficFileNo": "TF99887",
//     "VYear": "2024",
//     "ChassisNo": "CHS998877",
//     "Description": "Delivery Van",
//     "Brand": "Toyota",
//     "Model": "Hiace",
//     "City": "1001,1002",
//     "InitialOdo": 1200,
//     "CurrentOdo": 1200,
//     "VehicleStatusID": 1,
//     "ImagePath1": "",
//     "ImagePath2": "",
//     "ImagePath3": "",
//     "ImagePath4": "",
//     "ImagePath5": "",
//     "ImagePath6": "",
//     "ConditionID" : 1,
//     "FuelStationID" : 1001,
//     "Documents": [ ... ],
//     "Tyre": [ ... ]
// }
