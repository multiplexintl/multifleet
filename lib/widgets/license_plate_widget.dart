import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DubaiLicensePlateWidget extends StatefulWidget {
  final Function(String letter, String emirate, String number) onDataChanged;
  final double? width; // Optional custom width

  const DubaiLicensePlateWidget({
    super.key,
    required this.onDataChanged,
    this.width,
  });

  @override
  State<DubaiLicensePlateWidget> createState() =>
      _DubaiLicensePlateWidgetState();
}

class _DubaiLicensePlateWidgetState extends State<DubaiLicensePlateWidget> {
  String _letter = '';
  String _emirate = 'DUBAI';
  String _arabicText = 'دبي'; // Default Arabic for Dubai
  String _number = '';

  final Map<String, String> _emiratesMap = {
    'DUBAI': 'دبي',
    'U.A.E': 'الإمارات',
    // 'ABU DHABI': 'أبوظبي',
    // 'SHARJAH': 'الشارقة',
    // 'AJMAN': 'عجمان',
    // 'UMM AL QUWAIN': 'أم القيوين',
    // 'RAS AL KHAIMAH': 'رأس الخيمة',
    // 'FUJAIRAH': 'الفجيرة',
  };

  void _updateParent() {
    widget.onDataChanged(_letter, _emirate, _number);
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width to calculate responsive sizes
    final screenWidth = MediaQuery.of(context).size.width;

    // Make plate width responsive with appropriate constraints
    final plateWidth = widget.width ??
        (screenWidth < 400
            ? screenWidth * 0.85
            : screenWidth < 600
                ? 320.0
                : 380.0);

    // Height proportional to width for correct aspect ratio
    final plateHeight = plateWidth / 6;

    // Font sizes proportional to plate dimensions
    final letterFontSize = plateHeight * 0.55;
    final emirateFontSize = plateHeight * 0.25;
    final numberFontSize = plateHeight * 0.55;
    final arabicFontSize = plateHeight * 0.22;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: plateWidth,
        height: plateHeight,
        decoration: BoxDecoration(
          // Metallic outer border
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey.shade400,
              Colors.grey.shade300,
              Colors.grey.shade200,
              Colors.grey.shade300,
            ],
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(plateHeight * 0.09), // Responsive padding
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  // Letter section (A)
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () => _showLetterInput(context),
                      child: Container(
                        margin: EdgeInsets.all(plateHeight * 0.02),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Text(
                              _letter.isEmpty ? 'A' : _letter,
                              style: TextStyle(
                                fontSize: letterFontSize,
                                color: _letter.isEmpty
                                    ? Colors.grey.shade500
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Arial',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Middle section (Emirates + Year)
                  Expanded(
                    flex: 4,
                    child: GestureDetector(
                      onTap: () => _showEmirateDropdown(context),
                      child: Column(
                        children: [
                          // Arabic text for selected emirate
                          Expanded(
                            flex: 1,
                            child: Container(
                              alignment: Alignment.bottomCenter,
                              // padding: EdgeInsets.only(bottom: 2),
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Text(
                                  _arabicText,
                                  style: TextStyle(
                                    fontSize: arabicFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    height: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Emirate name
                          Expanded(
                            flex: 2,
                            child: Container(
                              alignment: Alignment.center,
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Text(
                                  _emirate,
                                  style: TextStyle(
                                    fontSize: emirateFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Number section (0123)
                  Expanded(
                    flex: 6,
                    child: GestureDetector(
                      onTap: () => _showNumberInput(context),
                      child: Container(
                        margin: EdgeInsets.all(plateHeight * 0.02),
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            _number.isEmpty ? '0123' : _number,
                            style: TextStyle(
                              fontSize: numberFontSize,
                              color: _number.isEmpty
                                  ? Colors.grey.shade400
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Arial',
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Show dialog for letter input
  void _showLetterInput(BuildContext context) {
    final TextEditingController controller =
        TextEditingController(text: _letter);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Letter Code'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'A, B, AB, etc.',
              labelText: 'Letter Code',
            ),
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[A-Za-z]')),
              LengthLimitingTextInputFormatter(2),
            ],
            onChanged: (value) {
              controller.value = controller.value.copyWith(
                text: value.toUpperCase(),
                selection: TextSelection.collapsed(offset: value.length),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _letter = controller.text.toUpperCase();
                  _updateParent();
                });
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Show dropdown for emirate selection
  void _showEmirateDropdown(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Emirate'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _emiratesMap.length,
              itemBuilder: (context, index) {
                final emirate = _emiratesMap.keys.elementAt(index);
                return ListTile(
                  title: Text(emirate),
                  selected: emirate == _emirate,
                  onTap: () {
                    setState(() {
                      _emirate = emirate;
                      _arabicText = _emiratesMap[emirate]!;
                      _updateParent();
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Show dialog for number input
  void _showNumberInput(BuildContext context) {
    final TextEditingController controller =
        TextEditingController(text: _number);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Plate Number'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: '1234, 56789, etc.',
              labelText: 'Plate Number',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(7),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _number = controller.text;
                  _updateParent();
                });
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
