import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:multifleet/controllers/general_masters.dart';
import 'package:multifleet/models/employee.dart';
import 'package:multifleet/models/vendor.dart';
import 'package:multifleet/repo/general_master_repo.dart';
import 'package:multifleet/services/company_service.dart';
import 'package:multifleet/services/theme_service.dart';
import 'package:multifleet/widgets/date_picker_field.dart';

// ============================================================
// MASTER ITEM — generic id+name pair for simple list pages
// ============================================================

class _MasterItem {
  final int? id;
  final String name;
  const _MasterItem({this.id, required this.name});
}

// ============================================================
// REUSABLE SIMPLE MASTER PAGE (list + add + inline edit)
// ============================================================

class _SimpleMasterPage extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<_MasterItem> Function() getItems;
  final RxBool isLoading;
  // name + existing id (0 = new)
  final Future<void> Function(String name, int existingId) onSave;
  final Future<void> Function() onRefresh;

  const _SimpleMasterPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.getItems,
    required this.isLoading,
    required this.onSave,
    required this.onRefresh,
  });

  @override
  State<_SimpleMasterPage> createState() => _SimpleMasterPageState();
}

class _SimpleMasterPageState extends State<_SimpleMasterPage> {
  final _nameCtrl = TextEditingController();
  bool _saving = false;
  String? _error;
  int? _editingId;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _startEdit(_MasterItem item) {
    _nameCtrl.text = item.name;
    setState(() {
      _editingId = item.id;
      _error = null;
    });
  }

  void _cancelEdit() {
    _nameCtrl.clear();
    setState(() {
      _editingId = null;
      _error = null;
    });
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Name is required');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSave(name, _editingId ?? 0);
      _nameCtrl.clear();
      setState(() => _editingId = null);
      await widget.onRefresh();
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = ThemeService.to.accentColor;
    final theme = Theme.of(context);
    final isEditing = _editingId != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────
          Row(
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
                    Text(widget.subtitle, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              IconButton(
                onPressed: widget.onRefresh,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Add / Edit card ──────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isEditing ? accent.withOpacity(0.4) : theme.dividerColor,
                width: isEditing ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isEditing ? 'Edit Entry' : 'Add New',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (isEditing) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('Editing',
                            style: TextStyle(
                                color: accent,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameCtrl,
                        onSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          labelText: 'Name *',
                          hintText:
                              'Enter ${widget.title.toLowerCase()} name...',
                          errorText: _error,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      children: [
                        SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _saving ? null : _submit,
                            icon: _saving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : Icon(isEditing
                                    ? Icons.save_outlined
                                    : Icons.add),
                            label: Text(isEditing ? 'Save' : 'Add'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accent,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        if (isEditing) ...[
                          const SizedBox(height: 8),
                          TextButton(
                              onPressed: _cancelEdit,
                              child: const Text('Cancel')),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── List ─────────────────────────────────────────────
          Obx(() {
            final items = widget.getItems();
            return Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor),
              ),
              child: widget.isLoading.value
                  ? const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : items.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(40),
                          child: Center(
                            child: Text('No items yet. Add one above.',
                                style: theme.textTheme.bodySmall),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              Divider(height: 1, color: theme.dividerColor),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final isCurrentEdit =
                                _editingId == item.id && item.id != null;
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: accent.withOpacity(0.1),
                                radius: 18,
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: accent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              title: Text(
                                item.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isCurrentEdit
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isCurrentEdit ? accent : null,
                                ),
                              ),
                              subtitle: null,
                              trailing: IconButton(
                                icon: Icon(Icons.edit_outlined,
                                    size: 18, color: theme.hintColor),
                                tooltip: 'Edit',
                                onPressed: () => _startEdit(item),
                              ),
                            );
                          },
                        ),
            );
          }),
        ],
      ),
    );
  }
}

// ============================================================
// VEHICLE TYPES
// ============================================================

