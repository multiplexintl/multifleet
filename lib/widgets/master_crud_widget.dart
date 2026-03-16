import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multifleet/theme/app_theme.dart';
// Import for icon mapping - you'll need to adjust path
import '../models/settings/base_master.dart';
import '../models/settings/vehicle_category.dart';
import '../services/theme_service.dart';

/// ============================================================
/// GENERIC MASTER CRUD WIDGET
/// ============================================================
/// Reusable widget for all master data management.
/// Provides: List view, Search, Add/Edit dialog, Active toggle
/// ============================================================

class MasterCrudWidget<T extends BaseMaster> extends StatefulWidget {
  /// Title displayed in header
  final String title;

  /// Subtitle/description
  final String? subtitle;

  /// Icon for header
  final IconData icon;

  /// Repository for CRUD operations
  final BaseMasterRepository<T> repository;

  /// Field definitions for the form
  final List<MasterField> fields;

  /// Factory to create new item from form data
  final T Function(Map<String, dynamic> data) createItem;

  /// Factory to update item from form data
  final T Function(T existing, Map<String, dynamic> data) updateItem;

  /// Extract form data from existing item for editing
  final Map<String, dynamic> Function(T item) extractFormData;

  /// Optional custom list tile builder
  final Widget Function(BuildContext context, T item, VoidCallback onEdit,
      VoidCallback onToggle)? listTileBuilder;

  /// Whether to show color indicator in list
  final bool showColorIndicator;

  /// Whether to show icon in list
  final bool showIcon;

  /// Allow reordering
  final bool allowReorder;

  const MasterCrudWidget({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.repository,
    required this.fields,
    required this.createItem,
    required this.updateItem,
    required this.extractFormData,
    this.listTileBuilder,
    this.showColorIndicator = false,
    this.showIcon = true,
    this.allowReorder = false,
  });

  @override
  State<MasterCrudWidget<T>> createState() => _MasterCrudWidgetState<T>();
}

