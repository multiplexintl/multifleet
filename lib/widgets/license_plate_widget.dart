import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../models/plate_data.dart';
import '../services/company_service.dart';

enum PlateCountry { uae, qatar, oman, bahrain }

class LicensePlateWidget extends StatefulWidget {
  final PlateData? initialData;
  final ValueChanged<PlateData>? onChanged;
  final bool readOnly;
  final double? width;

  const LicensePlateWidget({
    super.key,
    this.initialData,
    this.onChanged,
    this.readOnly = false,
    this.width,
  });

  @override
  State<LicensePlateWidget> createState() => _LicensePlateWidgetState();
}

class _LicensePlateWidgetState extends State<LicensePlateWidget> {
  late PlateCountry _country;
  late PlateData _data;
  Worker? _companyWorker;

  // Company to country mapping
  static const _companyCountryMap = {
    'EPIC01': PlateCountry.uae,
    'EPIC02': PlateCountry.uae,
    'EPIC03': PlateCountry.qatar,
    'EPIC04': PlateCountry.oman,
    'EPIC05': PlateCountry.bahrain,
  };

  // UAE Emirates with Arabic names
  static const _uaeEmirates = {
    'DUBAI': 'دبي',
    'ABU DHABI': 'أبوظبي',
    'SHARJAH': 'الشارقة',
    'AJMAN': 'عجمان',
    'UMM AL QUWAIN': 'أم القيوين',
    'RAS AL KHAIMAH': 'رأس الخيمة',
    'FUJAIRAH': 'الفجيرة',
  };

  @override
  void initState() {
    super.initState();
    _initializeCountry();
    _data = widget.initialData ?? const PlateData();
    _listenToCompanyChanges();
  }

  void _initializeCountry() {
    try {
      final companyService = Get.find<CompanyService>();
      final companyId = companyService.selectedCompany?.id ?? 'EPIC01';
      _country = _companyCountryMap[companyId] ?? PlateCountry.uae;
    } catch (_) {
      _country = PlateCountry.uae;
    }
  }

  void _listenToCompanyChanges() {
    try {
      _companyWorker = ever(
        Get.find<CompanyService>().selectedCompanyObs,
        (company) {
          if (company != null && mounted) {
            final newCountry =
                _companyCountryMap[company.id] ?? PlateCountry.uae;
            if (newCountry != _country) {
              setState(() {
                _country = newCountry;
                _data = const PlateData(); // Reset on country change
              });
              _notifyChange();
            }
          }
        },
      );
    } catch (_) {}
  }

  @override
  void didUpdateWidget(LicensePlateWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialData != oldWidget.initialData &&
        widget.initialData != null) {
      setState(() => _data = widget.initialData!);
    }
  }

  @override
  void dispose() {
    _companyWorker?.dispose();
    super.dispose();
  }

  void _notifyChange() {
    widget.onChanged?.call(_data);
  }

  void _updateData(PlateData newData) {
    setState(() => _data = newData);
    _notifyChange();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final plateWidth =
            widget.width ?? _calculateWidth(constraints.maxWidth);
        final plateHeight = plateWidth / _aspectRatio;

        return Container(
          width: plateWidth,
          height: plateHeight,
          decoration: _plateDecoration,
          clipBehavior: Clip.antiAlias,
          child: _buildPlateContent(
            plateHeight,
            backgroundColor: _backgroundColor,
          ),
        );
      },
    );
  }

  double _calculateWidth(double maxWidth) {
    return maxWidth.clamp(200.0, 400.0);
  }

  double get _aspectRatio {
    switch (_country) {
      case PlateCountry.oman:
        return 4.5;
      default:
        return 5.5;
    }
  }

  BoxDecoration get _plateDecoration {
    return BoxDecoration(
      color: _backgroundColor,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: Colors.grey.shade400, width: 1.5),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Color get _backgroundColor {
    switch (_country) {
      case PlateCountry.oman:
        return const Color(0xFFFFD700); // Yellow
      default:
        return Colors.white;
    }
  }

  Widget _buildPlateContent(double height, {Color? backgroundColor}) {
    switch (_country) {
      case PlateCountry.uae:
        return _UAEPlate(
          data: _data,
          height: height,
          readOnly: widget.readOnly,
          onUpdate: _updateData,
          emirates: _uaeEmirates,
        );
      case PlateCountry.qatar:
        return _QatarPlate(
          data: _data,
          height: height,
          readOnly: widget.readOnly,
          onUpdate: _updateData,
        );
      case PlateCountry.oman:
        return _OmanPlate(
          data: _data,
          height: height,
          readOnly: widget.readOnly,
          onUpdate: _updateData,
          bgColor: backgroundColor,
        );
      case PlateCountry.bahrain:
        return _BahrainPlate(
          data: _data,
          height: height,
          readOnly: widget.readOnly,
          onUpdate: _updateData,
        );
    }
  }
}