class VehicleTypesSettings extends StatelessWidget {
  const VehicleTypesSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final masters = Get.find<GeneralMastersController>();
    final repo = GeneralMasterRepo();
    return _SimpleMasterPage(
      title: 'Vehicle Types',
      subtitle: 'Manage vehicle type classifications',
      icon: Icons.directions_car_outlined,
      getItems: () => masters.vehicleTypeMasters
          .where((m) => (m.status ?? '').isNotEmpty)
          .map((m) => _MasterItem(id: m.statusId, name: m.status!))
          .toList(),
      isLoading: masters.isLoading,
      onSave: (name, id) async {
        final result = await repo.createVehicleType(name, id: id);
        result.fold((e) => throw Exception(e), (_) {});
      },
      onRefresh: masters.fetchVehicleTypeMasters,
    );
  }
}

// ============================================================
// VEHICLE CONDITIONS
// ============================================================

class VehicleConditionsSettings extends StatelessWidget {
  const VehicleConditionsSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final masters = Get.find<GeneralMastersController>();
    final repo = GeneralMasterRepo();
    return _SimpleMasterPage(
      title: 'Vehicle Conditions',
      subtitle: 'Manage vehicle condition classifications',
      icon: Icons.car_repair_outlined,
      getItems: () => masters.vehicleConditionMasters
          .where((m) => (m.status ?? '').isNotEmpty)
          .map((m) => _MasterItem(id: m.statusId, name: m.status!))
          .toList(),
      isLoading: masters.isLoading,
      onSave: (name, id) async {
        final result = await repo.createVehicleCondition(name, id: id);
        result.fold((e) => throw Exception(e), (_) {});
      },
      onRefresh: masters.fetchVehicleConditionMasters,
    );
  }
}

// ============================================================
// TYRE POSITIONS
// ============================================================

class TyrePositionsSettings extends StatelessWidget {
  const TyrePositionsSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final masters = Get.find<GeneralMastersController>();
    final repo = GeneralMasterRepo();
    return _SimpleMasterPage(
      title: 'Tyre Positions',
      subtitle: 'Manage tyre position labels',
      icon: Icons.tire_repair_outlined,
      getItems: () => masters.tirePositionMaster
          .where((m) => (m.status ?? '').isNotEmpty)
          .map((m) => _MasterItem(id: m.statusId, name: m.status!))
          .toList(),
      isLoading: masters.isLoading,
      onSave: (name, id) async {
        final result = await repo.createTyrePosition(name, id: id);
        result.fold((e) => throw Exception(e), (_) {});
      },
      onRefresh: masters.fetchTirePositionMaster,
    );
  }
}

// ============================================================
// MAINTENANCE TYPES
// ============================================================

class MaintenanceTypesSettings extends StatelessWidget {
  const MaintenanceTypesSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final masters = Get.find<GeneralMastersController>();
    final repo = GeneralMasterRepo();
    return _SimpleMasterPage(
      title: 'Maintenance Types',
      subtitle: 'Manage service and maintenance type classifications',
      icon: Icons.build_outlined,
      getItems: () => masters.mainteneceMasters
          .where((m) => (m.maintenanceType ?? '').isNotEmpty)
          .map(
              (m) => _MasterItem(id: m.maintenanceID, name: m.maintenanceType!))
          .toList(),
      isLoading: masters.isLoading,
      onSave: (name, id) async {
        final result = await repo.createMaintenanceType(name, id: id);
        result.fold((e) => throw Exception(e), (_) {});
      },
      onRefresh: masters.fetchMaintenanceTypes,
    );
  }
}

// ============================================================
// FINE TYPES
// ============================================================

class FineTypesRealSettings extends StatelessWidget {
  const FineTypesRealSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final masters = Get.find<GeneralMastersController>();
    final repo = GeneralMasterRepo();
    final cs = Get.find<CompanyService>();

