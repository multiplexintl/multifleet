import 'package:flutter/material.dart';

/// ============================================================
/// BASE MASTER MODEL
/// ============================================================
/// Base class for all master data models.
/// Each master extends this with its own fields.
/// ============================================================

abstract class BaseMaster {
  String get id;
  String get name;
  bool get isActive;

  /// For display in lists
  String get displayName => name;

  /// Optional subtitle for list items
  String? get subtitle => null;

  /// Optional icon
  IconData? get icon => null;

  /// Optional color
  Color? get color => null;

  /// Convert to JSON for API
  Map<String, dynamic> toJson();

  /// Create a copy with updated fields
  BaseMaster copyWith({String? name, bool? isActive});
}

/// ============================================================
/// BASE MASTER REPOSITORY
/// ============================================================
/// Interface for all master CRUD operations.
/// Implement this for each master type.
/// ============================================================

abstract class BaseMasterRepository<T extends BaseMaster> {
  /// Get all items
  Future<List<T>> getAll();

  /// Get by ID
  Future<T?> getById(String id);

  /// Get only active items
  Future<List<T>> getActive() async {
    final all = await getAll();
    return all.where((item) => item.isActive).toList();
  }

  /// Create new item
  Future<T> create(T item);

  /// Update existing item
  Future<T> update(T item);

  /// Toggle active status
  Future<T> toggleActive(String id) async {
    final item = await getById(id);
    if (item == null) throw Exception('Item not found');
    final updated = item.copyWith(isActive: !item.isActive) as T;
    return update(updated);
  }

  /// Delete item (soft delete by setting inactive, or hard delete)
  Future<void> delete(String id);

  /// Search items by name
  Future<List<T>> search(String query) async {
    final all = await getAll();
    final lowerQuery = query.toLowerCase();
    return all
        .where((item) => item.name.toLowerCase().contains(lowerQuery))
        .toList();
  }
}

/// ============================================================
/// API RESULT WRAPPER
/// ============================================================
/// Standard wrapper for API responses.
/// ============================================================

class ApiResult<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  ApiResult.success(this.data)
      : error = null,
        isSuccess = true;

  ApiResult.failure(this.error)
      : data = null,
        isSuccess = false;
}

/// ============================================================
/// MASTER FIELD DEFINITION
/// ============================================================
/// Defines a field for the generic CRUD form.
/// ============================================================

enum MasterFieldType {
  text,
  number,
  dropdown,
  color,
  icon,
  toggle,
  date,
  multiline,
}

class MasterField {
  final String key;
  final String label;
  final MasterFieldType type;
  final bool required;
  final String? hint;
  final dynamic defaultValue;
  final List<DropdownOption>? dropdownOptions;
  final String? Function(String?)? validator;
  final int? maxLength;
  final int? maxLines;

  const MasterField({
    required this.key,
    required this.label,
    this.type = MasterFieldType.text,
    this.required = false,
    this.hint,
    this.defaultValue,
    this.dropdownOptions,
    this.validator,
    this.maxLength,
    this.maxLines,
  });
}

class DropdownOption {
  final String value;
  final String label;

  const DropdownOption(this.value, this.label);
}
