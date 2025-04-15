import 'package:flutter/material.dart';
import 'package:multifleet/widgets/button_widget.dart';

import 'license_plate_widget.dart';

class SearchVehicleWidget extends StatelessWidget {
  final String? heading;
  final String? labelText;
  final TextEditingController? controller;
  final void Function()? onSearch;
  final String? searchText;
  final void Function()? onClear;
  final String? clearText;
  final void Function()? onTapTextField;
  final dynamic Function(String, String, String) onDataChanged;
  const SearchVehicleWidget(
      {super.key,
      this.controller,
      this.onSearch,
      this.onClear,
      this.heading,
      this.searchText,
      this.clearText,
      this.labelText,
      this.onTapTextField,
      required this.onDataChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              heading ?? 'Search Vehicle',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: DubaiLicensePlateWidget(onDataChanged: onDataChanged),
                ),
                // Expanded(
                //   flex: 3,
                //   child: TextField(
                //     onTap: onTapTextField,
                //     controller: controller,
                //     decoration: InputDecoration(
                //       labelText: labelText ?? 'Enter Plate Number',
                //       border: OutlineInputBorder(
                //         borderRadius: BorderRadius.circular(12),
                //       ),
                //       prefixIcon: const Icon(Icons.car_rental),
                //     ),
                //   ),
                // ),
                const SizedBox(width: 16),
                Expanded(
                    child: CustomButtonWidget(
                  title: searchText ?? "Search",
                  isCancel: false,
                  onPressed: onSearch,
                )),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButtonWidget(
                    title: clearText ?? "Clear",
                    isCancel: true,
                    onPressed: onClear,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