    return _SimpleMasterPage(
      title: 'Fine Types',
      subtitle: 'Manage traffic fine type classifications',
      icon: Icons.receipt_long_outlined,
      getItems: () => masters.fineTypeMasters
          .where((f) => (f.fineType ?? '').isNotEmpty)
          .map((f) => _MasterItem(id: f.fineTypeId, name: f.fineType!))
          .toList(),
      isLoading: masters.isLoading,
      onSave: (name, id) async {
        final company = cs.selectedCompanyObs.value?.id ?? '';
        if (company.isEmpty) throw Exception('No company selected');
        final result =
            await repo.createFineType(company: company, fineType: name, id: id);
        result.fold((e) => throw Exception(e), (_) {});
      },
      onRefresh: () =>
          masters.fetchFineTypeMasters(cs.selectedCompanyObs.value?.id ?? ''),
    );
  }
}

// ============================================================
// CITIES
// ============================================================

class CitiesSettings extends StatelessWidget {
  const CitiesSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final masters = Get.find<GeneralMastersController>();
    final repo = GeneralMasterRepo();
    final cs = Get.find<CompanyService>();

    return _SimpleMasterPage(
      title: 'Cities',
      subtitle: 'Manage city master list',
      icon: Icons.location_city_outlined,
      getItems: () => masters.companyCity
          .where((c) => (c.city ?? '').isNotEmpty)
          .map((c) => _MasterItem(id: c.cityId, name: c.city!))
          .toList(),
      isLoading: masters.isLoading,
      onSave: (name, id) async {
        final company = cs.selectedCompanyObs.value?.id ?? '';
        if (company.isEmpty) throw Exception('No company selected');
        final result =
            await repo.createCity(company: company, city: name, id: id);
        result.fold((e) => throw Exception(e), (_) {});
      },
      onRefresh: () =>
          masters.fetchCities(cs.selectedCompanyObs.value?.id ?? ''),
    );
  }
}

// ============================================================
// DOCUMENT TYPES
// ============================================================

class DocumentTypesSettings extends StatelessWidget {
  const DocumentTypesSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final masters = Get.find<GeneralMastersController>();
    final repo = GeneralMasterRepo();
    final cs = Get.find<CompanyService>();

    return _SimpleMasterPage(
      title: 'Document Types',
      subtitle: 'Manage vehicle document type classifications',
      icon: Icons.description_outlined,
      getItems: () => masters.companyDocumentTypes
          .where((d) => (d.docDescription ?? '').isNotEmpty)
          .map((d) => _MasterItem(id: d.docType, name: d.docDescription!))
          .toList(),
      isLoading: masters.isLoading,
      onSave: (name, id) async {
        final company = cs.selectedCompanyObs.value?.id ?? '';
        if (company.isEmpty) throw Exception('No company selected');
        final result = await repo.createDocumentType(
            company: company, docDescription: name, id: id);
        result.fold((e) => throw Exception(e), (_) {});
      },
      onRefresh: () => masters
          .fetchCompanyDocumentTypes(cs.selectedCompanyObs.value?.id ?? ''),
    );
  }
}

// ============================================================
// FUEL STATIONS
// ============================================================

class FuelStationsSettings extends StatelessWidget {
  const FuelStationsSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final masters = Get.find<GeneralMastersController>();
    final repo = GeneralMasterRepo();
    final cs = Get.find<CompanyService>();

    return _SimpleMasterPage(
      title: 'Fuel Stations',
      subtitle: 'Manage fuel station master list',
      icon: Icons.ev_station_outlined,
      getItems: () => masters.availableFuelStations
          .where((f) => (f.fuelStation ?? '').isNotEmpty)
          .map((f) => _MasterItem(id: f.fuelStationId, name: f.fuelStation!))
          .toList(),
      isLoading: masters.isLoading,
      onSave: (name, id) async {
        final company = cs.selectedCompanyObs.value?.id ?? '';
        if (company.isEmpty) throw Exception('No company selected');
        final result = await repo.createFuelStation(
            company: company, fuelStation: name, id: id);
        result.fold((e) => throw Exception(e), (_) {});
      },
      onRefresh: () => masters
          .fetchCompanyFuelStations(cs.selectedCompanyObs.value?.id ?? ''),
    );
  }
}

