import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../domain/entities/threshold.dart';
import '../../../viewmodels/admin_thresholds_viewmodel.dart';

// ─── Constants ────────────────────────────────────────────────────────────────

const _metricTypes = [
  'blood_pressure',
  'blood_sugar',
  'spo2',
  'bmi',
  'weight',
];

const _metricLabels = {
  'blood_pressure': 'Blood Pressure',
  'blood_sugar': 'Blood Sugar',
  'spo2': 'SpO2',
  'bmi': 'BMI',
  'weight': 'Weight',
};

const _metricIcons = {
  'blood_pressure': Icons.favorite_border,
  'blood_sugar': Icons.water_drop_outlined,
  'spo2': Icons.air,
  'bmi': Icons.monitor_weight_outlined,
  'weight': Icons.monitor_weight_outlined,
};

const _metricColors = {
  'blood_pressure': AppColors.error,
  'blood_sugar': Color(0xFFF57C00),
  'spo2': AppColors.success,
  'bmi': Color(0xFF7B1FA2),
  'weight': Color(0xFF7B1FA2),
};

const _levels = ['NORMAL', 'DANGER', 'CRITICAL'];

const _levelColors = {
  'NORMAL': AppColors.success,
  'DANGER': AppColors.warning,
  'CRITICAL': AppColors.error,
};

// ─── Page ─────────────────────────────────────────────────────────────────────

class AdminThresholdsPage extends StatefulWidget {
  const AdminThresholdsPage({super.key});

  @override
  State<AdminThresholdsPage> createState() => _AdminThresholdsPageState();
}

class _AdminThresholdsPageState extends State<AdminThresholdsPage> {
  final Map<String, String?> _ageFilter = {};

