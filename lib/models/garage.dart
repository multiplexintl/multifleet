/// Garage/Workshop model for tracking service locations
class Garage {
  final String? company;
  final int? garageId;
  final String? name;
  final String? location;
  final String? contactPerson;
  final String? phone;
  final String? email;
  final bool? isActive;

  Garage({
    this.company,
    this.garageId,
    this.name,
    this.location,
    this.contactPerson,
    this.phone,
    this.email,
    this.isActive,
  });

  factory Garage.fromJson(Map<String, dynamic> json) {
    return Garage(
      company: json['Company'] as String?,
      garageId: json['GarageID'] as int?,
      name: json['Name'] as String?,
      location: json['Location'] as String?,
      contactPerson: json['ContactPerson'] as String?,
      phone: json['Phone'] as String?,
      email: json['Email'] as String?,
      isActive: json['IsActive'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'Company': company,
        'GarageID': garageId,
        'Name': name,
        'Location': location,
        'ContactPerson': contactPerson,
        'Phone': phone,
        'Email': email,
        'IsActive': isActive,
      };

  Garage copyWith({
    String? company,
    int? garageId,
    String? name,
    String? location,
    String? contactPerson,
    String? phone,
    String? email,
    bool? isActive,
  }) {
    return Garage(
      company: company ?? this.company,
      garageId: garageId ?? this.garageId,
      name: name ?? this.name,
      location: location ?? this.location,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() =>
      'Garage(garageId: $garageId, name: $name, location: $location)';
}
