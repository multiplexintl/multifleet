// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../../../models/settings/base_master.dart';
// import '../../../widgets/master_crud_widget.dart';

// /// ============================================================
// /// EXPENSE CATEGORIES SETTINGS
// /// ============================================================

// class ExpenseCategoriesSettings extends StatelessWidget {
//   const ExpenseCategoriesSettings({super.key});

//   static final List<MasterField> _fields = [
//     const MasterField(
//       key: 'name',
//       label: 'Category Name',
//       required: true,
//       hint: 'e.g., Fuel, Maintenance, Tolls',
//       maxLength: 50,
//     ),
//     const MasterField(
//       key: 'code',
//       label: 'Code',
//       hint: 'e.g., FUEL, MAINT',
//       maxLength: 10,
//     ),
//     MasterField(
//       key: 'expenseType',
//       label: 'Expense Type',
//       type: MasterFieldType.dropdown,
//       required: true,
//       defaultValue: 'Variable',
//       dropdownOptions: expenseTypes.map((t) => DropdownOption(t, t)).toList(),
//     ),
//     const MasterField(
//       key: 'isTaxable',
//       label: 'Taxable',
//       type: MasterFieldType.toggle,
//       defaultValue: false,
//     ),
//     const MasterField(
//       key: 'taxPercent',
//       label: 'Tax Percentage',
//       type: MasterFieldType.number,
//       hint: 'e.g., 5',
//     ),
//     const MasterField(
//       key: 'approvalThreshold',
//       label: 'Approval Threshold',
//       type: MasterFieldType.number,
//       hint: 'Amount requiring approval',
//     ),
//     const MasterField(
//       key: 'colorHex',
//       label: 'Color',
//       type: MasterFieldType.color,
//     ),
//     const MasterField(
//       key: 'description',
//       label: 'Description',
//       type: MasterFieldType.multiline,
//       maxLines: 2,
//       maxLength: 200,
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final repository = Get.put(ExpenseCategoryRepository());

//     return MasterCrudWidget<ExpenseCategory>(
//       title: 'Expense Categories',
//       subtitle: 'Manage expense types and tax settings',
//       icon: Icons.payments_outlined,
//       repository: repository,
//       fields: _fields,
//       showColorIndicator: true,
//       showIcon: false,
//       createItem: (data) => ExpenseCategory(
//         id: '',
//         name: data['name'] ?? '',
//         code: data['code'],
//         expenseType: data['expenseType'] ?? 'Variable',
//         isTaxable: data['isTaxable'] ?? false,
//         taxPercent: data['taxPercent']?.toDouble(),
//         approvalThreshold: data['approvalThreshold']?.toDouble(),
//         colorHex: data['colorHex'],
//         description: data['description'],
//       ),
//       updateItem: (existing, data) => existing.copyWith(
//         name: data['name'],
//         code: data['code'],
//         expenseType: data['expenseType'],
//         isTaxable: data['isTaxable'],
//         taxPercent: data['taxPercent']?.toDouble(),
//         approvalThreshold: data['approvalThreshold']?.toDouble(),
//         colorHex: data['colorHex'],
//         description: data['description'],
//       ),
//       extractFormData: (item) => {
//         'name': item.name,
//         'code': item.code,
//         'expenseType': item.expenseType,
//         'isTaxable': item.isTaxable,
//         'taxPercent': item.taxPercent?.toInt(),
//         'approvalThreshold': item.approvalThreshold?.toInt(),
//         'colorHex': item.colorHex,
//         'description': item.description,
//       },
//     );
//   }
// }