class _MasterCrudWidgetState<T extends BaseMaster>
    extends State<MasterCrudWidget<T>> {
  final _searchController = TextEditingController();
  final _items = <T>[].obs;
  final _filteredItems = <T>[].obs;
  final _isLoading = true.obs;
  final _searchQuery = ''.obs;
  final _showInactive = true.obs;

  @override
  void initState() {
    super.initState();
    _loadItems();

    // React to search query changes
    ever(_searchQuery, (_) => _filterItems());
    ever(_showInactive, (_) => _filterItems());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    _isLoading.value = true;
    try {
      final items = await widget.repository.getAll();
      _items.assignAll(items);
      _filterItems();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load items: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      _isLoading.value = false;
    }
  }

  void _filterItems() {
    var filtered = _items.toList();

    // Filter by search
    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      filtered = filtered
          .where((item) => item.name.toLowerCase().contains(query))
          .toList();
    }

    // Filter by active status
    if (!_showInactive.value) {
      filtered = filtered.where((item) => item.isActive).toList();
    }

    _filteredItems.assignAll(filtered);
  }

  Future<void> _toggleActive(T item) async {
    try {
      final updated = await widget.repository.toggleActive(item.id);
      final index = _items.indexWhere((e) => e.id == item.id);
      if (index != -1) {
        _items[index] = updated;
        _filterItems();
      }
      Get.snackbar(
        'Success',
        '${item.name} ${updated.isActive ? 'activated' : 'deactivated'}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _showAddEditDialog([T? item]) {
    final isEdit = item != null;
    final formKey = GlobalKey<FormState>();
    final formData = <String, dynamic>{};

    // Pre-fill form data if editing
    if (isEdit) {
      formData.addAll(widget.extractFormData(item));
    } else {
      // Set default values
      for (final field in widget.fields) {
        if (field.defaultValue != null) {
          formData[field.key] = field.defaultValue;
        }
      }
    }

    showDialog(
      context: context,
      builder: (context) => _MasterFormDialog(
        title: isEdit ? 'Edit ${widget.title}' : 'Add ${widget.title}',
        fields: widget.fields,
        formData: formData,
        formKey: formKey,
        onSave: () async {
          if (!formKey.currentState!.validate()) return;
          formKey.currentState!.save();

          try {
            if (isEdit) {
              final updated = widget.updateItem(item, formData);
              final result = await widget.repository.update(updated);
              final index = _items.indexWhere((e) => e.id == item.id);
              if (index != -1) _items[index] = result;
            } else {
              final newItem = widget.createItem(formData);
              final result = await widget.repository.create(newItem);
              _items.add(result);
            }
            _filterItems();
            Navigator.pop(context);
            Get.snackbar(
              'Success',
              '${isEdit ? 'Updated' : 'Added'} successfully',
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 2),
            );
          } catch (e) {
            Get.snackbar('Error', 'Failed to save: $e',
                snackPosition: SnackPosition.BOTTOM);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = ThemeService.to.accentColor;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(theme, accent),
          const SizedBox(height: 24),

          // Main content card
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              children: [
                // Toolbar
                _buildToolbar(theme, accent),
                Divider(height: 1, color: theme.dividerColor),

                // List
                Obx(() {
                  if (_isLoading.value) {
                    return const Padding(
                      padding: EdgeInsets.all(48),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (_filteredItems.isEmpty) {
                    return _buildEmptyState(theme);
                  }

                  return _buildList(theme, accent);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, Color accent) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(widget.icon, color: accent, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title, style: theme.textTheme.headlineSmall),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 2),
                Text(widget.subtitle!, style: theme.textTheme.bodySmall),
              ],
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _showAddEditDialog(),
          icon: const Icon(Icons.add, size: 20),
          label: const Text('Add New'),
        ),
      ],
    );
  }

  Widget _buildToolbar(ThemeData theme, Color accent) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Search
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (v) => _searchQuery.value = v,
              decoration: InputDecoration(
                hintText: 'Search ${widget.title.toLowerCase()}...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: Obx(() => _searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          _searchQuery.value = '';
                        },
                      )
                    : const SizedBox.shrink()),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Show inactive toggle
          Obx(() => FilterChip(
                label: const Text('Show Inactive'),
                selected: _showInactive.value,
                onSelected: (v) => _showInactive.value = v,
                selectedColor: accent.withOpacity(0.15),
                checkmarkColor: accent,
              )),
          const SizedBox(width: 8),

          // Refresh
          IconButton(
            onPressed: _loadItems,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }

  Widget _buildList(ThemeData theme, Color accent) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredItems.length,
      separatorBuilder: (_, __) =>
          Divider(height: 1, color: theme.dividerColor),
      itemBuilder: (context, index) {
        final item = _filteredItems[index];

        if (widget.listTileBuilder != null) {
          return widget.listTileBuilder!(
            context,
            item,
            () => _showAddEditDialog(item),
            () => _toggleActive(item),
          );
        }

        return _buildDefaultListTile(item, theme, accent);
      },
    );
  }

  Widget _buildDefaultListTile(T item, ThemeData theme, Color accent) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Color indicator
          if (widget.showColorIndicator && item.color != null)
            Container(
              width: 4,
              height: 40,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: item.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

          // Icon
          if (widget.showIcon)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (item.color ?? accent).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                item.icon ?? widget.icon,
                color: item.color ?? accent,
                size: 20,
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Text(
            item.name,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: item.isActive ? null : theme.disabledColor,
              decoration: item.isActive ? null : TextDecoration.lineThrough,
            ),
          ),
          if (!item.isActive) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.disabledColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Inactive',
                style: TextStyle(
                  fontSize: 11,
                  color: theme.disabledColor,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: item.subtitle != null
          ? Text(
              item.subtitle!,
              style:
                  TextStyle(color: item.isActive ? null : theme.disabledColor),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Active toggle
          Switch(
            value: item.isActive,
            onChanged: (_) => _toggleActive(item),
          ),
          const SizedBox(width: 8),

          // Edit button
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showAddEditDialog(item),
            tooltip: 'Edit',
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Center(
        child: Column(
          children: [
            Icon(widget.icon, size: 48, color: theme.disabledColor),
            const SizedBox(height: 16),
            Text(
              _searchQuery.value.isNotEmpty
                  ? 'No results found'
                  : 'No ${widget.title.toLowerCase()} yet',
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: theme.disabledColor),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.value.isNotEmpty
                  ? 'Try a different search term'
                  : 'Click "Add New" to create one',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================
/// MASTER FORM DIALOG
/// ============================================================

class _MasterFormDialog extends StatefulWidget {
  final String title;
  final List<MasterField> fields;
  final Map<String, dynamic> formData;
  final GlobalKey<FormState> formKey;
  final VoidCallback onSave;

  const _MasterFormDialog({
    required this.title,
    required this.fields,
    required this.formData,
    required this.formKey,
    required this.onSave,
  });

  @override
  State<_MasterFormDialog> createState() => _MasterFormDialogState();
}

class _MasterFormDialogState extends State<_MasterFormDialog> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = ThemeService.to.accentColor;

    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 400,
        child: Form(
          key: widget.formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: widget.fields
                  .map((field) => _buildField(field, theme))
                  .toList(),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving
              ? null
              : () async {
                  setState(() => _isSaving = true);
                  widget.onSave();
                  // Note: Dialog is closed by onSave if successful
                  if (mounted) setState(() => _isSaving = false);
                },
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildField(MasterField field, ThemeData theme) {
    Widget fieldWidget;

    switch (field.type) {
      case MasterFieldType.text:
        fieldWidget = TextFormField(
          initialValue: widget.formData[field.key]?.toString(),
          decoration: InputDecoration(
            labelText: field.label,
            hintText: field.hint,
          ),
          maxLength: field.maxLength,
          validator: field.required
              ? (v) => v == null || v.isEmpty
                  ? '${field.label} is required'
                  : field.validator?.call(v)
              : field.validator,
          onSaved: (v) => widget.formData[field.key] = v,
        );
        break;

      case MasterFieldType.multiline:
        fieldWidget = TextFormField(
          initialValue: widget.formData[field.key]?.toString(),
          decoration: InputDecoration(
            labelText: field.label,
            hintText: field.hint,
            alignLabelWithHint: true,
          ),
          maxLines: field.maxLines ?? 3,
          maxLength: field.maxLength,
          validator: field.required
              ? (v) =>
                  v == null || v.isEmpty ? '${field.label} is required' : null
              : null,
          onSaved: (v) => widget.formData[field.key] = v,
        );
        break;

      case MasterFieldType.number:
        fieldWidget = TextFormField(
          initialValue: widget.formData[field.key]?.toString(),
          decoration: InputDecoration(
            labelText: field.label,
            hintText: field.hint,
          ),
          keyboardType: TextInputType.number,
          validator: field.required
              ? (v) =>
                  v == null || v.isEmpty ? '${field.label} is required' : null
              : null,
          onSaved: (v) =>
              widget.formData[field.key] = v != null ? int.tryParse(v) : null,
        );
        break;

      case MasterFieldType.dropdown:
        fieldWidget = DropdownButtonFormField<String>(
          value: widget.formData[field.key]?.toString(),
          decoration: InputDecoration(
            labelText: field.label,
            hintText: field.hint,
          ),
          items: field.dropdownOptions
              ?.map((opt) =>
                  DropdownMenuItem(value: opt.value, child: Text(opt.label)))
              .toList(),
          validator: field.required
              ? (v) => v == null ? '${field.label} is required' : null
              : null,
          onChanged: (v) => setState(() => widget.formData[field.key] = v),
          onSaved: (v) => widget.formData[field.key] = v,
        );
        break;

      case MasterFieldType.toggle:
        fieldWidget = SwitchListTile(
          title: Text(field.label),
          subtitle: field.hint != null ? Text(field.hint!) : null,
          value: widget.formData[field.key] ?? field.defaultValue ?? false,
          onChanged: (v) => setState(() => widget.formData[field.key] = v),
          contentPadding: EdgeInsets.zero,
        );
        break;

      case MasterFieldType.color:
        fieldWidget = _ColorPickerField(
          label: field.label,
          value: widget.formData[field.key],
          onChanged: (v) => setState(() => widget.formData[field.key] = v),
        );
        break;

      case MasterFieldType.icon:
        fieldWidget = _IconPickerField(
          label: field.label,
          value: widget.formData[field.key],
          options: field.dropdownOptions ?? [],
          onChanged: (v) => setState(() => widget.formData[field.key] = v),
        );
        break;

      case MasterFieldType.date:
        fieldWidget = _DatePickerField(
          label: field.label,
          value: widget.formData[field.key],
          required: field.required,
          onChanged: (v) => setState(() => widget.formData[field.key] = v),
        );
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: fieldWidget,
    );
  }
}

/// ============================================================
/// CUSTOM FIELD WIDGETS
/// ============================================================

class _ColorPickerField extends StatelessWidget {
  final String label;
  final String? value;
  final ValueChanged<String?> onChanged;

  const _ColorPickerField({
    required this.label,
    this.value,
    required this.onChanged,
  });

  static const _presetColors = [
    '3B82F6', // Blue
    '10B981', // Emerald
    '14B8A6', // Teal
    '8B5CF6', // Purple
    'EC4899', // Pink
    'F59E0B', // Amber
    'EF4444', // Red
    'F97316', // Orange
    '06B6D4', // Cyan
    '6366F1', // Indigo
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // No color option
            _ColorOption(
              color: null,
              isSelected: value == null,
              onTap: () => onChanged(null),
            ),
            // Preset colors
            ..._presetColors.map((hex) => _ColorOption(
                  color: Color(int.parse('FF$hex', radix: 16)),
                  isSelected: value == hex,
                  onTap: () => onChanged(hex),
                )),
          ],
        ),
      ],
    );
  }
}

class _ColorOption extends StatelessWidget {
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorOption({
    this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color ?? AppColors.divider,
          shape: BoxShape.circle,
          border: Border.all(
            color:
                isSelected ? ThemeService.to.accentColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: color == null
            ? Icon(Icons.block, size: 16, color: AppColors.textMuted)
            : isSelected
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
      ),
    );
  }
}

class _IconPickerField extends StatelessWidget {
  final String label;
  final String? value;
  final List<DropdownOption> options;
  final ValueChanged<String?> onChanged;

  const _IconPickerField({
    required this.label,
    this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((opt) {
            final isSelected = value == opt.value;
            final iconData = vehicleCategoryIcons[opt.value];

            return Tooltip(
              message: opt.label,
              child: GestureDetector(
                onTap: () => onChanged(opt.value),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? ThemeService.to.accentColor.withOpacity(0.1)
                        : Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? ThemeService.to.accentColor
                          : Theme.of(context).dividerColor,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Icon(
                    iconData ?? Icons.help_outline,
                    color: isSelected ? ThemeService.to.accentColor : null,
                    size: 20,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final bool required;
  final ValueChanged<DateTime?> onChanged;

  const _DatePickerField({
    required this.label,
    this.value,
    this.required = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null) onChanged(date);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today, size: 20),
        ),
        child: Text(
          value != null
              ? '${value!.day}/${value!.month}/${value!.year}'
              : 'Select date',
          style: value == null
              ? TextStyle(color: Theme.of(context).hintColor)
              : null,
        ),
      ),
    );
  }
}
