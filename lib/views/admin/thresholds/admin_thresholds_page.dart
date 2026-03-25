import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../domain/entities/threshold.dart';
import '../../../viewmodels/admin_thresholds_viewmodel.dart';

// ─── Constants ────────────────────────────────────────────────────────────────

const _metricTypes = [
  'blood_pressure_systolic',
  'blood_pressure_diastolic',
  'blood_pressure_pulse',
  'blood_sugar',
  'spo2',
];

const _metricLabels = {
  'blood_pressure_systolic': 'Tâm Thu',
  'blood_pressure_diastolic': 'Tâm Trương',
  'blood_pressure_pulse': 'Nhịp Tim',
  'blood_sugar': 'Đường Huyết',
  'spo2': 'SpO2',
};

const _metricIcons = {
  'blood_pressure_systolic': Icons.favorite,
  'blood_pressure_diastolic': Icons.favorite_border,
  'blood_pressure_pulse': Icons.monitor_heart_outlined,
  'blood_sugar': Icons.water_drop_outlined,
  'spo2': Icons.air,
};

const _metricColors = {
  'blood_pressure_systolic': AppColors.error,
  'blood_pressure_diastolic': Color(0xFFE53935),
  'blood_pressure_pulse': Color(0xFFFF7043),
  'blood_sugar': Color(0xFFF57C00),
  'spo2': AppColors.success,
};

const _metricGroupLabel = {
  'blood_pressure_systolic': 'Huyết Áp',
  'blood_pressure_diastolic': 'Huyết Áp',
  'blood_pressure_pulse': 'Huyết Áp',
};

const _metricDefaultUnit = {
  'blood_pressure_systolic': 'mmHg',
  'blood_pressure_diastolic': 'mmHg',
  'blood_pressure_pulse': 'bpm',
  'blood_sugar': 'mg/dL',
  'spo2': '%',
};

const _bloodSugarUnits = ['mg/dL', 'mmol/L'];

// ─── Helpers ──────────────────────────────────────────────────────────────────

String _fmtNum(double v) =>
    v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1);

String _ageKey(HealthThreshold t) {
  if (t.fromAge == null && t.toAge == null) return 'Mọi độ tuổi';
  final from = t.fromAge ?? 0;
  final to = t.toAge;
  return (to == null || to >= 120) ? '$from+ tuổi' : '$from–$to tuổi';
}

int _ageSortKey(String key) =>
    int.tryParse(key.replaceAll(RegExp(r'[^\d].*'), '')) ?? 999;

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
      (_) => context.read<AdminThresholdsViewModel>().load(),
    );
  }

  List<String> _tabs(Map<String, List<HealthThreshold>> g) {
    final ordered = _metricTypes.where(g.containsKey).toList();
    final extras = g.keys.where((k) => !_metricTypes.contains(k)).toList();
    return [...ordered, ...extras];
  }

  void _openForm({HealthThreshold? editing}) {
    // Capture messenger của page cha TRƯỚC khi mở sheet để snackbar
    // hiển thị phía trên bottom sheet thay vì bị đè phía dưới.
    final messenger = ScaffoldMessenger.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<AdminThresholdsViewModel>(),
        child: _ThresholdForm(editing: editing, messenger: messenger),
      ),
    );
  }

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
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline,
                  color: AppColors.error, size: 18),
            ),
            const SizedBox(width: 10),
            Text('Xóa Quy Tắc', style: AppTextStyles.h3),
          ]),
          content: Text(
            'Xóa ngưỡng cho '
            '${_metricLabels[t.metricType] ?? t.metricType} '
            '(${_ageKey(t)})?\n\nHành động này không thể hoàn tác.',
            style: AppTextStyles.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.delete_outline, size: 16),
              label: const Text('Xóa'),
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
        title: Text('Ngưỡng Sức Khỏe', style: AppTextStyles.h3),
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
        label: const Text(
          'Thêm Quy Tắc',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminThresholdsViewModel>(
      builder: (ctx, vm, _) {
        if (vm.isLoading) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: _bareAppBar(vm),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (vm.error != null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: _bareAppBar(vm),
            body: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.cloud_off, size: 36, color: AppColors.error),
                const SizedBox(height: 12),
                Text(vm.error!, style: AppTextStyles.bodySmall),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: vm.load,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Thử Lại'),
                ),
              ]),
            ),
          );
        }
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
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.tune_outlined,
                      size: 36, color: AppColors.primary),
                ),
                const SizedBox(height: 16),
                Text('Chưa có ngưỡng nào', style: AppTextStyles.subtitle),
                const SizedBox(height: 6),
                Text('Nhấn + để thêm quy tắc đầu tiên',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
              ]),
            ),
          );
        }

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
                icon: const Icon(Icons.arrow_back,
                    color: AppColors.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text('Ngưỡng Sức Khỏe', style: AppTextStyles.h3),
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
                  final groupLabel = _metricGroupLabel[m];
                  return Tab(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(mainAxisSize: MainAxisSize.min, children: [
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
                                style: AppTextStyles.label.copyWith(
                                    color: color, fontSize: 10)),
                          ),
                        ]),
                        if (groupLabel != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            groupLabel,
                            style: AppTextStyles.label.copyWith(
                              fontSize: 9,
                              color:
                                  AppColors.textSecondary.withAlpha(160),
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ],
                    ),
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
      },
    );
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

  @override
  Widget build(BuildContext context) {
    final color = _metricColors[metricType] ?? AppColors.primary;
    final sorted = [...thresholds]..sort(
        (a, b) => (_ageSortKey(_ageKey(a))).compareTo(_ageSortKey(_ageKey(b))),
      );

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: sorted.length,
      itemBuilder: (_, i) => _RecordCard(
        record: sorted[i],
        accentColor: color,
        onEdit: () => onEdit(editing: sorted[i]),
        onDelete: () => onDelete(sorted[i]),
      ),
    );
  }
}