// ============================================================
// VENDORS
// ============================================================

class VendorsSettings extends StatefulWidget {
  const VendorsSettings({super.key});

  @override
  State<VendorsSettings> createState() => _VendorsSettingsState();
}

class _VendorsSettingsState extends State<VendorsSettings> {
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _contactNoCtrl = TextEditingController();
  final _contactPersonCtrl = TextEditingController();
  bool _saving = false;
  String? _error;
  int? _editingId;

  String get _company =>
      Get.find<CompanyService>().selectedCompanyObs.value?.id ?? '';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _contactNoCtrl.dispose();
    _contactPersonCtrl.dispose();
    super.dispose();
  }

  void _startEdit(Vendor v) {
    _nameCtrl.text = v.vendorName ?? '';
    _addressCtrl.text = v.address ?? '';
    _contactNoCtrl.text = v.contactNo ?? '';
    _contactPersonCtrl.text = v.contactPerson ?? '';
    setState(() {
      _editingId = int.tryParse(v.vendorID ?? '');
      _error = null;
    });
  }

  void _cancel() {
    _nameCtrl.clear();
    _addressCtrl.clear();
    _contactNoCtrl.clear();
    _contactPersonCtrl.clear();
    setState(() {
      _editingId = null;
      _error = null;
    });
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Vendor name is required');
      return;
    }
    if (_company.isEmpty) {
      setState(() => _error = 'No company selected');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final repo = GeneralMasterRepo();
      final result = await repo.createVendor(
        company: _company,
        vendorName: name,
        id: _editingId ?? 0,
        address: _addressCtrl.text.trim(),
        contactNo: _contactNoCtrl.text.trim(),
        contactPerson: _contactPersonCtrl.text.trim(),
      );
      result.fold(
        (e) => setState(() => _error = e),
        (_) {
          _cancel();
          Get.find<GeneralMastersController>().fetchVendorsByCompany(_company);
        },
      );
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = ThemeService.to.accentColor;
    final theme = Theme.of(context);
    final masters = Get.find<GeneralMastersController>();
    final isEditing = _editingId != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.store_outlined, color: accent, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Vendors / Garages',
                        style: theme.textTheme.headlineSmall),
                    Text('Manage service providers and garages',
                        style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => masters.fetchVendorsByCompany(_company),
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Form card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isEditing ? accent.withOpacity(0.4) : theme.dividerColor,
                width: isEditing ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isEditing ? 'Edit Vendor' : 'Add New Vendor',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (isEditing) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('Editing',
                            style: TextStyle(
                                color: accent,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child: _field(
                            _nameCtrl, 'Vendor Name *', 'e.g., Al Futtaim')),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _field(_contactPersonCtrl, 'Contact Person',
                            'e.g., Ahmed Ali')),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _field(_contactNoCtrl, 'Contact No',
                            'e.g., +971 4 555 1234')),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _field(
                            _addressCtrl, 'Address', 'e.g., Dubai, UAE')),
                  ],
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!,
                      style: TextStyle(
                          color: theme.colorScheme.error, fontSize: 12)),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isEditing)
                      TextButton(
                          onPressed: _cancel, child: const Text('Cancel')),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _saving ? null : _submit,
                      icon: _saving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Icon(isEditing ? Icons.save_outlined : Icons.add),
                      label: Text(isEditing ? 'Save' : 'Add Vendor'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // List
          Obx(() {
            final vendors = masters.companyVendors.whereType<Vendor>().toList();
            return Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor),
              ),
              child: masters.isLoading.value
                  ? const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()))
                  : vendors.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(40),
                          child: Center(
                              child: Text('No vendors yet.',
                                  style: theme.textTheme.bodySmall)),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: vendors.length,
                          separatorBuilder: (_, __) =>
                              Divider(height: 1, color: theme.dividerColor),
                          itemBuilder: (context, index) {
                            final v = vendors[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: accent.withOpacity(0.1),
                                radius: 18,
                                child: Text('${index + 1}',
                                    style: TextStyle(
                                        color: accent,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                              ),
                              title: Text(v.vendorName ?? '',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500)),
                              subtitle: () {
                                final sub = [v.contactPerson, v.contactNo]
                                    .where((s) => s != null && s.isNotEmpty)
                                    .join(' · ');
                                return sub.isNotEmpty
                                    ? Text(sub,
                                        style: theme.textTheme.bodySmall)
                                    : null;
                              }(),
                              trailing: IconButton(
                                icon: Icon(Icons.edit_outlined,
                                    size: 18, color: theme.hintColor),
                                onPressed: () => _startEdit(v),
                              ),
                            );
                          },
                        ),
            );
          }),
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, String hint) =>
      TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      );
}

