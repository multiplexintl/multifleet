class City {
  String? company;
  int? cityId;
  String? city;

  City({this.company, this.cityId, this.city});

  @override
  String toString() {
    return 'City(company: $company, cityId: $cityId, city: $city)';
  }

  factory City.fromJson(Map<String, dynamic> json) => City(
        company: json['Company'] as String?,
        cityId: json['CityID'] as int?,
        city: json['City'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'Company': company,
        'CityID': cityId,
        'City': city,
      };

  City copyWith({
    String? company,
    int? cityId,
    String? city,
  }) {
    return City(
      company: company ?? this.company,
      cityId: cityId ?? this.cityId,
      city: city ?? this.city,
    );
  }
}
