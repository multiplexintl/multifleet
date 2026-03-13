// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../../../models/vendor.dart';
// import '../../../widgets/master_crud_widget.dart';

// /// ============================================================
// /// VENDORS SETTINGS
// /// ============================================================

// class VendorsSettings extends StatelessWidget {
//   const VendorsSettings({super.key});

//   static final List<MasterField> _fields = [
//     const MasterField(
//       key: 'name',
//       label: 'Vendor Name',
//       required: true,
//       hint: 'e.g., Al Futtaim Service Center',
//       maxLength: 100,
//     ),
//     const MasterField(
//       key: 'code',
//       label: 'Short Code',
//       hint: 'e.g., AFS',
//       maxLength: 10,
//     ),
//     MasterField(
//       key: 'type',
//       label: 'Vendor Type',
//       type: MasterFieldType.dropdown,
//       required: true,
//       defaultValue: 'Garage',
//       dropdownOptions: vendorTypes.map((t) => DropdownOption(t, t)).toList(),
//     ),
//     const MasterField(
//       key: 'contactPerson',
//       label: 'Contact Person',
//       hint: 'Name of primary contact',
//       maxLength: 50,
//     ),
//     const MasterField(
//       key: 'phone',
//       label: 'Phone Number',
//       hint: 'e.g., +971 4 555 1234',
//       maxLength: 20,
//     ),
//     const MasterField(
//       key: 'email',
//       label: 'Email',
//       hint: 'e.g., contact@vendor.com',
//       maxLength: 100,
//     ),
//     const MasterField(
//       key: 'city',
//       label: 'City',
//       hint: 'e.g., Dubai',
//       maxLength: 50,
//     ),
//     const MasterField(
//       key: 'address',
//       label: 'Address',
//       type: MasterFieldType.multiline,
//       maxLines: 2,
//       maxLength: 200,
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
//     final repository = Get.put(VendorRepository());

//     return MasterCrudWidget<Vendor>(
//       title: 'Vendors',
//       subtitle: 'Manage service providers and suppliers',
//       icon: Icons.store_outlined,
//       repository: repository,
//       fields: _fields,
//       showColorIndicator: false,
//       showIcon: false,
//       createItem: (data) => Vendor(
//         id: '',
//         name: data['name'] ?? '',
//         code: data['code'],
//         type: data['type'] ?? 'Garage',
//         contactPerson: data['contactPerson'],
//         phone: data['phone'],
//         email: data['email'],
//         city: data['city'],
//         address: data['address'],
//         notes: data['notes'],
//       ),
//       updateItem: (existing, data) => existing.copyWith(
//         name: data['name'],
//         code: data['code'],
//         type: data['type'],
//         contactPerson: data['contactPerson'],
//         phone: data['phone'],
//         email: data['email'],
//         city: data['city'],
//         address: data['address'],
//         notes: data['notes'],
//       ),
//       extractFormData: (item) => {
//         'name': item.name,
//         'code': item.code,
//         'type': item.type,
//         'contactPerson': item.contactPerson,
//         'phone': item.phone,
//         'email': item.email,
//         'city': item.city,
//         'address': item.address,
//         'notes': item.notes,
//       },
//     );
//   }
// }
