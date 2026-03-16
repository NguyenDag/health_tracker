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
  'weight',
];

const _metricLabels = {
  'blood_pressure': 'Blood Pressure',
  'blood_sugar': 'Blood Sugar',
  'spo2': 'SpO2',
  'weight': 'Weight',
};

const _metricIcons = {
  'blood_pressure': Icons.favorite_border,
  'blood_sugar': Icons.water_drop_outlined,
  'spo2': Icons.air,
  'weight': Icons.monitor_weight_outlined,
};

const _metricColors = {
  'blood_pressure': AppColors.error,
  'blood_sugar': Color(0xFFF57C00),
  'spo2': AppColors.success,
  'weight': Color(0xFF7B1FA2),
};

// Fixed unit per metric; blood_sugar has two options
const _metricDefaultUnit = {
  'blood_pressure': 'mmHg',
  'blood_sugar': 'mg/dL',
  'spo2': '%',
  'weight': 'kg',
};

const _bloodSugarUnits = ['mg/dL', 'mmol/L'];

const _levels = ['NORMAL', 'DANGER', 'CRITICAL'];

const _levelColors = {
  'NORMAL': AppColors.success,
  'DANGER': AppColors.warning,
  'CRITICAL': AppColors.error,
};

const _levelBg = {
  'NORMAL': Color(0xFFE8F5E9),
  'DANGER': Color(0xFFFFF3E0),
  'CRITICAL': Color(0xFFFFEBEE),
};


// ─── Helpers ──────────────────────────────────────────────────────────────────

String _levelLabel(String l) => l[0] + l.substring(1).toLowerCase();

String _fmtNum(double? v) => v == null
    ? '?'
    : (v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1));

String _ageKey(HealthThreshold t) {
  if (t.fromAge == null && t.toAge == null) return 'All ages';
  final from = t.fromAge ?? 0;
  final to = t.toAge;
  return (to == null || to >= 120) ? '$from+ yrs' : '$from–$to yrs';
}

int _ageSortKey(String key) =>
    int.tryParse(key.replaceAll(RegExp(r'[^\d].*'), '')) ?? 999;

extension _TSort on List<HealthThreshold> {
  List<HealthThreshold> bySeverityThenMin() {
    const order = {'CRITICAL': 0, 'DANGER': 1, 'NORMAL': 2};
    return [...this]..sort((a, b) {
        final lo = (order[a.level] ?? 3).compareTo(order[b.level] ?? 3);
        if (lo != 0) return lo;
        return (a.minValue ?? 0).compareTo(b.minValue ?? 0);
      });
  }
}

// ─── Page ─────────────────────────────────────────────────────────────────────

class AdminThresholdsPage extends StatefulWidget {
  const AdminThresholdsPage({super.key});
  @override
  State<AdminThresholdsPage> createState() => _AdminThresholdsPageState();
}

