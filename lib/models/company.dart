class Company {
  String? id;
  String? name;
  String? shortName;
  String? currency;

  Company({this.id, this.name, this.shortName, this.currency});

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['Company'] as String?,
      name: json['CompanyName'] as String?,
      shortName: json['ShortName'] as String?,
      currency: json['currency'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'shortName': shortName,
      'currency': currency,
    };
  }

  Company copyWith({String? id, String? name}) {
    return Company(
      id: id ?? this.id,
      name: name ?? this.name,
      shortName: shortName,
      currency: currency,
    );
  }

  @override
  String toString() =>
      'Company(id: $id, name: $name, shortName: $shortName, currency: $currency)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Company &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          shortName == other.shortName &&
          currency == other.currency;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