// ============================================================================
// Inline Editable Text Field - replaces dialog-based input
// Uses TextField with transparent decoration for web & mobile compatibility
// ============================================================================
class _InlinePlateField extends StatefulWidget {
  final String? value;
  final String placeholder;
  final double fontSize;
  final Color? color;
  final Color? bgColor;
  final bool readOnly;
  final int maxLength;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String> onChanged;

  const _InlinePlateField({
    required this.value,
    required this.placeholder,
    required this.fontSize,
    this.color,
    required this.readOnly,
    required this.maxLength,
    required this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    required this.onChanged,
    this.bgColor,
  });

  @override
  State<_InlinePlateField> createState() => _InlinePlateFieldState();
}

class _InlinePlateFieldState extends State<_InlinePlateField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? '');
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      final hadFocus = _hasFocus;
      setState(() => _hasFocus = _focusNode.hasFocus);
      // Commit on blur
      if (hadFocus && !_focusNode.hasFocus) {
        _commitValue();
      }
    });
  }

  @override
  void didUpdateWidget(_InlinePlateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && !_hasFocus) {
      _controller.text = widget.value ?? '';
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _commitValue() {
    String value = _controller.text;
    if (widget.textCapitalization == TextCapitalization.characters) {
      value = value.toUpperCase();
    }
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.color ?? Colors.black;
    final bgColor = widget.bgColor ?? Colors.white;

    return Center(
      child: widget.readOnly
          ? FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                (widget.value?.isNotEmpty == true)
                    ? widget.value!
                    : widget.placeholder,
                style: TextStyle(
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.bold,
                  color: (widget.value?.isNotEmpty == true)
                      ? textColor
                      : Colors.grey.shade400,
                  letterSpacing: 1,
                ),
              ),
            )
          : TextField(
              controller: _controller,
              focusNode: _focusNode,
              readOnly: widget.readOnly,
              keyboardType: widget.keyboardType,
              textCapitalization: widget.textCapitalization,
              textAlign: TextAlign.center,
              maxLength: widget.maxLength,
              inputFormatters: [
                ...?widget.inputFormatters,
              ],
              style: TextStyle(
                fontSize: widget.fontSize,
                fontWeight: FontWeight.bold,
                color: textColor,
                letterSpacing: 1,
              ),
              cursorColor: textColor,
              cursorHeight: widget.fontSize - 8,
              cursorWidth: 2,
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
                isCollapsed: true,
                counterText: '', // Hide character counter
                hintText: widget.placeholder,
                hintStyle: TextStyle(
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade400,
                  letterSpacing: 1,
                ),
                filled: true,
                fillColor: bgColor,
              ),
              onChanged: (value) {
                if (widget.textCapitalization ==
                    TextCapitalization.characters) {
                  final upper = value.toUpperCase();
                  if (upper != value) {
                    _controller.value = TextEditingValue(
                      text: upper,
                      selection: TextSelection.collapsed(offset: upper.length),
                    );
                  }
                }
                // Live callback so data flows immediately
                _commitValue();
              },
              onSubmitted: (_) => _commitValue(),
            ),
    );
  }
}

// ============================================================================
// Scrollable Emirate Widget - scroll to cycle through emirates (UAE only)
// ============================================================================
class _ScrollableEmirate extends StatefulWidget {
  final String? currentEmirate;
  final Map<String, String> emirates;
  final double height;
  final bool readOnly;
  final ValueChanged<String> onChanged;

  const _ScrollableEmirate({
    required this.currentEmirate,
    required this.emirates,
    required this.height,
    required this.readOnly,
    required this.onChanged,
  });

  @override
  State<_ScrollableEmirate> createState() => _ScrollableEmirateState();
}