// ============================================================
// EMPLOYEES
// ============================================================

class EmployeesSettings extends StatefulWidget {
  const EmployeesSettings({super.key});

  @override
  State<EmployeesSettings> createState() => _EmployeesSettingsState();
}

class _EmployeesSettingsState extends State<EmployeesSettings> {
  final _empNoCtrl = TextEditingController();
  final _empNameCtrl = TextEditingController();
  final _designationCtrl = TextEditingController();
  final _departmentCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _licenseNoCtrl = TextEditingController();
  DateTime? _licenseExpiry;
  final _nationalityCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();
  String _stat = 'A'; // 'A' | 'R' | 'T'
  bool _saving = false;
  String? _error;
  bool _isEditing = false;

  String get _company =>
      Get.find<CompanyService>().selectedCompanyObs.value?.id ?? '';

  @override
  void dispose() {
    _empNoCtrl.dispose();
    _empNameCtrl.dispose();
    _designationCtrl.dispose();
    _departmentCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _licenseNoCtrl.dispose();
    _nationalityCtrl.dispose();
    _remarksCtrl.dispose();
    super.dispose();
  }

  void _startEdit(Employee e) {
    _empNoCtrl.text = e.empNo ?? '';
    _empNameCtrl.text = e.empName ?? '';
    _designationCtrl.text = e.designation ?? '';
    _departmentCtrl.text = e.department ?? '';
    _phoneCtrl.text = e.phone ?? '';
    _emailCtrl.text = e.email ?? '';
    _licenseNoCtrl.text = e.licenseNo ?? '';
    _nationalityCtrl.text = e.nationality ?? '';
    _remarksCtrl.text = e.remarks ?? '';
    setState(() {
      _licenseExpiry = e.licenseExpiry != null && e.licenseExpiry!.isNotEmpty
          ? DateTime.tryParse(e.licenseExpiry!)
          : null;
      _stat = e.stat ?? 'A';
      _isEditing = true;
      _error = null;
    });
  }

  void _cancel() {
    for (final c in [
      _empNoCtrl,
      _empNameCtrl,
      _designationCtrl,
      _departmentCtrl,
      _phoneCtrl,
      _emailCtrl,
      _licenseNoCtrl,
      _nationalityCtrl,
      _remarksCtrl,
    ]) {
      c.clear();
    }
    setState(() {
      _licenseExpiry = null;
      _stat = 'A';
      _isEditing = false;
      _error = null;
    });
  }

