import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multifleet/theme/app_theme.dart';

/// ============================================================
/// CUSTOM DATE RANGE PICKER
/// ============================================================
/// Reusable date range picker dialog following MultiFleet Design System
/// ============================================================

class DateRangeResult {
  final DateTime? start;
  final DateTime? end;

  DateRangeResult({this.start, this.end});

  @override
  String toString() {
    return 'DateRangeResult(start: $start, end: $end)';
  }
}

Future<DateRangeResult?> showCustomDateRangePicker({
  required BuildContext context,
  DateTime? startDate,
  DateTime? endDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  return await showDialog<DateRangeResult>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _DateRangePickerDialog(
      initialStart: startDate,
      initialEnd: endDate,
      firstDate:
          firstDate ?? DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365 * 5)),
    ),
  );
}

class _DateRangePickerDialog extends StatefulWidget {
  final DateTime? initialStart;
  final DateTime? initialEnd;
  final DateTime firstDate;
  final DateTime lastDate;

  const _DateRangePickerDialog({
    this.initialStart,
    this.initialEnd,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<_DateRangePickerDialog> createState() => _DateRangePickerDialogState();
}

class _DateRangePickerDialogState extends State<_DateRangePickerDialog> {
  DateTime? _startDate;
  DateTime? _endDate;
  late DateTime _currentMonth;
  late int _selectedYear;
  late int _selectedMonth;

  // Selection state: 0 = none, 1 = start selected, 2 = both selected
  int _selectionState = 0;

  final List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStart;
    _endDate = widget.initialEnd;

    if (_startDate != null && _endDate != null) {
      _selectionState = 2;
    } else if (_startDate != null) {
      _selectionState = 1;
    }

    // Initialize to start date month or current month
    _currentMonth = _startDate ?? DateTime.now();
    _selectedYear = _currentMonth.year;
    _selectedMonth = _currentMonth.month;
  }

  void _onDayTap(DateTime date) {
    setState(() {
      if (_selectionState == 0 || _selectionState == 2) {
        // No selection or both selected → set new start
        _startDate = date;
        _endDate = null;
        _selectionState = 1;
      } else if (_selectionState == 1) {
        // Start selected → set end
        if (date.isBefore(_startDate!)) {
          // Swap if tapped date is before start
          _endDate = _startDate;
          _startDate = date;
        } else {
          _endDate = date;
        }
        _selectionState = 2;
      }
    });
  }

  void _goToPreviousMonth() {
    setState(() {
      if (_selectedMonth == 1) {
        _selectedMonth = 12;
        _selectedYear--;
      } else {
        _selectedMonth--;
      }
      _currentMonth = DateTime(_selectedYear, _selectedMonth);
    });
  }

  void _goToNextMonth() {
    setState(() {
      if (_selectedMonth == 12) {
        _selectedMonth = 1;
        _selectedYear++;
      } else {
        _selectedMonth++;
      }
      _currentMonth = DateTime(_selectedYear, _selectedMonth);
    });
  }

  void _onMonthChanged(int? month) {
    if (month != null) {
      setState(() {
        _selectedMonth = month;
        _currentMonth = DateTime(_selectedYear, _selectedMonth);
      });
    }
  }

  void _onYearChanged(int? year) {
    if (year != null) {
      setState(() {
        _selectedYear = year;
        _currentMonth = DateTime(_selectedYear, _selectedMonth);
      });
    }
  }

  List<int> _getYearRange() {
    return List.generate(
      widget.lastDate.year - widget.firstDate.year + 1,
      (index) => widget.firstDate.year + index,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
      backgroundColor: AppColors.cardBg,
      child: Container(
        width: 540,
        constraints: const BoxConstraints(maxHeight: 420),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Panel - Selected Dates
            _buildLeftPanel(),
            // Divider
            Container(width: 1, color: AppColors.divider),
            // Right Panel - Calendar
            Expanded(child: _buildRightPanel()),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftPanel() {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xl),
          bottomLeft: Radius.circular(AppRadius.xl),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select range',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 24),

          // Start Date
          Text(
            'Start:',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _startDate != null
                ? DateFormat('EEE, MMM d').format(_startDate!)
                : '—',
            style: AppTextStyles.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // End Date
          Text(
            'End:',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _endDate != null ? DateFormat('EEE, MMM d').format(_endDate!) : '—',
            style: AppTextStyles.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildRightPanel() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Month/Year Selector Row
          _buildMonthYearSelector(),
          const SizedBox(height: 16),

          // Weekday Headers
          _buildWeekdayHeaders(),
          const SizedBox(height: 8),

          // Calendar Grid
          Expanded(child: _buildCalendarGrid()),

          // Action Buttons
          const SizedBox(height: 16),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildMonthYearSelector() {
    return Row(
      children: [
        // Month Dropdown
        Expanded(
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.borderMd,
              border: Border.all(color: AppColors.divider),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedMonth,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
                items: List.generate(12, (index) {
                  return DropdownMenuItem(
                    value: index + 1,
                    child: Text(_months[index]),
                  );
                }),
                onChanged: _onMonthChanged,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Year Dropdown
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.borderMd,
            border: Border.all(color: AppColors.divider),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedYear,
              icon: const Icon(Icons.keyboard_arrow_down, size: 20),
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
              items: _getYearRange().map((year) {
                return DropdownMenuItem(
                  value: year,
                  child: Text(year.toString()),
                );
              }).toList(),
              onChanged: _onYearChanged,
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Navigation Arrows
        _NavArrowButton(
          icon: Icons.chevron_left,
          onTap: _goToPreviousMonth,
        ),
        const SizedBox(width: 4),
        _NavArrowButton(
          icon: Icons.chevron_right,
          onTap: _goToNextMonth,
        ),
      ],
    );
  }

  Widget _buildWeekdayHeaders() {
    const weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Row(
      children: weekdays.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_selectedYear, _selectedMonth, 1);
    final lastDayOfMonth = DateTime(_selectedYear, _selectedMonth + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final startingWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday

    final totalCells = ((startingWeekday + daysInMonth) / 7).ceil() * 7;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.2,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        final dayOffset = index - startingWeekday;

        if (dayOffset < 0 || dayOffset >= daysInMonth) {
          return const SizedBox.shrink();
        }

        final date = DateTime(_selectedYear, _selectedMonth, dayOffset + 1);
        return _buildDayCell(date);
      },
    );
  }

  Widget _buildDayCell(DateTime date) {
    final isStart = _startDate != null && _isSameDay(date, _startDate!);
    final isEnd = _endDate != null && _isSameDay(date, _endDate!);
    final isInRange = _isInRange(date);
    final isToday = _isSameDay(date, DateTime.now());
    final isDisabled =
        date.isBefore(widget.firstDate) || date.isAfter(widget.lastDate);

    // Determine background and text colors
    Color textColor = AppColors.textPrimary;

    if (isStart || isEnd) {
      textColor = Colors.white;
    } else if (isInRange) {}

    if (isDisabled) {
      textColor = AppColors.textMuted.withOpacity(0.4);
    }

    // Build range highlight background
    Widget child = Center(
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: (isStart || isEnd) ? AppColors.accent : null,
          shape: BoxShape.circle,
          border: isToday && !isStart && !isEnd
              ? Border.all(color: AppColors.accent, width: 1.5)
              : null,
        ),
        child: Center(
          child: Text(
            '${date.day}',
            style: AppTextStyles.body.copyWith(
              color: textColor,
              fontWeight: (isStart || isEnd || isToday)
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
          ),
        ),
      ),
    );

    // Range background (behind the circle)
    if (isInRange && !isStart && !isEnd) {
      child = Container(
        color: AppColors.accent.withOpacity(0.15),
        child: child,
      );
    } else if (isStart && _endDate != null) {
      // Start with range extending right
      child = Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              AppColors.accent.withOpacity(0.15),
            ],
            stops: const [0.5, 0.5],
          ),
        ),
        child: child,
      );
    } else if (isEnd && _startDate != null) {
      // End with range extending left
      child = Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.accent.withOpacity(0.15),
              Colors.transparent,
            ],
            stops: const [0.5, 0.5],
          ),
        ),
        child: child,
      );
    }

    return GestureDetector(
      onTap: isDisabled ? null : () => _onDayTap(date),
      child: child,
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isInRange(DateTime date) {
    if (_startDate == null || _endDate == null) return false;
    return date.isAfter(_startDate!) && date.isBefore(_endDate!);
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(
              DateRangeResult(start: _startDate, end: _endDate),
            );
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.accent,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text('OK'),
        ),
      ],
    );
  }
}