class _AdminThresholdsPageState extends State<AdminThresholdsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<AdminThresholdsViewModel>().load());
  }

  List<String> _tabs(Map<String, List<HealthThreshold>> g) {
    final ordered = _metricTypes.where(g.containsKey).toList();
    final extras = g.keys.where((k) => !_metricTypes.contains(k)).toList();
    return [...ordered, ...extras];
  }

  void _openForm({HealthThreshold? editing}) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<AdminThresholdsViewModel>(),
          child: _ThresholdForm(editing: editing),
        ),
      );

  void _confirmDelete(HealthThreshold t) => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(18),
                  shape: BoxShape.circle),
              child: const Icon(Icons.delete_outline,
                  color: AppColors.error, size: 18),
            ),
            const SizedBox(width: 10),
            Text('Delete Rule', style: AppTextStyles.h3),
          ]),
          content: Text(
            'Remove the ${_levelLabel(t.level)} rule for '
            '${_metricLabels[t.metricType] ?? t.metricType}?\n\nThis cannot be undone.',
            style: AppTextStyles.bodyMedium,
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              icon: const Icon(Icons.delete_outline, size: 16),
              label: const Text('Delete'),
              onPressed: () async {
                Navigator.pop(context);
                await context.read<AdminThresholdsViewModel>().delete(t.id);
              },
            ),
          ],
        ),
      );

  AppBar _bareAppBar(AdminThresholdsViewModel vm) => AppBar(
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

  Widget _fab() => FloatingActionButton.extended(
        heroTag: 'add_threshold',
        onPressed: () => _openForm(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Rule',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      );

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminThresholdsViewModel>(builder: (ctx, vm, _) {
      // Loading
      if (vm.isLoading) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _bareAppBar(vm),
          body: const Center(child: CircularProgressIndicator()),
        );
      }
      // Error
      if (vm.error != null) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _bareAppBar(vm),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: AppColors.error.withAlpha(15),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.cloud_off,
                      size: 36, color: AppColors.error),
                ),
                const SizedBox(height: 16),
                Text('Failed to load', style: AppTextStyles.subtitle),
                const SizedBox(height: 6),
                Text(vm.error!,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: vm.load,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Retry'),
                ),
              ]),
            ),
          ),
        );
      }
      // Empty
      if (vm.items.isEmpty) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _bareAppBar(vm),
          floatingActionButton: _fab(),
          body: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(15),
                    shape: BoxShape.circle),
                child: const Icon(Icons.tune_outlined,
                    size: 36, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              Text('No thresholds yet', style: AppTextStyles.subtitle),
              const SizedBox(height: 6),
              Text('Tap + to add the first rule',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary)),
            ]),
          ),
        );
      }

      // Data
      final grouped = vm.grouped;
      final tabs = _tabs(grouped);

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
                final color = _metricColors[m] ?? AppColors.primary;
                final icon =
                    _metricIcons[m] ?? Icons.monitor_heart_outlined;
                final count = grouped[m]?.length ?? 0;
                return Tab(
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(icon, size: 15, color: color),
                    const SizedBox(width: 6),
                    Text(_metricLabels[m] ?? m),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: color.withAlpha(22),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('$count',
                          style: AppTextStyles.label
                              .copyWith(color: color, fontSize: 10)),
                    ),
                  ]),
                );
              }).toList(),
            ),
          ),
          floatingActionButton: _fab(),
          body: TabBarView(
            children: tabs.map((metric) {
              final items = grouped[metric] ?? [];
              return _MetricTab(
                metricType: metric,
                thresholds: items,
                onEdit: _openForm,
                onDelete: _confirmDelete,
              );
            }).toList(),
          ),
        ),
      );
    });
  }
}

// ─── Metric Tab ───────────────────────────────────────────────────────────────

class _MetricTab extends StatelessWidget {
  final String metricType;
  final List<HealthThreshold> thresholds;
  final void Function({HealthThreshold? editing}) onEdit;
  final void Function(HealthThreshold) onDelete;

  const _MetricTab({
    required this.metricType,
    required this.thresholds,
    required this.onEdit,
    required this.onDelete,
  });

  Map<String, List<HealthThreshold>> _byAge() {
    final map = <String, List<HealthThreshold>>{};
    for (final t in thresholds) {
      (map[_ageKey(t)] ??= []).add(t);
    }
    final sorted = map.entries.toList()
      ..sort((a, b) => _ageSortKey(a.key).compareTo(_ageSortKey(b.key)));
    return Map.fromEntries(sorted);
  }

  @override
  Widget build(BuildContext context) {
    final byAge = _byAge();
    final color = _metricColors[metricType] ?? AppColors.primary;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: byAge.length,
      itemBuilder: (_, i) {
        final ageKey = byAge.keys.elementAt(i);
        final rules = byAge[ageKey]!;
        return _AgeBandCard(
          ageKey: ageKey,
          rules: rules,
          accentColor: color,
          onEdit: onEdit,
          onDelete: onDelete,
        );
      },
    );
  }
}

// ─── Age Band Card ────────────────────────────────────────────────────────────

class _AgeBandCard extends StatefulWidget {
  final String ageKey;
  final List<HealthThreshold> rules;
  final Color accentColor;
  final void Function({HealthThreshold? editing}) onEdit;
  final void Function(HealthThreshold) onDelete;

