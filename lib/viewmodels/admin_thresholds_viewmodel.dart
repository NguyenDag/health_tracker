import 'package:flutter/foundation.dart';

import '../data/implementations/repositories/threshold_repository.dart';
import '../data/interfaces/repositories/i_threshold_repository.dart';
import '../domain/entities/threshold.dart';

class AdminThresholdsViewModel extends ChangeNotifier {
  AdminThresholdsViewModel({IThresholdRepository? repository})
      : _repo = repository ?? ThresholdRepository();

  final IThresholdRepository _repo;

  List<HealthThreshold> _items = [];
  bool _isLoading = false;
  String? _error;

  List<HealthThreshold> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Map<String, List<HealthThreshold>> get grouped {
    final map = <String, List<HealthThreshold>>{};
    for (final t in _items) {
      (map[t.metricType] ??= []).add(t);
    }
    return map;
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await _repo.getAll();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Age-range validation helpers ───────────────────────────────────────────

  /// Kiểm tra xem đoạn [from, to] có được phủ hoàn toàn bởi [rules] không.
  /// Dùng thuật toán quét: sắp xếp các rule theo fromAge rồi kiểm tra liên tục.
  bool _isCovered(int from, int to, Iterable<HealthThreshold> rules) {
    final segments = rules
        .map((t) => (t.fromAge ?? 0, t.toAge ?? 999))
        .where((r) => r.$1 <= to && r.$2 >= from)
        .toList()
      ..sort((a, b) => a.$1.compareTo(b.$1));

    int cursor = from;
    for (final (rFrom, rTo) in segments) {
      if (rFrom > cursor) return false; // khoảng trống trước segment này
      if (rTo >= to) return true;       // phủ đủ
      cursor = rTo + 1;
    }
    return cursor > to;
  }

  String _ageRangeLabel(int from, int to) {
    if (to >= 999) return '$from tuổi trở lên';
    if (from <= 0) return 'dưới $to tuổi';
    return '$from–$to tuổi';
  }

  /// Trả về lỗi nếu [incoming] có khoảng tuổi trùng (overlap) với rule cùng
  /// loại. [excludeId] dùng khi update để bỏ qua chính rule đó.
  ///
  /// Các case bắt được:
  /// - Overlap một phần: 55–65 với 60–70
  /// - Overlap biên: 15–60 với 60–70 (age 60 ở cả hai)
  /// - Chứa hoàn toàn: 50–80 với 60–70
  String? ageOverlapError(HealthThreshold incoming, {String? excludeId}) {
    final others = _items.where(
      (t) => t.metricType == incoming.metricType && t.id != (excludeId ?? ''),
    );
    final inFrom = incoming.fromAge ?? 0;
    final inTo = incoming.toAge ?? 999;
    for (final t in others) {
      final tFrom = t.fromAge ?? 0;
      final tTo = t.toAge ?? 999;
      if (inFrom <= tTo && tFrom <= inTo) {
        final label = _ageRangeLabel(tFrom, tTo);
        return 'Khoảng tuổi trùng với rule đã tồn tại ($label)';
      }
    }
    return null;
  }

  /// Trả về lỗi nếu việc **chỉnh sửa** rule [excludeId] sang [incoming] tạo
  /// ra khoảng trống tuổi không có rule nào phủ.
  ///
  /// Ví dụ: đang có 15–60 và 60–70. Sửa 15–60 thành 15–55
  /// → khoảng 56–59 không có rule nào → trả về lỗi.
  String? ageGapWarning(HealthThreshold incoming, String excludeId) {
    final originalIdx = _items.indexWhere((t) => t.id == excludeId);
    if (originalIdx == -1) return null;
    final original = _items[originalIdx];

    final others = _items
        .where((t) => t.metricType == incoming.metricType && t.id != excludeId)
        .toList();

    // Không có rule nào khác cùng loại → không có coverage liên tục cần bảo vệ
    if (others.isEmpty) return null;

    final oldFrom = original.fromAge ?? 0;
    final oldTo = original.toAge ?? 999;
    final newFrom = incoming.fromAge ?? 0;
    final newTo = incoming.toAge ?? 999;

    final gaps = <String>[];

    // Phần trái bị thu hẹp: [oldFrom, newFrom-1]
    if (newFrom > oldFrom) {
      final segFrom = oldFrom;
      final segTo = newFrom - 1;
      if (!_isCovered(segFrom, segTo, others)) {
        gaps.add(_ageRangeLabel(segFrom, segTo));
      }
    }

    // Phần phải bị thu hẹp: [newTo+1, oldTo]
    if (newTo < oldTo) {
      final segFrom = newTo + 1;
      final segTo = oldTo;
      if (!_isCovered(segFrom, segTo, others)) {
        gaps.add(_ageRangeLabel(segFrom, segTo));
      }
    }

    if (gaps.isEmpty) return null;
    return 'Chỉnh sửa tạo khoảng trống chưa có rule: ${gaps.join(', ')}';
  }

  Future<bool> add(HealthThreshold threshold) async {
    try {
      await _repo.add(threshold);
      await load();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> update(HealthThreshold threshold) async {
    try {
      await _repo.update(threshold);
      final idx = _items.indexWhere((t) => t.id == threshold.id);
      if (idx != -1) {
        _items[idx] = threshold;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> delete(String id) async {
    try {
      await _repo.delete(id);
      _items.removeWhere((t) => t.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
