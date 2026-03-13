import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/settings/base_master.dart';
import '../../../models/settings/fine_category.dart';
import '../../../widgets/master_crud_widget.dart';

/// ============================================================
/// FINE CATEGORIES SETTINGS
/// ============================================================

class FineCategoriesSettings extends StatelessWidget {
  const FineCategoriesSettings({super.key});

  static final List<MasterField> _fields = [
    const MasterField(
      key: 'name',
      label: 'Fine Type',
      required: true,
      hint: 'e.g., Speeding, Parking Violation',
      maxLength: 50,
    ),
    const MasterField(
      key: 'code',
      label: 'Short Code',
      hint: 'e.g., SPD, PRK',
      maxLength: 10,
    ),
    MasterField(
      key: 'severity',
      label: 'Severity',
      type: MasterFieldType.dropdown,
      required: true,
      defaultValue: 'Medium',
      dropdownOptions:
          fineSeverityLevels.map((c) => DropdownOption(c, c)).toList(),
    ),
    const MasterField(
      key: 'defaultAmount',
      label: 'Default Amount',
      type: MasterFieldType.number,
      hint: 'e.g., 500',
    ),
    MasterField(
      key: 'currency',
      label: 'Currency',
      type: MasterFieldType.dropdown,
      defaultValue: 'AED',
      dropdownOptions: currencies.map((c) => DropdownOption(c, c)).toList(),
    ),
    const MasterField(
      key: 'blackPoints',
      label: 'Black Points',
      type: MasterFieldType.number,
      hint: 'e.g., 4',
    ),
    const MasterField(
      key: 'description',
      label: 'Description',
      type: MasterFieldType.multiline,
      maxLines: 2,
      maxLength: 200,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final repository = Get.put(FineCategoryRepository());

    return MasterCrudWidget<FineCategory>(
      title: 'Fine Categories',
      subtitle: 'Manage traffic fine types and penalties',
      icon: Icons.receipt_long_outlined,
      repository: repository,
      fields: _fields,
      showColorIndicator: true,
      showIcon: false,
      createItem: (data) => FineCategory(
        id: '',
        name: data['name'] ?? '',
        code: data['code'],
        severity: data['severity'] ?? 'Medium',
        defaultAmount: data['defaultAmount']?.toDouble(),
        currency: data['currency'] ?? 'AED',
        blackPoints: data['blackPoints'],
        description: data['description'],
      ),
      updateItem: (existing, data) => existing.copyWith(
        name: data['name'],
        code: data['code'],
        severity: data['severity'],
        defaultAmount: data['defaultAmount']?.toDouble(),
        currency: data['currency'],
        blackPoints: data['blackPoints'],
        description: data['description'],
      ),
      extractFormData: (item) => {
        'name': item.name,
        'code': item.code,
        'severity': item.severity,
        'defaultAmount': item.defaultAmount?.toInt(),
        'currency': item.currency,
        'blackPoints': item.blackPoints,
        'description': item.description,
      },
    );
  }
}