  const _AgeBandCard({
    required this.ageKey,
    required this.rules,
    required this.accentColor,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_AgeBandCard> createState() => _AgeBandCardState();
}

class _AgeBandCardState extends State<_AgeBandCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final nCount = widget.rules.where((r) => r.level == 'NORMAL').length;
    final dCount = widget.rules.where((r) => r.level == 'DANGER').length;
    final cCount = widget.rules.where((r) => r.level == 'CRITICAL').length;
    final sorted = widget.rules.bySeverityThenMin();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(children: [
          // ── Header ──────────────────────────────────────────
          Material(
            color: Colors.white,
            child: InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: widget.accentColor.withAlpha(18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.people_outline,
                        size: 15, color: widget.accentColor),
                  ),
                  const SizedBox(width: 10),
                  Text(widget.ageKey,
                      style: AppTextStyles.subtitle.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(width: 8),
                  if (cCount > 0) _MiniPill('C$cCount', AppColors.error),
                  if (dCount > 0) _MiniPill('D$dCount', AppColors.warning),
                  if (nCount > 0) _MiniPill('N$nCount', AppColors.success),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _expanded ? 0 : -0.25,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down,
                        color: AppColors.textSecondary, size: 20),
                  ),
                ]),
              ),
            ),
          ),

          // ── Body ────────────────────────────────────────────
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Column(children: [
              const Divider(height: 1, thickness: 1),
              // Range bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: _RangeBar(rules: widget.rules),
              ),
              const Divider(height: 1, thickness: 1),
              // Rule rows
              ...sorted.map((r) => _RuleRow(
                    rule: r,
                    isLast: r == sorted.last,
                    onEdit: () => widget.onEdit(editing: r),
                    onDelete: () => widget.onDelete(r),
                  )),
            ]),
            secondChild: const SizedBox.shrink(),
          ),
        ]),
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  final String text;
  final Color color;
  const _MiniPill(this.text, this.color);

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withAlpha(22),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Text(text,
            style: AppTextStyles.label
                .copyWith(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
      );
}

// ─── Range Bar ────────────────────────────────────────────────────────────────

class _RangeBar extends StatelessWidget {
  final List<HealthThreshold> rules;
  const _RangeBar({required this.rules});

  @override
  Widget build(BuildContext context) {
    final valid =
        rules.where((r) => r.minValue != null && r.maxValue != null).toList();
    if (valid.isEmpty) return const SizedBox.shrink();

    final globalMin =
        valid.map((r) => r.minValue!).reduce((a, b) => a < b ? a : b);
    final globalMax =
        valid.map((r) => r.maxValue!).reduce((a, b) => a > b ? a : b);
    final span = globalMax - globalMin;
    if (span <= 0) return const SizedBox.shrink();

    final sorted = [...valid]
      ..sort((a, b) => a.minValue!.compareTo(b.minValue!));

    // Which levels appear in this band
    final presentLevels =
        _levels.where((l) => rules.any((r) => r.level == l)).toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Range',
              style: AppTextStyles.label
                  .copyWith(color: AppColors.textSecondary, fontSize: 10)),
          // Legend
          Row(
            children: presentLevels
                .map((l) => Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Row(children: [
                        Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                                color: _levelColors[l],
                                borderRadius: BorderRadius.circular(2))),
                        const SizedBox(width: 4),
                        Text(_levelLabel(l),
                            style: AppTextStyles.label.copyWith(
                                color: AppColors.textSecondary, fontSize: 10)),
                      ]),
                    ))
                .toList(),
          ),
        ],
      ),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: LayoutBuilder(builder: (_, c) {
          final totalW = c.maxWidth;
          return Stack(children: [
            Container(
                width: totalW, height: 12, color: Colors.grey.withAlpha(25)),
            ...sorted.map((r) {
              final left = (r.minValue! - globalMin) / span * totalW;
              final w =
                  ((r.maxValue! - r.minValue!) / span * totalW).clamp(2.0, totalW);
              return Positioned(
                left: left,
                width: w,
                top: 0,
                bottom: 0,
                child: Container(
                    color: (_levelColors[r.level] ?? Colors.grey)
                        .withAlpha(210)),
              );
            }),
          ]);
        }),
      ),
      const SizedBox(height: 4),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(_fmtNum(globalMin),
            style: AppTextStyles.label
                .copyWith(color: AppColors.textSecondary, fontSize: 10)),
        Text(_fmtNum(globalMax),
            style: AppTextStyles.label
                .copyWith(color: AppColors.textSecondary, fontSize: 10)),
      ]),
    ]);
  }
}

// ─── Rule Row ─────────────────────────────────────────────────────────────────

