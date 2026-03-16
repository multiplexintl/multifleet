import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/settings/base_master.dart';
import '../../../models/settings/vehicle_category.dart';
import '../../../widgets/master_crud_widget.dart';

/// ============================================================
/// VEHICLE CATEGORIES SETTINGS
/// ============================================================
/// Settings page for managing vehicle categories master data.
/// Uses the generic MasterCrudWidget.
/// ============================================================

class VehicleCategoriesSettings extends StatelessWidget {
  const VehicleCategoriesSettings({super.key});

  // Define form fields for Vehicle Category
  static final List<MasterField> _fields = [
    const MasterField(
      key: 'name',
      label: 'Category Name',
      required: true,
      hint: 'e.g., Sedan, SUV, Truck',
      maxLength: 50,
    ),
    const MasterField(
      key: 'code',
      label: 'Short Code',
      hint: 'e.g., SDN, SUV (optional)',
      maxLength: 10,
    ),
    const MasterField(
      key: 'description',
      label: 'Description',
      type: MasterFieldType.multiline,
      hint: 'Brief description of this category',
      maxLines: 2,
      maxLength: 200,
    ),
    MasterField(
      key: 'iconName',
      label: 'Icon',
      type: MasterFieldType.icon,
      dropdownOptions: vehicleCategoryIcons.entries
          .map((e) => DropdownOption(e.key, _formatIconName(e.key)))
          .toList(),
    ),
    const MasterField(
      key: 'colorHex',
      label: 'Color',
      type: MasterFieldType.color,
    ),
  ];

  static String _formatIconName(String name) {
    return name.replaceAll('_', ' ').split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    // Create repository instance - in real app, inject via GetX
    final repository = Get.put(VehicleCategoryRepository());

    return MasterCrudWidget<VehicleCategory>(
      title: 'Vehicle Categories',
      subtitle: 'Manage vehicle types and classifications',
      icon: Icons.directions_car_outlined,
      repository: repository,
      fields: _fields,
      showColorIndicator: true,
      showIcon: true,

      // Factory to create new item from form data
      createItem: (data) => VehicleCategory(
        id: '', // Will be assigned by repository
        name: data['name'] ?? '',
        code: data['code'],
        description: data['description'],
        iconName: data['iconName'],
        colorHex: data['colorHex'],
      ),

      // Factory to update existing item
      updateItem: (existing, data) => existing.copyWith(
        name: data['name'],
        code: data['code'],
        description: data['description'],
        iconName: data['iconName'],
        colorHex: data['colorHex'],
      ),

      // Extract form data from existing item
      extractFormData: (item) => {
        'name': item.name,
        'code': item.code,
        'description': item.description,
        'iconName': item.iconName,
        'colorHex': item.colorHex,
      },
    );
  }
}