// ============================================================
// SINGLE DATE PICKER
// ============================================================

/// Shows the same custom calendar UI but picks a single date.
/// Returns the selected [DateTime] or null if cancelled.
Future<DateTime?> showCustomSingleDatePicker({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  return await showDialog<DateTime>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _SingleDatePickerDialog(
      initialDate: initialDate,
      firstDate: firstDate ?? DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365 * 10)),
    ),
  );
}

class _SingleDatePickerDialog extends StatefulWidget {
  final DateTime? initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const _SingleDatePickerDialog({
    this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<_SingleDatePickerDialog> createState() =>
      _SingleDatePickerDialogState();
}

class _SingleDatePickerDialogState extends State<_SingleDatePickerDialog> {
  DateTime? _selected;
  late int _selectedYear;
  late int _selectedMonth;

  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.initialDate;
    final base = _selected ?? DateTime.now();
    _selectedYear = base.year;
    _selectedMonth = base.month;
  }

  void _goToPreviousMonth() {
    setState(() {
      if (_selectedMonth == 1) {
        _selectedMonth = 12;
        _selectedYear--;
      } else {
        _selectedMonth--;
      }
    });
  }

  void _goToNextMonth() {
    setState(() {
      if (_selectedMonth == 12) {
        _selectedMonth = 1;
        _selectedYear++;
      } else {
        _selectedMonth++;
      }
    });
  }

  List<int> _getYearRange() => List.generate(
        widget.lastDate.year - widget.firstDate.year + 1,
        (i) => widget.firstDate.year + i,
      );

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
      backgroundColor: AppColors.cardBg,
      child: Container(
        width: 560,
        constraints: const BoxConstraints(maxHeight: 500),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left panel
            Container(
              width: 160,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.xl),
                  bottomLeft: Radius.circular(AppRadius.xl),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select date',
                    style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.8)),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _selected != null
                        ? DateFormat('EEE,\nMMM d\nyyyy').format(_selected!)
                        : '—',
                    style: AppTextStyles.h4.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            Container(width: 1, color: AppColors.divider),
            // Right panel
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Month/year selector
                    Row(
                      children: [
                        // Month — fixed width wide enough for "September"
                        SizedBox(
                          width: 140,
                          height: 40,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: AppRadius.borderMd,
                              border: Border.all(color: AppColors.divider),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: _selectedMonth,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down,
                                    size: 20),
                                style: AppTextStyles.body
                                    .copyWith(fontWeight: FontWeight.w500),
                                items: List.generate(
                                  12,
                                  (i) => DropdownMenuItem(
                                      value: i + 1,
                                      child: Text(_months[i])),
                                ),
                                onChanged: (v) {
                                  if (v != null) {
                                    setState(() => _selectedMonth = v);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Year — fixed width
                        SizedBox(
                          width: 84,
                          height: 40,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: AppRadius.borderMd,
                              border: Border.all(color: AppColors.divider),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: _selectedYear,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down,
                                    size: 20),
                                style: AppTextStyles.body
                                    .copyWith(fontWeight: FontWeight.w500),
                                items: _getYearRange()
                                    .map((y) => DropdownMenuItem(
                                        value: y, child: Text(y.toString())))
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) {
                                    setState(() => _selectedYear = v);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        _NavArrowButton(
                            icon: Icons.chevron_left,
                            onTap: _goToPreviousMonth),
                        const SizedBox(width: 4),
                        _NavArrowButton(
                            icon: Icons.chevron_right,
                            onTap: _goToNextMonth),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Weekday headers
                    Row(
                      children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                          .map((d) => Expanded(
                                child: Center(
                                  child: Text(d,
                                      style: AppTextStyles.bodySmall.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSecondary)),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    // Calendar grid
                    Expanded(child: _buildGrid()),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: _selected == null
                              ? null
                              : () => Navigator.of(context).pop(_selected),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.accent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    final firstDay = DateTime(_selectedYear, _selectedMonth, 1);
    final daysInMonth = DateTime(_selectedYear, _selectedMonth + 1, 0).day;
    final startOffset = firstDay.weekday % 7;
    final totalCells = ((startOffset + daysInMonth) / 7).ceil() * 7;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.2,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        final dayOffset = index - startOffset;
        if (dayOffset < 0 || dayOffset >= daysInMonth) {
          return const SizedBox.shrink();
        }
        final date = DateTime(_selectedYear, _selectedMonth, dayOffset + 1);
        final isSelected =
            _selected != null && _isSameDay(date, _selected!);
        final isToday = _isSameDay(date, DateTime.now());
        final isDisabled = date.isBefore(widget.firstDate) ||
            date.isAfter(widget.lastDate);

        return GestureDetector(
          onTap: isDisabled ? null : () => setState(() => _selected = date),
          child: Center(
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accent : null,
                shape: BoxShape.circle,
                border: isToday && !isSelected
                    ? Border.all(color: AppColors.accent, width: 1.5)
                    : null,
              ),
              child: Center(
                child: Text(
                  '${date.day}',
                  style: AppTextStyles.body.copyWith(
                    color: isSelected
                        ? Colors.white
                        : isDisabled
                            ? AppColors.textMuted.withOpacity(0.4)
                            : AppColors.textPrimary,
                    fontWeight: isSelected || isToday
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ============================================================

class _NavArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.borderSm,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.borderSm,
          border: Border.all(color: AppColors.divider),
        ),
        child: Icon(icon, size: 20, color: AppColors.textSecondary),
      ),
    );
  }
}