class _ScrollableEmirateState extends State<_ScrollableEmirate> {
  late List<String> _emirateKeys;
  late int _currentIndex;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _emirateKeys = widget.emirates.keys.toList();
    _currentIndex = _emirateKeys.indexOf(widget.currentEmirate ?? 'DUBAI');
    if (_currentIndex < 0) _currentIndex = 0;
  }

  @override
  void didUpdateWidget(_ScrollableEmirate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentEmirate != oldWidget.currentEmirate) {
      final idx = _emirateKeys.indexOf(widget.currentEmirate ?? 'DUBAI');
      if (idx >= 0) _currentIndex = idx;
    }
  }

  void _scrollEmirate(int delta) {
    if (widget.readOnly) return;
    setState(() {
      _currentIndex = (_currentIndex + delta) % _emirateKeys.length;
      if (_currentIndex < 0) _currentIndex = _emirateKeys.length - 1;
    });
    widget.onChanged(_emirateKeys[_currentIndex]);
  }

  String get _currentKey => _emirateKeys[_currentIndex];
  String get _arabicName => widget.emirates[_currentKey] ?? '';

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Listener(
        onPointerSignal: (event) {
          if (event is PointerScrollEvent && !widget.readOnly) {
            _scrollEmirate(event.scrollDelta.dy > 0 ? 1 : -1);
          }
        },
        child: GestureDetector(
          onVerticalDragUpdate: widget.readOnly
              ? null
              : (details) {
                  if (details.primaryDelta != null &&
                      details.primaryDelta!.abs() > 8) {
                    _scrollEmirate(details.primaryDelta! < 0 ? 1 : -1);
                  }
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: !widget.readOnly && _isHovering
                ? BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  )
                : null,
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _PlateText(
                        text: _arabicName,
                        placeholder: 'دبي',
                        fontSize: widget.height * 0.22,
                        fontWeight: FontWeight.w600,
                      ),
                      const SizedBox(height: 2),
                      _PlateText(
                        text: _currentKey,
                        placeholder: 'DUBAI',
                        fontSize: widget.height * 0.18,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
                // Scroll hint arrows on hover
                if (!widget.readOnly && _isHovering) ...[
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Icon(
                        Icons.keyboard_arrow_up,
                        size: widget.height * 0.18,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: widget.height * 0.18,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// UAE Plate: [Code] | [Emirate (Arabic/English)] | [Number]
// ============================================================================
class _UAEPlate extends StatelessWidget {
  final PlateData data;
  final double height;
  final bool readOnly;
  final ValueChanged<PlateData> onUpdate;
  final Map<String, String> emirates;

  const _UAEPlate({
    required this.data,
    required this.height,
    required this.readOnly,
    required this.onUpdate,
    required this.emirates,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: height * 0.15, vertical: height * 0.1),
      child: Row(
        children: [
          // Code section - inline editable
          Expanded(
            flex: 2,
            child: _InlinePlateField(
              value: data.code,
              placeholder: 'A',
              fontSize: height * 0.5,
              readOnly: readOnly,
              maxLength: 3,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.characters,
              onChanged: (value) =>
                  onUpdate(data.copyWith(code: value.toUpperCase())),
            ),
          ),
          // Divider
          Container(
              width: 1.5, height: height * 0.6, color: Colors.grey.shade400),
          // Emirate section - scroll to change
          Expanded(
            flex: 3,
            child: _ScrollableEmirate(
              currentEmirate: data.region ?? 'DUBAI',
              emirates: emirates,
              height: height,
              readOnly: readOnly,
              onChanged: (emirate) => onUpdate(data.copyWith(region: emirate)),
            ),
          ),
          // Divider
          Container(
              width: 1.5, height: height * 0.6, color: Colors.grey.shade400),
          // Number section - inline editable
          Expanded(
            flex: 5,
            child: _InlinePlateField(
              value: data.number,
              placeholder: '12345',
              fontSize: height * 0.5,
              readOnly: readOnly,
              maxLength: 5,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) => onUpdate(data.copyWith(number: value)),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Qatar Plate: [Flag] | [قطر / Number]
// ============================================================================
class _QatarPlate extends StatelessWidget {
  final PlateData data;
  final double height;
  final bool readOnly;
  final ValueChanged<PlateData> onUpdate;

  const _QatarPlate({
    required this.data,
    required this.height,
    required this.readOnly,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: height * 0.15, vertical: height * 0.01),
      child: Row(
        children: [
          // Flag section
          SizedBox(
            width: height * 0.8,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(
                'assets/images/qatar_flag.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    _QatarFlagFallback(height: height),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Main content
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Arabic text
                Text(
                  'قطر',
                  style: TextStyle(
                    fontSize: height * 0.20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF8B1538),
                  ),
                ),
                const SizedBox(height: 0),
                // Number - inline editable
                _InlinePlateField(
                  value: data.number,
                  placeholder: '123456',
                  fontSize: height * 0.4,
                  color: const Color(0xFF8B1538),
                  readOnly: readOnly,
                  maxLength: 6,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) => onUpdate(data.copyWith(number: value)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QatarFlagFallback extends StatelessWidget {
  final double height;
  const _QatarFlagFallback({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF8B1538), Colors.white],
          stops: [0.35, 0.35],
        ),
      ),
    );
  }
}

// ============================================================================
// Oman Plate: [Number] | [Code] | [عُمان]
// ============================================================================
class _OmanPlate extends StatelessWidget {
  final PlateData data;
  final double height;
  final bool readOnly;
  final ValueChanged<PlateData> onUpdate;
  final Color? bgColor;

  const _OmanPlate({
    required this.data,
    required this.height,
    required this.readOnly,
    required this.onUpdate,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: height * 0.15, vertical: height * 0.1),
      child: Row(
        children: [
          // Number section - inline editable
          Expanded(
            flex: 4,
            child: _InlinePlateField(
              value: data.number,
              placeholder: '12345',
              fontSize: height * 0.5,
              readOnly: readOnly,
              maxLength: 5,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) => onUpdate(data.copyWith(number: value)),
              bgColor: bgColor,
            ),
          ),
          // Divider
          Container(width: 1.5, height: height * 0.6, color: Colors.black54),
          // Code section - inline editable
          Expanded(
            flex: 2,
            child: _InlinePlateField(
              value: data.code,
              placeholder: 'A',
              fontSize: height * 0.5,
              readOnly: readOnly,
              maxLength: 2,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.characters,
              onChanged: (value) =>
                  onUpdate(data.copyWith(code: value.toUpperCase())),
              bgColor: bgColor,
            ),
          ),
          // Divider
          Container(width: 1.5, height: height * 0.6, color: Colors.black54),
          // Arabic text (static)
          Expanded(
            flex: 3,
            child: Center(
              child: Text(
                'عُمان',
                style: TextStyle(
                  fontSize: height * 0.35,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Bahrain Plate: [Flag] | [Number] | [البحرين / BAHRAIN]
// ============================================================================
class _BahrainPlate extends StatelessWidget {
  final PlateData data;
  final double height;
  final bool readOnly;
  final ValueChanged<PlateData> onUpdate;

  const _BahrainPlate({
    required this.data,
    required this.height,
    required this.readOnly,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: height * 0.15, vertical: height * 0.1),
      child: Row(
        children: [
          // Flag section
          SizedBox(
            width: height * 0.7,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(
                'assets/images/bahrain_flag.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.flag, color: Colors.red),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Number section - inline editable
          Expanded(
            flex: 5,
            child: _InlinePlateField(
              value: data.number,
              placeholder: '123456',
              fontSize: height * 0.45,
              color: const Color(0xFF1E3A8A),
              readOnly: readOnly,
              maxLength: 7,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) => onUpdate(data.copyWith(number: value)),
            ),
          ),
          // Text section
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'البحرين',
                  style: TextStyle(
                    fontSize: height * 0.22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'BAHRAIN',
                  style: TextStyle(
                    fontSize: height * 0.16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E3A8A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Shared Components
// ============================================================================

class _PlateText extends StatelessWidget {
  final String? text;
  final String placeholder;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? color;

  const _PlateText({
    required this.text,
    required this.placeholder,
    required this.fontSize,
    this.fontWeight = FontWeight.bold,
    this.color,
  });

  bool get _isEmpty => text == null || text!.isEmpty;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          _isEmpty ? placeholder : text!,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: _isEmpty ? Colors.grey.shade400 : (color ?? Colors.black),
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