// ─── Record Card ──────────────────────────────────────────────────────────────

class _RecordCard extends StatelessWidget {
  final HealthThreshold record;
  final Color accentColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RecordCard({
    required this.record,
    required this.accentColor,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final unit = record.unit?.isNotEmpty == true ? ' ${record.unit}' : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.people_outline,
                    size: 15, color: accentColor),
              ),
              const SizedBox(width: 10),
              Text(
                _ageKey(record),
                style: AppTextStyles.subtitle.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
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
          const Divider(height: 1, thickness: 1),

          // ── Range bar ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: _RangeBar(record: record, accentColor: accentColor),
          ),

          // ── Range labels ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Row(children: [
              Expanded(
                child: _RangeLabel(
                  color: AppColors.success,
                  label: 'Bình Thường',
                  lines: ['${_fmtNum(record.normalMin)} – ${_fmtNum(record.normalMax)}$unit'],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _RangeLabel(
                  color: AppColors.warning,
                  label: 'Nguy Hiểm',
                  lines: [
                    if (record.normalMin > record.dangerMin)
                      '${_fmtNum(record.dangerMin)} – ${_fmtNum(record.normalMin)}$unit',
                    if (record.normalMax < record.dangerMax)
                      '${_fmtNum(record.normalMax)} – ${_fmtNum(record.dangerMax)}$unit',
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _RangeLabel(
                  color: AppColors.error,
                  label: 'Nghiêm Trọng',
                  lines: [
                    if (record.normalMin > record.dangerMin)
                      '< ${_fmtNum(record.dangerMin)}$unit',
                    if (record.normalMax < record.dangerMax)
                      '> ${_fmtNum(record.dangerMax)}$unit',
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _RangeLabel extends StatelessWidget {
  final Color color;
  final String label;
  final List<String> lines;
  const _RangeLabel(
      {required this.color, required this.label, required this.lines});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 4),
            Text(label,
                style: AppTextStyles.label
                    .copyWith(color: color, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 2),
          ...lines.map((l) => Text(l,
              style: AppTextStyles.label
                  .copyWith(color: AppColors.textSecondary, fontSize: 10))),
        ],
      );
}

// ─── Range Bar ────────────────────────────────────────────────────────────────

class _RangeBar extends StatelessWidget {
  final HealthThreshold record;
  final Color accentColor;
  const _RangeBar({required this.record, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final dMin = record.dangerMin;
    final dMax = record.dangerMax;
    final nMin = record.normalMin;
    final nMax = record.normalMax;
    final span = dMax - dMin;
    if (span <= 0) return const SizedBox.shrink();

    return LayoutBuilder(builder: (_, c) {
      final w = c.maxWidth;

      // danger zone left/right margins
      final nLeft = ((nMin - dMin) / span * w).clamp(0.0, w);
      final nWidth = ((nMax - nMin) / span * w).clamp(2.0, w);

      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(children: [
            // base: danger zone (orange)
            Container(
              width: w,
              height: 14,
              color: AppColors.warning.withAlpha(60),
            ),
            // normal zone (green)
            Positioned(
              left: nLeft,
              width: nWidth,
              top: 0,
              bottom: 0,
              child: Container(color: AppColors.success.withAlpha(180)),
            ),
          ]),
        ),
        const SizedBox(height: 4),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(_fmtNum(dMin),
              style: AppTextStyles.label
                  .copyWith(color: AppColors.textSecondary, fontSize: 10)),
          if (nMin > dMin)
            Text(_fmtNum(nMin),
                style: AppTextStyles.label
                    .copyWith(color: AppColors.success, fontSize: 10)),
          if (nMax < dMax)
            Text(_fmtNum(nMax),
                style: AppTextStyles.label
                    .copyWith(color: AppColors.success, fontSize: 10)),
          Text(_fmtNum(dMax),
              style: AppTextStyles.label
                  .copyWith(color: AppColors.textSecondary, fontSize: 10)),
        ]),
      ]);
    });
  }
}

// ─── Add / Edit Form ──────────────────────────────────────────────────────────

class _ThresholdForm extends StatefulWidget {
  final HealthThreshold? editing;
  final ScaffoldMessengerState messenger;
  const _ThresholdForm({this.editing, required this.messenger});
  @override
  State<_ThresholdForm> createState() => _ThresholdFormState();
}

class _ThresholdFormState extends State<_ThresholdForm> {
  final _formKey = GlobalKey<FormState>();

