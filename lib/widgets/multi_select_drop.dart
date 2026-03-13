import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A reusable multi-select chip dropdown that works with any type T.
/// Items are displayed using [displayBuilder] (defaults to toString).
class MultiSelectDropDown<T> extends StatefulWidget {
  final String label;
  final List<T> options;
  final List<T> initiallySelected;
  final void Function(List<T>)? onChanged;
  final String Function(T)? displayBuilder;
  final String? hint;

  const MultiSelectDropDown({
    super.key,
    required this.label,
    required this.options,
    this.initiallySelected = const [],
    this.onChanged,
    this.displayBuilder,
    this.hint,
  });

  @override
  State<MultiSelectDropDown<T>> createState() => _MultiSelectDropDownState<T>();
}

class _MultiSelectDropDownState<T> extends State<MultiSelectDropDown<T>> {
  late List<T> _selected;

  String _display(T item) => widget.displayBuilder != null
      ? widget.displayBuilder!(item)
      : item.toString();

  @override
  void initState() {
    super.initState();
    _selected = List<T>.from(widget.initiallySelected);
  }

  @override
  void didUpdateWidget(covariant MultiSelectDropDown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync if parent changes initiallySelected (e.g. after data loads)
    if (oldWidget.initiallySelected != widget.initiallySelected) {
      _selected = List<T>.from(widget.initiallySelected);
    }
  }

  void _openPicker() {
    // Local copy so we can cancel
    List<T> temp = List<T>.from(_selected);

    showDialog<List<T>>(
      context: context,
      builder: (ctx) => _MultiSelectDialog<T>(
        label: widget.label,
        options: widget.options,
        selected: temp,
        displayBuilder: _display,
      ),
    ).then((result) {
      if (result != null) {
        setState(() => _selected = result);
        widget.onChanged?.call(_selected);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = _selected.isNotEmpty;
    return GestureDetector(
      onTap: _openPicker,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: AppTextStyles.bodySmall,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          prefixIcon: Icon(Icons.location_city_outlined,
              color: AppColors.accent, size: 20),
          suffixIcon: Icon(Icons.arrow_drop_down, color: AppColors.textMuted),
          filled: true,
          fillColor: AppColors.cardBg,
          border: OutlineInputBorder(
            borderRadius: AppRadius.borderMd,
            borderSide: BorderSide(color: AppColors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.borderMd,
            borderSide: BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.borderMd,
            borderSide: BorderSide(color: AppColors.accent, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
        isEmpty: !hasValue,
        child: hasValue
            ? Wrap(
                spacing: 6,
                runSpacing: 4,
                children: _selected
                    .map((item) => _Chip(
                          label: _display(item),
                          onRemove: () {
                            setState(() => _selected.remove(item));
                            widget.onChanged?.call(_selected);
                          },
                        ))
                    .toList(),
              )
            : Text(
                widget.hint ?? '',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
      ),
    );
  }
}

// ── Internal dialog ────────────────────────────────────────────────────────

class _MultiSelectDialog<T> extends StatefulWidget {
  final String label;
  final List<T> options;
  final List<T> selected;
  final String Function(T) displayBuilder;

  const _MultiSelectDialog({
    required this.label,
    required this.options,
    required this.selected,
    required this.displayBuilder,
  });

  @override
  State<_MultiSelectDialog<T>> createState() => _MultiSelectDialogState<T>();
}

class _MultiSelectDialogState<T> extends State<_MultiSelectDialog<T>> {
  late List<T> _temp;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _temp = List<T>.from(widget.selected);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.options
        .where((o) => widget
            .displayBuilder(o)
            .toLowerCase()
            .contains(_search.toLowerCase()))
        .toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
      child: Container(
        width: 400,
        constraints: const BoxConstraints(maxHeight: 520),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.borderXl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Search
            TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                prefixIcon:
                    Icon(Icons.search, color: AppColors.accent, size: 20),
                filled: true,
                fillColor: AppColors.cardBg,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.borderMd,
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
            const SizedBox(height: 8),

            // Select All / Clear row
            Row(
              children: [
                TextButton(
                  onPressed: () =>
                      setState(() => _temp = List<T>.from(widget.options)),
                  child: Text('Select All',
                      style: TextStyle(color: AppColors.accent, fontSize: 12)),
                ),
                TextButton(
                  onPressed: () => setState(() => _temp.clear()),
                  child: Text('Clear',
                      style:
                          TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ),
              ],
            ),

            const Divider(height: 1),

            // List
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final item = filtered[i];
                  final isSelected = _temp.contains(item);
                  return CheckboxListTile(
                    dense: true,
                    title: Text(
                      widget.displayBuilder(item),
                      style:
                          TextStyle(fontSize: 14, color: AppColors.textPrimary),
                    ),
                    value: isSelected,
                    activeColor: AppColors.accent,
                    checkColor: Colors.white,
                    onChanged: (_) {
                      setState(() {
                        isSelected ? _temp.remove(item) : _temp.add(item);
                      });
                    },
                  );
                },
              ),
            ),

            const Divider(height: 1),
            const SizedBox(height: 12),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: BorderSide(color: AppColors.divider),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.borderMd),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(_temp),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.borderMd),
                    ),
                    child: Text('Done (${_temp.length})'),
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

// ── Small removable chip ───────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _Chip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(fontSize: 12, color: AppColors.primaryDark)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close, size: 14, color: AppColors.primaryDark),
          ),
        ],
      ),
    );
  }
}

// ── Helper function (unchanged signature, added displayBuilder) ────────────

Widget buildMultiSelectField<T>({
  required String label,
  required List<T> options,
  required List<T> initiallySelected,
  required void Function(List<T>) onChanged,
  String Function(T)? displayBuilder,
  String? hint,
}) {
  return MultiSelectDropDown<T>(
    label: label,
    options: options,
    initiallySelected: initiallySelected,
    onChanged: onChanged,
    displayBuilder: displayBuilder,
    hint: hint,
  );
}
