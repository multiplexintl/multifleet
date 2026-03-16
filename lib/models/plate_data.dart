/// Model representing license plate data across GCC countries
class PlateData {
  final String? code; // Letter code (UAE: A-Z, Oman: A, AB, etc.)
  final String? number; // Plate number (up to 5-6 digits)
  final String? region; // Region/Emirate (UAE only)

  const PlateData({
    this.code,
    this.number,
    this.region,
  });

  /// Check if plate has any data
  bool get isEmpty =>
      (code == null || code!.isEmpty) && (number == null || number!.isEmpty);

  bool get isNotEmpty => !isEmpty;

  /// Create a copy with updated values
  PlateData copyWith({
    String? code,
    String? number,
    String? region,
  }) {
    return PlateData(
      code: code ?? this.code,
      number: number ?? this.number,
      region: region ?? this.region,
    );
  }

  @override
  String toString() {
    final parts = <String>[];
    if (code != null && code!.isNotEmpty) parts.add(code!);
    if (number != null && number!.isNotEmpty) parts.add(number!);
    return parts.join(' ');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlateData &&
        other.code == code &&
        other.number == number &&
        other.region == region;
  }

  @override
  int get hashCode => Object.hash(code, number, region);
}
