import 'package:multifleet/models/tire.dart';
import 'package:multifleet/models/vehicle_docs.dart';

class Vehicle {
  String? company;
  String? vehicleNo;
  String? description;
  String? brand;
  String? model;
  String? city;
  int? initialOdo;
  String? imagePath1;
  String? imagePath2;
  String? status;
  String? type;
  String? traficFileNo;
  int? vYear;
  String? chassisNo;
  List<VehicleDocument>? documents;
  List<Tire>? tires;

  Vehicle({
    this.company,
    this.vehicleNo,
    this.description,
    this.brand,
    this.model,
    this.city,
    this.initialOdo,
    this.imagePath1,
    this.imagePath2,
    this.status,
    this.type,
    this.traficFileNo,
    this.vYear,
    this.chassisNo,
    this.documents,
    this.tires,
  });

  @override
  String toString() {
    return 'Vehicle(company: $company, vehicleNo: $vehicleNo, description: $description, brand: $brand, model: $model, city: $city, initialOdo: $initialOdo, imagePath1: $imagePath1, imagePath2: $imagePath2, status: $status, type: $type, traficFileNo: $traficFileNo, vYear: $vYear, chassisNo: $chassisNo, documents: $documents, tires: $tires)';
  }

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
        company: json['Company'] as String?,
        vehicleNo: json['VehicleNo'] as String?,
        description: json['Description'] as String?,
        brand: json['Brand'] as String?,
        model: json['Model'] as String?,
        city: json['City'] as String?,
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
        tires: json['Tires'] != null
            ? (json['Tires'] as List)
                .map((e) => Tire.fromJson(e as Map<String, dynamic>))
                .toList()
            : null,
      );

  Map<String, dynamic> toJson() => {
        'Company': company,
        'VehicleNo': vehicleNo,
        'Description': description,
        'Brand': brand,
        'Model': model,
        'City': city,
        'InitialOdo': initialOdo,
        'ImagePath1': imagePath1,
        'ImagePath2': imagePath2,
        'Status': status,
        'Type': type,
        'TraficFileNo': traficFileNo,
        'VYear': vYear,
        'ChassisNo': chassisNo,
        'Documents': documents?.map((e) => e.toJson()).toList(),
        'Tires': tires?.map((e) => e.toJson()).toList(),
      };

  Vehicle copyWith({
    String? company,
    String? vehicleNo,
    String? description,
    String? brand,
    String? model,
    String? city,
    int? initialOdo,
    String? imagePath1,
    String? imagePath2,
    String? status,
    String? type,
    String? traficFileNo,
    int? vYear,
    String? chassisNo,
    List<VehicleDocument>? documents,
    List<Tire>? tires,
  }) {
    return Vehicle(
      company: company ?? this.company,
      vehicleNo: vehicleNo ?? this.vehicleNo,
      description: description ?? this.description,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      city: city ?? this.city,
      initialOdo: initialOdo ?? this.initialOdo,
      imagePath1: imagePath1 ?? this.imagePath1,
      imagePath2: imagePath2 ?? this.imagePath2,
      status: status ?? this.status,
      type: type ?? this.type,
      traficFileNo: traficFileNo ?? this.traficFileNo,
      vYear: vYear ?? this.vYear,
      chassisNo: chassisNo ?? this.chassisNo,
      documents: documents ?? this.documents,
      tires: tires ?? this.tires,
    );
  }

  // Add method to incorporate documents
  Vehicle withDocuments(List<VehicleDocument> docs) {
    return copyWith(
      documents: docs,
    );
  }

  // Add method to incorporate tires
  Vehicle withTires(List<Tire> vehicleTires) {
    return copyWith(
      tires: vehicleTires,
    );
  }
}
