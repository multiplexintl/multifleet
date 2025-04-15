class Vendor {
  final String? company;
  final String? vendorID;
  final String? vendorName;
  final String? address;
  final String? city;
  final String? contactNo;
  final String? contactPerson;

  Vendor({
    this.company,
    this.vendorID,
    this.vendorName,
    this.address,
    this.city,
    this.contactNo,
    this.contactPerson,
  });

  // Copy with method
  Vendor copyWith({
    String? company,
    String? vendorID,
    String? vendorName,
    String? address,
    String? city,
    String? contactNo,
    String? contactPerson,
  }) {
    return Vendor(
      company: company ?? this.company,
      vendorID: vendorID ?? this.vendorID,
      vendorName: vendorName ?? this.vendorName,
      address: address ?? this.address,
      city: city ?? this.city,
      contactNo: contactNo ?? this.contactNo,
      contactPerson: contactPerson ?? this.contactPerson,
    );
  }

  // From JSON factory constructor
  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      company: json['Company'],
      vendorID: json['VendorID'],
      vendorName: json['VendorName'],
      address: json['Address'],
      city: json['City'],
      contactNo: json['ContactNo'],
      contactPerson: json['ContactPerson'],
    );
  }

  // To JSON method
  Map<String, dynamic> toJson() {
    return {
      'Company': company,
      'VendorID': vendorID,
      'VendorName': vendorName,
      'Address': address,
      'City': city,
      'ContactNo': contactNo,
      'ContactPerson': contactPerson,
    };
  }

  // toString method
  @override
  String toString() {
    return 'Vendor{company: $company, vendorID: $vendorID, vendorName: $vendorName, '
        'address: $address, city: $city, contactNo: $contactNo, contactPerson: $contactPerson}';
  }
}