  late String _metricType;
  late String _unit;
  final _fromAge = TextEditingController();
  final _toAge = TextEditingController();
  final _normalMin = TextEditingController();
  final _normalMax = TextEditingController();
  final _dangerMin = TextEditingController();
  final _dangerMax = TextEditingController();
  bool _saving = false;
  bool _deleting = false;
  String? _errorMessage;

  bool get _isEdit => widget.editing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    _metricType = e?.metricType ?? _metricTypes.first;
    _unit = e?.unit ?? _metricDefaultUnit[_metricType] ?? '';
    _fromAge.text = e?.fromAge?.toString() ?? '';
    _toAge.text = e?.toAge?.toString() ?? '';
    _normalMin.text = e != null ? _fmtNum(e.normalMin) : '';
    _normalMax.text = e != null ? _fmtNum(e.normalMax) : '';
    _dangerMin.text = e != null ? _fmtNum(e.dangerMin) : '';
    _dangerMax.text = e != null ? _fmtNum(e.dangerMax) : '';
  }

  void _onMetricChanged(String m) => setState(() {
        _metricType = m;
        _unit = _metricDefaultUnit[m] ?? '';
      });

  @override
  void dispose() {
    _fromAge.dispose();
    _toAge.dispose();
    _normalMin.dispose();
    _normalMax.dispose();
    _dangerMin.dispose();
    _dangerMax.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _saving = true; _errorMessage = null; });
    final vm = context.read<AdminThresholdsViewModel>();
    final t = HealthThreshold(
      id: widget.editing?.id ?? '',
      metricType: _metricType,
      fromAge:
          _fromAge.text.isNotEmpty ? int.tryParse(_fromAge.text) : null,
      toAge: _toAge.text.isNotEmpty ? int.tryParse(_toAge.text) : null,
      normalMin: double.parse(_normalMin.text),
      normalMax: double.parse(_normalMax.text),
      dangerMin: double.parse(_dangerMin.text),
      dangerMax: double.parse(_dangerMax.text),
      unit: _unit.trim().isNotEmpty ? _unit.trim() : null,
    );
    // --- Validate age range ---
    // 1. Overlap: range mới trùng với rule cùng loại đã tồn tại
    final overlapError = vm.ageOverlapError(
      t,
      excludeId: _isEdit ? widget.editing!.id : null,
    );
    if (overlapError != null) {
      setState(() { _saving = false; _errorMessage = overlapError; });
      return;
    }
    // 2. Gap: thu hẹp range khi edit tạo khoảng trống không có rule nào phủ
    if (_isEdit) {
      final gapError = vm.ageGapWarning(t, widget.editing!.id);
      if (gapError != null) {
        setState(() { _saving = false; _errorMessage = gapError; });
        return;
      }
    }

    final ok = _isEdit ? await vm.update(t) : await vm.add(t);
    if (mounted) {
      setState(() => _saving = false);
      if (ok) {
        Navigator.pop(context);
      } else {
        setState(() => _errorMessage = vm.error ?? 'Lưu thất bại');
      }
    }
  }

  Future<void> _deleteRule() async {
    setState(() => _deleting = true);
    final ok = await context
        .read<AdminThresholdsViewModel>()
        .delete(widget.editing!.id);
    if (mounted) {
      setState(() => _deleting = false);
      if (ok) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
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
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Title + delete
                Row(children: [
                  Expanded(
                    child: Text(
                      _isEdit ? 'Chỉnh Sửa Quy Tắc' : 'Quy Tắc Ngưỡng Mới',
                      style: AppTextStyles.h3,
                    ),
                  ),
                  if (_isEdit)
                    _deleting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.error),
                          )
                        : IconButton(
                            icon: Icon(Icons.delete_outline,
                                color: AppColors.error.withAlpha(200)),
                            onPressed: _deleteRule,
                            tooltip: 'Delete rule',
                          ),
                ]),
                const SizedBox(height: 20),

                // ── Metric type ──────────────────────────────────
                _Label('Loại Chỉ Số'),
                const SizedBox(height: 8),
                if (_isEdit)
                  _ReadonlyRow(
                    icon: _metricIcons[_metricType] ??
                        Icons.monitor_heart_outlined,
                    color: _metricColors[_metricType] ?? AppColors.primary,
                    label: _metricLabels[_metricType] ?? _metricType,
                  )
                else
                  _MetricGrid(
                    selected: _metricType,
                    onChanged: _onMetricChanged,
                  ),
                const SizedBox(height: 18),

                // ── Age range ────────────────────────────────────
                _Label('Độ Tuổi  (tùy chọn)'),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                      child: _NField(
                          controller: _fromAge,
                          hint: 'Từ',
                          integer: true)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('–',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textSecondary)),
                  ),
                  Expanded(
                      child: _NField(
                          controller: _toAge,
                          hint: 'Đến',
                          integer: true)),
                  const SizedBox(width: 8),
                  Text('tuổi',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary)),
                ]),
                const SizedBox(height: 18),

                // ── Normal range ─────────────────────────────────
                _Label('Ngưỡng Bình Thường'),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                      child: _NField(
                          controller: _normalMin,
                          hint: 'Tối thiểu',
                          validator: _required)),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 14),
                    child: Text('–',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textSecondary)),
                  ),
                  Expanded(
                      child: _NField(
                          controller: _normalMax,
                          hint: 'Tối đa',
                          validator: _required)),
                  const SizedBox(width: 8),
                  Text(_unit,
                      style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600)),
                ]),
                const SizedBox(height: 14),

                // ── Danger range ─────────────────────────────────
                _Label('Ngưỡng Nguy Hiểm'),
                const SizedBox(height: 4),
                Text(
                  'Ngoài ngưỡng bình thường nhưng trong ngưỡng nguy hiểm → cảnh báo. Ngoài ngưỡng nguy hiểm → nghiêm trọng.',
                  style: AppTextStyles.label
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                      child: _NField(
                          controller: _dangerMin,
                          hint: 'Tối thiểu',
                          validator: _required)),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 14),
                    child: Text('–',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textSecondary)),
                  ),
                  Expanded(
                      child: _NField(
                          controller: _dangerMax,
                          hint: 'Tối đa',
                          validator: _required)),
                  const SizedBox(width: 8),
                  Text(_unit,
                      style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600)),
                ]),
                const SizedBox(height: 14),

                // ── Unit ────────────────────────────────────────
                _Label('Đơn Vị'),
                const SizedBox(height: 8),
                if (!_isEdit && _metricType == 'blood_sugar')
                  Row(
                    children: _bloodSugarUnits.map((u) {
                      final on = _unit == u;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _UnitChip(
                          label: u,
                          selected: on,
                          onTap: () => setState(() => _unit = u),
                        ),
                      );
                    }).toList(),
                  )
                else
                  _ReadonlyRow(
                    icon: Icons.straighten_outlined,
                    color: AppColors.primary,
                    label: _unit.isNotEmpty ? _unit : '—',
                  ),
                const SizedBox(height: 24),

                // Inline error
                if (_errorMessage != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.error.withAlpha(20),
                      border: Border.all(color: AppColors.error.withAlpha(80)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.error_outline,
                            color: AppColors.error, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Save button
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
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            _isEdit ? 'Lưu Thay Đổi' : 'Thêm Quy Tắc',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
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

  String? _required(String? v) {
    if (v == null || v.isEmpty) return 'Bắt buộc';
    if (double.tryParse(v) == null) return 'Số không hợp lệ';
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
                width: on ? 1.5 : 1,
              ),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon,
                  size: 14,
                  color: on ? color : AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                _metricLabels[m] ?? m,
                style: AppTextStyles.bodySmall.copyWith(
                  color: on ? color : AppColors.textSecondary,
                  fontWeight:
                      on ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ]),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Small helpers ────────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: AppTextStyles.label.copyWith(
          color: AppColors.textSecondary, fontWeight: FontWeight.w600));
}

class _ReadonlyRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  const _ReadonlyRow(
      {required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.withAlpha(80)),
        ),
        child: Row(children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(label, style: AppTextStyles.bodyMedium),
        ]),
      );
}

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
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary
                : AppColors.primary.withAlpha(12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.primary.withAlpha(40),
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: selected ? Colors.white : AppColors.primary,
              fontWeight:
                  selected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      );
}

class _NField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool integer;
  final String? Function(String?)? validator;
  const _NField({
    required this.controller,
    required this.hint,
    this.integer = false,
    this.validator,
  });

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
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 12),
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.error),
          ),
        ),
      );
}
