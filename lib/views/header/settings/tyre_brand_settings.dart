// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// /// ============================================================
// /// TIRE BRANDS SETTINGS
// /// ============================================================

// class TireBrandsSettings extends StatelessWidget {
//   const TireBrandsSettings({super.key});

//   static final List<MasterField> _fields = [
//     const MasterField(
//       key: 'name',
//       label: 'Brand Name',
//       required: true,
//       hint: 'e.g., Michelin, Bridgestone',
//       maxLength: 50,
//     ),
//     const MasterField(
//       key: 'country',
//       label: 'Country of Origin',
//       hint: 'e.g., France, Japan',
//       maxLength: 50,
//     ),
//     MasterField(
//       key: 'tier',
//       label: 'Brand Tier',
//       type: MasterFieldType.dropdown,
//       dropdownOptions: tireTiers.map((t) => DropdownOption(t, t)).toList(),
//     ),
//     const MasterField(
//       key: 'warrantyMonths',
//       label: 'Warranty (Months)',
//       type: MasterFieldType.number,
//       hint: 'e.g., 48',
//     ),
//     const MasterField(
//       key: 'notes',
//       label: 'Notes',
//       type: MasterFieldType.multiline,
//       maxLines: 2,
//       maxLength: 200,
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final repository = Get.put(TireBrandRepository());

//     return MasterCrudWidget<TireBrand>(
//       title: 'Tire Brands',
//       subtitle: 'Manage tire brands and specifications',
//       icon: Icons.tire_repair_outlined,
//       repository: repository,
//       fields: _fields,
//       showColorIndicator: false,
//       showIcon: false,
//       createItem: (data) => TireBrand(
//         id: '',
//         name: data['name'] ?? '',
//         country: data['country'],
//         tier: data['tier'],
//         warrantyMonths: data['warrantyMonths'],
//         notes: data['notes'],
//       ),
//       updateItem: (existing, data) => existing.copyWith(
//         name: data['name'],
//         country: data['country'],
//         tier: data['tier'],
//         warrantyMonths: data['warrantyMonths'],
//         notes: data['notes'],
//       ),
//       extractFormData: (item) => {
//         'name': item.name,
//         'country': item.country,
//         'tier': item.tier,
//         'warrantyMonths': item.warrantyMonths,
//         'notes': item.notes,
//       },
//     );
//   }
// }