class _RuleRow extends StatelessWidget {
  final HealthThreshold rule;
  final bool isLast;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RuleRow({
    required this.rule,
    required this.isLast,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final levelColor = _levelColors[rule.level] ?? AppColors.textSecondary;
    final levelBgColor = _levelBg[rule.level] ?? Colors.grey.shade50;
    final unit = rule.unit?.isNotEmpty == true ? ' ${rule.unit}' : '';

    return Column(children: [
      InkWell(
        onTap: onEdit,
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: levelColor, width: 3)),
          ),
          padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
          child: Row(children: [
            // Level badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: levelBgColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                        color: levelColor, shape: BoxShape.circle)),
                const SizedBox(width: 5),
                Text(_levelLabel(rule.level),
                    style: AppTextStyles.label.copyWith(
                        color: levelColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 11)),
              ]),
            ),
            const SizedBox(width: 12),
            // Value
            Expanded(
              child: Text(
                '${_fmtNum(rule.minValue)} – ${_fmtNum(rule.maxValue)}$unit',
                style: AppTextStyles.bodyMedium
                    .copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            // Actions
            IconButton(
              icon: const Icon(Icons.edit_outlined,
                  size: 17, color: AppColors.textSecondary),
              onPressed: onEdit,
              visualDensity: VisualDensity.compact,
              tooltip: 'Edit',
            ),
            IconButton(
              icon: Icon(Icons.delete_outline,
                  size: 17, color: AppColors.error.withAlpha(160)),
              onPressed: onDelete,
              visualDensity: VisualDensity.compact,
              tooltip: 'Delete',
            ),
          ]),
        ),
      ),
      if (!isLast) const Divider(height: 1, indent: 17, endIndent: 0),
    ]);
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
  bool _deleting = false;

  bool get _isEdit => widget.editing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    _metricType = e?.metricType ?? _metricTypes.first;
    _level = e?.level ?? 'NORMAL';
    _unit = e?.unit ?? _metricDefaultUnit[_metricType] ?? '';
    _fromAge.text = e?.fromAge?.toString() ?? '';
    _toAge.text = e?.toAge?.toString() ?? '';
    _minValue.text = e?.minValue != null ? _fmtNum(e!.minValue) : '';
    _maxValue.text = e?.maxValue != null ? _fmtNum(e!.maxValue) : '';
  }

  void _onMetricChanged(String m) {
    setState(() {
      _metricType = m;
      _unit = _metricDefaultUnit[m] ?? '';
    });
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
    final t = HealthThreshold(
      id: widget.editing?.id ?? '',
      metricType: _metricType,
      fromAge: _fromAge.text.isNotEmpty ? int.tryParse(_fromAge.text) : null,
      toAge: _toAge.text.isNotEmpty ? int.tryParse(_toAge.text) : null,
      minValue:
          _minValue.text.isNotEmpty ? double.tryParse(_minValue.text) : null,
      maxValue:
          _maxValue.text.isNotEmpty ? double.tryParse(_maxValue.text) : null,
      level: _level,
      unit: _unit.trim().isNotEmpty ? _unit.trim() : null,
    );
    final ok = _isEdit ? await vm.update(t) : await vm.add(t);
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

  Future<void> _deleteRule() async {
    setState(() => _deleting = true);
    final ok =
        await context.read<AdminThresholdsViewModel>().delete(widget.editing!.id);
    if (mounted) {
      setState(() => _deleting = false);
      if (ok) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                // Title + delete
                Row(children: [
                  Expanded(
                    child: Text(
                      _isEdit ? 'Edit Rule' : 'New Threshold Rule',
                      style: AppTextStyles.h3,
                    ),
                  ),
                  if (_isEdit)
                    _deleting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.error))
                        : IconButton(
                            icon: Icon(Icons.delete_outline,
                                color: AppColors.error.withAlpha(200)),
                            onPressed: _deleteRule,
                            tooltip: 'Delete rule',
                          ),
                ]),
                const SizedBox(height: 20),

                // ── Metric type ─────────────────────────────────────
                _Label('Metric Type'),
                const SizedBox(height: 8),
                if (_isEdit)
                  _ReadonlyRow(
                    icon: _metricIcons[_metricType] ?? Icons.monitor_heart_outlined,
                    color: _metricColors[_metricType] ?? AppColors.primary,
                    label: _metricLabels[_metricType] ?? _metricType,
                  )
                else
                  _MetricGrid(
                    selected: _metricType,
                    onChanged: _onMetricChanged,
                  ),
                const SizedBox(height: 18),

                // ── Level ───────────────────────────────────────────
                _Label('Level'),
                const SizedBox(height: 8),
                if (_isEdit)
                  _ReadonlyRow(
                    icon: Icons.circle,
                    color: _levelColors[_level] ?? AppColors.primary,
                    label: _levelLabel(_level),
                  )
                else
                  _LevelBar(
                    selected: _level,
                    onChanged: (v) => setState(() => _level = v),
                  ),
                const SizedBox(height: 18),

                // ── Age range ───────────────────────────────────────
                _Label('Age Range  (optional)'),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                      child: _NField(
                          controller: _fromAge,
                          hint: 'From',
                          integer: true)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('–',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textSecondary)),
                  ),
                  Expanded(
                      child: _NField(
                          controller: _toAge, hint: 'To', integer: true)),
                  const SizedBox(width: 8),
                  Text('yrs',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary)),
                ]),
                const SizedBox(height: 18),

                // ── Value range ─────────────────────────────────────
                _Label('Value Range'),
                const SizedBox(height: 8),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                    child: _NField(
                      controller: _minValue,
                      hint: 'Min',
                      validator: _numValidator,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 14),
                    child: Text('–',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textSecondary)),
                  ),
                  Expanded(
                    child: _NField(
                      controller: _maxValue,
                      hint: 'Max',
                      validator: _numValidator,
                    ),
                  ),
                ]),
                const SizedBox(height: 10),

                // Unit
                _Label('Unit'),
                const SizedBox(height: 8),
                if (!_isEdit && _metricType == 'blood_sugar')
                  Row(children: _bloodSugarUnits.map((u) {
                    final on = _unit == u;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _UnitChip(
                        label: u,
                        selected: on,
                        onTap: () => setState(() => _unit = u),
                      ),
                    );
                  }).toList())
                else
                  _ReadonlyRow(
                    icon: Icons.straighten_outlined,
                    color: AppColors.primary,
                    label: _unit.isNotEmpty ? _unit : '—',
                  ),
                const SizedBox(height: 20),

                // Save
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text(
                            _isEdit ? 'Save Changes' : 'Add Rule',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15),
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

  String? _numValidator(String? v) {
    if (v != null && v.isNotEmpty && double.tryParse(v) == null) {
      return 'Invalid number';
    }
    return null;
  }
}

