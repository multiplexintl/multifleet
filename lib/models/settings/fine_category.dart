import 'package:flutter/material.dart';
import 'base_master.dart';

/// ============================================================
/// FINE CATEGORY MODEL
/// ============================================================

class FineCategory extends BaseMaster {
  @override
  final String id;

  @override
  final String name;

  @override
  final bool isActive;

  /// Short code for display (e.g., "SDN", "SUV")
  final String? code;

  /// Description
  final String? description;

  /// Icon name (Material icon)
  final String? iconName;

  /// Display color hex
  final String? colorHex;

  /// Sort order for display
  final int sortOrder;

  /// severity level of fine category
  final String severity;

  // /// default amount of fine category
  final double? defaultAmount;

  // /// currency of fine category
  final String? currency;

  // /// black points of fine category
  final int? blackPoints;

  FineCategory({
    required this.id,
    required this.name,
    this.isActive = true,
    this.code,
    this.description,
    this.iconName,
    this.colorHex,
    this.sortOrder = 0,
    required this.severity,
    this.defaultAmount,
    this.currency,
    this.blackPoints,
  });

  @override
  String? get subtitle => code != null ? '($code)' : description;

  @override
  // IconData? get icon => _getIconData(iconName);

  @override
  Color? get color =>
      colorHex != null ? Color(int.parse('FF$colorHex', radix: 16)) : null;

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isActive': isActive,
        'code': code,
        'description': description,
        'iconName': iconName,
        'colorHex': colorHex,
        'sortOrder': sortOrder,
        'severity': severity,
        'defaultAmount': defaultAmount,
        'currency': currency,
        'blackPoints': blackPoints
      };

  factory FineCategory.fromJson(Map<String, dynamic> json) => FineCategory(
        id: json['id'] as String,
        name: json['name'] as String,
        isActive: json['isActive'] as bool? ?? true,
        code: json['code'] as String?,
        description: json['description'] as String?,
        iconName: json['iconName'] as String?,
        colorHex: json['colorHex'] as String?,
        sortOrder: json['sortOrder'] as int? ?? 0,
        severity: json['severity'] as String,
        defaultAmount: json['defaultAmount'] as double?,
        currency: json['currency'] as String?,
        blackPoints: json['blackPoints'] as int?,
      );

  @override
  FineCategory copyWith({
    String? id,
    String? name,
    bool? isActive,
    String? code,
    String? description,
    String? iconName,
    String? colorHex,
    int? sortOrder,
    String? severity,
    double? defaultAmount,
    String? currency,
    int? blackPoints,
  }) =>
      FineCategory(
        id: id ?? this.id,
        name: name ?? this.name,
        isActive: isActive ?? this.isActive,
        code: code ?? this.code,
        description: description ?? this.description,
        iconName: iconName ?? this.iconName,
        colorHex: colorHex ?? this.colorHex,
        sortOrder: sortOrder ?? this.sortOrder,
        severity: severity ?? this.severity,
        defaultAmount: defaultAmount ?? this.defaultAmount,
        currency: currency ?? this.currency,
        blackPoints: blackPoints ?? this.blackPoints,
      );
}

/// Available fine severity levels

const List<String> fineSeverityLevels = [
  'Low',
  'Medium',
  'High',
  'Severe',
];

/// currency options
const List<String> currencies = [
  'AED',
  'QAR',
  'OMR',
  'SAR',
  'USD',
];

/// ============================================================
/// VEHICLE CATEGORY REPOSITORY
/// ============================================================

class FineCategoryRepository extends BaseMasterRepository<FineCategory> {
  // TODO: Replace with actual API client
  // final ApiClient _apiClient;
  // FineCategoryRepository(this._apiClient);

  // Mock data store - remove when connecting to real API
  final List<FineCategory> _mockData = [
    /// craete mock data here

    FineCategory(
      id: '2',
      name: 'Parking Violation',
      code: 'PRK',
      description: 'Parking violation',
      iconName: 'directions_car_filled',
      colorHex: '10B981',
      sortOrder: 2,
      severity: 'Medium',
      defaultAmount: 500,
      currency: 'AED',
      blackPoints: 4,
    ),
    FineCategory(
      id: '3',
      name: 'Speeding',
      code: 'SPD',
      description: 'Speeding violation',
      iconName: 'local_shipping',
      colorHex: 'F59E0B',
      sortOrder: 3,
      severity: 'High',
      defaultAmount: 1000,
      currency: 'QAR',
      blackPoints: 6,
    ),
    FineCategory(
        id: '4',
        name: 'Parking Violation',
        code: 'PRK',
        description: 'Parking violation',
        iconName: 'airport_shuttle',
        colorHex: '8B5CF6',
        sortOrder: 4,
        severity: 'Low',
        defaultAmount: 200,
        currency: 'SAR',
        blackPoints: 2),
    FineCategory(
      id: '1',
      name: 'Speeding',
      code: 'SPD',
      description: 'Speeding violation',
      iconName: 'directions_car',
      colorHex: '3B82F6',
      sortOrder: 1,
      severity: 'Medium',
      defaultAmount: 500,
      currency: 'USD',
      blackPoints: 0,
    ),
  ];

  @override
  Future<List<FineCategory>> getAll() async {
    // TODO: Replace with API call
    // final response = await _apiClient.get('/api/masters/vehicle-categories');
    // return (response.data as List).map((e) => FineCategory.fromJson(e)).toList();

    // Mock delay to simulate network
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_mockData)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  @override
  Future<FineCategory?> getById(String id) async {
    // TODO: Replace with API call
    // final response = await _apiClient.get('/api/masters/vehicle-categories/$id');
    // return FineCategory.fromJson(response.data);

    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _mockData.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<FineCategory> create(FineCategory item) async {
    // TODO: Replace with API call
    // final response = await _apiClient.post('/api/masters/vehicle-categories', data: item.toJson());
    // return FineCategory.fromJson(response.data);

    await Future.delayed(const Duration(milliseconds: 300));
    final newItem = item.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sortOrder: _mockData.length + 1,
    );
    _mockData.add(newItem);
    return newItem;
  }

  @override
  Future<FineCategory> update(FineCategory item) async {
    // TODO: Replace with API call
    // final response = await _apiClient.put('/api/masters/vehicle-categories/${item.id}', data: item.toJson());
    // return FineCategory.fromJson(response.data);

    await Future.delayed(const Duration(milliseconds: 300));
    final index = _mockData.indexWhere((e) => e.id == item.id);
    if (index == -1) throw Exception('Item not found');
    _mockData[index] = item;
    return item;
  }

  @override
  Future<void> delete(String id) async {
    // TODO: Replace with API call
    // await _apiClient.delete('/api/masters/vehicle-categories/$id');

    await Future.delayed(const Duration(milliseconds: 300));
    _mockData.removeWhere((e) => e.id == id);
  }
}
