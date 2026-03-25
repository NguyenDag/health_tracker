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