// ─── Metric Grid ──────────────────────────────────────────────────────────────

class _MetricGrid extends StatelessWidget {
  final String selected;
  final void Function(String) onChanged;
  const _MetricGrid({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _metricTypes.map((m) {
        final on = m == selected;
        final color = _metricColors[m] ?? AppColors.primary;
        final icon = _metricIcons[m] ?? Icons.monitor_heart_outlined;
        return GestureDetector(
          onTap: () => onChanged(m),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: on ? color.withAlpha(22) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: on ? color : Colors.grey.withAlpha(80),
                  width: on ? 1.5 : 1),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 14, color: on ? color : AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(_metricLabels[m] ?? m,
                  style: AppTextStyles.bodySmall.copyWith(
                      color: on ? color : AppColors.textSecondary,
                      fontWeight:
                          on ? FontWeight.w600 : FontWeight.normal)),
            ]),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Level Bar ────────────────────────────────────────────────────────────────

class _LevelBar extends StatelessWidget {
  final String selected;
  final void Function(String) onChanged;
  const _LevelBar({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _levels.asMap().entries.map((e) {
        final i = e.key;
        final l = e.value;
        final on = l == selected;
        final color = _levelColors[l] ?? AppColors.primary;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(l),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: EdgeInsets.only(right: i < _levels.length - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: on ? color : color.withAlpha(15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: on ? color : color.withAlpha(50),
                    width: on ? 0 : 1),
              ),
              child: Column(children: [
                Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        color: on ? Colors.white : color,
                        shape: BoxShape.circle)),
                const SizedBox(height: 5),
                Text(_levelLabel(l),
                    style: AppTextStyles.label.copyWith(
                        color: on ? Colors.white : color,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Unit Chip ────────────────────────────────────────────────────────────────

class _UnitChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _UnitChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.primary.withAlpha(12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: selected
                    ? AppColors.primary
                    : AppColors.primary.withAlpha(40)),
          ),
          child: Text(label,
              style: AppTextStyles.label.copyWith(
                  color: selected ? Colors.white : AppColors.primary,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal)),
        ),
      );
}

// ─── Numeric Field ────────────────────────────────────────────────────────────

class _NField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool integer;
  final String? Function(String?)? validator;
  const _NField(
      {required this.controller,
      required this.hint,
      this.integer = false,
      this.validator});

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        style: AppTextStyles.bodyMedium,
        keyboardType: integer
            ? TextInputType.number
            : const TextInputType.numberWithOptions(decimal: true),
        inputFormatters:
            integer ? [FilteringTextInputFormatter.digitsOnly] : null,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodySmall
              .copyWith(color: AppColors.textSecondary),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.withAlpha(80))),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.withAlpha(80))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.error)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      );
}

// ─── Label ────────────────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2));
}

// ─── Readonly Row ─────────────────────────────────────────────────────────────

class _ReadonlyRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  const _ReadonlyRow({required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.withAlpha(80)),
        ),
        child: Row(children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(label,
              style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
          const Spacer(),
          Icon(Icons.lock_outline, size: 14, color: Colors.grey.withAlpha(120)),
        ]),
      );
}
