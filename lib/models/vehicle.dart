import 'package:multifleet/models/tyre.dart';
import 'package:multifleet/models/vehicle_docs.dart';

class Vehicle {
  String? company;
  String? vehicleNo;
  String? description;
  String? brand;
  String? model;
  List<String>? city;
  int? initialOdo;
  int? currentOdo;
  String? imagePath1;
  String? imagePath2;
  String? status;
  String? type;
  String? traficFileNo;
  String? fuelStation;
  int? vYear;
  String? chassisNo;
  String? condition;
  List<VehicleDocument>? documents;
  List<Tyre>? tyres;

  Vehicle({
    this.company,
    this.vehicleNo,
    this.description,
    this.brand,
    this.model,
    this.city,
    this.initialOdo,
    this.currentOdo,
    this.imagePath1,
    this.imagePath2,
    this.status,
    this.type,
    this.traficFileNo,
    this.fuelStation,
    this.vYear,
    this.chassisNo,
    this.documents,
    this.tyres,
    this.condition,
  });

  @override
  String toString() {
    return 'Vehicle(company: $company, vehicleNo: $vehicleNo, description: $description, brand: $brand, model: $model, city: ${city?.toList()}, initialOdo: $initialOdo, currentOdo: $currentOdo, imagePath1: $imagePath1, imagePath2: $imagePath2, status: $status, type: $type, traficFileNo: $traficFileNo, fuelStation: $fuelStation, vYear: $vYear, chassisNo: $chassisNo, documents: $documents, tyres: $tyres, condition: $condition)';
  }

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    final raw = json['City'] as String?;
    return Vehicle(
      company: json['Company'] as String?,
      vehicleNo: json['VehicleNo'] as String?,
      description: json['Description'] as String?,
      brand: json['Brand'] as String?,
      model: json['Model'] as String?,
      city: raw
          ?.split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      initialOdo: json['InitialOdo'] as int?,
      imagePath1: json['ImagePath1'] as String?,
      imagePath2: json['ImagePath2'] as String?,
      status: json['Status'] as String?,
      type: json['Type'] as String?,
      traficFileNo: json['TraficFileNo'] as String?,
      vYear: json['VYear'] as int?,
      chassisNo: json['ChassisNo'] as String?,
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

  Map<String, dynamic> toJson() => {
        'Company': company,
        'VehicleNo': vehicleNo,
        'Description': description,
        'Brand': brand,
        'Model': model,
        'City': city?.join(','),
        'InitialOdo': initialOdo,
        'CurrentOdo': currentOdo,
        'ImagePath1': imagePath1,
        'ImagePath2': imagePath2,
        'Status': status,
        'Type': type,
        'TraficFileNo': traficFileNo,
        'VYear': vYear,
        'ChassisNo': chassisNo,
        'Condition': condition,
        'FuelStation': fuelStation,
        'Documents': documents?.map((e) => e.toJson()).toList(),
        'Tyre': tyres?.map((e) => e.toJson()).toList(),
      };

  Vehicle copyWith({
    String? company,
    String? vehicleNo,
    String? description,
    String? brand,
    String? model,
    List<String>? city,
    int? initialOdo,
    int? currentOdo,
    String? imagePath1,
    String? imagePath2,
    String? status,
    String? type,
    String? traficFileNo,
    String? fuelStation,
    int? vYear,
    String? chassisNo,
    List<VehicleDocument>? documents,
    List<Tyre>? tyres,
    String? condition,
  }) {
    return Vehicle(
      company: company ?? this.company,
      vehicleNo: vehicleNo ?? this.vehicleNo,
      description: description ?? this.description,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      city: city ?? this.city,
      initialOdo: initialOdo ?? this.initialOdo,
      currentOdo: currentOdo ?? this.currentOdo,
      imagePath1: imagePath1 ?? this.imagePath1,
      imagePath2: imagePath2 ?? this.imagePath2,
      status: status ?? this.status,
      type: type ?? this.type,
      traficFileNo: traficFileNo ?? this.traficFileNo,
      fuelStation: fuelStation ?? this.fuelStation,
      vYear: vYear ?? this.vYear,
      chassisNo: chassisNo ?? this.chassisNo,
      documents: documents ?? this.documents,
      tyres: tyres ?? this.tyres,
      condition: condition ?? this.condition,
    );
  }

  // Add method to incorporate documents
  Vehicle withDocuments(List<VehicleDocument> docs) {
    return copyWith(
      documents: docs,
    );
  }

  // Add method to incorporate tyres
  Vehicle withTyres(List<Tyre> vehicleTyres) {
    return copyWith(
      tyres: vehicleTyres,
    );
  }
}
