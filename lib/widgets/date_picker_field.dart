import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:multifleet/theme/app_theme.dart';

/// ============================================================
/// DatePickerField
/// ============================================================
/// Reusable date (+ optional time) picker field.
///
/// Two modes:
///  • Reactive  — pass [value] as `Rx[DateTime?]`; rebuilds automatically.
///  • Plain     — pass [staticValue] + [onChanged]; call setState externally.
///
/// Optional params:
///  [label]        — text label above the field.
///  [isRequired]   — shows red asterisk.
///  [pickTime]     — also shows a time picker after date. Default: false.
///  [clearable]    — show ✕ button to clear the value. Default: true.
///  [hint]         — placeholder when empty.
///  [warnIfPast]   — tints field amber when date is in the past. Default: false.
///  [firstDate]    — earliest selectable (default: 10 years ago).
///  [lastDate]     — latest selectable (default: 10 years ahead).
/// ============================================================

class DatePickerField extends StatefulWidget {
  final String label;
  final Rx<DateTime?>? value;
  final DateTime? staticValue;
  final ValueChanged<DateTime>? onChanged;
  final VoidCallback? onCleared;
  final bool isRequired;
  final bool pickTime;
  final bool clearable;
  final bool warnIfPast;
  final String? hint;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const DatePickerField({
    super.key,
    required this.label,
    this.value,
    this.staticValue,
    this.onChanged,
    this.onCleared,
    this.isRequired = false,
    this.pickTime = false,
    this.clearable = true,
    this.warnIfPast = false,
    this.hint,
    this.firstDate,
    this.lastDate,
  });

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  // Local mirror of staticValue so we rebuild when parent calls setState.
  DateTime? _localValue;

  @override
  void initState() {
    super.initState();
    _localValue = widget.staticValue;
  }

  @override
  void didUpdateWidget(DatePickerField old) {
    super.didUpdateWidget(old);
    // Sync when parent updates staticValue (e.g. edit button pressed).
    if (widget.staticValue != old.staticValue) {
      _localValue = widget.staticValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.value != null) {
      return Obx(() => _buildField(context, widget.value!.value));
    }
    return _buildField(context, _localValue);
  }

  Widget _buildField(BuildContext context, DateTime? current) {
    final bool hasValue = current != null;
    final bool isPast =
        widget.warnIfPast && hasValue && current.isBefore(DateTime.now());

    final String displayText = hasValue
        ? (widget.pickTime
            ? DateFormat('dd MMM yyyy   hh:mm a').format(current)
            : DateFormat('dd MMM yyyy').format(current))
        : (widget.hint ??
            (widget.pickTime ? 'Select date & time' : 'Select date'));

    // Colours
    final Color borderColor = isPast
        ? Colors.orange.shade400
        : hasValue
            ? AppColors.accent.withOpacity(0.5)
            : AppColors.divider;
    final Color bgColor = isPast
        ? Colors.orange.withOpacity(0.05)
        : AppColors.surface;
    final Color iconColor =
        isPast ? Colors.orange.shade600 : AppColors.accent;
    final Color textColor =
        hasValue ? AppColors.textPrimary : AppColors.textMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Label ──────────────────────────────────────────
        Row(
          children: [
            Text(
              widget.label,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            if (widget.isRequired) ...[
              const SizedBox(width: 3),
              Text('*',
                  style: TextStyle(color: AppColors.error, fontSize: 13)),
            ],
            if (isPast) ...[
              const SizedBox(width: 6),
              Icon(Icons.warning_amber_rounded,
                  size: 13, color: Colors.orange.shade600),
              const SizedBox(width: 3),
              Text('Expired',
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w600)),
            ],
          ],
        ),
        const SizedBox(height: 6),

        // ── Field ──────────────────────────────────────────
        InkWell(
          onTap: () => _pick(context, current),
          borderRadius: AppRadius.borderMd,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: AppRadius.borderMd,
              border: Border.all(color: borderColor, width: hasValue ? 1.5 : 1),
            ),
            child: Row(
              children: [
                // Calendar icon
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    hasValue
                        ? Icons.event_available_outlined
                        : Icons.calendar_today_outlined,
                    key: ValueKey(hasValue),
                    color: iconColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),

                // Text
                Expanded(
                  child: Text(
                    displayText,
                    style: AppTextStyles.body.copyWith(
                      color: textColor,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Clear button or chevron
                if (hasValue && widget.clearable)
                  GestureDetector(
                    onTap: _clear,
                    child: Icon(Icons.close,
                        size: 16, color: AppColors.textMuted),
                  )
                else
                  Icon(Icons.expand_more,
                      size: 20, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pick(BuildContext context, DateTime? current) async {
    final first = widget.firstDate ??
        DateTime.now().subtract(const Duration(days: 365 * 10));
    final last = widget.lastDate ??
        DateTime.now().add(const Duration(days: 365 * 10));

    // Clamp initialDate within bounds
    final initial = current != null
        ? (current.isBefore(first)
            ? first
            : current.isAfter(last)
                ? last
                : current)
        : DateTime.now().clamp(first, last);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      builder: (ctx, child) => _themed(ctx, child),
    );

    if (pickedDate == null || !context.mounted) return;

    if (widget.pickTime) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: current != null
            ? TimeOfDay.fromDateTime(current)
            : TimeOfDay.now(),
        builder: (ctx, child) => _themed(ctx, child),
      );
      if (pickedTime == null) return;
      _emit(DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      ));
    } else {
      _emit(DateTime(pickedDate.year, pickedDate.month, pickedDate.day));
    }
  }

  void _emit(DateTime result) {
    if (widget.value != null) {
      widget.value!.value = result;
    } else {
      setState(() => _localValue = result);
    }
    widget.onChanged?.call(result);
  }

  void _clear() {
    if (widget.value != null) {
      widget.value!.value = null;
    } else {
      setState(() => _localValue = null);
    }
    widget.onCleared?.call();
  }

  Widget _themed(BuildContext context, Widget? child) {
    return Theme(
      data: Theme.of(Get.context!).copyWith(
        colorScheme: ColorScheme.light(
          primary: AppColors.accent,
          onPrimary: Colors.white,
          surface: AppColors.cardBg,
          onSurface: AppColors.textPrimary,
        ),
      ),
      child: child!,
    );
  }
}

// Extension used internally to clamp DateTime.
extension _DateTimeClamp on DateTime {
  DateTime clamp(DateTime min, DateTime max) {
    if (isBefore(min)) return min;
    if (isAfter(max)) return max;
    return this;
  }
}