  List<String> _activeTabs(Map<String, List<HealthThreshold>> grouped) {
    final order = _metricTypes.where(grouped.containsKey).toList();
    final extras = grouped.keys.where((k) => !_metricTypes.contains(k)).toList();
    return [...order, ...extras];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminThresholdsViewModel>().load();
    });
  }

  void _showForm({HealthThreshold? editing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<AdminThresholdsViewModel>(),
        child: _ThresholdForm(editing: editing),
      ),
    );
  }

  void _confirmDelete(HealthThreshold t) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Threshold', style: AppTextStyles.h3),
        content: Text(
          'Delete ${_levelLabel(t.level)} rule for ${_metricLabels[t.metricType] ?? t.metricType}?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AdminThresholdsViewModel>().delete(t.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  AppBar _simpleAppBar(AdminThresholdsViewModel vm) => AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Health Thresholds', style: AppTextStyles.h3),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: vm.load,
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminThresholdsViewModel>(
      builder: (context, vm, _) {
        // ── Loading ──────────────────────────────────────────
        if (vm.isLoading) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: _simpleAppBar(vm),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // ── Error ────────────────────────────────────────────
        if (vm.error != null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: _simpleAppBar(vm),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off,
                      size: 52, color: AppColors.textSecondary),
                  const SizedBox(height: 12),
                  Text('Failed to load', style: AppTextStyles.subtitle),
                  const SizedBox(height: 6),
                  Text(vm.error!,
                      style: AppTextStyles.bodySmall,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: vm.load,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // ── Empty ────────────────────────────────────────────
        if (vm.items.isEmpty) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: _simpleAppBar(vm),
            floatingActionButton: _fab(),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.tune_outlined,
                      size: 52, color: AppColors.textSecondary),
                  const SizedBox(height: 8),
                  Text('No thresholds configured',
                      style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 4),
                  Text('Tap + to add the first rule',
                      style: AppTextStyles.bodySmall),
                ],
              ),
            ),
          );
        }

        // ── Data ─────────────────────────────────────────────
        final grouped = vm.grouped;
        final tabs = _activeTabs(grouped);

        return DefaultTabController(
          key: ValueKey(tabs.join(',')),
          length: tabs.length,
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon:
                    const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text('Health Thresholds', style: AppTextStyles.h3),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppColors.primary),
                  onPressed: vm.load,
                ),
              ],
              bottom: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelStyle: AppTextStyles.bodyMedium
                    .copyWith(fontWeight: FontWeight.w600),
                unselectedLabelStyle: AppTextStyles.bodyMedium,
                tabs: tabs.map((m) {
                  final icon =
                      _metricIcons[m] ?? Icons.monitor_heart_outlined;
                  final color = _metricColors[m] ?? AppColors.primary;
                  final count = grouped[m]?.length ?? 0;
                  return Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 16, color: color),
                        const SizedBox(width: 6),
                        Text(_metricLabels[m] ?? m),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$count',
                            style: AppTextStyles.label
                                .copyWith(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            floatingActionButton: _fab(),
            body: TabBarView(
              children: tabs.map((metricType) {
                final items = grouped[metricType] ?? [];
                return _MetricTabContent(
                  metricType: metricType,
                  thresholds: items,
                  selectedAge: _ageFilter[metricType],
                  onAgeSelected: (key) =>
                      setState(() => _ageFilter[metricType] = key),
                  onEdit: (t) => _showForm(editing: t),
                  onDelete: _confirmDelete,
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _fab() => FloatingActionButton.extended(
        onPressed: () => _showForm(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Rule', style: TextStyle(color: Colors.white)),
      );
}

// ─── Metric Tab Content ────────────────────────────────────────────────────────

class _MetricTabContent extends StatelessWidget {
  final String metricType;
  final List<HealthThreshold> thresholds;
  final String? selectedAge;
  final void Function(String?) onAgeSelected;
  final void Function(HealthThreshold) onEdit;
  final void Function(HealthThreshold) onDelete;

  const _MetricTabContent({
    required this.metricType,
    required this.thresholds,
    required this.selectedAge,
    required this.onAgeSelected,
    required this.onEdit,
    required this.onDelete,
  });

  /// Build distinct age-group keys from data: e.g. "0–1", "2–5", …
  List<String> _ageGroupKeys() {
    final seen = <String>{};
    for (final t in thresholds) {
      seen.add(_ageKey(t));
    }
    final list = seen.toList()
      ..sort((a, b) => _ageSort(a).compareTo(_ageSort(b)));
    return list;
  }

  static String _ageKey(HealthThreshold t) {
    if (t.fromAge == null && t.toAge == null) return 'All ages';
    final from = t.fromAge ?? 0;
    final to = t.toAge;
    return to == null || to >= 120 ? '$from+' : '$from–$to';
  }

  static int _ageSort(String key) {
    final n = int.tryParse(key.replaceAll(RegExp(r'[^\d].*'), ''));
    return n ?? 999;
  }

  List<HealthThreshold> _filtered() {
    if (selectedAge == null) return thresholds;
    return thresholds.where((t) => _ageKey(t) == selectedAge).toList();
  }

  @override
  Widget build(BuildContext context) {
    final ageKeys = _ageGroupKeys();
    final filtered = _filtered();
    final color = _metricColors[metricType] ?? AppColors.primary;

    return Column(
      children: [
        // ── Age filter chips ──────────────────────────────────────
        if (ageKeys.length > 1)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.person_search_outlined,
                          size: 15, color: AppColors.textSecondary),
                      const SizedBox(width: 5),
                      Text('Filter by age group',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _AgeChip(
                        label: 'All',
                        selected: selectedAge == null,
                        color: color,
                        onTap: () => onAgeSelected(null),
                      ),
                      const SizedBox(width: 6),
                      ...ageKeys.map((key) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: _AgeChip(
                              label: key,
                              selected: selectedAge == key,
                              color: color,
                              onTap: () => onAgeSelected(
                                  selectedAge == key ? null : key),
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        if (ageKeys.length > 1) const Divider(height: 1),

        // ── Level summary strip ───────────────────────────────────
        _LevelSummaryStrip(thresholds: filtered),
        const Divider(height: 1),

        // ── Threshold list ────────────────────────────────────────
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.filter_list_off,
                          size: 40, color: AppColors.textSecondary),
                      const SizedBox(height: 8),
                      Text('No rules for this age group',
                          style: AppTextStyles.bodyMedium),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _ThresholdCard(
                    threshold: filtered[i],
                    onEdit: () => onEdit(filtered[i]),
                    onDelete: () => onDelete(filtered[i]),
                  ),
                ),
        ),
      ],
    );
  }
}

// ─── Age Chip ─────────────────────────────────────────────────────────────────

class _AgeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _AgeChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : Colors.grey.withAlpha(100),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// ─── Level Summary Strip ──────────────────────────────────────────────────────

class _LevelSummaryStrip extends StatelessWidget {
  final List<HealthThreshold> thresholds;
  const _LevelSummaryStrip({required this.thresholds});

  @override
  Widget build(BuildContext context) {
    final counts = <String, int>{};
    for (final t in thresholds) {
      counts[t.level] = (counts[t.level] ?? 0) + 1;
    }
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Text(
            '${thresholds.length} rule${thresholds.length == 1 ? '' : 's'}',
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary),
          ),
          const Spacer(),
          ..._levels.where((l) => (counts[l] ?? 0) > 0).map((l) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _levelColors[l],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_levelLabel(l)} ${counts[l]}',
                      style: AppTextStyles.label.copyWith(
                        color: _levelColors[l],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ─── Threshold Card ────────────────────────────────────────────────────────────

class _ThresholdCard extends StatelessWidget {
  final HealthThreshold threshold;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ThresholdCard({
    required this.threshold,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final levelColor = _levelColors[threshold.level] ?? AppColors.textSecondary;
    final unit = threshold.unit?.isNotEmpty == true ? ' ${threshold.unit}' : '';
    final from = threshold.fromAge ?? 0;
    final to = threshold.toAge;
    final ageLabel = (threshold.fromAge == null && threshold.toAge == null)
        ? 'All ages'
        : (to == null || to >= 120)
            ? '$from+ years'
            : '$from–$to years';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Level badge
              Container(
                width: 74,
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                decoration: BoxDecoration(
                  color: levelColor.withAlpha(22),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: levelColor.withAlpha(80)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(bottom: 3),
                      decoration: BoxDecoration(
                        color: levelColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      _levelLabel(threshold.level),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.label
                          .copyWith(color: levelColor, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Age + value range
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person_outline,
                            size: 13, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(ageLabel,
                            style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_fmtNum(threshold.minValue)} – ${_fmtNum(threshold.maxValue)}$unit',
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              // Actions
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert,
                    size: 18, color: AppColors.textSecondary),
                onSelected: (v) {
                  if (v == 'edit') onEdit();
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete',
                        style: TextStyle(color: AppColors.error)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Add / Edit Form ──────────────────────────────────────────────────────────

class _ThresholdForm extends StatefulWidget {
  final HealthThreshold? editing;
  const _ThresholdForm({this.editing});

  @override
  State<_ThresholdForm> createState() => _ThresholdFormState();
}

class _ThresholdFormState extends State<_ThresholdForm> {
  final _formKey = GlobalKey<FormState>();

  late String _metricType;
  late String _level;
  late String _unit;
  final _fromAge = TextEditingController();
  final _toAge = TextEditingController();
  final _minValue = TextEditingController();
  final _maxValue = TextEditingController();

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    _metricType = e?.metricType ?? _metricTypes.first;
    _level = e?.level ?? 'NORMAL';
    _unit = e?.unit ?? '';
    _fromAge.text = e?.fromAge?.toString() ?? '';
    _toAge.text = e?.toAge?.toString() ?? '';
    _minValue.text = _fmtNum(e?.minValue) == 'N/A' ? '' : _fmtNum(e?.minValue);
    _maxValue.text = _fmtNum(e?.maxValue) == 'N/A' ? '' : _fmtNum(e?.maxValue);
  }

  @override
  void dispose() {
    _fromAge.dispose();
    _toAge.dispose();
    _minValue.dispose();
    _maxValue.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final vm = context.read<AdminThresholdsViewModel>();
    final threshold = HealthThreshold(
      id: widget.editing?.id ?? '',
      metricType: _metricType,
      fromAge: _fromAge.text.isNotEmpty ? int.tryParse(_fromAge.text) : null,
      toAge: _toAge.text.isNotEmpty ? int.tryParse(_toAge.text) : null,
      minValue: _minValue.text.isNotEmpty ? double.tryParse(_minValue.text) : null,
      maxValue: _maxValue.text.isNotEmpty ? double.tryParse(_maxValue.text) : null,
      level: _level,
      unit: _unit.trim().isNotEmpty ? _unit.trim() : null,
    );

    final ok = widget.editing != null
        ? await vm.update(threshold)
        : await vm.add(threshold);

    if (mounted) {
      setState(() => _saving = false);
      if (ok) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(vm.error ?? 'Failed to save'),
          backgroundColor: AppColors.error,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.editing != null;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  isEdit ? 'Edit Threshold Rule' : 'Add Threshold Rule',
                  style: AppTextStyles.h3,
                ),
                const SizedBox(height: 20),

                _FormLabel('Metric Type'),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _metricType,
                  decoration: _inputDeco(),
                  items: _metricTypes
                      .map((m) => DropdownMenuItem(
                            value: m,
                            child: Row(children: [
                              Icon(
                                _metricIcons[m] ?? Icons.monitor_heart_outlined,
                                size: 16,
                                color: _metricColors[m] ?? AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(_metricLabels[m] ?? m,
                                  style: AppTextStyles.bodyMedium),
                            ]),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _metricType = v!),
                ),
                const SizedBox(height: 14),

                _FormLabel('Level'),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _level,
                  decoration: _inputDeco(),
                  items: _levels
                      .map((l) => DropdownMenuItem(
                            value: l,
                            child: Row(children: [
                              Container(
                                width: 10,
                                height: 10,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: _levelColors[l],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Text(_levelLabel(l),
                                  style: AppTextStyles.bodyMedium),
                            ]),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _level = v!),
                ),
                const SizedBox(height: 14),

                _FormLabel('Age Range (optional)'),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _fromAge,
                        decoration: _inputDeco(hint: 'From age'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('–'),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _toAge,
                        decoration: _inputDeco(hint: 'To age'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                _FormLabel('Value Range'),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _minValue,
                        decoration: _inputDeco(hint: 'Min'),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style: AppTextStyles.bodyMedium,
                        validator: (v) {
                          if (v != null &&
                              v.isNotEmpty &&
                              double.tryParse(v) == null) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('–'),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _maxValue,
                        decoration: _inputDeco(hint: 'Max'),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style: AppTextStyles.bodyMedium,
                        validator: (v) {
                          if (v != null &&
                              v.isNotEmpty &&
                              double.tryParse(v) == null) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                _FormLabel('Unit (optional)'),
                const SizedBox(height: 6),
                TextFormField(
                  initialValue: _unit,
                  decoration: _inputDeco(hint: 'e.g. mmHg, mg/dL, %, BMI'),
                  style: AppTextStyles.bodyMedium,
                  onChanged: (v) => _unit = v,
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isEdit ? 'Save Changes' : 'Add Rule',
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco({String? hint}) => InputDecoration(
        hintText: hint,
        hintStyle:
            AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.withAlpha(80)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.withAlpha(80)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        filled: true,
        fillColor: Colors.white,
      );
}

class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      );
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

String _levelLabel(String level) =>
    level[0] + level.substring(1).toLowerCase();

String _fmtNum(double? v) =>
    v == null ? 'N/A' : (v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1));