  Future<void> _submit() async {
    final empNo = _empNoCtrl.text.trim();
    final empName = _empNameCtrl.text.trim();
    if (empNo.isEmpty || empName.isEmpty) {
      setState(() => _error = 'Employee No and Name are required');
      return;
    }
    if (_company.isEmpty) {
      setState(() => _error = 'No company selected');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final repo = GeneralMasterRepo();
      final result = await repo.createEmployee(
        company: _company,
        empNo: empNo,
        empName: empName,
        designation: _designationCtrl.text.trim().nullIfEmpty,
        department: _departmentCtrl.text.trim().nullIfEmpty,
        phone: _phoneCtrl.text.trim().nullIfEmpty,
        email: _emailCtrl.text.trim().nullIfEmpty,
        licenseNo: _licenseNoCtrl.text.trim().nullIfEmpty,
        licenseExpiry: _licenseExpiry != null
            ? DateFormat('yyyy-MM-dd').format(_licenseExpiry!)
            : null,
        nationality: _nationalityCtrl.text.trim().nullIfEmpty,
        remarks: _remarksCtrl.text.trim().nullIfEmpty,
        stat: _stat,
      );
      result.fold(
        (e) => setState(() => _error = e),
        (_) {
          _cancel();
          Get.find<GeneralMastersController>()
              .fetchEmployeesByCompany(_company);
        },
      );
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = ThemeService.to.accentColor;
    final theme = Theme.of(context);
    final masters = Get.find<GeneralMastersController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.people_outlined, color: accent, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Employees', style: theme.textTheme.headlineSmall),
                    Text('Manage employee master list',
                        style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => masters.fetchEmployeesByCompany(_company),
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Form
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    _isEditing ? accent.withOpacity(0.4) : theme.dividerColor,
                width: _isEditing ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _isEditing ? 'Edit Employee' : 'Add New Employee',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (_isEditing) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('Editing',
                            style: TextStyle(
                                color: accent,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                // Row 1: Identity
                Row(
                  children: [
                    Expanded(
                        child: _field(
                            _empNoCtrl, 'Employee No *', 'e.g., MX1234')),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _field(
                            _empNameCtrl, 'Full Name *', 'e.g., Ahmed Ali')),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _field(
                            _designationCtrl, 'Designation', 'e.g., Driver')),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _field(
                            _departmentCtrl, 'Department', 'e.g., Operations')),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _stat,
                        decoration: InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(value: 'A', child: Text('Active')),
                          DropdownMenuItem(value: 'R', child: Text('Resigned')),
                          DropdownMenuItem(
                              value: 'T', child: Text('Terminated')),
                        ],
                        onChanged: (v) => setState(() => _stat = v ?? 'A'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Row 2: Contact
                Row(
                  children: [
                    Expanded(
                        child: _field(
                            _phoneCtrl, 'Phone', 'e.g., +971 50 123 4567')),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _field(
                            _emailCtrl, 'Email', 'e.g., ahmed@multiplrx.com')),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _field(
                            _nationalityCtrl, 'Nationality', 'e.g., UAE')),
                    const SizedBox(width: 12),
                    Expanded(
                        child:
                            _field(_remarksCtrl, 'Remarks', 'Optional notes')),
                  ],
                ),
                const SizedBox(height: 12),
                // Row 3: License
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                        child: _field(
                            _licenseNoCtrl, 'License No', 'e.g., DL-12345')),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: DatePickerField(
                        label: 'License Expiry',
                        staticValue: _licenseExpiry,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        warnIfPast: true,
                        onChanged: (d) => setState(() => _licenseExpiry = d),
                        onCleared: () => setState(() => _licenseExpiry = null),
                      ),
                    ),
                    const Expanded(flex: 2, child: SizedBox()),
                  ],
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!,
                      style: TextStyle(
                          color: theme.colorScheme.error, fontSize: 12)),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_isEditing)
                      TextButton(
                          onPressed: _cancel, child: const Text('Cancel')),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _saving ? null : _submit,
                      icon: _saving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Icon(_isEditing ? Icons.save_outlined : Icons.add),
                      label: Text(_isEditing ? 'Save' : 'Add Employee'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // List
          Obx(() {
            final emps = masters.companyEmployees;
            return Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor),
              ),
              child: masters.isLoading.value
                  ? const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()))
                  : emps.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(40),
                          child: Center(
                              child: Text('No employees yet.',
                                  style: theme.textTheme.bodySmall)),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: emps.length,
                          separatorBuilder: (_, __) =>
                              Divider(height: 1, color: theme.dividerColor),
                          itemBuilder: (context, index) {
                            final e = emps[index];
                            final statColor = e.stat == 'R'
                                ? Colors.orange
                                : e.stat == 'T'
                                    ? Colors.red
                                    : accent;
                            final statLabel = e.stat == 'R'
                                ? 'Resigned'
                                : e.stat == 'T'
                                    ? 'Terminated'
                                    : null;
                            return ListTile(
                              tileColor: e.stat == 'R'
                                  ? Colors.orange.withOpacity(0.05)
                                  : e.stat == 'T'
                                      ? Colors.red.withOpacity(0.05)
                                      : null,
                              leading: CircleAvatar(
                                backgroundColor: statColor.withOpacity(0.15),
                                radius: 18,
                                child: Text('${index + 1}',
                                    style: TextStyle(
                                        color: statColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                              ),
                              title: Text(
                                  '${e.empNo ?? ''} — ${e.empName ?? ''}',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500)),
                              subtitle: () {
                                final parts = [
                                  e.designation,
                                  e.department,
                                  e.phone,
                                ]
                                    .where((s) => s != null && s.isNotEmpty)
                                    .join(' · ');
                                return parts.isNotEmpty
                                    ? Text(parts,
                                        style: theme.textTheme.bodySmall)
                                    : null;
                              }(),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (statLabel != null)
                                    Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: statColor.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(statLabel,
                                          style: TextStyle(
                                              color: statColor,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                  IconButton(
                                    icon: Icon(Icons.visibility_outlined,
                                        size: 18, color: theme.hintColor),
                                    tooltip: 'View details',
                                    onPressed: () => _showDetails(e),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.edit_outlined,
                                        size: 18, color: theme.hintColor),
                                    tooltip: 'Edit',
                                    onPressed: () => _startEdit(e),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            );
          }),
        ],
      ),
    );
  }

  void _showDetails(Employee e) {
    final accent = ThemeService.to.accentColor;
    final statColor = e.stat == 'R'
        ? Colors.orange
        : e.stat == 'T'
            ? Colors.red
            : accent;
    final statLabel = e.stat == 'R'
        ? 'Resigned'
        : e.stat == 'T'
            ? 'Terminated'
            : 'Active';

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: 560,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header bar
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.empName ?? '—',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          Text(e.empNo ?? '',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statColor == accent
                            ? Colors.white24
                            : statColor.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(6),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.4)),
                      ),
                      child: Text(statLabel,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              // Details grid
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _detailRow('Designation', e.designation),
                    _detailRow('Department', e.department),
                    const Divider(height: 20),
                    _detailRow('Phone', e.phone),
                    _detailRow('Email', e.email),
                    _detailRow('Nationality', e.nationality),
                    const Divider(height: 20),
                    _detailRow('License No', e.licenseNo),
                    _detailRow(
                      'License Expiry',
                      e.licenseExpiry != null && e.licenseExpiry!.isNotEmpty
                          ? () {
                              final d = DateTime.tryParse(e.licenseExpiry!);
                              if (d == null) return e.licenseExpiry;
                              final isExpired = d.isBefore(DateTime.now());
                              return '${DateFormat('dd MMM yyyy').format(d)}${isExpired ? '  ⚠ Expired' : ''}';
                            }()
                          : null,
                    ),
                    _detailRow('Company', e.company),
                    if ((e.remarks ?? '').isNotEmpty) ...[
                      const Divider(height: 20),
                      _detailRow('Remarks', e.remarks),
                    ],
                  ],
                ),
              ),
              // Footer
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Close'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _startEdit(e);
                      },
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Edit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, String hint) =>
      TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      );
}

// ============================================================
// STRING EXTENSION
// ============================================================

extension _NullIfEmptyExt on String {
  String? get nullIfEmpty => isEmpty ? null : this;
}
