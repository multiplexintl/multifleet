import 'package:flutter/material.dart';
import 'base_master.dart';

/// ============================================================
/// VEHICLE CATEGORY MODEL
/// ============================================================

class VehicleCategory extends BaseMaster {
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

  VehicleCategory({
    required this.id,
    required this.name,
    this.isActive = true,
    this.code,
    this.description,
    this.iconName,
    this.colorHex,
    this.sortOrder = 0,
  });

  @override
  String? get subtitle => code != null ? '($code)' : description;

  @override
  IconData? get icon => _getIconData(iconName);

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
      };

  factory VehicleCategory.fromJson(Map<String, dynamic> json) =>
      VehicleCategory(
        id: json['id'] as String,
        name: json['name'] as String,
        isActive: json['isActive'] as bool? ?? true,
        code: json['code'] as String?,
        description: json['description'] as String?,
        iconName: json['iconName'] as String?,
        colorHex: json['colorHex'] as String?,
        sortOrder: json['sortOrder'] as int? ?? 0,
      );

  @override
  VehicleCategory copyWith({
    String? id,
    String? name,
    bool? isActive,
    String? code,
    String? description,
    String? iconName,
    String? colorHex,
    int? sortOrder,
  }) =>
      VehicleCategory(
        id: id ?? this.id,
        name: name ?? this.name,
        isActive: isActive ?? this.isActive,
        code: code ?? this.code,
        description: description ?? this.description,
        iconName: iconName ?? this.iconName,
        colorHex: colorHex ?? this.colorHex,
        sortOrder: sortOrder ?? this.sortOrder,
      );

  /// Helper to get IconData from string name
  static IconData? _getIconData(String? name) {
    if (name == null) return null;
    return vehicleCategoryIcons[name];
  }
}

/// Available icons for vehicle categories
const Map<String, IconData> vehicleCategoryIcons = {
  'directions_car': Icons.directions_car,
  'directions_car_filled': Icons.directions_car_filled,
  'local_shipping': Icons.local_shipping,
  'airport_shuttle': Icons.airport_shuttle,
  'directions_bus': Icons.directions_bus,
  'two_wheeler': Icons.two_wheeler,
  'electric_car': Icons.electric_car,
  'fire_truck': Icons.fire_truck,
  'agriculture': Icons.agriculture,
  'rv_hookup': Icons.rv_hookup,
};

/// ============================================================
/// VEHICLE CATEGORY REPOSITORY
/// ============================================================

class VehicleCategoryRepository extends BaseMasterRepository<VehicleCategory> {
  // TODO: Replace with actual API client
  // final ApiClient _apiClient;
  // VehicleCategoryRepository(this._apiClient);

  // Mock data store - remove when connecting to real API
  final List<VehicleCategory> _mockData = [
    VehicleCategory(
      id: '1',
      name: 'Sedan',
      code: 'SDN',
      description: 'Standard passenger sedan',
      iconName: 'directions_car',
      colorHex: '3B82F6',
      sortOrder: 1,
    ),
    VehicleCategory(
      id: '2',
      name: 'SUV',
      code: 'SUV',
      description: 'Sport utility vehicle',
      iconName: 'directions_car_filled',
      colorHex: '10B981',
      sortOrder: 2,
    ),
    VehicleCategory(
      id: '3',
      name: 'Pickup Truck',
      code: 'PKP',
      description: 'Light pickup truck',
      iconName: 'local_shipping',
      colorHex: 'F59E0B',
      sortOrder: 3,
    ),
    VehicleCategory(
      id: '4',
      name: 'Van',
      code: 'VAN',
      description: 'Passenger or cargo van',
      iconName: 'airport_shuttle',
      colorHex: '8B5CF6',
      sortOrder: 4,
    ),
    VehicleCategory(
      id: '5',
      name: 'Bus',
      code: 'BUS',
      description: 'Passenger bus',
      iconName: 'directions_bus',
      colorHex: 'EC4899',
      sortOrder: 5,
    ),
    VehicleCategory(
      id: '6',
      name: 'Heavy Truck',
      code: 'HVY',
      description: 'Heavy duty truck',
      iconName: 'local_shipping',
      colorHex: 'EF4444',
      isActive: false,
      sortOrder: 6,
    ),
  ];

  @override
  Future<List<VehicleCategory>> getAll() async {
    // TODO: Replace with API call
    // final response = await _apiClient.get('/api/masters/vehicle-categories');
    // return (response.data as List).map((e) => VehicleCategory.fromJson(e)).toList();

    // Mock delay to simulate network
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_mockData)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  @override
  Future<VehicleCategory?> getById(String id) async {
    // TODO: Replace with API call
    // final response = await _apiClient.get('/api/masters/vehicle-categories/$id');
    // return VehicleCategory.fromJson(response.data);

    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _mockData.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<VehicleCategory> create(VehicleCategory item) async {
    // TODO: Replace with API call
    // final response = await _apiClient.post('/api/masters/vehicle-categories', data: item.toJson());
    // return VehicleCategory.fromJson(response.data);

    await Future.delayed(const Duration(milliseconds: 300));
    final newItem = item.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sortOrder: _mockData.length + 1,
    );
    _mockData.add(newItem);
    return newItem;
  }

  @override
  Future<VehicleCategory> update(VehicleCategory item) async {
    // TODO: Replace with API call
    // final response = await _apiClient.put('/api/masters/vehicle-categories/${item.id}', data: item.toJson());
    // return VehicleCategory.fromJson(response.data);

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
